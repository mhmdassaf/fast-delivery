import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../../../dashboard/data/models/shop_model.dart';
import '../models/menu_item_model.dart';

/// Data source interface for shop details and menu operations.
abstract class ShopDetailsDataSource {
  /// Fetch a single shop by its [shopId].
  Future<Result<ShopModel>> getShopById(String shopId);

  /// Fetch all active menu items for a given shop,
  /// sorted by their [MenuItemModel.order] ascending.
  Future<Result<List<MenuItemModel>>> getMenuItems(String shopId);
}

/// Implementation of [ShopDetailsDataSource] using Firebase Firestore.
class ShopDetailsDataSourceImpl implements ShopDetailsDataSource {
  final FirebaseFirestore _firestore;

  ShopDetailsDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<ShopModel>> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();

      if (!doc.exists) {
        return Result.failure(
          ShopDetailsFailure.fetchShopFailed('Shop not found'),
        );
      }

      final shop = ShopModel.fromFirestore(doc);
      return Result.success(shop);
    } on FirebaseException catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchShopFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchShopFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<List<MenuItemModel>>> getMenuItems(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('menu_items')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      // `isAvailable` is filtered client-side because adding it to the
      // composite index with `isActive` + `order` would require a new index.
      // This is acceptable since menu items are typically < 100 per shop.
      final items = snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .where((item) => item.isAvailable)
          .toList();

      return Result.success(items);
    } on FirebaseException catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchMenuFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        ShopDetailsFailure.fetchMenuFailed(e.toString()),
      );
    }
  }
}
