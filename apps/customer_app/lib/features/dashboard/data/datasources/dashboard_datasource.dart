import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../models/category_model.dart';
import '../models/shop_filter_model.dart';
import '../models/shop_model.dart';

/// Page size for shop pagination
const int _kDefaultPageSize = 20;

/// Data source interface for dashboard operations
abstract class DashboardDataSource {
  /// Fetch all active categories sorted by display order
  Future<Result<List<CategoryModel>>> getCategories();

  /// Fetch shops with optional filters, category, sorting, and pagination.
  ///
  /// [categoryId] - filter by category (null for all)
  /// [filter] - additional filters (rating, delivery fee, open now)
  /// [searchQuery] - client-side search string (null to skip)
  /// [lastDocument] - cursor for pagination (null for first page)
  /// [pageSize] - number of items per page
  Future<Result<ShopsResult>> getShops({
    String? categoryId,
    ShopFilterModel? filter,
    String? searchQuery,
    DocumentSnapshot<Object?>? lastDocument,
    int pageSize = _kDefaultPageSize,
  });
}

/// Result wrapper for paginated shop queries
class ShopsResult {
  final List<ShopModel> shops;
  final DocumentSnapshot<Object?>? lastDocument;
  final bool hasMore;

  const ShopsResult({
    required this.shops,
    this.lastDocument,
    required this.hasMore,
  });
}

/// Implementation of DashboardDataSource using Firebase Firestore
class DashboardDataSourceImpl implements DashboardDataSource {
  final FirebaseFirestore _firestore;

  DashboardDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<CategoryModel>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('order', descending: false)
          .get();

      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      return Result.success(categories);
    } on FirebaseException catch (e) {
      return Result.failure(
        DashboardFailure.fetchCategoriesFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        DashboardFailure.fetchCategoriesFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<ShopsResult>> getShops({
    String? categoryId,
    ShopFilterModel? filter,
    String? searchQuery,
    DocumentSnapshot<Object?>? lastDocument,
    int pageSize = _kDefaultPageSize,
  }) async {
    try {
      final effectiveFilter = filter ?? const ShopFilterModel();

      // FIRESTORE QUERY STRATEGY:
      //
      // Firestore constraints:
      //   1. Only ONE range filter (>=, <=, >, <) per query
      //   2. First orderBy must match the inequality filter field
      //   3. No two range filters can be combined
      //
      // To keep indexes minimal and queries robust, we use a hybrid approach:
      //   - Server-side: Equality filters only (isActive, categoryId, isOpen)
      //     + always orderBy createdAt for consistent pagination
      //   - Client-side: Range filters (rating, deliveryFee), sorting, search
      //
      // This requires only 4 composite indexes (far fewer than alternatives):
      //   1. isActive ↑, createdAt ↓
      //   2. isActive ↑, categoryId ↑, createdAt ↓
      //   3. isActive ↑, isOpen ↑, createdAt ↓
      //   4. isActive ↑, categoryId ↑, isOpen ↑, createdAt ↓

      Query query = _firestore.collection('shops');

      // Always filter active shops
      query = query.where('isActive', isEqualTo: true);

      // Apply category filter (equality — always safe)
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Apply open now filter (equality — always safe)
      if (effectiveFilter.openNow) {
        query = query.where('isOpen', isEqualTo: true);
      }

      // Always order by createdAt for consistent cursor-based pagination
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination cursor
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Limit page size (+1 to determine if more pages exist)
      query = query.limit(pageSize + 1);

      final snapshot = await query.get();

      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore ? snapshot.docs.take(pageSize).toList() : snapshot.docs;

      var shops = docs
          .map((doc) => ShopModel.fromFirestore(doc))
          .toList();

      // Apply client-side range filters
      if (effectiveFilter.minRating != null) {
        shops = shops.where(
          (s) => s.rating >= effectiveFilter.minRating!,
        ).toList();
      }
      if (effectiveFilter.maxDeliveryFee != null) {
        shops = shops.where(
          (s) => s.deliveryFee <= effectiveFilter.maxDeliveryFee!,
        ).toList();
      }

      // Apply client-side sorting
      switch (effectiveFilter.sortBy) {
        case SortOption.rating:
          shops.sort((a, b) => b.rating.compareTo(a.rating));
        case SortOption.deliveryFee:
          shops.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
        case SortOption.distance:
          // Future: sort by distance using geolocation
          break;
        case SortOption.newest:
          // Already sorted by createdAt desc from Firestore
          break;
      }

      // Apply client-side search filtering
      shops = _applySearchFilter(shops, searchQuery);

      return Result.success(
        ShopsResult(
          shops: shops,
          lastDocument: docs.isNotEmpty ? docs.last : null,
          hasMore: hasMore,
        ),
      );
    } on FirebaseException catch (e) {
      // Catch missing index errors with helpful message
      if (e.code == 'failed-precondition' &&
          (e.message?.contains('index') == true ||
              e.message?.contains('requires an index') == true)) {
        return Result.failure(
          DashboardFailure.fetchFailed(
            'Database index required. Please check Firebase console.',
          ),
        );
      }
      return Result.failure(
        DashboardFailure.fetchFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        DashboardFailure.fetchFailed(e.toString()),
      );
    }
  }

  /// Client-side search filter by name and tags.
  /// Returns shops matching the query in name or any tag.
  List<ShopModel> _applySearchFilter(List<ShopModel> shops, String? query) {
    if (query == null || query.trim().isEmpty) return shops;

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return shops;

    return shops.where((shop) {
      // Search by name
      if (shop.name.toLowerCase().contains(normalizedQuery)) {
        return true;
      }

      // Search by tags
      if (shop.tags.any(
        (tag) => tag.toLowerCase().contains(normalizedQuery),
      )) {
        return true;
      }

      // Search by short description
      if (shop.shortDescription?.toLowerCase().contains(normalizedQuery) ==
          true) {
        return true;
      }

      return false;
    }).toList();
  }
}
