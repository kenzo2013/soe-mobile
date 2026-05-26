// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChildDto _$ChildDtoFromJson(Map<String, dynamic> json) {
  return _ChildDto.fromJson(json);
}

/// @nodoc
mixin _$ChildDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'school_class')
  Map<String, dynamic>? get schoolClass => throw _privateConstructorUsedError;
  String? get section => throw _privateConstructorUsedError;
  String? get education => throw _privateConstructorUsedError;
  List<String> get subjects => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get address => throw _privateConstructorUsedError;

  /// Serializes this ChildDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChildDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildDtoCopyWith<ChildDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildDtoCopyWith<$Res> {
  factory $ChildDtoCopyWith(ChildDto value, $Res Function(ChildDto) then) =
      _$ChildDtoCopyWithImpl<$Res, ChildDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      int age,
      String? gender,
      @JsonKey(name: 'school_class') Map<String, dynamic>? schoolClass,
      String? section,
      String? education,
      List<String> subjects,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      Map<String, dynamic>? address});
}

/// @nodoc
class _$ChildDtoCopyWithImpl<$Res, $Val extends ChildDto>
    implements $ChildDtoCopyWith<$Res> {
  _$ChildDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? age = null,
    Object? gender = freezed,
    Object? schoolClass = freezed,
    Object? section = freezed,
    Object? education = freezed,
    Object? subjects = null,
    Object? avatarUrl = freezed,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      schoolClass: freezed == schoolClass
          ? _value.schoolClass
          : schoolClass // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      section: freezed == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChildDtoImplCopyWith<$Res>
    implements $ChildDtoCopyWith<$Res> {
  factory _$$ChildDtoImplCopyWith(
          _$ChildDtoImpl value, $Res Function(_$ChildDtoImpl) then) =
      __$$ChildDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      int age,
      String? gender,
      @JsonKey(name: 'school_class') Map<String, dynamic>? schoolClass,
      String? section,
      String? education,
      List<String> subjects,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      Map<String, dynamic>? address});
}

/// @nodoc
class __$$ChildDtoImplCopyWithImpl<$Res>
    extends _$ChildDtoCopyWithImpl<$Res, _$ChildDtoImpl>
    implements _$$ChildDtoImplCopyWith<$Res> {
  __$$ChildDtoImplCopyWithImpl(
      _$ChildDtoImpl _value, $Res Function(_$ChildDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChildDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? age = null,
    Object? gender = freezed,
    Object? schoolClass = freezed,
    Object? section = freezed,
    Object? education = freezed,
    Object? subjects = null,
    Object? avatarUrl = freezed,
    Object? address = freezed,
  }) {
    return _then(_$ChildDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      schoolClass: freezed == schoolClass
          ? _value._schoolClass
          : schoolClass // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      section: freezed == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value._address
          : address // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildDtoImpl implements _ChildDto {
  const _$ChildDtoImpl(
      {required this.id,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      this.age = 0,
      this.gender,
      @JsonKey(name: 'school_class') final Map<String, dynamic>? schoolClass,
      this.section,
      this.education,
      final List<String> subjects = const <String>[],
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      final Map<String, dynamic>? address})
      : _schoolClass = schoolClass,
        _subjects = subjects,
        _address = address;

  factory _$ChildDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey()
  final int age;
  @override
  final String? gender;
  final Map<String, dynamic>? _schoolClass;
  @override
  @JsonKey(name: 'school_class')
  Map<String, dynamic>? get schoolClass {
    final value = _schoolClass;
    if (value == null) return null;
    if (_schoolClass is EqualUnmodifiableMapView) return _schoolClass;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? section;
  @override
  final String? education;
  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final Map<String, dynamic>? _address;
  @override
  Map<String, dynamic>? get address {
    final value = _address;
    if (value == null) return null;
    if (_address is EqualUnmodifiableMapView) return _address;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChildDto(id: $id, firstName: $firstName, lastName: $lastName, age: $age, gender: $gender, schoolClass: $schoolClass, section: $section, education: $education, subjects: $subjects, avatarUrl: $avatarUrl, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            const DeepCollectionEquality()
                .equals(other._schoolClass, _schoolClass) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.education, education) ||
                other.education == education) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(other._address, _address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      age,
      gender,
      const DeepCollectionEquality().hash(_schoolClass),
      section,
      education,
      const DeepCollectionEquality().hash(_subjects),
      avatarUrl,
      const DeepCollectionEquality().hash(_address));

  /// Create a copy of ChildDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildDtoImplCopyWith<_$ChildDtoImpl> get copyWith =>
      __$$ChildDtoImplCopyWithImpl<_$ChildDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildDtoImplToJson(
      this,
    );
  }
}

abstract class _ChildDto implements ChildDto {
  const factory _ChildDto(
      {required final String id,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      final int age,
      final String? gender,
      @JsonKey(name: 'school_class') final Map<String, dynamic>? schoolClass,
      final String? section,
      final String? education,
      final List<String> subjects,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final Map<String, dynamic>? address}) = _$ChildDtoImpl;

  factory _ChildDto.fromJson(Map<String, dynamic> json) =
      _$ChildDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  int get age;
  @override
  String? get gender;
  @override
  @JsonKey(name: 'school_class')
  Map<String, dynamic>? get schoolClass;
  @override
  String? get section;
  @override
  String? get education;
  @override
  List<String> get subjects;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  Map<String, dynamic>? get address;

  /// Create a copy of ChildDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildDtoImplCopyWith<_$ChildDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
