// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessions_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SessionsListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SessionSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SessionSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SessionSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SLInit value) initial,
    required TResult Function(_SLLoading value) loading,
    required TResult Function(_SLLoaded value) loaded,
    required TResult Function(_SLError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SLInit value)? initial,
    TResult? Function(_SLLoading value)? loading,
    TResult? Function(_SLLoaded value)? loaded,
    TResult? Function(_SLError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SLInit value)? initial,
    TResult Function(_SLLoading value)? loading,
    TResult Function(_SLLoaded value)? loaded,
    TResult Function(_SLError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionsListStateCopyWith<$Res> {
  factory $SessionsListStateCopyWith(
          SessionsListState value, $Res Function(SessionsListState) then) =
      _$SessionsListStateCopyWithImpl<$Res, SessionsListState>;
}

/// @nodoc
class _$SessionsListStateCopyWithImpl<$Res, $Val extends SessionsListState>
    implements $SessionsListStateCopyWith<$Res> {
  _$SessionsListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SLInitImplCopyWith<$Res> {
  factory _$$SLInitImplCopyWith(
          _$SLInitImpl value, $Res Function(_$SLInitImpl) then) =
      __$$SLInitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SLInitImplCopyWithImpl<$Res>
    extends _$SessionsListStateCopyWithImpl<$Res, _$SLInitImpl>
    implements _$$SLInitImplCopyWith<$Res> {
  __$$SLInitImplCopyWithImpl(
      _$SLInitImpl _value, $Res Function(_$SLInitImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SLInitImpl implements _SLInit {
  const _$SLInitImpl();

  @override
  String toString() {
    return 'SessionsListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SLInitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SessionSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SessionSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SessionSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SLInit value) initial,
    required TResult Function(_SLLoading value) loading,
    required TResult Function(_SLLoaded value) loaded,
    required TResult Function(_SLError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SLInit value)? initial,
    TResult? Function(_SLLoading value)? loading,
    TResult? Function(_SLLoaded value)? loaded,
    TResult? Function(_SLError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SLInit value)? initial,
    TResult Function(_SLLoading value)? loading,
    TResult Function(_SLLoaded value)? loaded,
    TResult Function(_SLError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _SLInit implements SessionsListState {
  const factory _SLInit() = _$SLInitImpl;
}

/// @nodoc
abstract class _$$SLLoadingImplCopyWith<$Res> {
  factory _$$SLLoadingImplCopyWith(
          _$SLLoadingImpl value, $Res Function(_$SLLoadingImpl) then) =
      __$$SLLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SLLoadingImplCopyWithImpl<$Res>
    extends _$SessionsListStateCopyWithImpl<$Res, _$SLLoadingImpl>
    implements _$$SLLoadingImplCopyWith<$Res> {
  __$$SLLoadingImplCopyWithImpl(
      _$SLLoadingImpl _value, $Res Function(_$SLLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SLLoadingImpl implements _SLLoading {
  const _$SLLoadingImpl();

  @override
  String toString() {
    return 'SessionsListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SLLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SessionSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SessionSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SessionSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SLInit value) initial,
    required TResult Function(_SLLoading value) loading,
    required TResult Function(_SLLoaded value) loaded,
    required TResult Function(_SLError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SLInit value)? initial,
    TResult? Function(_SLLoading value)? loading,
    TResult? Function(_SLLoaded value)? loaded,
    TResult? Function(_SLError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SLInit value)? initial,
    TResult Function(_SLLoading value)? loading,
    TResult Function(_SLLoaded value)? loaded,
    TResult Function(_SLError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _SLLoading implements SessionsListState {
  const factory _SLLoading() = _$SLLoadingImpl;
}

/// @nodoc
abstract class _$$SLLoadedImplCopyWith<$Res> {
  factory _$$SLLoadedImplCopyWith(
          _$SLLoadedImpl value, $Res Function(_$SLLoadedImpl) then) =
      __$$SLLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<SessionSummary> items});
}

/// @nodoc
class __$$SLLoadedImplCopyWithImpl<$Res>
    extends _$SessionsListStateCopyWithImpl<$Res, _$SLLoadedImpl>
    implements _$$SLLoadedImplCopyWith<$Res> {
  __$$SLLoadedImplCopyWithImpl(
      _$SLLoadedImpl _value, $Res Function(_$SLLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$SLLoadedImpl(
      null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SessionSummary>,
    ));
  }
}

/// @nodoc

class _$SLLoadedImpl implements _SLLoaded {
  const _$SLLoadedImpl(final List<SessionSummary> items) : _items = items;

  final List<SessionSummary> _items;
  @override
  List<SessionSummary> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'SessionsListState.loaded(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SLLoadedImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SLLoadedImplCopyWith<_$SLLoadedImpl> get copyWith =>
      __$$SLLoadedImplCopyWithImpl<_$SLLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SessionSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(items);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SessionSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(items);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SessionSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(items);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SLInit value) initial,
    required TResult Function(_SLLoading value) loading,
    required TResult Function(_SLLoaded value) loaded,
    required TResult Function(_SLError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SLInit value)? initial,
    TResult? Function(_SLLoading value)? loading,
    TResult? Function(_SLLoaded value)? loaded,
    TResult? Function(_SLError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SLInit value)? initial,
    TResult Function(_SLLoading value)? loading,
    TResult Function(_SLLoaded value)? loaded,
    TResult Function(_SLError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _SLLoaded implements SessionsListState {
  const factory _SLLoaded(final List<SessionSummary> items) = _$SLLoadedImpl;

  List<SessionSummary> get items;

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SLLoadedImplCopyWith<_$SLLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SLErrorImplCopyWith<$Res> {
  factory _$$SLErrorImplCopyWith(
          _$SLErrorImpl value, $Res Function(_$SLErrorImpl) then) =
      __$$SLErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$SLErrorImplCopyWithImpl<$Res>
    extends _$SessionsListStateCopyWithImpl<$Res, _$SLErrorImpl>
    implements _$$SLErrorImplCopyWith<$Res> {
  __$$SLErrorImplCopyWithImpl(
      _$SLErrorImpl _value, $Res Function(_$SLErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$SLErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$SLErrorImpl implements _SLError {
  const _$SLErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'SessionsListState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SLErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SLErrorImplCopyWith<_$SLErrorImpl> get copyWith =>
      __$$SLErrorImplCopyWithImpl<_$SLErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SessionSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SessionSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SessionSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SLInit value) initial,
    required TResult Function(_SLLoading value) loading,
    required TResult Function(_SLLoaded value) loaded,
    required TResult Function(_SLError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SLInit value)? initial,
    TResult? Function(_SLLoading value)? loading,
    TResult? Function(_SLLoaded value)? loaded,
    TResult? Function(_SLError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SLInit value)? initial,
    TResult Function(_SLLoading value)? loading,
    TResult Function(_SLLoaded value)? loaded,
    TResult Function(_SLError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _SLError implements SessionsListState {
  const factory _SLError(final Failure failure) = _$SLErrorImpl;

  Failure get failure;

  /// Create a copy of SessionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SLErrorImplCopyWith<_$SLErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SessionDetailState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SessionDetail detail) loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SessionDetail detail)? loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SessionDetail detail)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SDInit value) initial,
    required TResult Function(_SDLoading value) loading,
    required TResult Function(_SDLoaded value) loaded,
    required TResult Function(_SDError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SDInit value)? initial,
    TResult? Function(_SDLoading value)? loading,
    TResult? Function(_SDLoaded value)? loaded,
    TResult? Function(_SDError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SDInit value)? initial,
    TResult Function(_SDLoading value)? loading,
    TResult Function(_SDLoaded value)? loaded,
    TResult Function(_SDError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionDetailStateCopyWith<$Res> {
  factory $SessionDetailStateCopyWith(
          SessionDetailState value, $Res Function(SessionDetailState) then) =
      _$SessionDetailStateCopyWithImpl<$Res, SessionDetailState>;
}

/// @nodoc
class _$SessionDetailStateCopyWithImpl<$Res, $Val extends SessionDetailState>
    implements $SessionDetailStateCopyWith<$Res> {
  _$SessionDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SDInitImplCopyWith<$Res> {
  factory _$$SDInitImplCopyWith(
          _$SDInitImpl value, $Res Function(_$SDInitImpl) then) =
      __$$SDInitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SDInitImplCopyWithImpl<$Res>
    extends _$SessionDetailStateCopyWithImpl<$Res, _$SDInitImpl>
    implements _$$SDInitImplCopyWith<$Res> {
  __$$SDInitImplCopyWithImpl(
      _$SDInitImpl _value, $Res Function(_$SDInitImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SDInitImpl implements _SDInit {
  const _$SDInitImpl();

  @override
  String toString() {
    return 'SessionDetailState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SDInitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SessionDetail detail) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SessionDetail detail)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SessionDetail detail)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SDInit value) initial,
    required TResult Function(_SDLoading value) loading,
    required TResult Function(_SDLoaded value) loaded,
    required TResult Function(_SDError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SDInit value)? initial,
    TResult? Function(_SDLoading value)? loading,
    TResult? Function(_SDLoaded value)? loaded,
    TResult? Function(_SDError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SDInit value)? initial,
    TResult Function(_SDLoading value)? loading,
    TResult Function(_SDLoaded value)? loaded,
    TResult Function(_SDError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _SDInit implements SessionDetailState {
  const factory _SDInit() = _$SDInitImpl;
}

/// @nodoc
abstract class _$$SDLoadingImplCopyWith<$Res> {
  factory _$$SDLoadingImplCopyWith(
          _$SDLoadingImpl value, $Res Function(_$SDLoadingImpl) then) =
      __$$SDLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SDLoadingImplCopyWithImpl<$Res>
    extends _$SessionDetailStateCopyWithImpl<$Res, _$SDLoadingImpl>
    implements _$$SDLoadingImplCopyWith<$Res> {
  __$$SDLoadingImplCopyWithImpl(
      _$SDLoadingImpl _value, $Res Function(_$SDLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SDLoadingImpl implements _SDLoading {
  const _$SDLoadingImpl();

  @override
  String toString() {
    return 'SessionDetailState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SDLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SessionDetail detail) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SessionDetail detail)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SessionDetail detail)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SDInit value) initial,
    required TResult Function(_SDLoading value) loading,
    required TResult Function(_SDLoaded value) loaded,
    required TResult Function(_SDError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SDInit value)? initial,
    TResult? Function(_SDLoading value)? loading,
    TResult? Function(_SDLoaded value)? loaded,
    TResult? Function(_SDError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SDInit value)? initial,
    TResult Function(_SDLoading value)? loading,
    TResult Function(_SDLoaded value)? loaded,
    TResult Function(_SDError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _SDLoading implements SessionDetailState {
  const factory _SDLoading() = _$SDLoadingImpl;
}

/// @nodoc
abstract class _$$SDLoadedImplCopyWith<$Res> {
  factory _$$SDLoadedImplCopyWith(
          _$SDLoadedImpl value, $Res Function(_$SDLoadedImpl) then) =
      __$$SDLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionDetail detail});
}

/// @nodoc
class __$$SDLoadedImplCopyWithImpl<$Res>
    extends _$SessionDetailStateCopyWithImpl<$Res, _$SDLoadedImpl>
    implements _$$SDLoadedImplCopyWith<$Res> {
  __$$SDLoadedImplCopyWithImpl(
      _$SDLoadedImpl _value, $Res Function(_$SDLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_$SDLoadedImpl(
      null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as SessionDetail,
    ));
  }
}

/// @nodoc

class _$SDLoadedImpl implements _SDLoaded {
  const _$SDLoadedImpl(this.detail);

  @override
  final SessionDetail detail;

  @override
  String toString() {
    return 'SessionDetailState.loaded(detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SDLoadedImpl &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SDLoadedImplCopyWith<_$SDLoadedImpl> get copyWith =>
      __$$SDLoadedImplCopyWithImpl<_$SDLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SessionDetail detail) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(detail);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SessionDetail detail)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(detail);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SessionDetail detail)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(detail);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SDInit value) initial,
    required TResult Function(_SDLoading value) loading,
    required TResult Function(_SDLoaded value) loaded,
    required TResult Function(_SDError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SDInit value)? initial,
    TResult? Function(_SDLoading value)? loading,
    TResult? Function(_SDLoaded value)? loaded,
    TResult? Function(_SDError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SDInit value)? initial,
    TResult Function(_SDLoading value)? loading,
    TResult Function(_SDLoaded value)? loaded,
    TResult Function(_SDError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _SDLoaded implements SessionDetailState {
  const factory _SDLoaded(final SessionDetail detail) = _$SDLoadedImpl;

  SessionDetail get detail;

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SDLoadedImplCopyWith<_$SDLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SDErrorImplCopyWith<$Res> {
  factory _$$SDErrorImplCopyWith(
          _$SDErrorImpl value, $Res Function(_$SDErrorImpl) then) =
      __$$SDErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$SDErrorImplCopyWithImpl<$Res>
    extends _$SessionDetailStateCopyWithImpl<$Res, _$SDErrorImpl>
    implements _$$SDErrorImplCopyWith<$Res> {
  __$$SDErrorImplCopyWithImpl(
      _$SDErrorImpl _value, $Res Function(_$SDErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$SDErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$SDErrorImpl implements _SDError {
  const _$SDErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'SessionDetailState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SDErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SDErrorImplCopyWith<_$SDErrorImpl> get copyWith =>
      __$$SDErrorImplCopyWithImpl<_$SDErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SessionDetail detail) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(SessionDetail detail)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SessionDetail detail)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SDInit value) initial,
    required TResult Function(_SDLoading value) loading,
    required TResult Function(_SDLoaded value) loaded,
    required TResult Function(_SDError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SDInit value)? initial,
    TResult? Function(_SDLoading value)? loading,
    TResult? Function(_SDLoaded value)? loaded,
    TResult? Function(_SDError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SDInit value)? initial,
    TResult Function(_SDLoading value)? loading,
    TResult Function(_SDLoaded value)? loaded,
    TResult Function(_SDError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _SDError implements SessionDetailState {
  const factory _SDError(final Failure failure) = _$SDErrorImpl;

  Failure get failure;

  /// Create a copy of SessionDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SDErrorImplCopyWith<_$SDErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
