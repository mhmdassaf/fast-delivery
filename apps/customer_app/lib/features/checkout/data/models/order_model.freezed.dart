// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderModel {

 String get id; String get customerId; String get customerName; String get customerPhone; String get shopId; String get shopName; List<CartItemModel> get items; DeliveryAddressModel get deliveryAddress; String get deliveryTimeLabel; double get subtotal; double get deliveryFee; double get total; OrderStatus get status; List<StatusHistoryEntry> get statusHistory; DateTime? get createdAt;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.deliveryTimeLabel, deliveryTimeLabel) || other.deliveryTimeLabel == deliveryTimeLabel)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerName,customerPhone,shopId,shopName,const DeepCollectionEquality().hash(items),deliveryAddress,deliveryTimeLabel,subtotal,deliveryFee,total,status,const DeepCollectionEquality().hash(statusHistory),createdAt);

@override
String toString() {
  return 'OrderModel(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, shopId: $shopId, shopName: $shopName, items: $items, deliveryAddress: $deliveryAddress, deliveryTimeLabel: $deliveryTimeLabel, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, status: $status, statusHistory: $statusHistory, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, String customerName, String customerPhone, String shopId, String shopName, List<CartItemModel> items, DeliveryAddressModel deliveryAddress, String deliveryTimeLabel, double subtotal, double deliveryFee, double total, OrderStatus status, List<StatusHistoryEntry> statusHistory, DateTime? createdAt
});


$DeliveryAddressModelCopyWith<$Res> get deliveryAddress;

}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? shopId = null,Object? shopName = null,Object? items = null,Object? deliveryAddress = null,Object? deliveryTimeLabel = null,Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? status = null,Object? statusHistory = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddressModel,deliveryTimeLabel: null == deliveryTimeLabel ? _self.deliveryTimeLabel : deliveryTimeLabel // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressModelCopyWith<$Res> get deliveryAddress {
  
  return $DeliveryAddressModelCopyWith<$Res>(_self.deliveryAddress, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  String customerName,  String customerPhone,  String shopId,  String shopName,  List<CartItemModel> items,  DeliveryAddressModel deliveryAddress,  String deliveryTimeLabel,  double subtotal,  double deliveryFee,  double total,  OrderStatus status,  List<StatusHistoryEntry> statusHistory,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.shopId,_that.shopName,_that.items,_that.deliveryAddress,_that.deliveryTimeLabel,_that.subtotal,_that.deliveryFee,_that.total,_that.status,_that.statusHistory,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  String customerName,  String customerPhone,  String shopId,  String shopName,  List<CartItemModel> items,  DeliveryAddressModel deliveryAddress,  String deliveryTimeLabel,  double subtotal,  double deliveryFee,  double total,  OrderStatus status,  List<StatusHistoryEntry> statusHistory,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.shopId,_that.shopName,_that.items,_that.deliveryAddress,_that.deliveryTimeLabel,_that.subtotal,_that.deliveryFee,_that.total,_that.status,_that.statusHistory,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  String customerName,  String customerPhone,  String shopId,  String shopName,  List<CartItemModel> items,  DeliveryAddressModel deliveryAddress,  String deliveryTimeLabel,  double subtotal,  double deliveryFee,  double total,  OrderStatus status,  List<StatusHistoryEntry> statusHistory,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.shopId,_that.shopName,_that.items,_that.deliveryAddress,_that.deliveryTimeLabel,_that.subtotal,_that.deliveryFee,_that.total,_that.status,_that.statusHistory,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderModel extends OrderModel {
  const _OrderModel({required this.id, required this.customerId, required this.customerName, required this.customerPhone, required this.shopId, required this.shopName, required final  List<CartItemModel> items, required this.deliveryAddress, required this.deliveryTimeLabel, required this.subtotal, required this.deliveryFee, required this.total, this.status = OrderStatus.waitingRiderConfirmation, final  List<StatusHistoryEntry> statusHistory = const [], this.createdAt}): _items = items,_statusHistory = statusHistory,super._();
  factory _OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  String customerName;
@override final  String customerPhone;
@override final  String shopId;
@override final  String shopName;
 final  List<CartItemModel> _items;
@override List<CartItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  DeliveryAddressModel deliveryAddress;
@override final  String deliveryTimeLabel;
@override final  double subtotal;
@override final  double deliveryFee;
@override final  double total;
@override@JsonKey() final  OrderStatus status;
 final  List<StatusHistoryEntry> _statusHistory;
@override@JsonKey() List<StatusHistoryEntry> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  DateTime? createdAt;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.deliveryTimeLabel, deliveryTimeLabel) || other.deliveryTimeLabel == deliveryTimeLabel)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerName,customerPhone,shopId,shopName,const DeepCollectionEquality().hash(_items),deliveryAddress,deliveryTimeLabel,subtotal,deliveryFee,total,status,const DeepCollectionEquality().hash(_statusHistory),createdAt);

@override
String toString() {
  return 'OrderModel(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, shopId: $shopId, shopName: $shopName, items: $items, deliveryAddress: $deliveryAddress, deliveryTimeLabel: $deliveryTimeLabel, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, status: $status, statusHistory: $statusHistory, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, String customerName, String customerPhone, String shopId, String shopName, List<CartItemModel> items, DeliveryAddressModel deliveryAddress, String deliveryTimeLabel, double subtotal, double deliveryFee, double total, OrderStatus status, List<StatusHistoryEntry> statusHistory, DateTime? createdAt
});


@override $DeliveryAddressModelCopyWith<$Res> get deliveryAddress;

}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? shopId = null,Object? shopName = null,Object? items = null,Object? deliveryAddress = null,Object? deliveryTimeLabel = null,Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? status = null,Object? statusHistory = null,Object? createdAt = freezed,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddressModel,deliveryTimeLabel: null == deliveryTimeLabel ? _self.deliveryTimeLabel : deliveryTimeLabel // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressModelCopyWith<$Res> get deliveryAddress {
  
  return $DeliveryAddressModelCopyWith<$Res>(_self.deliveryAddress, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}

// dart format on
