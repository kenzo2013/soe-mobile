// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserDto _$UserDtoFromJson(Map<String, dynamic> json) {
  return _UserDto.fromJson(json);
}

/// @nodoc
mixin _$UserDto {
  String get id => throw _privateConstructorUsedError;
  UserAttributesDto get attributes => throw _privateConstructorUsedError;

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoCopyWith<UserDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoCopyWith<$Res> {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) then) =
      _$UserDtoCopyWithImpl<$Res, UserDto>;
  @useResult
  $Res call({String id, UserAttributesDto attributes});

  $UserAttributesDtoCopyWith<$Res> get attributes;
}

/// @nodoc
class _$UserDtoCopyWithImpl<$Res, $Val extends UserDto>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? attributes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as UserAttributesDto,
    ) as $Val);
  }

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserAttributesDtoCopyWith<$Res> get attributes {
    return $UserAttributesDtoCopyWith<$Res>(_value.attributes, (value) {
      return _then(_value.copyWith(attributes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserDtoImplCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$$UserDtoImplCopyWith(
          _$UserDtoImpl value, $Res Function(_$UserDtoImpl) then) =
      __$$UserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, UserAttributesDto attributes});

  @override
  $UserAttributesDtoCopyWith<$Res> get attributes;
}

/// @nodoc
class __$$UserDtoImplCopyWithImpl<$Res>
    extends _$UserDtoCopyWithImpl<$Res, _$UserDtoImpl>
    implements _$$UserDtoImplCopyWith<$Res> {
  __$$UserDtoImplCopyWithImpl(
      _$UserDtoImpl _value, $Res Function(_$UserDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? attributes = null,
  }) {
    return _then(_$UserDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as UserAttributesDto,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDtoImpl implements _UserDto {
  const _$UserDtoImpl({required this.id, required this.attributes});

  factory _$UserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoImplFromJson(json);

  @override
  final String id;
  @override
  final UserAttributesDto attributes;

  @override
  String toString() {
    return 'UserDto(id: $id, attributes: $attributes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.attributes, attributes) ||
                other.attributes == attributes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, attributes);

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      __$$UserDtoImplCopyWithImpl<_$UserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoImplToJson(
      this,
    );
  }
}

abstract class _UserDto implements UserDto {
  const factory _UserDto(
      {required final String id,
      required final UserAttributesDto attributes}) = _$UserDtoImpl;

  factory _UserDto.fromJson(Map<String, dynamic> json) = _$UserDtoImpl.fromJson;

  @override
  String get id;
  @override
  UserAttributesDto get attributes;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserAttributesDto _$UserAttributesDtoFromJson(Map<String, dynamic> json) {
  return _UserAttributesDto.fromJson(json);
}

/// @nodoc
mixin _$UserAttributesDto {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String? get civility => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get lang => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'multi_role')
  bool? get multiRole => throw _privateConstructorUsedError;

  /// Serializes this UserAttributesDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserAttributesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserAttributesDtoCopyWith<UserAttributesDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAttributesDtoCopyWith<$Res> {
  factory $UserAttributesDtoCopyWith(
          UserAttributesDto value, $Res Function(UserAttributesDto) then) =
      _$UserAttributesDtoCopyWithImpl<$Res, UserAttributesDto>;
  @useResult
  $Res call(
      {String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      String role,
      String? civility,
      String? phone,
      String? lang,
      String? status,
      String? reference,
      @JsonKey(name: 'full_name') String? fullName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'multi_role') bool? multiRole});
}

/// @nodoc
class _$UserAttributesDtoCopyWithImpl<$Res, $Val extends UserAttributesDto>
    implements $UserAttributesDtoCopyWith<$Res> {
  _$UserAttributesDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserAttributesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? civility = freezed,
    Object? phone = freezed,
    Object? lang = freezed,
    Object? status = freezed,
    Object? reference = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? multiRole = freezed,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      civility: freezed == civility
          ? _value.civility
          : civility // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      multiRole: freezed == multiRole
          ? _value.multiRole
          : multiRole // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserAttributesDtoImplCopyWith<$Res>
    implements $UserAttributesDtoCopyWith<$Res> {
  factory _$$UserAttributesDtoImplCopyWith(_$UserAttributesDtoImpl value,
          $Res Function(_$UserAttributesDtoImpl) then) =
      __$$UserAttributesDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String email,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      String role,
      String? civility,
      String? phone,
      String? lang,
      String? status,
      String? reference,
      @JsonKey(name: 'full_name') String? fullName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'multi_role') bool? multiRole});
}

/// @nodoc
class __$$UserAttributesDtoImplCopyWithImpl<$Res>
    extends _$UserAttributesDtoCopyWithImpl<$Res, _$UserAttributesDtoImpl>
    implements _$$UserAttributesDtoImplCopyWith<$Res> {
  __$$UserAttributesDtoImplCopyWithImpl(_$UserAttributesDtoImpl _value,
      $Res Function(_$UserAttributesDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserAttributesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? civility = freezed,
    Object? phone = freezed,
    Object? lang = freezed,
    Object? status = freezed,
    Object? reference = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? multiRole = freezed,
  }) {
    return _then(_$UserAttributesDtoImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      civility: freezed == civility
          ? _value.civility
          : civility // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      lang: freezed == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      multiRole: freezed == multiRole
          ? _value.multiRole
          : multiRole // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserAttributesDtoImpl implements _UserAttributesDto {
  const _$UserAttributesDtoImpl(
      {required this.email,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      required this.role,
      this.civility,
      this.phone,
      this.lang,
      this.status,
      this.reference,
      @JsonKey(name: 'full_name') this.fullName,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      @JsonKey(name: 'multi_role') this.multiRole});

  factory _$UserAttributesDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserAttributesDtoImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  final String role;
  @override
  final String? civility;
  @override
  final String? phone;
  @override
  final String? lang;
  @override
  final String? status;
  @override
  final String? reference;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'multi_role')
  final bool? multiRole;

  @override
  String toString() {
    return 'UserAttributesDto(email: $email, firstName: $firstName, lastName: $lastName, role: $role, civility: $civility, phone: $phone, lang: $lang, status: $status, reference: $reference, fullName: $fullName, avatarUrl: $avatarUrl, multiRole: $multiRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAttributesDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.civility, civility) ||
                other.civility == civility) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.multiRole, multiRole) ||
                other.multiRole == multiRole));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, firstName, lastName, role,
      civility, phone, lang, status, reference, fullName, avatarUrl, multiRole);

  /// Create a copy of UserAttributesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAttributesDtoImplCopyWith<_$UserAttributesDtoImpl> get copyWith =>
      __$$UserAttributesDtoImplCopyWithImpl<_$UserAttributesDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserAttributesDtoImplToJson(
      this,
    );
  }
}

abstract class _UserAttributesDto implements UserAttributesDto {
  const factory _UserAttributesDto(
          {required final String email,
          @JsonKey(name: 'first_name') required final String firstName,
          @JsonKey(name: 'last_name') required final String lastName,
          required final String role,
          final String? civility,
          final String? phone,
          final String? lang,
          final String? status,
          final String? reference,
          @JsonKey(name: 'full_name') final String? fullName,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          @JsonKey(name: 'multi_role') final bool? multiRole}) =
      _$UserAttributesDtoImpl;

  factory _UserAttributesDto.fromJson(Map<String, dynamic> json) =
      _$UserAttributesDtoImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  String get role;
  @override
  String? get civility;
  @override
  String? get phone;
  @override
  String? get lang;
  @override
  String? get status;
  @override
  String? get reference;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'multi_role')
  bool? get multiRole;

  /// Create a copy of UserAttributesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserAttributesDtoImplCopyWith<_$UserAttributesDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
