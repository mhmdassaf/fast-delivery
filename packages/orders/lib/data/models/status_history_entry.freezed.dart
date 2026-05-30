// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatusHistoryEntry {
  int get status;
  DateTime get timestamp;
  String get actionTakenBy;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StatusHistoryEntryCopyWith<StatusHistoryEntry> get copyWith =>
      _$StatusHistoryEntryCopyWithImpl<StatusHistoryEntry>(
          this as StatusHistoryEntry, _$identity);

  /// Serializes this StatusHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StatusHistoryEntry &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actionTakenBy, actionTakenBy) ||
                other.actionTakenBy == actionTakenBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, status, timestamp, actionTakenBy);

  @override
  String toString() {
    return 'StatusHistoryEntry(status: $status, timestamp: $timestamp, actionTakenBy: $actionTakenBy)';
  }
}

/// @nodoc
abstract mixin class $StatusHistoryEntryCopyWith<$Res> {
  factory $StatusHistoryEntryCopyWith(
          StatusHistoryEntry value, $Res Function(StatusHistoryEntry) _then) =
      _$StatusHistoryEntryCopyWithImpl;
  @useResult
  $Res call({int status, DateTime timestamp, String actionTakenBy});
}

/// @nodoc
class _$StatusHistoryEntryCopyWithImpl<$Res>
    implements $StatusHistoryEntryCopyWith<$Res> {
  _$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final StatusHistoryEntry _self;
  final $Res Function(StatusHistoryEntry) _then;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? timestamp = null,
    Object? actionTakenBy = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actionTakenBy: null == actionTakenBy
          ? _self.actionTakenBy
          : actionTakenBy // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [StatusHistoryEntry].
extension StatusHistoryEntryPatterns on StatusHistoryEntry {
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
    TResult Function(_StatusHistoryEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry() when $default != null:
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
    TResult Function(_StatusHistoryEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry():
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
    TResult? Function(_StatusHistoryEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry() when $default != null:
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
    TResult Function(int status, DateTime timestamp, String actionTakenBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry() when $default != null:
        return $default(_that.status, _that.timestamp, _that.actionTakenBy);
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
    TResult Function(int status, DateTime timestamp, String actionTakenBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry():
        return $default(_that.status, _that.timestamp, _that.actionTakenBy);
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
    TResult? Function(int status, DateTime timestamp, String actionTakenBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusHistoryEntry() when $default != null:
        return $default(_that.status, _that.timestamp, _that.actionTakenBy);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StatusHistoryEntry extends StatusHistoryEntry {
  const _StatusHistoryEntry(
      {required this.status,
      required this.timestamp,
      required this.actionTakenBy})
      : super._();
  factory _StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);

  @override
  final int status;
  @override
  final DateTime timestamp;
  @override
  final String actionTakenBy;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StatusHistoryEntryCopyWith<_StatusHistoryEntry> get copyWith =>
      __$StatusHistoryEntryCopyWithImpl<_StatusHistoryEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StatusHistoryEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StatusHistoryEntry &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actionTakenBy, actionTakenBy) ||
                other.actionTakenBy == actionTakenBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, status, timestamp, actionTakenBy);

  @override
  String toString() {
    return 'StatusHistoryEntry(status: $status, timestamp: $timestamp, actionTakenBy: $actionTakenBy)';
  }
}

/// @nodoc
abstract mixin class _$StatusHistoryEntryCopyWith<$Res>
    implements $StatusHistoryEntryCopyWith<$Res> {
  factory _$StatusHistoryEntryCopyWith(
          _StatusHistoryEntry value, $Res Function(_StatusHistoryEntry) _then) =
      __$StatusHistoryEntryCopyWithImpl;
  @override
  @useResult
  $Res call({int status, DateTime timestamp, String actionTakenBy});
}

/// @nodoc
class __$StatusHistoryEntryCopyWithImpl<$Res>
    implements _$StatusHistoryEntryCopyWith<$Res> {
  __$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final _StatusHistoryEntry _self;
  final $Res Function(_StatusHistoryEntry) _then;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? timestamp = null,
    Object? actionTakenBy = null,
  }) {
    return _then(_StatusHistoryEntry(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actionTakenBy: null == actionTakenBy
          ? _self.actionTakenBy
          : actionTakenBy // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
