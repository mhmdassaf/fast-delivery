import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../../../dashboard/data/models/shop_model.dart';
import '../datasources/shop_details_datasource.dart';
import '../models/menu_item_model.dart';

/// Repository interface for shop details operations.
abstract class ShopDetailsRepository {
  /// Fetch a single shop by its [shopId].
  Future<Result<ShopModel>> getShopById(String shopId);

  /// Fetch all active menu items for a given shop.
  Future<Result<List<MenuItemModel>>> getMenuItems(String shopId);
}

/// Implementation of [ShopDetailsRepository].
class ShopDetailsRepositoryImpl implements ShopDetailsRepository {
  final ShopDetailsDataSource _dataSource;

  ShopDetailsRepositoryImpl({required ShopDetailsDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<ShopModel>> getShopById(String shopId) async {
    try {
      return await _dataSource.getShopById(shopId);
    } catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchShopFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<List<MenuItemModel>>> getMenuItems(String shopId) async {
    try {
      return await _dataSource.getMenuItems(shopId);
    } catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchMenuFailed(e.toString()),
      );
    }
  }
}
