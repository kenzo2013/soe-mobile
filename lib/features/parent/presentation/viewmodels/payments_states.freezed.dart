// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentsListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Payment> items) loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Payment> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Payment> items)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PLInit value) initial,
    required TResult Function(_PLLoading value) loading,
    required TResult Function(_PLLoaded value) loaded,
    required TResult Function(_PLError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PLInit value)? initial,
    TResult? Function(_PLLoading value)? loading,
    TResult? Function(_PLLoaded value)? loaded,
    TResult? Function(_PLError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PLInit value)? initial,
    TResult Function(_PLLoading value)? loading,
    TResult Function(_PLLoaded value)? loaded,
    TResult Function(_PLError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentsListStateCopyWith<$Res> {
  factory $PaymentsListStateCopyWith(
          PaymentsListState value, $Res Function(PaymentsListState) then) =
      _$PaymentsListStateCopyWithImpl<$Res, PaymentsListState>;
}

/// @nodoc
class _$PaymentsListStateCopyWithImpl<$Res, $Val extends PaymentsListState>
    implements $PaymentsListStateCopyWith<$Res> {
  _$PaymentsListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PLInitImplCopyWith<$Res> {
  factory _$$PLInitImplCopyWith(
          _$PLInitImpl value, $Res Function(_$PLInitImpl) then) =
      __$$PLInitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PLInitImplCopyWithImpl<$Res>
    extends _$PaymentsListStateCopyWithImpl<$Res, _$PLInitImpl>
    implements _$$PLInitImplCopyWith<$Res> {
  __$$PLInitImplCopyWithImpl(
      _$PLInitImpl _value, $Res Function(_$PLInitImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PLInitImpl implements _PLInit {
  const _$PLInitImpl();

  @override
  String toString() {
    return 'PaymentsListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PLInitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Payment> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Payment> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Payment> items)? loaded,
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
    required TResult Function(_PLInit value) initial,
    required TResult Function(_PLLoading value) loading,
    required TResult Function(_PLLoaded value) loaded,
    required TResult Function(_PLError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PLInit value)? initial,
    TResult? Function(_PLLoading value)? loading,
    TResult? Function(_PLLoaded value)? loaded,
    TResult? Function(_PLError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PLInit value)? initial,
    TResult Function(_PLLoading value)? loading,
    TResult Function(_PLLoaded value)? loaded,
    TResult Function(_PLError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _PLInit implements PaymentsListState {
  const factory _PLInit() = _$PLInitImpl;
}

/// @nodoc
abstract class _$$PLLoadingImplCopyWith<$Res> {
  factory _$$PLLoadingImplCopyWith(
          _$PLLoadingImpl value, $Res Function(_$PLLoadingImpl) then) =
      __$$PLLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PLLoadingImplCopyWithImpl<$Res>
    extends _$PaymentsListStateCopyWithImpl<$Res, _$PLLoadingImpl>
    implements _$$PLLoadingImplCopyWith<$Res> {
  __$$PLLoadingImplCopyWithImpl(
      _$PLLoadingImpl _value, $Res Function(_$PLLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PLLoadingImpl implements _PLLoading {
  const _$PLLoadingImpl();

  @override
  String toString() {
    return 'PaymentsListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PLLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Payment> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Payment> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Payment> items)? loaded,
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
    required TResult Function(_PLInit value) initial,
    required TResult Function(_PLLoading value) loading,
    required TResult Function(_PLLoaded value) loaded,
    required TResult Function(_PLError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PLInit value)? initial,
    TResult? Function(_PLLoading value)? loading,
    TResult? Function(_PLLoaded value)? loaded,
    TResult? Function(_PLError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PLInit value)? initial,
    TResult Function(_PLLoading value)? loading,
    TResult Function(_PLLoaded value)? loaded,
    TResult Function(_PLError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _PLLoading implements PaymentsListState {
  const factory _PLLoading() = _$PLLoadingImpl;
}

/// @nodoc
abstract class _$$PLLoadedImplCopyWith<$Res> {
  factory _$$PLLoadedImplCopyWith(
          _$PLLoadedImpl value, $Res Function(_$PLLoadedImpl) then) =
      __$$PLLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Payment> items});
}

/// @nodoc
class __$$PLLoadedImplCopyWithImpl<$Res>
    extends _$PaymentsListStateCopyWithImpl<$Res, _$PLLoadedImpl>
    implements _$$PLLoadedImplCopyWith<$Res> {
  __$$PLLoadedImplCopyWithImpl(
      _$PLLoadedImpl _value, $Res Function(_$PLLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$PLLoadedImpl(
      null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
    ));
  }
}

/// @nodoc

class _$PLLoadedImpl implements _PLLoaded {
  const _$PLLoadedImpl(final List<Payment> items) : _items = items;

  final List<Payment> _items;
  @override
  List<Payment> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'PaymentsListState.loaded(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PLLoadedImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PLLoadedImplCopyWith<_$PLLoadedImpl> get copyWith =>
      __$$PLLoadedImplCopyWithImpl<_$PLLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Payment> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(items);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Payment> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(items);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Payment> items)? loaded,
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
    required TResult Function(_PLInit value) initial,
    required TResult Function(_PLLoading value) loading,
    required TResult Function(_PLLoaded value) loaded,
    required TResult Function(_PLError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PLInit value)? initial,
    TResult? Function(_PLLoading value)? loading,
    TResult? Function(_PLLoaded value)? loaded,
    TResult? Function(_PLError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PLInit value)? initial,
    TResult Function(_PLLoading value)? loading,
    TResult Function(_PLLoaded value)? loaded,
    TResult Function(_PLError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _PLLoaded implements PaymentsListState {
  const factory _PLLoaded(final List<Payment> items) = _$PLLoadedImpl;

  List<Payment> get items;

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PLLoadedImplCopyWith<_$PLLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PLErrorImplCopyWith<$Res> {
  factory _$$PLErrorImplCopyWith(
          _$PLErrorImpl value, $Res Function(_$PLErrorImpl) then) =
      __$$PLErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$PLErrorImplCopyWithImpl<$Res>
    extends _$PaymentsListStateCopyWithImpl<$Res, _$PLErrorImpl>
    implements _$$PLErrorImplCopyWith<$Res> {
  __$$PLErrorImplCopyWithImpl(
      _$PLErrorImpl _value, $Res Function(_$PLErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$PLErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$PLErrorImpl implements _PLError {
  const _$PLErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'PaymentsListState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PLErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PLErrorImplCopyWith<_$PLErrorImpl> get copyWith =>
      __$$PLErrorImplCopyWithImpl<_$PLErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Payment> items) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Payment> items)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Payment> items)? loaded,
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
    required TResult Function(_PLInit value) initial,
    required TResult Function(_PLLoading value) loading,
    required TResult Function(_PLLoaded value) loaded,
    required TResult Function(_PLError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PLInit value)? initial,
    TResult? Function(_PLLoading value)? loading,
    TResult? Function(_PLLoaded value)? loaded,
    TResult? Function(_PLError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PLInit value)? initial,
    TResult Function(_PLLoading value)? loading,
    TResult Function(_PLLoaded value)? loaded,
    TResult Function(_PLError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _PLError implements PaymentsListState {
  const factory _PLError(final Failure failure) = _$PLErrorImpl;

  Failure get failure;

  /// Create a copy of PaymentsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PLErrorImplCopyWith<_$PLErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CheckoutState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Payment payment) processing,
    required TResult Function(Payment payment) completed,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Payment payment)? processing,
    TResult? Function(Payment payment)? completed,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Payment payment)? processing,
    TResult Function(Payment payment)? completed,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CIdle value) idle,
    required TResult Function(_CProcessing value) processing,
    required TResult Function(_CCompleted value) completed,
    required TResult Function(_CError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CIdle value)? idle,
    TResult? Function(_CProcessing value)? processing,
    TResult? Function(_CCompleted value)? completed,
    TResult? Function(_CError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CIdle value)? idle,
    TResult Function(_CProcessing value)? processing,
    TResult Function(_CCompleted value)? completed,
    TResult Function(_CError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutStateCopyWith<$Res> {
  factory $CheckoutStateCopyWith(
          CheckoutState value, $Res Function(CheckoutState) then) =
      _$CheckoutStateCopyWithImpl<$Res, CheckoutState>;
}

/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res, $Val extends CheckoutState>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CIdleImplCopyWith<$Res> {
  factory _$$CIdleImplCopyWith(
          _$CIdleImpl value, $Res Function(_$CIdleImpl) then) =
      __$$CIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CIdleImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CIdleImpl>
    implements _$$CIdleImplCopyWith<$Res> {
  __$$CIdleImplCopyWithImpl(
      _$CIdleImpl _value, $Res Function(_$CIdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CIdleImpl implements _CIdle {
  const _$CIdleImpl();

  @override
  String toString() {
    return 'CheckoutState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Payment payment) processing,
    required TResult Function(Payment payment) completed,
    required TResult Function(Failure failure) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Payment payment)? processing,
    TResult? Function(Payment payment)? completed,
    TResult? Function(Failure failure)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Payment payment)? processing,
    TResult Function(Payment payment)? completed,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CIdle value) idle,
    required TResult Function(_CProcessing value) processing,
    required TResult Function(_CCompleted value) completed,
    required TResult Function(_CError value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CIdle value)? idle,
    TResult? Function(_CProcessing value)? processing,
    TResult? Function(_CCompleted value)? completed,
    TResult? Function(_CError value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CIdle value)? idle,
    TResult Function(_CProcessing value)? processing,
    TResult Function(_CCompleted value)? completed,
    TResult Function(_CError value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _CIdle implements CheckoutState {
  const factory _CIdle() = _$CIdleImpl;
}

/// @nodoc
abstract class _$$CProcessingImplCopyWith<$Res> {
  factory _$$CProcessingImplCopyWith(
          _$CProcessingImpl value, $Res Function(_$CProcessingImpl) then) =
      __$$CProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Payment payment});
}

/// @nodoc
class __$$CProcessingImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CProcessingImpl>
    implements _$$CProcessingImplCopyWith<$Res> {
  __$$CProcessingImplCopyWithImpl(
      _$CProcessingImpl _value, $Res Function(_$CProcessingImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payment = null,
  }) {
    return _then(_$CProcessingImpl(
      null == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as Payment,
    ));
  }
}

/// @nodoc

class _$CProcessingImpl implements _CProcessing {
  const _$CProcessingImpl(this.payment);

  @override
  final Payment payment;

  @override
  String toString() {
    return 'CheckoutState.processing(payment: $payment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CProcessingImpl &&
            (identical(other.payment, payment) || other.payment == payment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payment);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CProcessingImplCopyWith<_$CProcessingImpl> get copyWith =>
      __$$CProcessingImplCopyWithImpl<_$CProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Payment payment) processing,
    required TResult Function(Payment payment) completed,
    required TResult Function(Failure failure) error,
  }) {
    return processing(payment);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Payment payment)? processing,
    TResult? Function(Payment payment)? completed,
    TResult? Function(Failure failure)? error,
  }) {
    return processing?.call(payment);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Payment payment)? processing,
    TResult Function(Payment payment)? completed,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(payment);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CIdle value) idle,
    required TResult Function(_CProcessing value) processing,
    required TResult Function(_CCompleted value) completed,
    required TResult Function(_CError value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CIdle value)? idle,
    TResult? Function(_CProcessing value)? processing,
    TResult? Function(_CCompleted value)? completed,
    TResult? Function(_CError value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CIdle value)? idle,
    TResult Function(_CProcessing value)? processing,
    TResult Function(_CCompleted value)? completed,
    TResult Function(_CError value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _CProcessing implements CheckoutState {
  const factory _CProcessing(final Payment payment) = _$CProcessingImpl;

  Payment get payment;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CProcessingImplCopyWith<_$CProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CCompletedImplCopyWith<$Res> {
  factory _$$CCompletedImplCopyWith(
          _$CCompletedImpl value, $Res Function(_$CCompletedImpl) then) =
      __$$CCompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Payment payment});
}

/// @nodoc
class __$$CCompletedImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CCompletedImpl>
    implements _$$CCompletedImplCopyWith<$Res> {
  __$$CCompletedImplCopyWithImpl(
      _$CCompletedImpl _value, $Res Function(_$CCompletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payment = null,
  }) {
    return _then(_$CCompletedImpl(
      null == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as Payment,
    ));
  }
}

/// @nodoc

class _$CCompletedImpl implements _CCompleted {
  const _$CCompletedImpl(this.payment);

  @override
  final Payment payment;

  @override
  String toString() {
    return 'CheckoutState.completed(payment: $payment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CCompletedImpl &&
            (identical(other.payment, payment) || other.payment == payment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payment);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CCompletedImplCopyWith<_$CCompletedImpl> get copyWith =>
      __$$CCompletedImplCopyWithImpl<_$CCompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Payment payment) processing,
    required TResult Function(Payment payment) completed,
    required TResult Function(Failure failure) error,
  }) {
    return completed(payment);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Payment payment)? processing,
    TResult? Function(Payment payment)? completed,
    TResult? Function(Failure failure)? error,
  }) {
    return completed?.call(payment);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Payment payment)? processing,
    TResult Function(Payment payment)? completed,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(payment);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CIdle value) idle,
    required TResult Function(_CProcessing value) processing,
    required TResult Function(_CCompleted value) completed,
    required TResult Function(_CError value) error,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CIdle value)? idle,
    TResult? Function(_CProcessing value)? processing,
    TResult? Function(_CCompleted value)? completed,
    TResult? Function(_CError value)? error,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CIdle value)? idle,
    TResult Function(_CProcessing value)? processing,
    TResult Function(_CCompleted value)? completed,
    TResult Function(_CError value)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class _CCompleted implements CheckoutState {
  const factory _CCompleted(final Payment payment) = _$CCompletedImpl;

  Payment get payment;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CCompletedImplCopyWith<_$CCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CErrorImplCopyWith<$Res> {
  factory _$$CErrorImplCopyWith(
          _$CErrorImpl value, $Res Function(_$CErrorImpl) then) =
      __$$CErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$CErrorImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CErrorImpl>
    implements _$$CErrorImplCopyWith<$Res> {
  __$$CErrorImplCopyWithImpl(
      _$CErrorImpl _value, $Res Function(_$CErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$CErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$CErrorImpl implements _CError {
  const _$CErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'CheckoutState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CErrorImplCopyWith<_$CErrorImpl> get copyWith =>
      __$$CErrorImplCopyWithImpl<_$CErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Payment payment) processing,
    required TResult Function(Payment payment) completed,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Payment payment)? processing,
    TResult? Function(Payment payment)? completed,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Payment payment)? processing,
    TResult Function(Payment payment)? completed,
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
    required TResult Function(_CIdle value) idle,
    required TResult Function(_CProcessing value) processing,
    required TResult Function(_CCompleted value) completed,
    required TResult Function(_CError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CIdle value)? idle,
    TResult? Function(_CProcessing value)? processing,
    TResult? Function(_CCompleted value)? completed,
    TResult? Function(_CError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CIdle value)? idle,
    TResult Function(_CProcessing value)? processing,
    TResult Function(_CCompleted value)? completed,
    TResult Function(_CError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _CError implements CheckoutState {
  const factory _CError(final Failure failure) = _$CErrorImpl;

  Failure get failure;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CErrorImplCopyWith<_$CErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PaymentReceiptState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(PaymentReceipt receipt) loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(PaymentReceipt receipt)? loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(PaymentReceipt receipt)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RInit value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInit value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInit value)? initial,
    TResult Function(_RLoading value)? loading,
    TResult Function(_RLoaded value)? loaded,
    TResult Function(_RError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentReceiptStateCopyWith<$Res> {
  factory $PaymentReceiptStateCopyWith(
          PaymentReceiptState value, $Res Function(PaymentReceiptState) then) =
      _$PaymentReceiptStateCopyWithImpl<$Res, PaymentReceiptState>;
}

/// @nodoc
class _$PaymentReceiptStateCopyWithImpl<$Res, $Val extends PaymentReceiptState>
    implements $PaymentReceiptStateCopyWith<$Res> {
  _$PaymentReceiptStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentReceiptState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RInitImplCopyWith<$Res> {
  factory _$$RInitImplCopyWith(
          _$RInitImpl value, $Res Function(_$RInitImpl) then) =
      __$$RInitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RInitImplCopyWithImpl<$Res>
    extends _$PaymentReceiptStateCopyWithImpl<$Res, _$RInitImpl>
    implements _$$RInitImplCopyWith<$Res> {
  __$$RInitImplCopyWithImpl(
      _$RInitImpl _value, $Res Function(_$RInitImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentReceiptState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RInitImpl implements _RInit {
  const _$RInitImpl();

  @override
  String toString() {
    return 'PaymentReceiptState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RInitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(PaymentReceipt receipt) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(PaymentReceipt receipt)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(PaymentReceipt receipt)? loaded,
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
    required TResult Function(_RInit value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInit value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInit value)? initial,
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

abstract class _RInit implements PaymentReceiptState {
  const factory _RInit() = _$RInitImpl;
}

/// @nodoc
abstract class _$$RLoadingImplCopyWith<$Res> {
  factory _$$RLoadingImplCopyWith(
          _$RLoadingImpl value, $Res Function(_$RLoadingImpl) then) =
      __$$RLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RLoadingImplCopyWithImpl<$Res>
    extends _$PaymentReceiptStateCopyWithImpl<$Res, _$RLoadingImpl>
    implements _$$RLoadingImplCopyWith<$Res> {
  __$$RLoadingImplCopyWithImpl(
      _$RLoadingImpl _value, $Res Function(_$RLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentReceiptState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RLoadingImpl implements _RLoading {
  const _$RLoadingImpl();

  @override
  String toString() {
    return 'PaymentReceiptState.loading()';
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
    required TResult Function(PaymentReceipt receipt) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(PaymentReceipt receipt)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(PaymentReceipt receipt)? loaded,
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
    required TResult Function(_RInit value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInit value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInit value)? initial,
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

abstract class _RLoading implements PaymentReceiptState {
  const factory _RLoading() = _$RLoadingImpl;
}

/// @nodoc
abstract class _$$RLoadedImplCopyWith<$Res> {
  factory _$$RLoadedImplCopyWith(
          _$RLoadedImpl value, $Res Function(_$RLoadedImpl) then) =
      __$$RLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PaymentReceipt receipt});
}

/// @nodoc
class __$$RLoadedImplCopyWithImpl<$Res>
    extends _$PaymentReceiptStateCopyWithImpl<$Res, _$RLoadedImpl>
    implements _$$RLoadedImplCopyWith<$Res> {
  __$$RLoadedImplCopyWithImpl(
      _$RLoadedImpl _value, $Res Function(_$RLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentReceiptState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? receipt = null,
  }) {
    return _then(_$RLoadedImpl(
      null == receipt
          ? _value.receipt
          : receipt // ignore: cast_nullable_to_non_nullable
              as PaymentReceipt,
    ));
  }
}

/// @nodoc

class _$RLoadedImpl implements _RLoaded {
  const _$RLoadedImpl(this.receipt);

  @override
  final PaymentReceipt receipt;

  @override
  String toString() {
    return 'PaymentReceiptState.loaded(receipt: $receipt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RLoadedImpl &&
            (identical(other.receipt, receipt) || other.receipt == receipt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, receipt);

  /// Create a copy of PaymentReceiptState
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
    required TResult Function(PaymentReceipt receipt) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(receipt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(PaymentReceipt receipt)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(receipt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(PaymentReceipt receipt)? loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(receipt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RInit value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInit value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInit value)? initial,
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

abstract class _RLoaded implements PaymentReceiptState {
  const factory _RLoaded(final PaymentReceipt receipt) = _$RLoadedImpl;

  PaymentReceipt get receipt;

  /// Create a copy of PaymentReceiptState
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
    extends _$PaymentReceiptStateCopyWithImpl<$Res, _$RErrorImpl>
    implements _$$RErrorImplCopyWith<$Res> {
  __$$RErrorImplCopyWithImpl(
      _$RErrorImpl _value, $Res Function(_$RErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentReceiptState
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
    return 'PaymentReceiptState.error(failure: $failure)';
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

  /// Create a copy of PaymentReceiptState
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
    required TResult Function(PaymentReceipt receipt) loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(PaymentReceipt receipt)? loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(PaymentReceipt receipt)? loaded,
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
    required TResult Function(_RInit value) initial,
    required TResult Function(_RLoading value) loading,
    required TResult Function(_RLoaded value) loaded,
    required TResult Function(_RError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RInit value)? initial,
    TResult? Function(_RLoading value)? loading,
    TResult? Function(_RLoaded value)? loaded,
    TResult? Function(_RError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RInit value)? initial,
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

abstract class _RError implements PaymentReceiptState {
  const factory _RError(final Failure failure) = _$RErrorImpl;

  Failure get failure;

  /// Create a copy of PaymentReceiptState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RErrorImplCopyWith<_$RErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
