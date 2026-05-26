// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) {
  return _LoginResponseDto.fromJson(json);
}

/// @nodoc
mixin _$LoginResponseDto {
  UserDto get data => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;

  /// Serializes this LoginResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseDtoCopyWith<LoginResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseDtoCopyWith<$Res> {
  factory $LoginResponseDtoCopyWith(
          LoginResponseDto value, $Res Function(LoginResponseDto) then) =
      _$LoginResponseDtoCopyWithImpl<$Res, LoginResponseDto>;
  @useResult
  $Res call({UserDto data, String accessToken});

  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class _$LoginResponseDtoCopyWithImpl<$Res, $Val extends LoginResponseDto>
    implements $LoginResponseDtoCopyWith<$Res> {
  _$LoginResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? accessToken = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoCopyWith<$Res> get data {
    return $UserDtoCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseDtoImplCopyWith<$Res>
    implements $LoginResponseDtoCopyWith<$Res> {
  factory _$$LoginResponseDtoImplCopyWith(_$LoginResponseDtoImpl value,
          $Res Function(_$LoginResponseDtoImpl) then) =
      __$$LoginResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserDto data, String accessToken});

  @override
  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class __$$LoginResponseDtoImplCopyWithImpl<$Res>
    extends _$LoginResponseDtoCopyWithImpl<$Res, _$LoginResponseDtoImpl>
    implements _$$LoginResponseDtoImplCopyWith<$Res> {
  __$$LoginResponseDtoImplCopyWithImpl(_$LoginResponseDtoImpl _value,
      $Res Function(_$LoginResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? accessToken = null,
  }) {
    return _then(_$LoginResponseDtoImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseDtoImpl implements _LoginResponseDto {
  const _$LoginResponseDtoImpl({required this.data, required this.accessToken});

  factory _$LoginResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseDtoImplFromJson(json);

  @override
  final UserDto data;
  @override
  final String accessToken;

  @override
  String toString() {
    return 'LoginResponseDto(data: $data, accessToken: $accessToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseDtoImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data, accessToken);

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseDtoImplCopyWith<_$LoginResponseDtoImpl> get copyWith =>
      __$$LoginResponseDtoImplCopyWithImpl<_$LoginResponseDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _LoginResponseDto implements LoginResponseDto {
  const factory _LoginResponseDto(
      {required final UserDto data,
      required final String accessToken}) = _$LoginResponseDtoImpl;

  factory _LoginResponseDto.fromJson(Map<String, dynamic> json) =
      _$LoginResponseDtoImpl.fromJson;

  @override
  UserDto get data;
  @override
  String get accessToken;

  /// Create a copy of LoginResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseDtoImplCopyWith<_$LoginResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterResponseDto _$RegisterResponseDtoFromJson(Map<String, dynamic> json) {
  return _RegisterResponseDto.fromJson(json);
}

/// @nodoc
mixin _$RegisterResponseDto {
  UserDto get data => throw _privateConstructorUsedError;

  /// Serializes this RegisterResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterResponseDtoCopyWith<RegisterResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterResponseDtoCopyWith<$Res> {
  factory $RegisterResponseDtoCopyWith(
          RegisterResponseDto value, $Res Function(RegisterResponseDto) then) =
      _$RegisterResponseDtoCopyWithImpl<$Res, RegisterResponseDto>;
  @useResult
  $Res call({UserDto data});

  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class _$RegisterResponseDtoCopyWithImpl<$Res, $Val extends RegisterResponseDto>
    implements $RegisterResponseDtoCopyWith<$Res> {
  _$RegisterResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
    ) as $Val);
  }

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoCopyWith<$Res> get data {
    return $UserDtoCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RegisterResponseDtoImplCopyWith<$Res>
    implements $RegisterResponseDtoCopyWith<$Res> {
  factory _$$RegisterResponseDtoImplCopyWith(_$RegisterResponseDtoImpl value,
          $Res Function(_$RegisterResponseDtoImpl) then) =
      __$$RegisterResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserDto data});

  @override
  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class __$$RegisterResponseDtoImplCopyWithImpl<$Res>
    extends _$RegisterResponseDtoCopyWithImpl<$Res, _$RegisterResponseDtoImpl>
    implements _$$RegisterResponseDtoImplCopyWith<$Res> {
  __$$RegisterResponseDtoImplCopyWithImpl(_$RegisterResponseDtoImpl _value,
      $Res Function(_$RegisterResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$RegisterResponseDtoImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterResponseDtoImpl implements _RegisterResponseDto {
  const _$RegisterResponseDtoImpl({required this.data});

  factory _$RegisterResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterResponseDtoImplFromJson(json);

  @override
  final UserDto data;

  @override
  String toString() {
    return 'RegisterResponseDto(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterResponseDtoImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterResponseDtoImplCopyWith<_$RegisterResponseDtoImpl> get copyWith =>
      __$$RegisterResponseDtoImplCopyWithImpl<_$RegisterResponseDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _RegisterResponseDto implements RegisterResponseDto {
  const factory _RegisterResponseDto({required final UserDto data}) =
      _$RegisterResponseDtoImpl;

  factory _RegisterResponseDto.fromJson(Map<String, dynamic> json) =
      _$RegisterResponseDtoImpl.fromJson;

  @override
  UserDto get data;

  /// Create a copy of RegisterResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterResponseDtoImplCopyWith<_$RegisterResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfirmationResponseDto _$ConfirmationResponseDtoFromJson(
    Map<String, dynamic> json) {
  return _ConfirmationResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ConfirmationResponseDto {
  UserDto get data => throw _privateConstructorUsedError;

  /// Serializes this ConfirmationResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfirmationResponseDtoCopyWith<ConfirmationResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfirmationResponseDtoCopyWith<$Res> {
  factory $ConfirmationResponseDtoCopyWith(ConfirmationResponseDto value,
          $Res Function(ConfirmationResponseDto) then) =
      _$ConfirmationResponseDtoCopyWithImpl<$Res, ConfirmationResponseDto>;
  @useResult
  $Res call({UserDto data});

  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class _$ConfirmationResponseDtoCopyWithImpl<$Res,
        $Val extends ConfirmationResponseDto>
    implements $ConfirmationResponseDtoCopyWith<$Res> {
  _$ConfirmationResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
    ) as $Val);
  }

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoCopyWith<$Res> get data {
    return $UserDtoCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConfirmationResponseDtoImplCopyWith<$Res>
    implements $ConfirmationResponseDtoCopyWith<$Res> {
  factory _$$ConfirmationResponseDtoImplCopyWith(
          _$ConfirmationResponseDtoImpl value,
          $Res Function(_$ConfirmationResponseDtoImpl) then) =
      __$$ConfirmationResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserDto data});

  @override
  $UserDtoCopyWith<$Res> get data;
}

/// @nodoc
class __$$ConfirmationResponseDtoImplCopyWithImpl<$Res>
    extends _$ConfirmationResponseDtoCopyWithImpl<$Res,
        _$ConfirmationResponseDtoImpl>
    implements _$$ConfirmationResponseDtoImplCopyWith<$Res> {
  __$$ConfirmationResponseDtoImplCopyWithImpl(
      _$ConfirmationResponseDtoImpl _value,
      $Res Function(_$ConfirmationResponseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$ConfirmationResponseDtoImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfirmationResponseDtoImpl implements _ConfirmationResponseDto {
  const _$ConfirmationResponseDtoImpl({required this.data});

  factory _$ConfirmationResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfirmationResponseDtoImplFromJson(json);

  @override
  final UserDto data;

  @override
  String toString() {
    return 'ConfirmationResponseDto(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfirmationResponseDtoImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfirmationResponseDtoImplCopyWith<_$ConfirmationResponseDtoImpl>
      get copyWith => __$$ConfirmationResponseDtoImplCopyWithImpl<
          _$ConfirmationResponseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfirmationResponseDtoImplToJson(
      this,
    );
  }
}

abstract class _ConfirmationResponseDto implements ConfirmationResponseDto {
  const factory _ConfirmationResponseDto({required final UserDto data}) =
      _$ConfirmationResponseDtoImpl;

  factory _ConfirmationResponseDto.fromJson(Map<String, dynamic> json) =
      _$ConfirmationResponseDtoImpl.fromJson;

  @override
  UserDto get data;

  /// Create a copy of ConfirmationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfirmationResponseDtoImplCopyWith<_$ConfirmationResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
