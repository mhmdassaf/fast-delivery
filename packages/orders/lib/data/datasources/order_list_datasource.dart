import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../../domain/order_status.dart';
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
/// - customer → filter by `userId`
/// - rider    → filter by `riderId`
/// - seller   → filter by `sellerId`
/// - admin    → no filter (all orders)
abstract class OrderListDataSource {
  /// Fetch orders with optional status list filtering and cursor pagination.
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    List<OrderStatus>? statuses,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  });

  /// Returns the number of orders with statuses in [statuses] for the given role.
  ///
  /// Uses Firestore's `count()` aggregation — no documents are fetched.
  Future<Result<int>> getActiveOrderCount({
    required String role,
    required String uid,
    required List<OrderStatus> statuses,
  });
}

/// Implementation of [OrderListDataSource] using Firebase Firestore.
class OrderListDataSourceImpl implements OrderListDataSource {
  final FirebaseFirestore _firestore;

  OrderListDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Applies the role-based Firestore filter to [query].
  ///
  /// - `customer` → `userId == uid`
  /// - `rider`    → `riderId == uid`
  /// - `seller`   → `sellerId == uid`
  /// - `admin`    → no filter (all orders)
  /// - unknown    → falls back to `userId == uid`
  Query _applyRoleFilter(Query query, String role, String uid) {
    switch (role) {
      case 'customer':
        return query.where('userId', isEqualTo: uid);
      case 'rider':
        return query.where('riderId', isEqualTo: uid);
      case 'seller':
        return query.where('sellerId', isEqualTo: uid);
      case 'admin':
        return query;
      default:
        return query.where('userId', isEqualTo: uid);
    }
  }

  @override
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    List<OrderStatus>? statuses,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  }) async {
    try {
      Query query = _firestore.collection('orders');
      query = _applyRoleFilter(query, role, uid);

      // Apply status filter group
      if (statuses != null && statuses.length == 1) {
        query = query.where('status', isEqualTo: statuses.first.toFirestore());
      } else if (statuses != null && statuses.length > 1) {
        query = query.where(
          'status',
          whereIn: statuses.map((e) => e.toFirestore()).toList(),
        );
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

  @override
  Future<Result<int>> getActiveOrderCount({
    required String role,
    required String uid,
    required List<OrderStatus> statuses,
  }) async {
    try {
      Query query = _firestore.collection('orders');
      query = _applyRoleFilter(query, role, uid);

      // Apply status filter (active statuses)
      query = query.where(
        'status',
        whereIn: statuses.map((e) => e.toFirestore()).toList(),
      );

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;
      return Result.success(count);
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
