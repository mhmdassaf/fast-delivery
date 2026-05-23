// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_address_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryAddressModel {

 double get latitude; double get longitude; String get addressLine; String get label;
/// Create a copy of DeliveryAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryAddressModelCopyWith<DeliveryAddressModel> get copyWith => _$DeliveryAddressModelCopyWithImpl<DeliveryAddressModel>(this as DeliveryAddressModel, _$identity);

  /// Serializes this DeliveryAddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryAddressModel&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,addressLine,label);

@override
String toString() {
  return 'DeliveryAddressModel(latitude: $latitude, longitude: $longitude, addressLine: $addressLine, label: $label)';
}


}

/// @nodoc
abstract mixin class $DeliveryAddressModelCopyWith<$Res>  {
  factory $DeliveryAddressModelCopyWith(DeliveryAddressModel value, $Res Function(DeliveryAddressModel) _then) = _$DeliveryAddressModelCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, String addressLine, String label
});




}
/// @nodoc
class _$DeliveryAddressModelCopyWithImpl<$Res>
    implements $DeliveryAddressModelCopyWith<$Res> {
  _$DeliveryAddressModelCopyWithImpl(this._self, this._then);

  final DeliveryAddressModel _self;
  final $Res Function(DeliveryAddressModel) _then;

/// Create a copy of DeliveryAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? addressLine = null,Object? label = null,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryAddressModel].
extension DeliveryAddressModelPatterns on DeliveryAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String addressLine,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryAddressModel() when $default != null:
return $default(_that.latitude,_that.longitude,_that.addressLine,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String addressLine,  String label)  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddressModel():
return $default(_that.latitude,_that.longitude,_that.addressLine,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  String addressLine,  String label)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddressModel() when $default != null:
return $default(_that.latitude,_that.longitude,_that.addressLine,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryAddressModel extends DeliveryAddressModel {
  const _DeliveryAddressModel({required this.latitude, required this.longitude, required this.addressLine, this.label = 'Current Location'}): super._();
  factory _DeliveryAddressModel.fromJson(Map<String, dynamic> json) => _$DeliveryAddressModelFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  String addressLine;
@override@JsonKey() final  String label;

/// Create a copy of DeliveryAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryAddressModelCopyWith<_DeliveryAddressModel> get copyWith => __$DeliveryAddressModelCopyWithImpl<_DeliveryAddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryAddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryAddressModel&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,addressLine,label);

@override
String toString() {
  return 'DeliveryAddressModel(latitude: $latitude, longitude: $longitude, addressLine: $addressLine, label: $label)';
}


}

/// @nodoc
abstract mixin class _$DeliveryAddressModelCopyWith<$Res> implements $DeliveryAddressModelCopyWith<$Res> {
  factory _$DeliveryAddressModelCopyWith(_DeliveryAddressModel value, $Res Function(_DeliveryAddressModel) _then) = __$DeliveryAddressModelCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, String addressLine, String label
});




}
/// @nodoc
class __$DeliveryAddressModelCopyWithImpl<$Res>
    implements _$DeliveryAddressModelCopyWith<$Res> {
  __$DeliveryAddressModelCopyWithImpl(this._self, this._then);

  final _DeliveryAddressModel _self;
  final $Res Function(_DeliveryAddressModel) _then;

/// Create a copy of DeliveryAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? addressLine = null,Object? label = null,}) {
  return _then(_DeliveryAddressModel(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
