// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_course_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorActiveCourseDto _$TutorActiveCourseDtoFromJson(Map<String, dynamic> json) {
  return _TutorActiveCourseDto.fromJson(json);
}

/// @nodoc
mixin _$TutorActiveCourseDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reference)
  String get reference => throw _privateConstructorUsedError;
  @JsonKey(readValue: _studentId)
  String? get studentId => throw _privateConstructorUsedError;
  @JsonKey(readValue: _student)
  String get student => throw _privateConstructorUsedError;
  @JsonKey(readValue: _classe)
  String get classe => throw _privateConstructorUsedError;
  @JsonKey(readValue: _courseSubjects)
  List<dynamic> get subjects => throw _privateConstructorUsedError;
  @JsonKey(readValue: _schedule)
  String get schedule => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TutorActiveCourseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorActiveCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorActiveCourseDtoCopyWith<TutorActiveCourseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorActiveCourseDtoCopyWith<$Res> {
  factory $TutorActiveCourseDtoCopyWith(TutorActiveCourseDto value,
          $Res Function(TutorActiveCourseDto) then) =
      _$TutorActiveCourseDtoCopyWithImpl<$Res, TutorActiveCourseDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _reference) String reference,
      @JsonKey(readValue: _studentId) String? studentId,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(readValue: _courseSubjects) List<dynamic> subjects,
      @JsonKey(readValue: _schedule) String schedule,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$TutorActiveCourseDtoCopyWithImpl<$Res,
        $Val extends TutorActiveCourseDto>
    implements $TutorActiveCourseDtoCopyWith<$Res> {
  _$TutorActiveCourseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorActiveCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? studentId = freezed,
    Object? student = null,
    Object? classe = null,
    Object? subjects = null,
    Object? schedule = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: freezed == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String?,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorActiveCourseDtoImplCopyWith<$Res>
    implements $TutorActiveCourseDtoCopyWith<$Res> {
  factory _$$TutorActiveCourseDtoImplCopyWith(_$TutorActiveCourseDtoImpl value,
          $Res Function(_$TutorActiveCourseDtoImpl) then) =
      __$$TutorActiveCourseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _reference) String reference,
      @JsonKey(readValue: _studentId) String? studentId,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(readValue: _courseSubjects) List<dynamic> subjects,
      @JsonKey(readValue: _schedule) String schedule,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$TutorActiveCourseDtoImplCopyWithImpl<$Res>
    extends _$TutorActiveCourseDtoCopyWithImpl<$Res, _$TutorActiveCourseDtoImpl>
    implements _$$TutorActiveCourseDtoImplCopyWith<$Res> {
  __$$TutorActiveCourseDtoImplCopyWithImpl(_$TutorActiveCourseDtoImpl _value,
      $Res Function(_$TutorActiveCourseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorActiveCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? studentId = freezed,
    Object? student = null,
    Object? classe = null,
    Object? subjects = null,
    Object? schedule = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$TutorActiveCourseDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: freezed == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String?,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorActiveCourseDtoImpl implements _TutorActiveCourseDto {
  const _$TutorActiveCourseDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _reference) this.reference = '',
      @JsonKey(readValue: _studentId) this.studentId,
      @JsonKey(readValue: _student) this.student = '',
      @JsonKey(readValue: _classe) this.classe = '',
      @JsonKey(readValue: _courseSubjects)
      final List<dynamic> subjects = const <dynamic>[],
      @JsonKey(readValue: _schedule) this.schedule = '',
      @JsonKey(name: 'created_at') this.createdAt})
      : _subjects = subjects;

  factory _$TutorActiveCourseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorActiveCourseDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _reference)
  final String reference;
  @override
  @JsonKey(readValue: _studentId)
  final String? studentId;
  @override
  @JsonKey(readValue: _student)
  final String student;
  @override
  @JsonKey(readValue: _classe)
  final String classe;
  final List<dynamic> _subjects;
  @override
  @JsonKey(readValue: _courseSubjects)
  List<dynamic> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @JsonKey(readValue: _schedule)
  final String schedule;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'TutorActiveCourseDto(id: $id, reference: $reference, studentId: $studentId, student: $student, classe: $classe, subjects: $subjects, schedule: $schedule, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorActiveCourseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reference,
      studentId,
      student,
      classe,
      const DeepCollectionEquality().hash(_subjects),
      schedule,
      createdAt);

  /// Create a copy of TutorActiveCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorActiveCourseDtoImplCopyWith<_$TutorActiveCourseDtoImpl>
      get copyWith =>
          __$$TutorActiveCourseDtoImplCopyWithImpl<_$TutorActiveCourseDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorActiveCourseDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorActiveCourseDto implements TutorActiveCourseDto {
  const factory _TutorActiveCourseDto(
          {final String id,
          @JsonKey(readValue: _reference) final String reference,
          @JsonKey(readValue: _studentId) final String? studentId,
          @JsonKey(readValue: _student) final String student,
          @JsonKey(readValue: _classe) final String classe,
          @JsonKey(readValue: _courseSubjects) final List<dynamic> subjects,
          @JsonKey(readValue: _schedule) final String schedule,
          @JsonKey(name: 'created_at') final String? createdAt}) =
      _$TutorActiveCourseDtoImpl;

  factory _TutorActiveCourseDto.fromJson(Map<String, dynamic> json) =
      _$TutorActiveCourseDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _reference)
  String get reference;
  @override
  @JsonKey(readValue: _studentId)
  String? get studentId;
  @override
  @JsonKey(readValue: _student)
  String get student;
  @override
  @JsonKey(readValue: _classe)
  String get classe;
  @override
  @JsonKey(readValue: _courseSubjects)
  List<dynamic> get subjects;
  @override
  @JsonKey(readValue: _schedule)
  String get schedule;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of TutorActiveCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorActiveCourseDtoImplCopyWith<_$TutorActiveCourseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TutorCourseSlotDto _$TutorCourseSlotDtoFromJson(Map<String, dynamic> json) {
  return _TutorCourseSlotDto.fromJson(json);
}

/// @nodoc
mixin _$TutorCourseSlotDto {
  String get day => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_range')
  String? get timeRange => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;

  /// Serializes this TutorCourseSlotDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorCourseSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorCourseSlotDtoCopyWith<TutorCourseSlotDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorCourseSlotDtoCopyWith<$Res> {
  factory $TutorCourseSlotDtoCopyWith(
          TutorCourseSlotDto value, $Res Function(TutorCourseSlotDto) then) =
      _$TutorCourseSlotDtoCopyWithImpl<$Res, TutorCourseSlotDto>;
  @useResult
  $Res call(
      {String day,
      @JsonKey(name: 'time_range') String? timeRange,
      String subject});
}

/// @nodoc
class _$TutorCourseSlotDtoCopyWithImpl<$Res, $Val extends TutorCourseSlotDto>
    implements $TutorCourseSlotDtoCopyWith<$Res> {
  _$TutorCourseSlotDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorCourseSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? timeRange = freezed,
    Object? subject = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorCourseSlotDtoImplCopyWith<$Res>
    implements $TutorCourseSlotDtoCopyWith<$Res> {
  factory _$$TutorCourseSlotDtoImplCopyWith(_$TutorCourseSlotDtoImpl value,
          $Res Function(_$TutorCourseSlotDtoImpl) then) =
      __$$TutorCourseSlotDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String day,
      @JsonKey(name: 'time_range') String? timeRange,
      String subject});
}

/// @nodoc
class __$$TutorCourseSlotDtoImplCopyWithImpl<$Res>
    extends _$TutorCourseSlotDtoCopyWithImpl<$Res, _$TutorCourseSlotDtoImpl>
    implements _$$TutorCourseSlotDtoImplCopyWith<$Res> {
  __$$TutorCourseSlotDtoImplCopyWithImpl(_$TutorCourseSlotDtoImpl _value,
      $Res Function(_$TutorCourseSlotDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorCourseSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? timeRange = freezed,
    Object? subject = null,
  }) {
    return _then(_$TutorCourseSlotDtoImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorCourseSlotDtoImpl implements _TutorCourseSlotDto {
  const _$TutorCourseSlotDtoImpl(
      {this.day = '',
      @JsonKey(name: 'time_range') this.timeRange,
      this.subject = ''});

  factory _$TutorCourseSlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorCourseSlotDtoImplFromJson(json);

  @override
  @JsonKey()
  final String day;
  @override
  @JsonKey(name: 'time_range')
  final String? timeRange;
  @override
  @JsonKey()
  final String subject;

  @override
  String toString() {
    return 'TutorCourseSlotDto(day: $day, timeRange: $timeRange, subject: $subject)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorCourseSlotDtoImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.timeRange, timeRange) ||
                other.timeRange == timeRange) &&
            (identical(other.subject, subject) || other.subject == subject));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, day, timeRange, subject);

  /// Create a copy of TutorCourseSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorCourseSlotDtoImplCopyWith<_$TutorCourseSlotDtoImpl> get copyWith =>
      __$$TutorCourseSlotDtoImplCopyWithImpl<_$TutorCourseSlotDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorCourseSlotDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorCourseSlotDto implements TutorCourseSlotDto {
  const factory _TutorCourseSlotDto(
      {final String day,
      @JsonKey(name: 'time_range') final String? timeRange,
      final String subject}) = _$TutorCourseSlotDtoImpl;

  factory _TutorCourseSlotDto.fromJson(Map<String, dynamic> json) =
      _$TutorCourseSlotDtoImpl.fromJson;

  @override
  String get day;
  @override
  @JsonKey(name: 'time_range')
  String? get timeRange;
  @override
  String get subject;

  /// Create a copy of TutorCourseSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorCourseSlotDtoImplCopyWith<_$TutorCourseSlotDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorCourseDetailDto _$TutorCourseDetailDtoFromJson(Map<String, dynamic> json) {
  return _TutorCourseDetailDto.fromJson(json);
}

/// @nodoc
mixin _$TutorCourseDetailDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _student)
  String get student => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(readValue: _classe)
  String get classe => throw _privateConstructorUsedError;
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects => throw _privateConstructorUsedError;
  List<TutorCourseSlotDto> get slots => throw _privateConstructorUsedError;

  /// Serializes this TutorCourseDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorCourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorCourseDetailDtoCopyWith<TutorCourseDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorCourseDetailDtoCopyWith<$Res> {
  factory $TutorCourseDetailDtoCopyWith(TutorCourseDetailDto value,
          $Res Function(TutorCourseDetailDto) then) =
      _$TutorCourseDetailDtoCopyWithImpl<$Res, TutorCourseDetailDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _student) String student,
      int age,
      String gender,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(name: 'subjects') List<dynamic> subjects,
      List<TutorCourseSlotDto> slots});
}

/// @nodoc
class _$TutorCourseDetailDtoCopyWithImpl<$Res,
        $Val extends TutorCourseDetailDto>
    implements $TutorCourseDetailDtoCopyWith<$Res> {
  _$TutorCourseDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorCourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? student = null,
    Object? age = null,
    Object? gender = null,
    Object? classe = null,
    Object? subjects = null,
    Object? slots = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<TutorCourseSlotDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorCourseDetailDtoImplCopyWith<$Res>
    implements $TutorCourseDetailDtoCopyWith<$Res> {
  factory _$$TutorCourseDetailDtoImplCopyWith(_$TutorCourseDetailDtoImpl value,
          $Res Function(_$TutorCourseDetailDtoImpl) then) =
      __$$TutorCourseDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _student) String student,
      int age,
      String gender,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(name: 'subjects') List<dynamic> subjects,
      List<TutorCourseSlotDto> slots});
}

/// @nodoc
class __$$TutorCourseDetailDtoImplCopyWithImpl<$Res>
    extends _$TutorCourseDetailDtoCopyWithImpl<$Res, _$TutorCourseDetailDtoImpl>
    implements _$$TutorCourseDetailDtoImplCopyWith<$Res> {
  __$$TutorCourseDetailDtoImplCopyWithImpl(_$TutorCourseDetailDtoImpl _value,
      $Res Function(_$TutorCourseDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorCourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? student = null,
    Object? age = null,
    Object? gender = null,
    Object? classe = null,
    Object? subjects = null,
    Object? slots = null,
  }) {
    return _then(_$TutorCourseDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<TutorCourseSlotDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorCourseDetailDtoImpl implements _TutorCourseDetailDto {
  const _$TutorCourseDetailDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _student) this.student = '',
      this.age = 0,
      this.gender = '',
      @JsonKey(readValue: _classe) this.classe = '',
      @JsonKey(name: 'subjects')
      final List<dynamic> subjects = const <dynamic>[],
      final List<TutorCourseSlotDto> slots = const <TutorCourseSlotDto>[]})
      : _subjects = subjects,
        _slots = slots;

  factory _$TutorCourseDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorCourseDetailDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _student)
  final String student;
  @override
  @JsonKey()
  final int age;
  @override
  @JsonKey()
  final String gender;
  @override
  @JsonKey(readValue: _classe)
  final String classe;
  final List<dynamic> _subjects;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  final List<TutorCourseSlotDto> _slots;
  @override
  @JsonKey()
  List<TutorCourseSlotDto> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  String toString() {
    return 'TutorCourseDetailDto(id: $id, student: $student, age: $age, gender: $gender, classe: $classe, subjects: $subjects, slots: $slots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorCourseDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      student,
      age,
      gender,
      classe,
      const DeepCollectionEquality().hash(_subjects),
      const DeepCollectionEquality().hash(_slots));

  /// Create a copy of TutorCourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorCourseDetailDtoImplCopyWith<_$TutorCourseDetailDtoImpl>
      get copyWith =>
          __$$TutorCourseDetailDtoImplCopyWithImpl<_$TutorCourseDetailDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorCourseDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorCourseDetailDto implements TutorCourseDetailDto {
  const factory _TutorCourseDetailDto(
      {final String id,
      @JsonKey(readValue: _student) final String student,
      final int age,
      final String gender,
      @JsonKey(readValue: _classe) final String classe,
      @JsonKey(name: 'subjects') final List<dynamic> subjects,
      final List<TutorCourseSlotDto> slots}) = _$TutorCourseDetailDtoImpl;

  factory _TutorCourseDetailDto.fromJson(Map<String, dynamic> json) =
      _$TutorCourseDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _student)
  String get student;
  @override
  int get age;
  @override
  String get gender;
  @override
  @JsonKey(readValue: _classe)
  String get classe;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects;
  @override
  List<TutorCourseSlotDto> get slots;

  /// Create a copy of TutorCourseDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorCourseDetailDtoImplCopyWith<_$TutorCourseDetailDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
