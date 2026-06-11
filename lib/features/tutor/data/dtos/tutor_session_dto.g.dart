// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorSessionDtoImpl _$$TutorSessionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorSessionDtoImpl(
      id: json['id'] as String? ?? '',
      startAt: _startAt(json, 'startAt') as String?,
      endAt: _endAt(json, 'endAt') as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      student: _student(json, 'student') as String? ?? '',
      subject: _subject(json, 'subject') as String? ?? '',
      status: json['status'] as String? ?? '',
      editable: _editable(json, 'editable') as bool? ?? false,
      reportAvailable:
          _reportAvailable(json, 'reportAvailable') as bool? ?? false,
      reportSubmitted:
          _reportSubmitted(json, 'reportSubmitted') as bool? ?? false,
    );

Map<String, dynamic> _$$TutorSessionDtoImplToJson(
        _$TutorSessionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'duration_minutes': instance.durationMinutes,
      'student': instance.student,
      'subject': instance.subject,
      'status': instance.status,
      'editable': instance.editable,
      'reportAvailable': instance.reportAvailable,
      'reportSubmitted': instance.reportSubmitted,
    };

_$TutorSessionDetailDtoImpl _$$TutorSessionDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorSessionDetailDtoImpl(
      id: json['id'] as String? ?? '',
      subject: _subject(json, 'subject') as String? ?? '',
      startAt: _startAt(json, 'startAt') as String?,
      endAt: _endAt(json, 'endAt') as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      student: _student(json, 'student') as String? ?? '',
      classe: _classe(json, 'classe') as String? ?? '',
      reservationRef: _reservationRef(json, 'reservationRef') as String? ?? '',
      status: json['status'] as String? ?? '',
      editable: _editable(json, 'editable') as bool? ?? false,
      reportAvailable:
          _reportAvailable(json, 'reportAvailable') as bool? ?? false,
    );

Map<String, dynamic> _$$TutorSessionDetailDtoImplToJson(
        _$TutorSessionDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'duration_minutes': instance.durationMinutes,
      'student': instance.student,
      'classe': instance.classe,
      'reservationRef': instance.reservationRef,
      'status': instance.status,
      'editable': instance.editable,
      'reportAvailable': instance.reportAvailable,
    };
