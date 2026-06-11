// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorSessionDto _$TutorSessionDtoFromJson(Map<String, dynamic> json) {
  return _TutorSessionDto.fromJson(json);
}

/// @nodoc
mixin _$TutorSessionDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _startAt)
  String? get startAt => throw _privateConstructorUsedError;
  @JsonKey(readValue: _endAt)
  String? get endAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(readValue: _student)
  String get student => throw _privateConstructorUsedError;
  @JsonKey(readValue: _subject)
  String get subject => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(readValue: _editable)
  bool get editable => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reportAvailable)
  bool get reportAvailable => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reportSubmitted)
  bool get reportSubmitted => throw _privateConstructorUsedError;

  /// Serializes this TutorSessionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorSessionDtoCopyWith<TutorSessionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorSessionDtoCopyWith<$Res> {
  factory $TutorSessionDtoCopyWith(
          TutorSessionDto value, $Res Function(TutorSessionDto) then) =
      _$TutorSessionDtoCopyWithImpl<$Res, TutorSessionDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _startAt) String? startAt,
      @JsonKey(readValue: _endAt) String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _subject) String subject,
      String status,
      @JsonKey(readValue: _editable) bool editable,
      @JsonKey(readValue: _reportAvailable) bool reportAvailable,
      @JsonKey(readValue: _reportSubmitted) bool reportSubmitted});
}

/// @nodoc
class _$TutorSessionDtoCopyWithImpl<$Res, $Val extends TutorSessionDto>
    implements $TutorSessionDtoCopyWith<$Res> {
  _$TutorSessionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? student = null,
    Object? subject = null,
    Object? status = null,
    Object? editable = null,
    Object? reportAvailable = null,
    Object? reportSubmitted = null,
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
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      editable: null == editable
          ? _value.editable
          : editable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportAvailable: null == reportAvailable
          ? _value.reportAvailable
          : reportAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportSubmitted: null == reportSubmitted
          ? _value.reportSubmitted
          : reportSubmitted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorSessionDtoImplCopyWith<$Res>
    implements $TutorSessionDtoCopyWith<$Res> {
  factory _$$TutorSessionDtoImplCopyWith(_$TutorSessionDtoImpl value,
          $Res Function(_$TutorSessionDtoImpl) then) =
      __$$TutorSessionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _startAt) String? startAt,
      @JsonKey(readValue: _endAt) String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _subject) String subject,
      String status,
      @JsonKey(readValue: _editable) bool editable,
      @JsonKey(readValue: _reportAvailable) bool reportAvailable,
      @JsonKey(readValue: _reportSubmitted) bool reportSubmitted});
}

/// @nodoc
class __$$TutorSessionDtoImplCopyWithImpl<$Res>
    extends _$TutorSessionDtoCopyWithImpl<$Res, _$TutorSessionDtoImpl>
    implements _$$TutorSessionDtoImplCopyWith<$Res> {
  __$$TutorSessionDtoImplCopyWithImpl(
      _$TutorSessionDtoImpl _value, $Res Function(_$TutorSessionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? student = null,
    Object? subject = null,
    Object? status = null,
    Object? editable = null,
    Object? reportAvailable = null,
    Object? reportSubmitted = null,
  }) {
    return _then(_$TutorSessionDtoImpl(
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
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      editable: null == editable
          ? _value.editable
          : editable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportAvailable: null == reportAvailable
          ? _value.reportAvailable
          : reportAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportSubmitted: null == reportSubmitted
          ? _value.reportSubmitted
          : reportSubmitted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorSessionDtoImpl extends _TutorSessionDto {
  const _$TutorSessionDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _startAt) this.startAt,
      @JsonKey(readValue: _endAt) this.endAt,
      @JsonKey(name: 'duration_minutes') this.durationMinutes,
      @JsonKey(readValue: _student) this.student = '',
      @JsonKey(readValue: _subject) this.subject = '',
      this.status = '',
      @JsonKey(readValue: _editable) this.editable = false,
      @JsonKey(readValue: _reportAvailable) this.reportAvailable = false,
      @JsonKey(readValue: _reportSubmitted) this.reportSubmitted = false})
      : super._();

  factory _$TutorSessionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorSessionDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _startAt)
  final String? startAt;
  @override
  @JsonKey(readValue: _endAt)
  final String? endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(readValue: _student)
  final String student;
  @override
  @JsonKey(readValue: _subject)
  final String subject;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(readValue: _editable)
  final bool editable;
  @override
  @JsonKey(readValue: _reportAvailable)
  final bool reportAvailable;
  @override
  @JsonKey(readValue: _reportSubmitted)
  final bool reportSubmitted;

  @override
  String toString() {
    return 'TutorSessionDto(id: $id, startAt: $startAt, endAt: $endAt, durationMinutes: $durationMinutes, student: $student, subject: $subject, status: $status, editable: $editable, reportAvailable: $reportAvailable, reportSubmitted: $reportSubmitted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorSessionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.editable, editable) ||
                other.editable == editable) &&
            (identical(other.reportAvailable, reportAvailable) ||
                other.reportAvailable == reportAvailable) &&
            (identical(other.reportSubmitted, reportSubmitted) ||
                other.reportSubmitted == reportSubmitted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startAt,
      endAt,
      durationMinutes,
      student,
      subject,
      status,
      editable,
      reportAvailable,
      reportSubmitted);

  /// Create a copy of TutorSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorSessionDtoImplCopyWith<_$TutorSessionDtoImpl> get copyWith =>
      __$$TutorSessionDtoImplCopyWithImpl<_$TutorSessionDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorSessionDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorSessionDto extends TutorSessionDto {
  const factory _TutorSessionDto(
          {final String id,
          @JsonKey(readValue: _startAt) final String? startAt,
          @JsonKey(readValue: _endAt) final String? endAt,
          @JsonKey(name: 'duration_minutes') final int? durationMinutes,
          @JsonKey(readValue: _student) final String student,
          @JsonKey(readValue: _subject) final String subject,
          final String status,
          @JsonKey(readValue: _editable) final bool editable,
          @JsonKey(readValue: _reportAvailable) final bool reportAvailable,
          @JsonKey(readValue: _reportSubmitted) final bool reportSubmitted}) =
      _$TutorSessionDtoImpl;
  const _TutorSessionDto._() : super._();

  factory _TutorSessionDto.fromJson(Map<String, dynamic> json) =
      _$TutorSessionDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _startAt)
  String? get startAt;
  @override
  @JsonKey(readValue: _endAt)
  String? get endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(readValue: _student)
  String get student;
  @override
  @JsonKey(readValue: _subject)
  String get subject;
  @override
  String get status;
  @override
  @JsonKey(readValue: _editable)
  bool get editable;
  @override
  @JsonKey(readValue: _reportAvailable)
  bool get reportAvailable;
  @override
  @JsonKey(readValue: _reportSubmitted)
  bool get reportSubmitted;

  /// Create a copy of TutorSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorSessionDtoImplCopyWith<_$TutorSessionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorSessionDetailDto _$TutorSessionDetailDtoFromJson(
    Map<String, dynamic> json) {
  return _TutorSessionDetailDto.fromJson(json);
}

/// @nodoc
mixin _$TutorSessionDetailDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _subject)
  String get subject => throw _privateConstructorUsedError;
  @JsonKey(readValue: _startAt)
  String? get startAt => throw _privateConstructorUsedError;
  @JsonKey(readValue: _endAt)
  String? get endAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(readValue: _student)
  String get student => throw _privateConstructorUsedError;
  @JsonKey(readValue: _classe)
  String get classe => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reservationRef)
  String get reservationRef => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(readValue: _editable)
  bool get editable => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reportAvailable)
  bool get reportAvailable => throw _privateConstructorUsedError;

  /// Serializes this TutorSessionDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorSessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorSessionDetailDtoCopyWith<TutorSessionDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorSessionDetailDtoCopyWith<$Res> {
  factory $TutorSessionDetailDtoCopyWith(TutorSessionDetailDto value,
          $Res Function(TutorSessionDetailDto) then) =
      _$TutorSessionDetailDtoCopyWithImpl<$Res, TutorSessionDetailDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _subject) String subject,
      @JsonKey(readValue: _startAt) String? startAt,
      @JsonKey(readValue: _endAt) String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(readValue: _reservationRef) String reservationRef,
      String status,
      @JsonKey(readValue: _editable) bool editable,
      @JsonKey(readValue: _reportAvailable) bool reportAvailable});
}

/// @nodoc
class _$TutorSessionDetailDtoCopyWithImpl<$Res,
        $Val extends TutorSessionDetailDto>
    implements $TutorSessionDetailDtoCopyWith<$Res> {
  _$TutorSessionDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorSessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? student = null,
    Object? classe = null,
    Object? reservationRef = null,
    Object? status = null,
    Object? editable = null,
    Object? reportAvailable = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
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
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      reservationRef: null == reservationRef
          ? _value.reservationRef
          : reservationRef // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      editable: null == editable
          ? _value.editable
          : editable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportAvailable: null == reportAvailable
          ? _value.reportAvailable
          : reportAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorSessionDetailDtoImplCopyWith<$Res>
    implements $TutorSessionDetailDtoCopyWith<$Res> {
  factory _$$TutorSessionDetailDtoImplCopyWith(
          _$TutorSessionDetailDtoImpl value,
          $Res Function(_$TutorSessionDetailDtoImpl) then) =
      __$$TutorSessionDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _subject) String subject,
      @JsonKey(readValue: _startAt) String? startAt,
      @JsonKey(readValue: _endAt) String? endAt,
      @JsonKey(name: 'duration_minutes') int? durationMinutes,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _classe) String classe,
      @JsonKey(readValue: _reservationRef) String reservationRef,
      String status,
      @JsonKey(readValue: _editable) bool editable,
      @JsonKey(readValue: _reportAvailable) bool reportAvailable});
}

/// @nodoc
class __$$TutorSessionDetailDtoImplCopyWithImpl<$Res>
    extends _$TutorSessionDetailDtoCopyWithImpl<$Res,
        _$TutorSessionDetailDtoImpl>
    implements _$$TutorSessionDetailDtoImplCopyWith<$Res> {
  __$$TutorSessionDetailDtoImplCopyWithImpl(_$TutorSessionDetailDtoImpl _value,
      $Res Function(_$TutorSessionDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorSessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? durationMinutes = freezed,
    Object? student = null,
    Object? classe = null,
    Object? reservationRef = null,
    Object? status = null,
    Object? editable = null,
    Object? reportAvailable = null,
  }) {
    return _then(_$TutorSessionDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
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
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      reservationRef: null == reservationRef
          ? _value.reservationRef
          : reservationRef // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      editable: null == editable
          ? _value.editable
          : editable // ignore: cast_nullable_to_non_nullable
              as bool,
      reportAvailable: null == reportAvailable
          ? _value.reportAvailable
          : reportAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorSessionDetailDtoImpl implements _TutorSessionDetailDto {
  const _$TutorSessionDetailDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _subject) this.subject = '',
      @JsonKey(readValue: _startAt) this.startAt,
      @JsonKey(readValue: _endAt) this.endAt,
      @JsonKey(name: 'duration_minutes') this.durationMinutes,
      @JsonKey(readValue: _student) this.student = '',
      @JsonKey(readValue: _classe) this.classe = '',
      @JsonKey(readValue: _reservationRef) this.reservationRef = '',
      this.status = '',
      @JsonKey(readValue: _editable) this.editable = false,
      @JsonKey(readValue: _reportAvailable) this.reportAvailable = false});

  factory _$TutorSessionDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorSessionDetailDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _subject)
  final String subject;
  @override
  @JsonKey(readValue: _startAt)
  final String? startAt;
  @override
  @JsonKey(readValue: _endAt)
  final String? endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(readValue: _student)
  final String student;
  @override
  @JsonKey(readValue: _classe)
  final String classe;
  @override
  @JsonKey(readValue: _reservationRef)
  final String reservationRef;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(readValue: _editable)
  final bool editable;
  @override
  @JsonKey(readValue: _reportAvailable)
  final bool reportAvailable;

  @override
  String toString() {
    return 'TutorSessionDetailDto(id: $id, subject: $subject, startAt: $startAt, endAt: $endAt, durationMinutes: $durationMinutes, student: $student, classe: $classe, reservationRef: $reservationRef, status: $status, editable: $editable, reportAvailable: $reportAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorSessionDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            (identical(other.reservationRef, reservationRef) ||
                other.reservationRef == reservationRef) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.editable, editable) ||
                other.editable == editable) &&
            (identical(other.reportAvailable, reportAvailable) ||
                other.reportAvailable == reportAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      subject,
      startAt,
      endAt,
      durationMinutes,
      student,
      classe,
      reservationRef,
      status,
      editable,
      reportAvailable);

  /// Create a copy of TutorSessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorSessionDetailDtoImplCopyWith<_$TutorSessionDetailDtoImpl>
      get copyWith => __$$TutorSessionDetailDtoImplCopyWithImpl<
          _$TutorSessionDetailDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorSessionDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorSessionDetailDto implements TutorSessionDetailDto {
  const factory _TutorSessionDetailDto(
          {final String id,
          @JsonKey(readValue: _subject) final String subject,
          @JsonKey(readValue: _startAt) final String? startAt,
          @JsonKey(readValue: _endAt) final String? endAt,
          @JsonKey(name: 'duration_minutes') final int? durationMinutes,
          @JsonKey(readValue: _student) final String student,
          @JsonKey(readValue: _classe) final String classe,
          @JsonKey(readValue: _reservationRef) final String reservationRef,
          final String status,
          @JsonKey(readValue: _editable) final bool editable,
          @JsonKey(readValue: _reportAvailable) final bool reportAvailable}) =
      _$TutorSessionDetailDtoImpl;

  factory _TutorSessionDetailDto.fromJson(Map<String, dynamic> json) =
      _$TutorSessionDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _subject)
  String get subject;
  @override
  @JsonKey(readValue: _startAt)
  String? get startAt;
  @override
  @JsonKey(readValue: _endAt)
  String? get endAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(readValue: _student)
  String get student;
  @override
  @JsonKey(readValue: _classe)
  String get classe;
  @override
  @JsonKey(readValue: _reservationRef)
  String get reservationRef;
  @override
  String get status;
  @override
  @JsonKey(readValue: _editable)
  bool get editable;
  @override
  @JsonKey(readValue: _reportAvailable)
  bool get reportAvailable;

  /// Create a copy of TutorSessionDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorSessionDetailDtoImplCopyWith<_$TutorSessionDetailDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
