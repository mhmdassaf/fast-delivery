import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../models/order_list_item_model.dart';

/// Result wrapper for paginated order queries.
class OrdersQueryResult {
  final List<OrderListItemModel> orders;
  final DocumentSnapshot<Object?>? lastDocument;
  final bool hasMore;

  const OrdersQueryResult({
    required this.orders,
    this.lastDocument,
    required this.hasMore,
  });
}

/// Data source for fetching orders from Firestore.
///
/// Queries are role-aware:
/// - user   → filter by `userId`
/// - rider  → filter by `riderId`
/// - seller → filter by `sellerId`
/// - admin  → no filter (all orders)
abstract class OrderListDataSource {
  /// Fetch orders with optional status group filtering and cursor pagination.
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    String? statusFilter,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  });
}

/// Implementation of [OrderListDataSource] using Firebase Firestore.
class OrderListDataSourceImpl implements OrderListDataSource {
  final FirebaseFirestore _firestore;

  OrderListDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Maps a status filter group to the actual Firestore status strings.
  ///
  /// Returns `null` for "All" (no status filter).
  List<String>? _statusesForFilter(String? filter) {
    switch (filter) {
      case 'Active':
        return [
          'Waiting Rider Confirmation',
          'Confirmed',
          'Preparing',
          'Out for Delivery',
        ];
      case 'Completed':
        return ['Delivered'];
      case 'Cancelled':
        return ['Cancelled'];
      default:
        return null; // "All" — no status filter
    }
  }

  @override
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    String? statusFilter,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  }) async {
    try {
      Query query = _firestore.collection('orders');

      // Apply role-based filter
      switch (role) {
        case 'user':
          query = query.where('userId', isEqualTo: uid);
          break;
        case 'rider':
          query = query.where('riderId', isEqualTo: uid);
          break;
        case 'seller':
          query = query.where('sellerId', isEqualTo: uid);
          break;
        case 'admin':
          // No filter — admins see all orders
          break;
        default:
          // Fall back to user-level filtering for unknown roles
          // instead of failing (graceful degradation)
          query = query.where('userId', isEqualTo: uid);
      }

      // Apply status filter group
      final statuses = _statusesForFilter(statusFilter);
      if (statuses != null && statuses.length == 1) {
        // Single status — use simple equality
        query = query.where('status', isEqualTo: statuses.first);
      } else if (statuses != null && statuses.length > 1) {
        // Multiple statuses — use 'in' filter
        query = query.where('status', whereIn: statuses);
      }

      // Always sort by createdAt descending
      query = query.orderBy('createdAt', descending: true);

      // Apply cursor pagination
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      final orders = snapshot.docs
          .map((doc) => OrderListItemModel.fromFirestore(doc))
          .toList();

      final lastDoc = orders.length == limit
          ? snapshot.docs.last as DocumentSnapshot<Object?>
          : null;

      return Result.success(OrdersQueryResult(
        orders: orders,
        lastDocument: lastDoc,
        hasMore: orders.length == limit,
      ));
    } on FirebaseException catch (e) {
      return Result.failure(
        OrdersFailure.fetchFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        OrdersFailure.fetchFailed(e.toString()),
      );
    }
  }
}
