// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_user_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderUserInfo {

@JsonKey(name: 'Id') String get id;@JsonKey(name: 'Name') String get name;@JsonKey(name: 'Email') String get email;@JsonKey(name: 'Phone') String? get phone;
/// Create a copy of OrderUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderUserInfoCopyWith<OrderUserInfo> get copyWith => _$OrderUserInfoCopyWithImpl<OrderUserInfo>(this as OrderUserInfo, _$identity);

  /// Serializes this OrderUserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone);

@override
String toString() {
  return 'OrderUserInfo(id: $id, name: $name, email: $email, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $OrderUserInfoCopyWith<$Res>  {
  factory $OrderUserInfoCopyWith(OrderUserInfo value, $Res Function(OrderUserInfo) _then) = _$OrderUserInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id') String id,@JsonKey(name: 'Name') String name,@JsonKey(name: 'Email') String email,@JsonKey(name: 'Phone') String? phone
});




}
/// @nodoc
class _$OrderUserInfoCopyWithImpl<$Res>
    implements $OrderUserInfoCopyWith<$Res> {
  _$OrderUserInfoCopyWithImpl(this._self, this._then);

  final OrderUserInfo _self;
  final $Res Function(OrderUserInfo) _then;

/// Create a copy of OrderUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderUserInfo].
extension OrderUserInfoPatterns on OrderUserInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderUserInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _OrderUserInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _OrderUserInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id')  String id, @JsonKey(name: 'Name')  String name, @JsonKey(name: 'Email')  String email, @JsonKey(name: 'Phone')  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id')  String id, @JsonKey(name: 'Name')  String name, @JsonKey(name: 'Email')  String email, @JsonKey(name: 'Phone')  String? phone)  $default,) {final _that = this;
switch (_that) {
case _OrderUserInfo():
return $default(_that.id,_that.name,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id')  String id, @JsonKey(name: 'Name')  String name, @JsonKey(name: 'Email')  String email, @JsonKey(name: 'Phone')  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _OrderUserInfo() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderUserInfo extends OrderUserInfo {
  const _OrderUserInfo({@JsonKey(name: 'Id') required this.id, @JsonKey(name: 'Name') this.name = '', @JsonKey(name: 'Email') this.email = '', @JsonKey(name: 'Phone') this.phone}): super._();
  factory _OrderUserInfo.fromJson(Map<String, dynamic> json) => _$OrderUserInfoFromJson(json);

@override@JsonKey(name: 'Id') final  String id;
@override@JsonKey(name: 'Name') final  String name;
@override@JsonKey(name: 'Email') final  String email;
@override@JsonKey(name: 'Phone') final  String? phone;

/// Create a copy of OrderUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderUserInfoCopyWith<_OrderUserInfo> get copyWith => __$OrderUserInfoCopyWithImpl<_OrderUserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderUserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderUserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone);

@override
String toString() {
  return 'OrderUserInfo(id: $id, name: $name, email: $email, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$OrderUserInfoCopyWith<$Res> implements $OrderUserInfoCopyWith<$Res> {
  factory _$OrderUserInfoCopyWith(_OrderUserInfo value, $Res Function(_OrderUserInfo) _then) = __$OrderUserInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id') String id,@JsonKey(name: 'Name') String name,@JsonKey(name: 'Email') String email,@JsonKey(name: 'Phone') String? phone
});




}
/// @nodoc
class __$OrderUserInfoCopyWithImpl<$Res>
    implements _$OrderUserInfoCopyWith<$Res> {
  __$OrderUserInfoCopyWithImpl(this._self, this._then);

  final _OrderUserInfo _self;
  final $Res Function(_OrderUserInfo) _then;

/// Create a copy of OrderUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = freezed,}) {
  return _then(_OrderUserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
