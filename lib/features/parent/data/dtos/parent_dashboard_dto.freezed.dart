// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_dashboard_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudentSummaryDto _$StudentSummaryDtoFromJson(Map<String, dynamic> json) {
  return _StudentSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$StudentSummaryDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'classe')
  String? get classe => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get section => throw _privateConstructorUsedError;
  List<String> get subjects => throw _privateConstructorUsedError;

  /// Serializes this StudentSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentSummaryDtoCopyWith<StudentSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentSummaryDtoCopyWith<$Res> {
  factory $StudentSummaryDtoCopyWith(
          StudentSummaryDto value, $Res Function(StudentSummaryDto) then) =
      _$StudentSummaryDtoCopyWithImpl<$Res, StudentSummaryDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'classe') String? classe,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? section,
      List<String> subjects});
}

/// @nodoc
class _$StudentSummaryDtoCopyWithImpl<$Res, $Val extends StudentSummaryDto>
    implements $StudentSummaryDtoCopyWith<$Res> {
  _$StudentSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? classe = freezed,
    Object? avatarUrl = freezed,
    Object? section = freezed,
    Object? subjects = null,
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
      classe: freezed == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      section: freezed == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudentSummaryDtoImplCopyWith<$Res>
    implements $StudentSummaryDtoCopyWith<$Res> {
  factory _$$StudentSummaryDtoImplCopyWith(_$StudentSummaryDtoImpl value,
          $Res Function(_$StudentSummaryDtoImpl) then) =
      __$$StudentSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      @JsonKey(name: 'classe') String? classe,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? section,
      List<String> subjects});
}

/// @nodoc
class __$$StudentSummaryDtoImplCopyWithImpl<$Res>
    extends _$StudentSummaryDtoCopyWithImpl<$Res, _$StudentSummaryDtoImpl>
    implements _$$StudentSummaryDtoImplCopyWith<$Res> {
  __$$StudentSummaryDtoImplCopyWithImpl(_$StudentSummaryDtoImpl _value,
      $Res Function(_$StudentSummaryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudentSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? classe = freezed,
    Object? avatarUrl = freezed,
    Object? section = freezed,
    Object? subjects = null,
  }) {
    return _then(_$StudentSummaryDtoImpl(
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
      classe: freezed == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      section: freezed == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentSummaryDtoImpl implements _StudentSummaryDto {
  const _$StudentSummaryDtoImpl(
      {required this.id,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      @JsonKey(name: 'classe') this.classe,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.section,
      final List<String> subjects = const <String>[]})
      : _subjects = subjects;

  factory _$StudentSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey(name: 'classe')
  final String? classe;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final String? section;
  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  String toString() {
    return 'StudentSummaryDto(id: $id, firstName: $firstName, lastName: $lastName, classe: $classe, avatarUrl: $avatarUrl, section: $section, subjects: $subjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.section, section) || other.section == section) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName, classe,
      avatarUrl, section, const DeepCollectionEquality().hash(_subjects));

  /// Create a copy of StudentSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentSummaryDtoImplCopyWith<_$StudentSummaryDtoImpl> get copyWith =>
      __$$StudentSummaryDtoImplCopyWithImpl<_$StudentSummaryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentSummaryDtoImplToJson(
      this,
    );
  }
}

abstract class _StudentSummaryDto implements StudentSummaryDto {
  const factory _StudentSummaryDto(
      {required final String id,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      @JsonKey(name: 'classe') final String? classe,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final String? section,
      final List<String> subjects}) = _$StudentSummaryDtoImpl;

  factory _StudentSummaryDto.fromJson(Map<String, dynamic> json) =
      _$StudentSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  @JsonKey(name: 'classe')
  String? get classe;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String? get section;
  @override
  List<String> get subjects;

  /// Create a copy of StudentSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentSummaryDtoImplCopyWith<_$StudentSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReservationSummaryDto _$ReservationSummaryDtoFromJson(
    Map<String, dynamic> json) {
  return _ReservationSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$ReservationSummaryDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference')
  String? get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_name')
  String? get childName => throw _privateConstructorUsedError;
  List<String> get subjects => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  int? get amount => throw _privateConstructorUsedError;

  /// Serializes this ReservationSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationSummaryDtoCopyWith<ReservationSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationSummaryDtoCopyWith<$Res> {
  factory $ReservationSummaryDtoCopyWith(ReservationSummaryDto value,
          $Res Function(ReservationSummaryDto) then) =
      _$ReservationSummaryDtoCopyWithImpl<$Res, ReservationSummaryDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'reference') String? reference,
      @JsonKey(name: 'status') String? status,
      @JsonKey(name: 'child_name') String? childName,
      List<String> subjects,
      @JsonKey(name: 'amount') int? amount});
}

/// @nodoc
class _$ReservationSummaryDtoCopyWithImpl<$Res,
        $Val extends ReservationSummaryDto>
    implements $ReservationSummaryDtoCopyWith<$Res> {
  _$ReservationSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? status = freezed,
    Object? childName = freezed,
    Object? subjects = null,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReservationSummaryDtoImplCopyWith<$Res>
    implements $ReservationSummaryDtoCopyWith<$Res> {
  factory _$$ReservationSummaryDtoImplCopyWith(
          _$ReservationSummaryDtoImpl value,
          $Res Function(_$ReservationSummaryDtoImpl) then) =
      __$$ReservationSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'reference') String? reference,
      @JsonKey(name: 'status') String? status,
      @JsonKey(name: 'child_name') String? childName,
      List<String> subjects,
      @JsonKey(name: 'amount') int? amount});
}

/// @nodoc
class __$$ReservationSummaryDtoImplCopyWithImpl<$Res>
    extends _$ReservationSummaryDtoCopyWithImpl<$Res,
        _$ReservationSummaryDtoImpl>
    implements _$$ReservationSummaryDtoImplCopyWith<$Res> {
  __$$ReservationSummaryDtoImplCopyWithImpl(_$ReservationSummaryDtoImpl _value,
      $Res Function(_$ReservationSummaryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? status = freezed,
    Object? childName = freezed,
    Object? subjects = null,
    Object? amount = freezed,
  }) {
    return _then(_$ReservationSummaryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationSummaryDtoImpl implements _ReservationSummaryDto {
  const _$ReservationSummaryDtoImpl(
      {required this.id,
      @JsonKey(name: 'reference') this.reference,
      @JsonKey(name: 'status') this.status,
      @JsonKey(name: 'child_name') this.childName,
      final List<String> subjects = const <String>[],
      @JsonKey(name: 'amount') this.amount})
      : _subjects = subjects;

  factory _$ReservationSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'reference')
  final String? reference;
  @override
  @JsonKey(name: 'status')
  final String? status;
  @override
  @JsonKey(name: 'child_name')
  final String? childName;
  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @JsonKey(name: 'amount')
  final int? amount;

  @override
  String toString() {
    return 'ReservationSummaryDto(id: $id, reference: $reference, status: $status, childName: $childName, subjects: $subjects, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, reference, status, childName,
      const DeepCollectionEquality().hash(_subjects), amount);

  /// Create a copy of ReservationSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationSummaryDtoImplCopyWith<_$ReservationSummaryDtoImpl>
      get copyWith => __$$ReservationSummaryDtoImplCopyWithImpl<
          _$ReservationSummaryDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationSummaryDtoImplToJson(
      this,
    );
  }
}

abstract class _ReservationSummaryDto implements ReservationSummaryDto {
  const factory _ReservationSummaryDto(
          {required final String id,
          @JsonKey(name: 'reference') final String? reference,
          @JsonKey(name: 'status') final String? status,
          @JsonKey(name: 'child_name') final String? childName,
          final List<String> subjects,
          @JsonKey(name: 'amount') final int? amount}) =
      _$ReservationSummaryDtoImpl;

  factory _ReservationSummaryDto.fromJson(Map<String, dynamic> json) =
      _$ReservationSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'reference')
  String? get reference;
  @override
  @JsonKey(name: 'status')
  String? get status;
  @override
  @JsonKey(name: 'child_name')
  String? get childName;
  @override
  List<String> get subjects;
  @override
  @JsonKey(name: 'amount')
  int? get amount;

  /// Create a copy of ReservationSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationSummaryDtoImplCopyWith<_$ReservationSummaryDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SessionSummaryDto _$SessionSummaryDtoFromJson(Map<String, dynamic> json) {
  return _SessionSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$SessionSummaryDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_at')
  String get startAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'subject')
  String? get subject => throw _privateConstructorUsedError;
  @JsonKey(name: 'tutor_name')
  String? get tutorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_name')
  String? get childName => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this SessionSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionSummaryDtoCopyWith<SessionSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionSummaryDtoCopyWith<$Res> {
  factory $SessionSummaryDtoCopyWith(
          SessionSummaryDto value, $Res Function(SessionSummaryDto) then) =
      _$SessionSummaryDtoCopyWithImpl<$Res, SessionSummaryDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String startAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      @JsonKey(name: 'subject') String? subject,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName,
      @JsonKey(name: 'status') String? status});
}

/// @nodoc
class _$SessionSummaryDtoCopyWithImpl<$Res, $Val extends SessionSummaryDto>
    implements $SessionSummaryDtoCopyWith<$Res> {
  _$SessionSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = null,
    Object? durationMinutes = null,
    Object? subject = freezed,
    Object? tutorName = freezed,
    Object? childName = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: null == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      subject: freezed == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String?,
      tutorName: freezed == tutorName
          ? _value.tutorName
          : tutorName // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionSummaryDtoImplCopyWith<$Res>
    implements $SessionSummaryDtoCopyWith<$Res> {
  factory _$$SessionSummaryDtoImplCopyWith(_$SessionSummaryDtoImpl value,
          $Res Function(_$SessionSummaryDtoImpl) then) =
      __$$SessionSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String startAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      @JsonKey(name: 'subject') String? subject,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName,
      @JsonKey(name: 'status') String? status});
}

/// @nodoc
class __$$SessionSummaryDtoImplCopyWithImpl<$Res>
    extends _$SessionSummaryDtoCopyWithImpl<$Res, _$SessionSummaryDtoImpl>
    implements _$$SessionSummaryDtoImplCopyWith<$Res> {
  __$$SessionSummaryDtoImplCopyWithImpl(_$SessionSummaryDtoImpl _value,
      $Res Function(_$SessionSummaryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = null,
    Object? durationMinutes = null,
    Object? subject = freezed,
    Object? tutorName = freezed,
    Object? childName = freezed,
    Object? status = freezed,
  }) {
    return _then(_$SessionSummaryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: null == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      subject: freezed == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String?,
      tutorName: freezed == tutorName
          ? _value.tutorName
          : tutorName // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionSummaryDtoImpl implements _SessionSummaryDto {
  const _$SessionSummaryDtoImpl(
      {required this.id,
      @JsonKey(name: 'start_at') required this.startAt,
      @JsonKey(name: 'duration_minutes') this.durationMinutes = 60,
      @JsonKey(name: 'subject') this.subject,
      @JsonKey(name: 'tutor_name') this.tutorName,
      @JsonKey(name: 'child_name') this.childName,
      @JsonKey(name: 'status') this.status});

  factory _$SessionSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'start_at')
  final String startAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'subject')
  final String? subject;
  @override
  @JsonKey(name: 'tutor_name')
  final String? tutorName;
  @override
  @JsonKey(name: 'child_name')
  final String? childName;
  @override
  @JsonKey(name: 'status')
  final String? status;

  @override
  String toString() {
    return 'SessionSummaryDto(id: $id, startAt: $startAt, durationMinutes: $durationMinutes, subject: $subject, tutorName: $tutorName, childName: $childName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.tutorName, tutorName) ||
                other.tutorName == tutorName) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startAt, durationMinutes,
      subject, tutorName, childName, status);

  /// Create a copy of SessionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionSummaryDtoImplCopyWith<_$SessionSummaryDtoImpl> get copyWith =>
      __$$SessionSummaryDtoImplCopyWithImpl<_$SessionSummaryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionSummaryDtoImplToJson(
      this,
    );
  }
}

abstract class _SessionSummaryDto implements SessionSummaryDto {
  const factory _SessionSummaryDto(
      {required final String id,
      @JsonKey(name: 'start_at') required final String startAt,
      @JsonKey(name: 'duration_minutes') final int durationMinutes,
      @JsonKey(name: 'subject') final String? subject,
      @JsonKey(name: 'tutor_name') final String? tutorName,
      @JsonKey(name: 'child_name') final String? childName,
      @JsonKey(name: 'status') final String? status}) = _$SessionSummaryDtoImpl;

  factory _SessionSummaryDto.fromJson(Map<String, dynamic> json) =
      _$SessionSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'start_at')
  String get startAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'subject')
  String? get subject;
  @override
  @JsonKey(name: 'tutor_name')
  String? get tutorName;
  @override
  @JsonKey(name: 'child_name')
  String? get childName;
  @override
  @JsonKey(name: 'status')
  String? get status;

  /// Create a copy of SessionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionSummaryDtoImplCopyWith<_$SessionSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentDashboardDto _$ParentDashboardDtoFromJson(Map<String, dynamic> json) {
  return _ParentDashboardDto.fromJson(json);
}

/// @nodoc
mixin _$ParentDashboardDto {
  List<StudentSummaryDto> get students => throw _privateConstructorUsedError;
  @JsonKey(name: 'today_sessions')
  List<SessionSummaryDto> get todaySessions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_reservations')
  List<ReservationSummaryDto> get recentReservations =>
      throw _privateConstructorUsedError;

  /// Serializes this ParentDashboardDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParentDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentDashboardDtoCopyWith<ParentDashboardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentDashboardDtoCopyWith<$Res> {
  factory $ParentDashboardDtoCopyWith(
          ParentDashboardDto value, $Res Function(ParentDashboardDto) then) =
      _$ParentDashboardDtoCopyWithImpl<$Res, ParentDashboardDto>;
  @useResult
  $Res call(
      {List<StudentSummaryDto> students,
      @JsonKey(name: 'today_sessions') List<SessionSummaryDto> todaySessions,
      @JsonKey(name: 'recent_reservations')
      List<ReservationSummaryDto> recentReservations});
}

/// @nodoc
class _$ParentDashboardDtoCopyWithImpl<$Res, $Val extends ParentDashboardDto>
    implements $ParentDashboardDtoCopyWith<$Res> {
  _$ParentDashboardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParentDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? todaySessions = null,
    Object? recentReservations = null,
  }) {
    return _then(_value.copyWith(
      students: null == students
          ? _value.students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentSummaryDto>,
      todaySessions: null == todaySessions
          ? _value.todaySessions
          : todaySessions // ignore: cast_nullable_to_non_nullable
              as List<SessionSummaryDto>,
      recentReservations: null == recentReservations
          ? _value.recentReservations
          : recentReservations // ignore: cast_nullable_to_non_nullable
              as List<ReservationSummaryDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParentDashboardDtoImplCopyWith<$Res>
    implements $ParentDashboardDtoCopyWith<$Res> {
  factory _$$ParentDashboardDtoImplCopyWith(_$ParentDashboardDtoImpl value,
          $Res Function(_$ParentDashboardDtoImpl) then) =
      __$$ParentDashboardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<StudentSummaryDto> students,
      @JsonKey(name: 'today_sessions') List<SessionSummaryDto> todaySessions,
      @JsonKey(name: 'recent_reservations')
      List<ReservationSummaryDto> recentReservations});
}

/// @nodoc
class __$$ParentDashboardDtoImplCopyWithImpl<$Res>
    extends _$ParentDashboardDtoCopyWithImpl<$Res, _$ParentDashboardDtoImpl>
    implements _$$ParentDashboardDtoImplCopyWith<$Res> {
  __$$ParentDashboardDtoImplCopyWithImpl(_$ParentDashboardDtoImpl _value,
      $Res Function(_$ParentDashboardDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ParentDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? students = null,
    Object? todaySessions = null,
    Object? recentReservations = null,
  }) {
    return _then(_$ParentDashboardDtoImpl(
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<StudentSummaryDto>,
      todaySessions: null == todaySessions
          ? _value._todaySessions
          : todaySessions // ignore: cast_nullable_to_non_nullable
              as List<SessionSummaryDto>,
      recentReservations: null == recentReservations
          ? _value._recentReservations
          : recentReservations // ignore: cast_nullable_to_non_nullable
              as List<ReservationSummaryDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentDashboardDtoImpl implements _ParentDashboardDto {
  const _$ParentDashboardDtoImpl(
      {final List<StudentSummaryDto> students = const <StudentSummaryDto>[],
      @JsonKey(name: 'today_sessions')
      final List<SessionSummaryDto> todaySessions = const <SessionSummaryDto>[],
      @JsonKey(name: 'recent_reservations')
      final List<ReservationSummaryDto> recentReservations =
          const <ReservationSummaryDto>[]})
      : _students = students,
        _todaySessions = todaySessions,
        _recentReservations = recentReservations;

  factory _$ParentDashboardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentDashboardDtoImplFromJson(json);

  final List<StudentSummaryDto> _students;
  @override
  @JsonKey()
  List<StudentSummaryDto> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  final List<SessionSummaryDto> _todaySessions;
  @override
  @JsonKey(name: 'today_sessions')
  List<SessionSummaryDto> get todaySessions {
    if (_todaySessions is EqualUnmodifiableListView) return _todaySessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaySessions);
  }

  final List<ReservationSummaryDto> _recentReservations;
  @override
  @JsonKey(name: 'recent_reservations')
  List<ReservationSummaryDto> get recentReservations {
    if (_recentReservations is EqualUnmodifiableListView)
      return _recentReservations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentReservations);
  }

  @override
  String toString() {
    return 'ParentDashboardDto(students: $students, todaySessions: $todaySessions, recentReservations: $recentReservations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentDashboardDtoImpl &&
            const DeepCollectionEquality().equals(other._students, _students) &&
            const DeepCollectionEquality()
                .equals(other._todaySessions, _todaySessions) &&
            const DeepCollectionEquality()
                .equals(other._recentReservations, _recentReservations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_students),
      const DeepCollectionEquality().hash(_todaySessions),
      const DeepCollectionEquality().hash(_recentReservations));

  /// Create a copy of ParentDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentDashboardDtoImplCopyWith<_$ParentDashboardDtoImpl> get copyWith =>
      __$$ParentDashboardDtoImplCopyWithImpl<_$ParentDashboardDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentDashboardDtoImplToJson(
      this,
    );
  }
}

abstract class _ParentDashboardDto implements ParentDashboardDto {
  const factory _ParentDashboardDto(
          {final List<StudentSummaryDto> students,
          @JsonKey(name: 'today_sessions')
          final List<SessionSummaryDto> todaySessions,
          @JsonKey(name: 'recent_reservations')
          final List<ReservationSummaryDto> recentReservations}) =
      _$ParentDashboardDtoImpl;

  factory _ParentDashboardDto.fromJson(Map<String, dynamic> json) =
      _$ParentDashboardDtoImpl.fromJson;

  @override
  List<StudentSummaryDto> get students;
  @override
  @JsonKey(name: 'today_sessions')
  List<SessionSummaryDto> get todaySessions;
  @override
  @JsonKey(name: 'recent_reservations')
  List<ReservationSummaryDto> get recentReservations;

  /// Create a copy of ParentDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentDashboardDtoImplCopyWith<_$ParentDashboardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
