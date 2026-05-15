import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_filter_model.freezed.dart';
part 'shop_filter_model.g.dart';

/// Sort options for shop listing
enum SortOption {
  /// Sort by rating (highest first)
  rating,

  /// Sort by delivery fee (lowest first)
  deliveryFee,

  /// Sort by distance (nearest first)
  distance,

  /// Sort by newest first
  newest,
}

/// Filter model for shop queries
@freezed
abstract class ShopFilterModel with _$ShopFilterModel {
  const factory ShopFilterModel({
    /// Minimum rating filter (e.g. 4.0 means 4+ stars)
    double? minRating,

    /// Maximum delivery fee filter
    double? maxDeliveryFee,

    /// Only show shops that are currently open
    @Default(true) bool openNow,

    /// Maximum distance in kilometers
    double? maxDistanceKm,

    /// Sort order for results
    @Default(SortOption.rating) SortOption sortBy,
  }) = _ShopFilterModel;

  const ShopFilterModel._();

  /// Check if any filter is active (beyond defaults)
  bool get hasActiveFilters =>
      minRating != null ||
      maxDeliveryFee != null ||
      maxDistanceKm != null;

  /// Reset all filters to defaults
  ShopFilterModel get reset => const ShopFilterModel();

  /// Toggle open now filter
  ShopFilterModel toggleOpenNow() => copyWith(openNow: !openNow);

  factory ShopFilterModel.fromJson(Map<String, dynamic> json) =>
      _$ShopFilterModelFromJson(json);
}
