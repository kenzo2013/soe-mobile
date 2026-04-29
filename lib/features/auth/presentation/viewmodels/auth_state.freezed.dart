// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AuthState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AuthState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AuthState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AuthenticatedImplCopyWith<$Res> {
  factory _$$AuthenticatedImplCopyWith(
          _$AuthenticatedImpl value, $Res Function(_$AuthenticatedImpl) then) =
      __$$AuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthSession session});
}

/// @nodoc
class __$$AuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
    implements _$$AuthenticatedImplCopyWith<$Res> {
  __$$AuthenticatedImplCopyWithImpl(
      _$AuthenticatedImpl _value, $Res Function(_$AuthenticatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? session = null,
  }) {
    return _then(_$AuthenticatedImpl(
      null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as AuthSession,
    ));
  }
}

/// @nodoc

class _$AuthenticatedImpl implements _Authenticated {
  const _$AuthenticatedImpl(this.session);

  @override
  final AuthSession session;

  @override
  String toString() {
    return 'AuthState.authenticated(session: $session)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedImpl &&
            (identical(other.session, session) || other.session == session));
  }

  @override
  int get hashCode => Object.hash(runtimeType, session);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return authenticated(session);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return authenticated?.call(session);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(session);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class _Authenticated implements AuthState {
  const factory _Authenticated(final AuthSession session) = _$AuthenticatedImpl;

  AuthSession get session;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisteredImplCopyWith<$Res> {
  factory _$$RegisteredImplCopyWith(
          _$RegisteredImpl value, $Res Function(_$RegisteredImpl) then) =
      __$$RegisteredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user});
}

/// @nodoc
class __$$RegisteredImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$RegisteredImpl>
    implements _$$RegisteredImplCopyWith<$Res> {
  __$$RegisteredImplCopyWithImpl(
      _$RegisteredImpl _value, $Res Function(_$RegisteredImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
  }) {
    return _then(_$RegisteredImpl(
      null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ));
  }
}

/// @nodoc

class _$RegisteredImpl implements _Registered {
  const _$RegisteredImpl(this.user);

  @override
  final User user;

  @override
  String toString() {
    return 'AuthState.registered(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisteredImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisteredImplCopyWith<_$RegisteredImpl> get copyWith =>
      __$$RegisteredImplCopyWithImpl<_$RegisteredImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return registered(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return registered?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return registered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return registered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(this);
    }
    return orElse();
  }
}

abstract class _Registered implements AuthState {
  const factory _Registered(final User user) = _$RegisteredImpl;

  User get user;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisteredImplCopyWith<_$RegisteredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordResetSentImplCopyWith<$Res> {
  factory _$$PasswordResetSentImplCopyWith(_$PasswordResetSentImpl value,
          $Res Function(_$PasswordResetSentImpl) then) =
      __$$PasswordResetSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$PasswordResetSentImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetSentImpl>
    implements _$$PasswordResetSentImplCopyWith<$Res> {
  __$$PasswordResetSentImplCopyWithImpl(_$PasswordResetSentImpl _value,
      $Res Function(_$PasswordResetSentImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$PasswordResetSentImpl(
      null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PasswordResetSentImpl implements _PasswordResetSent {
  const _$PasswordResetSentImpl(this.email);

  @override
  final String email;

  @override
  String toString() {
    return 'AuthState.passwordResetSent(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetSentImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetSentImplCopyWith<_$PasswordResetSentImpl> get copyWith =>
      __$$PasswordResetSentImplCopyWithImpl<_$PasswordResetSentImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return passwordResetSent(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return passwordResetSent?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (passwordResetSent != null) {
      return passwordResetSent(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return passwordResetSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return passwordResetSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (passwordResetSent != null) {
      return passwordResetSent(this);
    }
    return orElse();
  }
}

abstract class _PasswordResetSent implements AuthState {
  const factory _PasswordResetSent(final String email) =
      _$PasswordResetSentImpl;

  String get email;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetSentImplCopyWith<_$PasswordResetSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordResetSucceededImplCopyWith<$Res> {
  factory _$$PasswordResetSucceededImplCopyWith(
          _$PasswordResetSucceededImpl value,
          $Res Function(_$PasswordResetSucceededImpl) then) =
      __$$PasswordResetSucceededImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PasswordResetSucceededImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetSucceededImpl>
    implements _$$PasswordResetSucceededImplCopyWith<$Res> {
  __$$PasswordResetSucceededImplCopyWithImpl(
      _$PasswordResetSucceededImpl _value,
      $Res Function(_$PasswordResetSucceededImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PasswordResetSucceededImpl implements _PasswordResetSucceeded {
  const _$PasswordResetSucceededImpl();

  @override
  String toString() {
    return 'AuthState.passwordResetSucceeded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetSucceededImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return passwordResetSucceeded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return passwordResetSucceeded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (passwordResetSucceeded != null) {
      return passwordResetSucceeded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return passwordResetSucceeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return passwordResetSucceeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (passwordResetSucceeded != null) {
      return passwordResetSucceeded(this);
    }
    return orElse();
  }
}

abstract class _PasswordResetSucceeded implements AuthState {
  const factory _PasswordResetSucceeded() = _$PasswordResetSucceededImpl;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$ErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'AuthState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthSession session) authenticated,
    required TResult Function(User user) registered,
    required TResult Function(String email) passwordResetSent,
    required TResult Function() passwordResetSucceeded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthSession session)? authenticated,
    TResult? Function(User user)? registered,
    TResult? Function(String email)? passwordResetSent,
    TResult? Function()? passwordResetSucceeded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthSession session)? authenticated,
    TResult Function(User user)? registered,
    TResult Function(String email)? passwordResetSent,
    TResult Function()? passwordResetSucceeded,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Registered value) registered,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_PasswordResetSucceeded value)
        passwordResetSucceeded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Registered value)? registered,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Registered value)? registered,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_PasswordResetSucceeded value)? passwordResetSucceeded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements AuthState {
  const factory _Error(final Failure failure) = _$ErrorImpl;

  Failure get failure;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
