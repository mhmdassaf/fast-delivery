// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_list_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderListItemModel {
  String get id;
  String get userId;
  String get userName;
  String get shopId;
  String get shopName;
  String get deliveryAddressLine;
  double get total;
  int get itemCount;
  OrderStatus get status;
  DateTime get createdAt;

  /// Create a copy of OrderListItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderListItemModelCopyWith<OrderListItemModel> get copyWith =>
      _$OrderListItemModelCopyWithImpl<OrderListItemModel>(
          this as OrderListItemModel, _$identity);

  /// Serializes this OrderListItemModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderListItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.deliveryAddressLine, deliveryAddressLine) ||
                other.deliveryAddressLine == deliveryAddressLine) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, userName, shopId,
      shopName, deliveryAddressLine, total, itemCount, status, createdAt);

  @override
  String toString() {
    return 'OrderListItemModel(id: $id, userId: $userId, userName: $userName, shopId: $shopId, shopName: $shopName, deliveryAddressLine: $deliveryAddressLine, total: $total, itemCount: $itemCount, status: $status, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $OrderListItemModelCopyWith<$Res> {
  factory $OrderListItemModelCopyWith(
          OrderListItemModel value, $Res Function(OrderListItemModel) _then) =
      _$OrderListItemModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String shopId,
      String shopName,
      String deliveryAddressLine,
      double total,
      int itemCount,
      OrderStatus status,
      DateTime createdAt});
}

/// @nodoc
class _$OrderListItemModelCopyWithImpl<$Res>
    implements $OrderListItemModelCopyWith<$Res> {
  _$OrderListItemModelCopyWithImpl(this._self, this._then);

  final OrderListItemModel _self;
  final $Res Function(OrderListItemModel) _then;

  /// Create a copy of OrderListItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? shopId = null,
    Object? shopName = null,
    Object? deliveryAddressLine = null,
    Object? total = null,
    Object? itemCount = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      shopId: null == shopId
          ? _self.shopId
          : shopId // ignore: cast_nullable_to_non_nullable
              as String,
      shopName: null == shopName
          ? _self.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddressLine: null == deliveryAddressLine
          ? _self.deliveryAddressLine
          : deliveryAddressLine // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      itemCount: null == itemCount
          ? _self.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [OrderListItemModel].
extension OrderListItemModelPatterns on OrderListItemModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OrderListItemModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OrderListItemModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OrderListItemModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String userName,
            String shopId,
            String shopName,
            String deliveryAddressLine,
            double total,
            int itemCount,
            OrderStatus status,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.shopId,
            _that.shopName,
            _that.deliveryAddressLine,
            _that.total,
            _that.itemCount,
            _that.status,
            _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String userName,
            String shopId,
            String shopName,
            String deliveryAddressLine,
            double total,
            int itemCount,
            OrderStatus status,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel():
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.shopId,
            _that.shopName,
            _that.deliveryAddressLine,
            _that.total,
            _that.itemCount,
            _that.status,
            _that.createdAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String userId,
            String userName,
            String shopId,
            String shopName,
            String deliveryAddressLine,
            double total,
            int itemCount,
            OrderStatus status,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderListItemModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.shopId,
            _that.shopName,
            _that.deliveryAddressLine,
            _that.total,
            _that.itemCount,
            _that.status,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OrderListItemModel extends OrderListItemModel {
  const _OrderListItemModel(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.shopId,
      required this.shopName,
      required this.deliveryAddressLine,
      required this.total,
      required this.itemCount,
      required this.status,
      required this.createdAt})
      : super._();
  factory _OrderListItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderListItemModelFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String shopId;
  @override
  final String shopName;
  @override
  final String deliveryAddressLine;
  @override
  final double total;
  @override
  final int itemCount;
  @override
  final OrderStatus status;
  @override
  final DateTime createdAt;

  /// Create a copy of OrderListItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderListItemModelCopyWith<_OrderListItemModel> get copyWith =>
      __$OrderListItemModelCopyWithImpl<_OrderListItemModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OrderListItemModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderListItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.deliveryAddressLine, deliveryAddressLine) ||
                other.deliveryAddressLine == deliveryAddressLine) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, userName, shopId,
      shopName, deliveryAddressLine, total, itemCount, status, createdAt);

  @override
  String toString() {
    return 'OrderListItemModel(id: $id, userId: $userId, userName: $userName, shopId: $shopId, shopName: $shopName, deliveryAddressLine: $deliveryAddressLine, total: $total, itemCount: $itemCount, status: $status, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$OrderListItemModelCopyWith<$Res>
    implements $OrderListItemModelCopyWith<$Res> {
  factory _$OrderListItemModelCopyWith(
          _OrderListItemModel value, $Res Function(_OrderListItemModel) _then) =
      __$OrderListItemModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String shopId,
      String shopName,
      String deliveryAddressLine,
      double total,
      int itemCount,
      OrderStatus status,
      DateTime createdAt});
}

/// @nodoc
class __$OrderListItemModelCopyWithImpl<$Res>
    implements _$OrderListItemModelCopyWith<$Res> {
  __$OrderListItemModelCopyWithImpl(this._self, this._then);

  final _OrderListItemModel _self;
  final $Res Function(_OrderListItemModel) _then;

  /// Create a copy of OrderListItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? shopId = null,
    Object? shopName = null,
    Object? deliveryAddressLine = null,
    Object? total = null,
    Object? itemCount = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_OrderListItemModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      shopId: null == shopId
          ? _self.shopId
          : shopId // ignore: cast_nullable_to_non_nullable
              as String,
      shopName: null == shopName
          ? _self.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddressLine: null == deliveryAddressLine
          ? _self.deliveryAddressLine
          : deliveryAddressLine // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      itemCount: null == itemCount
          ? _self.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
