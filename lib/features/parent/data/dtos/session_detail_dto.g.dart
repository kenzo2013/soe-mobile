// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionTaskDtoImpl _$$SessionTaskDtoImplFromJson(Map<String, dynamic> json) =>
    _$SessionTaskDtoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
      dueDate: json['due_date'] as String?,
    );

Map<String, dynamic> _$$SessionTaskDtoImplToJson(
        _$SessionTaskDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'done': instance.done,
      'due_date': instance.dueDate,
    };

_$SessionReportDtoImpl _$$SessionReportDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionReportDtoImpl(
      summary: json['summary'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      rating: (json['rating'] as num?)?.toDouble(),
      submittedAt: json['submitted_at'] as String?,
    );

Map<String, dynamic> _$$SessionReportDtoImplToJson(
        _$SessionReportDtoImpl instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'attachments': instance.attachments,
      'rating': instance.rating,
      'submitted_at': instance.submittedAt,
    };

_$SessionDetailDtoImpl _$$SessionDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionDetailDtoImpl(
      id: json['id'] as String,
      startAt: json['start_at'] as String,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      subject: json['subject'] as String?,
      tutorName: json['tutor_name'] as String?,
      tutorId: json['tutor_id'] as String?,
      childName: json['child_name'] as String?,
      status: json['status'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      report: json['report'] == null
          ? null
          : SessionReportDto.fromJson(json['report'] as Map<String, dynamic>),
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => SessionTaskDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SessionTaskDto>[],
    );

Map<String, dynamic> _$$SessionDetailDtoImplToJson(
        _$SessionDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_at': instance.startAt,
      'duration_minutes': instance.durationMinutes,
      'subject': instance.subject,
      'tutor_name': instance.tutorName,
      'tutor_id': instance.tutorId,
      'child_name': instance.childName,
      'status': instance.status,
      'location': instance.location,
      'notes': instance.notes,
      'report': instance.report,
      'tasks': instance.tasks,
    };
