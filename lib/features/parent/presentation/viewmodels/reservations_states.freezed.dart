// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservations_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReservationsListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ReservationSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ReservationSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ReservationSummary> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RInitial value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInitial value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInitial value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationsListStateCopyWith<$Res> {
  factory $ReservationsListStateCopyWith(ReservationsListState value,
          $Res Function(ReservationsListState) then) =
      _$ReservationsListStateCopyWithImpl<$Res, ReservationsListState>;
}

/// @nodoc
class _$ReservationsListStateCopyWithImpl<$Res,
        $Val extends ReservationsListState>
    implements $ReservationsListStateCopyWith<$Res> {
  _$ReservationsListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RInitialImplCopyWith<$Res> {
  factory _$$RInitialImplCopyWith(
          _$RInitialImpl value, $Res Function(_$RInitialImpl) then) =
      __$$RInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RInitialImplCopyWithImpl<$Res>
    extends _$ReservationsListStateCopyWithImpl<$Res, _$RInitialImpl>
    implements _$$RInitialImplCopyWith<$Res> {
  __$$RInitialImplCopyWithImpl(
      _$RInitialImpl _value, $Res Function(_$RInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RInitialImpl implements _RInitial {
  const _$RInitialImpl();

  @override
  String toString() {
    return 'ReservationsListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ReservationSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ReservationSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ReservationSummary> items)? loaded,
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
    required TResult Function(_RInitial value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInitial value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInitial value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _RInitial implements ReservationsListState {
  const factory _RInitial() = _$RInitialImpl;
}

/// @nodoc
abstract class _$$RLoadingImplCopyWith<$Res> {
  factory _$$RLoadingImplCopyWith(
          _$RLoadingImpl value, $Res Function(_$RLoadingImpl) then) =
      __$$RLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RLoadingImplCopyWithImpl<$Res>
    extends _$ReservationsListStateCopyWithImpl<$Res, _$RLoadingImpl>
    implements _$$RLoadingImplCopyWith<$Res> {
  __$$RLoadingImplCopyWithImpl(
      _$RLoadingImpl _value, $Res Function(_$RLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RLoadingImpl implements _RLoading {
  const _$RLoadingImpl();

  @override
  String toString() {
    return 'ReservationsListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ReservationSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ReservationSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ReservationSummary> items)? loaded,
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
    required TResult Function(_RInitial value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInitial value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInitial value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _RLoading implements ReservationsListState {
  const factory _RLoading() = _$RLoadingImpl;
}

/// @nodoc
abstract class _$$RLoadedImplCopyWith<$Res> {
  factory _$$RLoadedImplCopyWith(
          _$RLoadedImpl value, $Res Function(_$RLoadedImpl) then) =
      __$$RLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ReservationSummary> items});
}

/// @nodoc
class __$$RLoadedImplCopyWithImpl<$Res>
    extends _$ReservationsListStateCopyWithImpl<$Res, _$RLoadedImpl>
    implements _$$RLoadedImplCopyWith<$Res> {
  __$$RLoadedImplCopyWithImpl(
      _$RLoadedImpl _value, $Res Function(_$RLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$RLoadedImpl(
      null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ReservationSummary>,
    ));
  }
}

/// @nodoc

class _$RLoadedImpl implements _RLoaded {
  const _$RLoadedImpl(final List<ReservationSummary> items) : _items = items;

  final List<ReservationSummary> _items;
  @override
  List<ReservationSummary> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ReservationsListState.loaded(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RLoadedImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RLoadedImplCopyWith<_$RLoadedImpl> get copyWith =>
      __$$RLoadedImplCopyWithImpl<_$RLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ReservationSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(items);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ReservationSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(items);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ReservationSummary> items)? loaded,
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
    required TResult Function(_RInitial value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInitial value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInitial value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _RLoaded implements ReservationsListState {
  const factory _RLoaded(final List<ReservationSummary> items) = _$RLoadedImpl;

  List<ReservationSummary> get items;

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RLoadedImplCopyWith<_$RLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RErrorImplCopyWith<$Res> {
  factory _$$RErrorImplCopyWith(
          _$RErrorImpl value, $Res Function(_$RErrorImpl) then) =
      __$$RErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$RErrorImplCopyWithImpl<$Res>
    extends _$ReservationsListStateCopyWithImpl<$Res, _$RErrorImpl>
    implements _$$RErrorImplCopyWith<$Res> {
  __$$RErrorImplCopyWithImpl(
      _$RErrorImpl _value, $Res Function(_$RErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$RErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$RErrorImpl implements _RError {
  const _$RErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'ReservationsListState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RErrorImplCopyWith<_$RErrorImpl> get copyWith =>
      __$$RErrorImplCopyWithImpl<_$RErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ReservationSummary> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ReservationSummary> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ReservationSummary> items)? loaded,
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
    required TResult Function(_RInitial value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInitial value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInitial value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _RError implements ReservationsListState {
  const factory _RError(final Failure failure) = _$RErrorImpl;

  Failure get failure;

  /// Create a copy of ReservationsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RErrorImplCopyWith<_$RErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReservationDetailState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationDetailStateCopyWith<$Res> {
  factory $ReservationDetailStateCopyWith(ReservationDetailState value,
          $Res Function(ReservationDetailState) then) =
      _$ReservationDetailStateCopyWithImpl<$Res, ReservationDetailState>;
}

/// @nodoc
class _$ReservationDetailStateCopyWithImpl<$Res,
        $Val extends ReservationDetailState>
    implements $ReservationDetailStateCopyWith<$Res> {
  _$ReservationDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DInitialImplCopyWith<$Res> {
  factory _$$DInitialImplCopyWith(
          _$DInitialImpl value, $Res Function(_$DInitialImpl) then) =
      __$$DInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DInitialImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DInitialImpl>
    implements _$$DInitialImplCopyWith<$Res> {
  __$$DInitialImplCopyWithImpl(
      _$DInitialImpl _value, $Res Function(_$DInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DInitialImpl implements _DInitial {
  const _$DInitialImpl();

  @override
  String toString() {
    return 'ReservationDetailState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
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
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _DInitial implements ReservationDetailState {
  const factory _DInitial() = _$DInitialImpl;
}

/// @nodoc
abstract class _$$DLoadingImplCopyWith<$Res> {
  factory _$$DLoadingImplCopyWith(
          _$DLoadingImpl value, $Res Function(_$DLoadingImpl) then) =
      __$$DLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DLoadingImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DLoadingImpl>
    implements _$$DLoadingImplCopyWith<$Res> {
  __$$DLoadingImplCopyWithImpl(
      _$DLoadingImpl _value, $Res Function(_$DLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DLoadingImpl implements _DLoading {
  const _$DLoadingImpl();

  @override
  String toString() {
    return 'ReservationDetailState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
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
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _DLoading implements ReservationDetailState {
  const factory _DLoading() = _$DLoadingImpl;
}

/// @nodoc
abstract class _$$DLoadedImplCopyWith<$Res> {
  factory _$$DLoadedImplCopyWith(
          _$DLoadedImpl value, $Res Function(_$DLoadedImpl) then) =
      __$$DLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ReservationDetail detail});
}

/// @nodoc
class __$$DLoadedImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DLoadedImpl>
    implements _$$DLoadedImplCopyWith<$Res> {
  __$$DLoadedImplCopyWithImpl(
      _$DLoadedImpl _value, $Res Function(_$DLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_$DLoadedImpl(
      null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ReservationDetail,
    ));
  }
}

/// @nodoc

class _$DLoadedImpl implements _DLoaded {
  const _$DLoadedImpl(this.detail);

  @override
  final ReservationDetail detail;

  @override
  String toString() {
    return 'ReservationDetailState.loaded(detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DLoadedImpl &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DLoadedImplCopyWith<_$DLoadedImpl> get copyWith =>
      __$$DLoadedImplCopyWithImpl<_$DLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(detail);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(detail);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
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
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _DLoaded implements ReservationDetailState {
  const factory _DLoaded(final ReservationDetail detail) = _$DLoadedImpl;

  ReservationDetail get detail;

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DLoadedImplCopyWith<_$DLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DActingImplCopyWith<$Res> {
  factory _$$DActingImplCopyWith(
          _$DActingImpl value, $Res Function(_$DActingImpl) then) =
      __$$DActingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DActingImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DActingImpl>
    implements _$$DActingImplCopyWith<$Res> {
  __$$DActingImplCopyWithImpl(
      _$DActingImpl _value, $Res Function(_$DActingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DActingImpl implements _DActing {
  const _$DActingImpl();

  @override
  String toString() {
    return 'ReservationDetailState.acting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DActingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return acting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return acting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (acting != null) {
      return acting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return acting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return acting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (acting != null) {
      return acting(this);
    }
    return orElse();
  }
}

abstract class _DActing implements ReservationDetailState {
  const factory _DActing() = _$DActingImpl;
}

/// @nodoc
abstract class _$$DActionSuccessImplCopyWith<$Res> {
  factory _$$DActionSuccessImplCopyWith(_$DActionSuccessImpl value,
          $Res Function(_$DActionSuccessImpl) then) =
      __$$DActionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ReservationDetail detail});
}

/// @nodoc
class __$$DActionSuccessImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DActionSuccessImpl>
    implements _$$DActionSuccessImplCopyWith<$Res> {
  __$$DActionSuccessImplCopyWithImpl(
      _$DActionSuccessImpl _value, $Res Function(_$DActionSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_$DActionSuccessImpl(
      null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ReservationDetail,
    ));
  }
}

/// @nodoc

class _$DActionSuccessImpl implements _DActionSuccess {
  const _$DActionSuccessImpl(this.detail);

  @override
  final ReservationDetail detail;

  @override
  String toString() {
    return 'ReservationDetailState.actionSuccess(detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DActionSuccessImpl &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DActionSuccessImplCopyWith<_$DActionSuccessImpl> get copyWith =>
      __$$DActionSuccessImplCopyWithImpl<_$DActionSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return actionSuccess(detail);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return actionSuccess?.call(detail);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (actionSuccess != null) {
      return actionSuccess(detail);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return actionSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return actionSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (actionSuccess != null) {
      return actionSuccess(this);
    }
    return orElse();
  }
}

abstract class _DActionSuccess implements ReservationDetailState {
  const factory _DActionSuccess(final ReservationDetail detail) =
      _$DActionSuccessImpl;

  ReservationDetail get detail;

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DActionSuccessImplCopyWith<_$DActionSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DErrorImplCopyWith<$Res> {
  factory _$$DErrorImplCopyWith(
          _$DErrorImpl value, $Res Function(_$DErrorImpl) then) =
      __$$DErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$DErrorImplCopyWithImpl<$Res>
    extends _$ReservationDetailStateCopyWithImpl<$Res, _$DErrorImpl>
    implements _$$DErrorImplCopyWith<$Res> {
  __$$DErrorImplCopyWithImpl(
      _$DErrorImpl _value, $Res Function(_$DErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$DErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$DErrorImpl implements _DError {
  const _$DErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'ReservationDetailState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DErrorImplCopyWith<_$DErrorImpl> get copyWith =>
      __$$DErrorImplCopyWithImpl<_$DErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ReservationDetail detail) loaded,
    required TResult Function() acting,
    required TResult Function(ReservationDetail detail) actionSuccess,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ReservationDetail detail)? loaded,
    TResult? Function()? acting,
    TResult? Function(ReservationDetail detail)? actionSuccess,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ReservationDetail detail)? loaded,
    TResult Function()? acting,
    TResult Function(ReservationDetail detail)? actionSuccess,
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
    required TResult Function(_DInitial value) initial,
    required TResult Function(_DLoading value) loading,
    required TResult Function(_DLoaded value) loaded,
    required TResult Function(_DActing value) acting,
    required TResult Function(_DActionSuccess value) actionSuccess,
    required TResult Function(_DError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DInitial value)? initial,
    TResult? Function(_DLoading value)? loading,
    TResult? Function(_DLoaded value)? loaded,
    TResult? Function(_DActing value)? acting,
    TResult? Function(_DActionSuccess value)? actionSuccess,
    TResult? Function(_DError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DInitial value)? initial,
    TResult Function(_DLoading value)? loading,
    TResult Function(_DLoaded value)? loaded,
    TResult Function(_DActing value)? acting,
    TResult Function(_DActionSuccess value)? actionSuccess,
    TResult Function(_DError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _DError implements ReservationDetailState {
  const factory _DError(final Failure failure) = _$DErrorImpl;

  Failure get failure;

  /// Create a copy of ReservationDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DErrorImplCopyWith<_$DErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NewReservationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() editing,
    required TResult Function() submitting,
    required TResult Function(ReservationDetail detail) submitted,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? editing,
    TResult? Function()? submitting,
    TResult? Function(ReservationDetail detail)? submitted,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? editing,
    TResult Function()? submitting,
    TResult Function(ReservationDetail detail)? submitted,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NEditing value) editing,
    required TResult Function(_NSubmitting value) submitting,
    required TResult Function(_NSubmitted value) submitted,
    required TResult Function(_NError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NEditing value)? editing,
    TResult? Function(_NSubmitting value)? submitting,
    TResult? Function(_NSubmitted value)? submitted,
    TResult? Function(_NError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NEditing value)? editing,
    TResult Function(_NSubmitting value)? submitting,
    TResult Function(_NSubmitted value)? submitted,
    TResult Function(_NError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewReservationStateCopyWith<$Res> {
  factory $NewReservationStateCopyWith(
          NewReservationState value, $Res Function(NewReservationState) then) =
      _$NewReservationStateCopyWithImpl<$Res, NewReservationState>;
}

/// @nodoc
class _$NewReservationStateCopyWithImpl<$Res, $Val extends NewReservationState>
    implements $NewReservationStateCopyWith<$Res> {
  _$NewReservationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NEditingImplCopyWith<$Res> {
  factory _$$NEditingImplCopyWith(
          _$NEditingImpl value, $Res Function(_$NEditingImpl) then) =
      __$$NEditingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NEditingImplCopyWithImpl<$Res>
    extends _$NewReservationStateCopyWithImpl<$Res, _$NEditingImpl>
    implements _$$NEditingImplCopyWith<$Res> {
  __$$NEditingImplCopyWithImpl(
      _$NEditingImpl _value, $Res Function(_$NEditingImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NEditingImpl implements _NEditing {
  const _$NEditingImpl();

  @override
  String toString() {
    return 'NewReservationState.editing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NEditingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() editing,
    required TResult Function() submitting,
    required TResult Function(ReservationDetail detail) submitted,
    required TResult Function(Failure failure) error,
  }) {
    return editing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? editing,
    TResult? Function()? submitting,
    TResult? Function(ReservationDetail detail)? submitted,
    TResult? Function(Failure failure)? error,
  }) {
    return editing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? editing,
    TResult Function()? submitting,
    TResult Function(ReservationDetail detail)? submitted,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (editing != null) {
      return editing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NEditing value) editing,
    required TResult Function(_NSubmitting value) submitting,
    required TResult Function(_NSubmitted value) submitted,
    required TResult Function(_NError value) error,
  }) {
    return editing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NEditing value)? editing,
    TResult? Function(_NSubmitting value)? submitting,
    TResult? Function(_NSubmitted value)? submitted,
    TResult? Function(_NError value)? error,
  }) {
    return editing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NEditing value)? editing,
    TResult Function(_NSubmitting value)? submitting,
    TResult Function(_NSubmitted value)? submitted,
    TResult Function(_NError value)? error,
    required TResult orElse(),
  }) {
    if (editing != null) {
      return editing(this);
    }
    return orElse();
  }
}

abstract class _NEditing implements NewReservationState {
  const factory _NEditing() = _$NEditingImpl;
}

/// @nodoc
abstract class _$$NSubmittingImplCopyWith<$Res> {
  factory _$$NSubmittingImplCopyWith(
          _$NSubmittingImpl value, $Res Function(_$NSubmittingImpl) then) =
      __$$NSubmittingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NSubmittingImplCopyWithImpl<$Res>
    extends _$NewReservationStateCopyWithImpl<$Res, _$NSubmittingImpl>
    implements _$$NSubmittingImplCopyWith<$Res> {
  __$$NSubmittingImplCopyWithImpl(
      _$NSubmittingImpl _value, $Res Function(_$NSubmittingImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NSubmittingImpl implements _NSubmitting {
  const _$NSubmittingImpl();

  @override
  String toString() {
    return 'NewReservationState.submitting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NSubmittingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() editing,
    required TResult Function() submitting,
    required TResult Function(ReservationDetail detail) submitted,
    required TResult Function(Failure failure) error,
  }) {
    return submitting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? editing,
    TResult? Function()? submitting,
    TResult? Function(ReservationDetail detail)? submitted,
    TResult? Function(Failure failure)? error,
  }) {
    return submitting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? editing,
    TResult Function()? submitting,
    TResult Function(ReservationDetail detail)? submitted,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NEditing value) editing,
    required TResult Function(_NSubmitting value) submitting,
    required TResult Function(_NSubmitted value) submitted,
    required TResult Function(_NError value) error,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NEditing value)? editing,
    TResult? Function(_NSubmitting value)? submitting,
    TResult? Function(_NSubmitted value)? submitted,
    TResult? Function(_NError value)? error,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NEditing value)? editing,
    TResult Function(_NSubmitting value)? submitting,
    TResult Function(_NSubmitted value)? submitted,
    TResult Function(_NError value)? error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class _NSubmitting implements NewReservationState {
  const factory _NSubmitting() = _$NSubmittingImpl;
}

/// @nodoc
abstract class _$$NSubmittedImplCopyWith<$Res> {
  factory _$$NSubmittedImplCopyWith(
          _$NSubmittedImpl value, $Res Function(_$NSubmittedImpl) then) =
      __$$NSubmittedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ReservationDetail detail});
}

/// @nodoc
class __$$NSubmittedImplCopyWithImpl<$Res>
    extends _$NewReservationStateCopyWithImpl<$Res, _$NSubmittedImpl>
    implements _$$NSubmittedImplCopyWith<$Res> {
  __$$NSubmittedImplCopyWithImpl(
      _$NSubmittedImpl _value, $Res Function(_$NSubmittedImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_$NSubmittedImpl(
      null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ReservationDetail,
    ));
  }
}

/// @nodoc

class _$NSubmittedImpl implements _NSubmitted {
  const _$NSubmittedImpl(this.detail);

  @override
  final ReservationDetail detail;

  @override
  String toString() {
    return 'NewReservationState.submitted(detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NSubmittedImpl &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NSubmittedImplCopyWith<_$NSubmittedImpl> get copyWith =>
      __$$NSubmittedImplCopyWithImpl<_$NSubmittedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() editing,
    required TResult Function() submitting,
    required TResult Function(ReservationDetail detail) submitted,
    required TResult Function(Failure failure) error,
  }) {
    return submitted(detail);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? editing,
    TResult? Function()? submitting,
    TResult? Function(ReservationDetail detail)? submitted,
    TResult? Function(Failure failure)? error,
  }) {
    return submitted?.call(detail);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? editing,
    TResult Function()? submitting,
    TResult Function(ReservationDetail detail)? submitted,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted(detail);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NEditing value) editing,
    required TResult Function(_NSubmitting value) submitting,
    required TResult Function(_NSubmitted value) submitted,
    required TResult Function(_NError value) error,
  }) {
    return submitted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NEditing value)? editing,
    TResult? Function(_NSubmitting value)? submitting,
    TResult? Function(_NSubmitted value)? submitted,
    TResult? Function(_NError value)? error,
  }) {
    return submitted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NEditing value)? editing,
    TResult Function(_NSubmitting value)? submitting,
    TResult Function(_NSubmitted value)? submitted,
    TResult Function(_NError value)? error,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted(this);
    }
    return orElse();
  }
}

abstract class _NSubmitted implements NewReservationState {
  const factory _NSubmitted(final ReservationDetail detail) = _$NSubmittedImpl;

  ReservationDetail get detail;

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NSubmittedImplCopyWith<_$NSubmittedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NErrorImplCopyWith<$Res> {
  factory _$$NErrorImplCopyWith(
          _$NErrorImpl value, $Res Function(_$NErrorImpl) then) =
      __$$NErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$NErrorImplCopyWithImpl<$Res>
    extends _$NewReservationStateCopyWithImpl<$Res, _$NErrorImpl>
    implements _$$NErrorImplCopyWith<$Res> {
  __$$NErrorImplCopyWithImpl(
      _$NErrorImpl _value, $Res Function(_$NErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$NErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$NErrorImpl implements _NError {
  const _$NErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'NewReservationState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NErrorImplCopyWith<_$NErrorImpl> get copyWith =>
      __$$NErrorImplCopyWithImpl<_$NErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() editing,
    required TResult Function() submitting,
    required TResult Function(ReservationDetail detail) submitted,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? editing,
    TResult? Function()? submitting,
    TResult? Function(ReservationDetail detail)? submitted,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? editing,
    TResult Function()? submitting,
    TResult Function(ReservationDetail detail)? submitted,
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
    required TResult Function(_NEditing value) editing,
    required TResult Function(_NSubmitting value) submitting,
    required TResult Function(_NSubmitted value) submitted,
    required TResult Function(_NError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NEditing value)? editing,
    TResult? Function(_NSubmitting value)? submitting,
    TResult? Function(_NSubmitted value)? submitted,
    TResult? Function(_NError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NEditing value)? editing,
    TResult Function(_NSubmitting value)? submitting,
    TResult Function(_NSubmitted value)? submitted,
    TResult Function(_NError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _NError implements NewReservationState {
  const factory _NError(final Failure failure) = _$NErrorImpl;

  Failure get failure;

  /// Create a copy of NewReservationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NErrorImplCopyWith<_$NErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
