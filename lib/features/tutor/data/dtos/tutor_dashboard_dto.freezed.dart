// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_dashboard_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorStatsDto _$TutorStatsDtoFromJson(Map<String, dynamic> json) {
  return _TutorStatsDto.fromJson(json);
}

/// @nodoc
mixin _$TutorStatsDto {
  @JsonKey(name: 'total_students')
  int get totalStudents => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_sessions')
  int get totalSessions => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_sessions')
  int get pendingSessions => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_sessions')
  int get completedSessions => throw _privateConstructorUsedError;

  /// Serializes this TutorStatsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorStatsDtoCopyWith<TutorStatsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorStatsDtoCopyWith<$Res> {
  factory $TutorStatsDtoCopyWith(
          TutorStatsDto value, $Res Function(TutorStatsDto) then) =
      _$TutorStatsDtoCopyWithImpl<$Res, TutorStatsDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_students') int totalStudents,
      @JsonKey(name: 'total_sessions') int totalSessions,
      @JsonKey(name: 'pending_sessions') int pendingSessions,
      @JsonKey(name: 'completed_sessions') int completedSessions});
}

/// @nodoc
class _$TutorStatsDtoCopyWithImpl<$Res, $Val extends TutorStatsDto>
    implements $TutorStatsDtoCopyWith<$Res> {
  _$TutorStatsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalStudents = null,
    Object? totalSessions = null,
    Object? pendingSessions = null,
    Object? completedSessions = null,
  }) {
    return _then(_value.copyWith(
      totalStudents: null == totalStudents
          ? _value.totalStudents
          : totalStudents // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessions: null == totalSessions
          ? _value.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      pendingSessions: null == pendingSessions
          ? _value.pendingSessions
          : pendingSessions // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorStatsDtoImplCopyWith<$Res>
    implements $TutorStatsDtoCopyWith<$Res> {
  factory _$$TutorStatsDtoImplCopyWith(
          _$TutorStatsDtoImpl value, $Res Function(_$TutorStatsDtoImpl) then) =
      __$$TutorStatsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_students') int totalStudents,
      @JsonKey(name: 'total_sessions') int totalSessions,
      @JsonKey(name: 'pending_sessions') int pendingSessions,
      @JsonKey(name: 'completed_sessions') int completedSessions});
}

/// @nodoc
class __$$TutorStatsDtoImplCopyWithImpl<$Res>
    extends _$TutorStatsDtoCopyWithImpl<$Res, _$TutorStatsDtoImpl>
    implements _$$TutorStatsDtoImplCopyWith<$Res> {
  __$$TutorStatsDtoImplCopyWithImpl(
      _$TutorStatsDtoImpl _value, $Res Function(_$TutorStatsDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalStudents = null,
    Object? totalSessions = null,
    Object? pendingSessions = null,
    Object? completedSessions = null,
  }) {
    return _then(_$TutorStatsDtoImpl(
      totalStudents: null == totalStudents
          ? _value.totalStudents
          : totalStudents // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessions: null == totalSessions
          ? _value.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      pendingSessions: null == pendingSessions
          ? _value.pendingSessions
          : pendingSessions // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorStatsDtoImpl implements _TutorStatsDto {
  const _$TutorStatsDtoImpl(
      {@JsonKey(name: 'total_students') this.totalStudents = 0,
      @JsonKey(name: 'total_sessions') this.totalSessions = 0,
      @JsonKey(name: 'pending_sessions') this.pendingSessions = 0,
      @JsonKey(name: 'completed_sessions') this.completedSessions = 0});

  factory _$TutorStatsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorStatsDtoImplFromJson(json);

  @override
  @JsonKey(name: 'total_students')
  final int totalStudents;
  @override
  @JsonKey(name: 'total_sessions')
  final int totalSessions;
  @override
  @JsonKey(name: 'pending_sessions')
  final int pendingSessions;
  @override
  @JsonKey(name: 'completed_sessions')
  final int completedSessions;

  @override
  String toString() {
    return 'TutorStatsDto(totalStudents: $totalStudents, totalSessions: $totalSessions, pendingSessions: $pendingSessions, completedSessions: $completedSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorStatsDtoImpl &&
            (identical(other.totalStudents, totalStudents) ||
                other.totalStudents == totalStudents) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.pendingSessions, pendingSessions) ||
                other.pendingSessions == pendingSessions) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalStudents, totalSessions,
      pendingSessions, completedSessions);

  /// Create a copy of TutorStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorStatsDtoImplCopyWith<_$TutorStatsDtoImpl> get copyWith =>
      __$$TutorStatsDtoImplCopyWithImpl<_$TutorStatsDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorStatsDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorStatsDto implements TutorStatsDto {
  const factory _TutorStatsDto(
          {@JsonKey(name: 'total_students') final int totalStudents,
          @JsonKey(name: 'total_sessions') final int totalSessions,
          @JsonKey(name: 'pending_sessions') final int pendingSessions,
          @JsonKey(name: 'completed_sessions') final int completedSessions}) =
      _$TutorStatsDtoImpl;

  factory _TutorStatsDto.fromJson(Map<String, dynamic> json) =
      _$TutorStatsDtoImpl.fromJson;

  @override
  @JsonKey(name: 'total_students')
  int get totalStudents;
  @override
  @JsonKey(name: 'total_sessions')
  int get totalSessions;
  @override
  @JsonKey(name: 'pending_sessions')
  int get pendingSessions;
  @override
  @JsonKey(name: 'completed_sessions')
  int get completedSessions;

  /// Create a copy of TutorStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorStatsDtoImplCopyWith<_$TutorStatsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorTodaySessionDto _$TutorTodaySessionDtoFromJson(Map<String, dynamic> json) {
  return _TutorTodaySessionDto.fromJson(json);
}

/// @nodoc
mixin _$TutorTodaySessionDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_at')
  String? get startAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_at')
  String? get endAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_range')
  String? get timeRange => throw _privateConstructorUsedError;
  String? get student => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_name')
  String? get studentName => throw _privateConstructorUsedError;
  String get classe => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this TutorTodaySessionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorTodaySessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorTodaySessionDtoCopyWith<TutorTodaySessionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorTodaySessionDtoCopyWith<$Res> {
  factory $TutorTodaySessionDtoCopyWith(TutorTodaySessionDto value,
          $Res Function(TutorTodaySessionDto) then) =
      _$TutorTodaySessionDtoCopyWithImpl<$Res, TutorTodaySessionDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String? startAt,
      @JsonKey(name: 'end_at') String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(name: 'time_range') String? timeRange,
      String? student,
      @JsonKey(name: 'student_name') String? studentName,
      String classe,
      String subject,
      String address,
      String? location,
      String status});
}

/// @nodoc
class _$TutorTodaySessionDtoCopyWithImpl<$Res,
        $Val extends TutorTodaySessionDto>
    implements $TutorTodaySessionDtoCopyWith<$Res> {
  _$TutorTodaySessionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorTodaySessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? timeRange = freezed,
    Object? student = freezed,
    Object? studentName = freezed,
    Object? classe = null,
    Object? subject = null,
    Object? address = null,
    Object? location = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: freezed == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as String?,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
      student: freezed == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String?,
      studentName: freezed == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String?,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorTodaySessionDtoImplCopyWith<$Res>
    implements $TutorTodaySessionDtoCopyWith<$Res> {
  factory _$$TutorTodaySessionDtoImplCopyWith(_$TutorTodaySessionDtoImpl value,
          $Res Function(_$TutorTodaySessionDtoImpl) then) =
      __$$TutorTodaySessionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String? startAt,
      @JsonKey(name: 'end_at') String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(name: 'time_range') String? timeRange,
      String? student,
      @JsonKey(name: 'student_name') String? studentName,
      String classe,
      String subject,
      String address,
      String? location,
      String status});
}

/// @nodoc
class __$$TutorTodaySessionDtoImplCopyWithImpl<$Res>
    extends _$TutorTodaySessionDtoCopyWithImpl<$Res, _$TutorTodaySessionDtoImpl>
    implements _$$TutorTodaySessionDtoImplCopyWith<$Res> {
  __$$TutorTodaySessionDtoImplCopyWithImpl(_$TutorTodaySessionDtoImpl _value,
      $Res Function(_$TutorTodaySessionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorTodaySessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? timeRange = freezed,
    Object? student = freezed,
    Object? studentName = freezed,
    Object? classe = null,
    Object? subject = null,
    Object? address = null,
    Object? location = freezed,
    Object? status = null,
  }) {
    return _then(_$TutorTodaySessionDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: freezed == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as String?,
      endAt: freezed == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
      student: freezed == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String?,
      studentName: freezed == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String?,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorTodaySessionDtoImpl implements _TutorTodaySessionDto {
  const _$TutorTodaySessionDtoImpl(
      {this.id = '',
      @JsonKey(name: 'start_at') this.startAt,
      @JsonKey(name: 'end_at') this.endAt,
      @JsonKey(name: 'duration_minutes') this.durationMinutes,
      @JsonKey(name: 'time_range') this.timeRange,
      this.student,
      @JsonKey(name: 'student_name') this.studentName,
      this.classe = '',
      this.subject = '',
      this.address = '',
      this.location,
      this.status = ''});

  factory _$TutorTodaySessionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorTodaySessionDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'start_at')
  final String? startAt;
  @override
  @JsonKey(name: 'end_at')
  final String? endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(name: 'time_range')
  final String? timeRange;
  @override
  final String? student;
  @override
  @JsonKey(name: 'student_name')
  final String? studentName;
  @override
  @JsonKey()
  final String classe;
  @override
  @JsonKey()
  final String subject;
  @override
  @JsonKey()
  final String address;
  @override
  final String? location;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'TutorTodaySessionDto(id: $id, startAt: $startAt, endAt: $endAt, durationMinutes: $durationMinutes, timeRange: $timeRange, student: $student, studentName: $studentName, classe: $classe, subject: $subject, address: $address, location: $location, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorTodaySessionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.timeRange, timeRange) ||
                other.timeRange == timeRange) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startAt,
      endAt,
      durationMinutes,
      timeRange,
      student,
      studentName,
      classe,
      subject,
      address,
      location,
      status);

  /// Create a copy of TutorTodaySessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorTodaySessionDtoImplCopyWith<_$TutorTodaySessionDtoImpl>
      get copyWith =>
          __$$TutorTodaySessionDtoImplCopyWithImpl<_$TutorTodaySessionDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorTodaySessionDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorTodaySessionDto implements TutorTodaySessionDto {
  const factory _TutorTodaySessionDto(
      {final String id,
      @JsonKey(name: 'start_at') final String? startAt,
      @JsonKey(name: 'end_at') final String? endAt,
      @JsonKey(name: 'duration_minutes') final int? durationMinutes,
      @JsonKey(name: 'time_range') final String? timeRange,
      final String? student,
      @JsonKey(name: 'student_name') final String? studentName,
      final String classe,
      final String subject,
      final String address,
      final String? location,
      final String status}) = _$TutorTodaySessionDtoImpl;

  factory _TutorTodaySessionDto.fromJson(Map<String, dynamic> json) =
      _$TutorTodaySessionDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'start_at')
  String? get startAt;
  @override
  @JsonKey(name: 'end_at')
  String? get endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(name: 'time_range')
  String? get timeRange;
  @override
  String? get student;
  @override
  @JsonKey(name: 'student_name')
  String? get studentName;
  @override
  String get classe;
  @override
  String get subject;
  @override
  String get address;
  @override
  String? get location;
  @override
  String get status;

  /// Create a copy of TutorTodaySessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorTodaySessionDtoImplCopyWith<_$TutorTodaySessionDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TutorDashboardDto _$TutorDashboardDtoFromJson(Map<String, dynamic> json) {
  return _TutorDashboardDto.fromJson(json);
}

/// @nodoc
mixin _$TutorDashboardDto {
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  TutorStatsDto get stats => throw _privateConstructorUsedError;
  @JsonKey(name: 'today_sessions')
  List<TutorTodaySessionDto> get todaySessions =>
      throw _privateConstructorUsedError;

  /// Serializes this TutorDashboardDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorDashboardDtoCopyWith<TutorDashboardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorDashboardDtoCopyWith<$Res> {
  factory $TutorDashboardDtoCopyWith(
          TutorDashboardDto value, $Res Function(TutorDashboardDto) then) =
      _$TutorDashboardDtoCopyWithImpl<$Res, TutorDashboardDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'first_name') String firstName,
      TutorStatsDto stats,
      @JsonKey(name: 'today_sessions')
      List<TutorTodaySessionDto> todaySessions});

  $TutorStatsDtoCopyWith<$Res> get stats;
}

/// @nodoc
class _$TutorDashboardDtoCopyWithImpl<$Res, $Val extends TutorDashboardDto>
    implements $TutorDashboardDtoCopyWith<$Res> {
  _$TutorDashboardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? stats = null,
    Object? todaySessions = null,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as TutorStatsDto,
      todaySessions: null == todaySessions
          ? _value.todaySessions
          : todaySessions // ignore: cast_nullable_to_non_nullable
              as List<TutorTodaySessionDto>,
    ) as $Val);
  }

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TutorStatsDtoCopyWith<$Res> get stats {
    return $TutorStatsDtoCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TutorDashboardDtoImplCopyWith<$Res>
    implements $TutorDashboardDtoCopyWith<$Res> {
  factory _$$TutorDashboardDtoImplCopyWith(_$TutorDashboardDtoImpl value,
          $Res Function(_$TutorDashboardDtoImpl) then) =
      __$$TutorDashboardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'first_name') String firstName,
      TutorStatsDto stats,
      @JsonKey(name: 'today_sessions')
      List<TutorTodaySessionDto> todaySessions});

  @override
  $TutorStatsDtoCopyWith<$Res> get stats;
}

/// @nodoc
class __$$TutorDashboardDtoImplCopyWithImpl<$Res>
    extends _$TutorDashboardDtoCopyWithImpl<$Res, _$TutorDashboardDtoImpl>
    implements _$$TutorDashboardDtoImplCopyWith<$Res> {
  __$$TutorDashboardDtoImplCopyWithImpl(_$TutorDashboardDtoImpl _value,
      $Res Function(_$TutorDashboardDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? stats = null,
    Object? todaySessions = null,
  }) {
    return _then(_$TutorDashboardDtoImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as TutorStatsDto,
      todaySessions: null == todaySessions
          ? _value._todaySessions
          : todaySessions // ignore: cast_nullable_to_non_nullable
              as List<TutorTodaySessionDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorDashboardDtoImpl implements _TutorDashboardDto {
  const _$TutorDashboardDtoImpl(
      {@JsonKey(name: 'first_name') this.firstName = '',
      this.stats = const TutorStatsDto(),
      @JsonKey(name: 'today_sessions')
      final List<TutorTodaySessionDto> todaySessions =
          const <TutorTodaySessionDto>[]})
      : _todaySessions = todaySessions;

  factory _$TutorDashboardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorDashboardDtoImplFromJson(json);

  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey()
  final TutorStatsDto stats;
  final List<TutorTodaySessionDto> _todaySessions;
  @override
  @JsonKey(name: 'today_sessions')
  List<TutorTodaySessionDto> get todaySessions {
    if (_todaySessions is EqualUnmodifiableListView) return _todaySessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todaySessions);
  }

  @override
  String toString() {
    return 'TutorDashboardDto(firstName: $firstName, stats: $stats, todaySessions: $todaySessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorDashboardDtoImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality()
                .equals(other._todaySessions, _todaySessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, stats,
      const DeepCollectionEquality().hash(_todaySessions));

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorDashboardDtoImplCopyWith<_$TutorDashboardDtoImpl> get copyWith =>
      __$$TutorDashboardDtoImplCopyWithImpl<_$TutorDashboardDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorDashboardDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorDashboardDto implements TutorDashboardDto {
  const factory _TutorDashboardDto(
          {@JsonKey(name: 'first_name') final String firstName,
          final TutorStatsDto stats,
          @JsonKey(name: 'today_sessions')
          final List<TutorTodaySessionDto> todaySessions}) =
      _$TutorDashboardDtoImpl;

  factory _TutorDashboardDto.fromJson(Map<String, dynamic> json) =
      _$TutorDashboardDtoImpl.fromJson;

  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  TutorStatsDto get stats;
  @override
  @JsonKey(name: 'today_sessions')
  List<TutorTodaySessionDto> get todaySessions;

  /// Create a copy of TutorDashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorDashboardDtoImplCopyWith<_$TutorDashboardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
