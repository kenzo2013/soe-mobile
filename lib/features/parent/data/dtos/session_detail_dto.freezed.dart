// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SessionTaskDto _$SessionTaskDtoFromJson(Map<String, dynamic> json) {
  return _SessionTaskDto.fromJson(json);
}

/// @nodoc
mixin _$SessionTaskDto {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  String? get dueDate => throw _privateConstructorUsedError;

  /// Serializes this SessionTaskDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionTaskDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionTaskDtoCopyWith<SessionTaskDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionTaskDtoCopyWith<$Res> {
  factory $SessionTaskDtoCopyWith(
          SessionTaskDto value, $Res Function(SessionTaskDto) then) =
      _$SessionTaskDtoCopyWithImpl<$Res, SessionTaskDto>;
  @useResult
  $Res call(
      {String id,
      String title,
      bool done,
      @JsonKey(name: 'due_date') String? dueDate});
}

/// @nodoc
class _$SessionTaskDtoCopyWithImpl<$Res, $Val extends SessionTaskDto>
    implements $SessionTaskDtoCopyWith<$Res> {
  _$SessionTaskDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionTaskDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? done = null,
    Object? dueDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionTaskDtoImplCopyWith<$Res>
    implements $SessionTaskDtoCopyWith<$Res> {
  factory _$$SessionTaskDtoImplCopyWith(_$SessionTaskDtoImpl value,
          $Res Function(_$SessionTaskDtoImpl) then) =
      __$$SessionTaskDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      bool done,
      @JsonKey(name: 'due_date') String? dueDate});
}

/// @nodoc
class __$$SessionTaskDtoImplCopyWithImpl<$Res>
    extends _$SessionTaskDtoCopyWithImpl<$Res, _$SessionTaskDtoImpl>
    implements _$$SessionTaskDtoImplCopyWith<$Res> {
  __$$SessionTaskDtoImplCopyWithImpl(
      _$SessionTaskDtoImpl _value, $Res Function(_$SessionTaskDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionTaskDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? done = null,
    Object? dueDate = freezed,
  }) {
    return _then(_$SessionTaskDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionTaskDtoImpl implements _SessionTaskDto {
  const _$SessionTaskDtoImpl(
      {required this.id,
      required this.title,
      this.done = false,
      @JsonKey(name: 'due_date') this.dueDate});

  factory _$SessionTaskDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionTaskDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final bool done;
  @override
  @JsonKey(name: 'due_date')
  final String? dueDate;

  @override
  String toString() {
    return 'SessionTaskDto(id: $id, title: $title, done: $done, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionTaskDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, done, dueDate);

  /// Create a copy of SessionTaskDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionTaskDtoImplCopyWith<_$SessionTaskDtoImpl> get copyWith =>
      __$$SessionTaskDtoImplCopyWithImpl<_$SessionTaskDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionTaskDtoImplToJson(
      this,
    );
  }
}

abstract class _SessionTaskDto implements SessionTaskDto {
  const factory _SessionTaskDto(
      {required final String id,
      required final String title,
      final bool done,
      @JsonKey(name: 'due_date') final String? dueDate}) = _$SessionTaskDtoImpl;

  factory _SessionTaskDto.fromJson(Map<String, dynamic> json) =
      _$SessionTaskDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  bool get done;
  @override
  @JsonKey(name: 'due_date')
  String? get dueDate;

  /// Create a copy of SessionTaskDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionTaskDtoImplCopyWith<_$SessionTaskDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionReportDto _$SessionReportDtoFromJson(Map<String, dynamic> json) {
  return _SessionReportDto.fromJson(json);
}

/// @nodoc
mixin _$SessionReportDto {
  String get summary => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'submitted_at')
  String? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this SessionReportDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionReportDtoCopyWith<SessionReportDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionReportDtoCopyWith<$Res> {
  factory $SessionReportDtoCopyWith(
          SessionReportDto value, $Res Function(SessionReportDto) then) =
      _$SessionReportDtoCopyWithImpl<$Res, SessionReportDto>;
  @useResult
  $Res call(
      {String summary,
      List<String> attachments,
      double? rating,
      @JsonKey(name: 'submitted_at') String? submittedAt});
}

/// @nodoc
class _$SessionReportDtoCopyWithImpl<$Res, $Val extends SessionReportDto>
    implements $SessionReportDtoCopyWith<$Res> {
  _$SessionReportDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? attachments = null,
    Object? rating = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(_value.copyWith(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionReportDtoImplCopyWith<$Res>
    implements $SessionReportDtoCopyWith<$Res> {
  factory _$$SessionReportDtoImplCopyWith(_$SessionReportDtoImpl value,
          $Res Function(_$SessionReportDtoImpl) then) =
      __$$SessionReportDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String summary,
      List<String> attachments,
      double? rating,
      @JsonKey(name: 'submitted_at') String? submittedAt});
}

/// @nodoc
class __$$SessionReportDtoImplCopyWithImpl<$Res>
    extends _$SessionReportDtoCopyWithImpl<$Res, _$SessionReportDtoImpl>
    implements _$$SessionReportDtoImplCopyWith<$Res> {
  __$$SessionReportDtoImplCopyWithImpl(_$SessionReportDtoImpl _value,
      $Res Function(_$SessionReportDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionReportDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? attachments = null,
    Object? rating = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(_$SessionReportDtoImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionReportDtoImpl implements _SessionReportDto {
  const _$SessionReportDtoImpl(
      {this.summary = '',
      final List<String> attachments = const <String>[],
      this.rating,
      @JsonKey(name: 'submitted_at') this.submittedAt})
      : _attachments = attachments;

  factory _$SessionReportDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionReportDtoImplFromJson(json);

  @override
  @JsonKey()
  final String summary;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final double? rating;
  @override
  @JsonKey(name: 'submitted_at')
  final String? submittedAt;

  @override
  String toString() {
    return 'SessionReportDto(summary: $summary, attachments: $attachments, rating: $rating, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionReportDtoImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, summary,
      const DeepCollectionEquality().hash(_attachments), rating, submittedAt);

  /// Create a copy of SessionReportDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionReportDtoImplCopyWith<_$SessionReportDtoImpl> get copyWith =>
      __$$SessionReportDtoImplCopyWithImpl<_$SessionReportDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionReportDtoImplToJson(
      this,
    );
  }
}

abstract class _SessionReportDto implements SessionReportDto {
  const factory _SessionReportDto(
          {final String summary,
          final List<String> attachments,
          final double? rating,
          @JsonKey(name: 'submitted_at') final String? submittedAt}) =
      _$SessionReportDtoImpl;

  factory _SessionReportDto.fromJson(Map<String, dynamic> json) =
      _$SessionReportDtoImpl.fromJson;

  @override
  String get summary;
  @override
  List<String> get attachments;
  @override
  double? get rating;
  @override
  @JsonKey(name: 'submitted_at')
  String? get submittedAt;

  /// Create a copy of SessionReportDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionReportDtoImplCopyWith<_$SessionReportDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionDetailDto _$SessionDetailDtoFromJson(Map<String, dynamic> json) {
  return _SessionDetailDto.fromJson(json);
}

/// @nodoc
mixin _$SessionDetailDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_at')
  String get startAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  String? get subject => throw _privateConstructorUsedError;
  @JsonKey(name: 'tutor_name')
  String? get tutorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_name')
  String? get childName => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  SessionReportDto? get report => throw _privateConstructorUsedError;
  List<SessionTaskDto> get tasks => throw _privateConstructorUsedError;

  /// Serializes this SessionDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionDetailDtoCopyWith<SessionDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionDetailDtoCopyWith<$Res> {
  factory $SessionDetailDtoCopyWith(
          SessionDetailDto value, $Res Function(SessionDetailDto) then) =
      _$SessionDetailDtoCopyWithImpl<$Res, SessionDetailDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String startAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      String? subject,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName,
      String? status,
      String? location,
      String? notes,
      SessionReportDto? report,
      List<SessionTaskDto> tasks});

  $SessionReportDtoCopyWith<$Res>? get report;
}

/// @nodoc
class _$SessionDetailDtoCopyWithImpl<$Res, $Val extends SessionDetailDto>
    implements $SessionDetailDtoCopyWith<$Res> {
  _$SessionDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionDetailDto
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
    Object? location = freezed,
    Object? notes = freezed,
    Object? report = freezed,
    Object? tasks = null,
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
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      report: freezed == report
          ? _value.report
          : report // ignore: cast_nullable_to_non_nullable
              as SessionReportDto?,
      tasks: null == tasks
          ? _value.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<SessionTaskDto>,
    ) as $Val);
  }

  /// Create a copy of SessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionReportDtoCopyWith<$Res>? get report {
    if (_value.report == null) {
      return null;
    }

    return $SessionReportDtoCopyWith<$Res>(_value.report!, (value) {
      return _then(_value.copyWith(report: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionDetailDtoImplCopyWith<$Res>
    implements $SessionDetailDtoCopyWith<$Res> {
  factory _$$SessionDetailDtoImplCopyWith(_$SessionDetailDtoImpl value,
          $Res Function(_$SessionDetailDtoImpl) then) =
      __$$SessionDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'start_at') String startAt,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      String? subject,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName,
      String? status,
      String? location,
      String? notes,
      SessionReportDto? report,
      List<SessionTaskDto> tasks});

  @override
  $SessionReportDtoCopyWith<$Res>? get report;
}

/// @nodoc
class __$$SessionDetailDtoImplCopyWithImpl<$Res>
    extends _$SessionDetailDtoCopyWithImpl<$Res, _$SessionDetailDtoImpl>
    implements _$$SessionDetailDtoImplCopyWith<$Res> {
  __$$SessionDetailDtoImplCopyWithImpl(_$SessionDetailDtoImpl _value,
      $Res Function(_$SessionDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionDetailDto
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
    Object? location = freezed,
    Object? notes = freezed,
    Object? report = freezed,
    Object? tasks = null,
  }) {
    return _then(_$SessionDetailDtoImpl(
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
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      report: freezed == report
          ? _value.report
          : report // ignore: cast_nullable_to_non_nullable
              as SessionReportDto?,
      tasks: null == tasks
          ? _value._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<SessionTaskDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionDetailDtoImpl implements _SessionDetailDto {
  const _$SessionDetailDtoImpl(
      {required this.id,
      @JsonKey(name: 'start_at') required this.startAt,
      @JsonKey(name: 'duration_minutes') this.durationMinutes = 60,
      this.subject,
      @JsonKey(name: 'tutor_name') this.tutorName,
      @JsonKey(name: 'child_name') this.childName,
      this.status,
      this.location,
      this.notes,
      this.report,
      final List<SessionTaskDto> tasks = const <SessionTaskDto>[]})
      : _tasks = tasks;

  factory _$SessionDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionDetailDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'start_at')
  final String startAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  final String? subject;
  @override
  @JsonKey(name: 'tutor_name')
  final String? tutorName;
  @override
  @JsonKey(name: 'child_name')
  final String? childName;
  @override
  final String? status;
  @override
  final String? location;
  @override
  final String? notes;
  @override
  final SessionReportDto? report;
  final List<SessionTaskDto> _tasks;
  @override
  @JsonKey()
  List<SessionTaskDto> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'SessionDetailDto(id: $id, startAt: $startAt, durationMinutes: $durationMinutes, subject: $subject, tutorName: $tutorName, childName: $childName, status: $status, location: $location, notes: $notes, report: $report, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.tutorName, tutorName) ||
                other.tutorName == tutorName) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.report, report) || other.report == report) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startAt,
      durationMinutes,
      subject,
      tutorName,
      childName,
      status,
      location,
      notes,
      report,
      const DeepCollectionEquality().hash(_tasks));

  /// Create a copy of SessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionDetailDtoImplCopyWith<_$SessionDetailDtoImpl> get copyWith =>
      __$$SessionDetailDtoImplCopyWithImpl<_$SessionDetailDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _SessionDetailDto implements SessionDetailDto {
  const factory _SessionDetailDto(
      {required final String id,
      @JsonKey(name: 'start_at') required final String startAt,
      @JsonKey(name: 'duration_minutes') final int durationMinutes,
      final String? subject,
      @JsonKey(name: 'tutor_name') final String? tutorName,
      @JsonKey(name: 'child_name') final String? childName,
      final String? status,
      final String? location,
      final String? notes,
      final SessionReportDto? report,
      final List<SessionTaskDto> tasks}) = _$SessionDetailDtoImpl;

  factory _SessionDetailDto.fromJson(Map<String, dynamic> json) =
      _$SessionDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'start_at')
  String get startAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  String? get subject;
  @override
  @JsonKey(name: 'tutor_name')
  String? get tutorName;
  @override
  @JsonKey(name: 'child_name')
  String? get childName;
  @override
  String? get status;
  @override
  String? get location;
  @override
  String? get notes;
  @override
  SessionReportDto? get report;
  @override
  List<SessionTaskDto> get tasks;

  /// Create a copy of SessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionDetailDtoImplCopyWith<_$SessionDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
