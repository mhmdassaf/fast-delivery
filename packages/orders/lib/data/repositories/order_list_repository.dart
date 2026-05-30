import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fast_delivery_core/errors/result.dart';

import '../../domain/order_status.dart';
import '../datasources/order_list_datasource.dart';

/// Repository wrapping [OrderListDataSource] for the orders list feature.
abstract class OrderListRepository {
  /// Fetch orders with optional status list filtering and pagination.
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    List<OrderStatus>? statuses,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  });

  /// Returns the number of active orders for the given role.
  Future<Result<int>> getActiveOrderCount({
    required String role,
    required String uid,
    required List<OrderStatus> statuses,
  });
}

/// Implementation of [OrderListRepository].
class OrderListRepositoryImpl implements OrderListRepository {
  final OrderListDataSource _dataSource;

  OrderListRepositoryImpl({required OrderListDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<OrdersQueryResult>> getOrders({
    required String role,
    required String uid,
    List<OrderStatus>? statuses,
    DocumentSnapshot<Object?>? cursor,
    int limit = 15,
  }) {
    return _dataSource.getOrders(
      role: role,
      uid: uid,
      statuses: statuses,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<Result<int>> getActiveOrderCount({
    required String role,
    required String uid,
    required List<OrderStatus> statuses,
  }) {
    return _dataSource.getActiveOrderCount(
      role: role,
      uid: uid,
      statuses: statuses,
    );
  }
}
