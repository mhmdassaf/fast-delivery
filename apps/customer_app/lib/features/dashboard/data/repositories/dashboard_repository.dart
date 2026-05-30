import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../datasources/dashboard_datasource.dart';
import '../models/category_model.dart';
import '../models/shop_filter_model.dart';

/// Repository interface for dashboard operations
abstract class DashboardRepository {
  /// Fetch all active categories
  Future<Result<List<CategoryModel>>> getCategories();

  /// Fetch shops with filters, pagination, and search
  Future<Result<ShopsResult>> getShops({
    String? categoryId,
    ShopFilterModel? filter,
    String? searchQuery,
    DocumentSnapshot<Object?>? lastDocument,
    int pageSize = 20,
  });
}

/// Implementation of DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  DashboardRepositoryImpl({required DashboardDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<CategoryModel>>> getCategories() async {
    try {
      return await _dataSource.getCategories();
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
    int pageSize = 20,
  }) async {
    try {
      return await _dataSource.getShops(
        categoryId: categoryId,
        filter: filter,
        searchQuery: searchQuery,
        lastDocument: lastDocument,
        pageSize: pageSize,
      );
    } catch (e) {
      return Result.failure(
        DashboardFailure.fetchFailed(e.toString()),
      );
    }
  }
}
