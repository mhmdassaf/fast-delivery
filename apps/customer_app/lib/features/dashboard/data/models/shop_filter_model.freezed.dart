// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_filter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopFilterModel {

/// Minimum rating filter (e.g. 4.0 means 4+ stars)
 double? get minRating;/// Maximum delivery fee filter
 double? get maxDeliveryFee;/// Only show shops that are currently open
 bool get openNow;/// Maximum distance in kilometers
 double? get maxDistanceKm;/// Sort order for results
 SortOption get sortBy;
/// Create a copy of ShopFilterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopFilterModelCopyWith<ShopFilterModel> get copyWith => _$ShopFilterModelCopyWithImpl<ShopFilterModel>(this as ShopFilterModel, _$identity);

  /// Serializes this ShopFilterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopFilterModel&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.maxDeliveryFee, maxDeliveryFee) || other.maxDeliveryFee == maxDeliveryFee)&&(identical(other.openNow, openNow) || other.openNow == openNow)&&(identical(other.maxDistanceKm, maxDistanceKm) || other.maxDistanceKm == maxDistanceKm)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minRating,maxDeliveryFee,openNow,maxDistanceKm,sortBy);

@override
String toString() {
  return 'ShopFilterModel(minRating: $minRating, maxDeliveryFee: $maxDeliveryFee, openNow: $openNow, maxDistanceKm: $maxDistanceKm, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class $ShopFilterModelCopyWith<$Res>  {
  factory $ShopFilterModelCopyWith(ShopFilterModel value, $Res Function(ShopFilterModel) _then) = _$ShopFilterModelCopyWithImpl;
@useResult
$Res call({
 double? minRating, double? maxDeliveryFee, bool openNow, double? maxDistanceKm, SortOption sortBy
});




}
/// @nodoc
class _$ShopFilterModelCopyWithImpl<$Res>
    implements $ShopFilterModelCopyWith<$Res> {
  _$ShopFilterModelCopyWithImpl(this._self, this._then);

  final ShopFilterModel _self;
  final $Res Function(ShopFilterModel) _then;

/// Create a copy of ShopFilterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minRating = freezed,Object? maxDeliveryFee = freezed,Object? openNow = null,Object? maxDistanceKm = freezed,Object? sortBy = null,}) {
  return _then(_self.copyWith(
minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,maxDeliveryFee: freezed == maxDeliveryFee ? _self.maxDeliveryFee : maxDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,openNow: null == openNow ? _self.openNow : openNow // ignore: cast_nullable_to_non_nullable
as bool,maxDistanceKm: freezed == maxDistanceKm ? _self.maxDistanceKm : maxDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortOption,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopFilterModel].
extension ShopFilterModelPatterns on ShopFilterModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopFilterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopFilterModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopFilterModel value)  $default,){
final _that = this;
switch (_that) {
case _ShopFilterModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopFilterModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShopFilterModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? minRating,  double? maxDeliveryFee,  bool openNow,  double? maxDistanceKm,  SortOption sortBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopFilterModel() when $default != null:
return $default(_that.minRating,_that.maxDeliveryFee,_that.openNow,_that.maxDistanceKm,_that.sortBy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? minRating,  double? maxDeliveryFee,  bool openNow,  double? maxDistanceKm,  SortOption sortBy)  $default,) {final _that = this;
switch (_that) {
case _ShopFilterModel():
return $default(_that.minRating,_that.maxDeliveryFee,_that.openNow,_that.maxDistanceKm,_that.sortBy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? minRating,  double? maxDeliveryFee,  bool openNow,  double? maxDistanceKm,  SortOption sortBy)?  $default,) {final _that = this;
switch (_that) {
case _ShopFilterModel() when $default != null:
return $default(_that.minRating,_that.maxDeliveryFee,_that.openNow,_that.maxDistanceKm,_that.sortBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopFilterModel extends ShopFilterModel {
  const _ShopFilterModel({this.minRating, this.maxDeliveryFee, this.openNow = true, this.maxDistanceKm, this.sortBy = SortOption.rating}): super._();
  factory _ShopFilterModel.fromJson(Map<String, dynamic> json) => _$ShopFilterModelFromJson(json);

/// Minimum rating filter (e.g. 4.0 means 4+ stars)
@override final  double? minRating;
/// Maximum delivery fee filter
@override final  double? maxDeliveryFee;
/// Only show shops that are currently open
@override@JsonKey() final  bool openNow;
/// Maximum distance in kilometers
@override final  double? maxDistanceKm;
/// Sort order for results
@override@JsonKey() final  SortOption sortBy;

/// Create a copy of ShopFilterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopFilterModelCopyWith<_ShopFilterModel> get copyWith => __$ShopFilterModelCopyWithImpl<_ShopFilterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopFilterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopFilterModel&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.maxDeliveryFee, maxDeliveryFee) || other.maxDeliveryFee == maxDeliveryFee)&&(identical(other.openNow, openNow) || other.openNow == openNow)&&(identical(other.maxDistanceKm, maxDistanceKm) || other.maxDistanceKm == maxDistanceKm)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minRating,maxDeliveryFee,openNow,maxDistanceKm,sortBy);

@override
String toString() {
  return 'ShopFilterModel(minRating: $minRating, maxDeliveryFee: $maxDeliveryFee, openNow: $openNow, maxDistanceKm: $maxDistanceKm, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class _$ShopFilterModelCopyWith<$Res> implements $ShopFilterModelCopyWith<$Res> {
  factory _$ShopFilterModelCopyWith(_ShopFilterModel value, $Res Function(_ShopFilterModel) _then) = __$ShopFilterModelCopyWithImpl;
@override @useResult
$Res call({
 double? minRating, double? maxDeliveryFee, bool openNow, double? maxDistanceKm, SortOption sortBy
});




}
/// @nodoc
class __$ShopFilterModelCopyWithImpl<$Res>
    implements _$ShopFilterModelCopyWith<$Res> {
  __$ShopFilterModelCopyWithImpl(this._self, this._then);

  final _ShopFilterModel _self;
  final $Res Function(_ShopFilterModel) _then;

/// Create a copy of ShopFilterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minRating = freezed,Object? maxDeliveryFee = freezed,Object? openNow = null,Object? maxDistanceKm = freezed,Object? sortBy = null,}) {
  return _then(_ShopFilterModel(
minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,maxDeliveryFee: freezed == maxDeliveryFee ? _self.maxDeliveryFee : maxDeliveryFee // ignore: cast_nullable_to_non_nullable
as double?,openNow: null == openNow ? _self.openNow : openNow // ignore: cast_nullable_to_non_nullable
as bool,maxDistanceKm: freezed == maxDistanceKm ? _self.maxDistanceKm : maxDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortOption,
  ));
}


}

// dart format on
