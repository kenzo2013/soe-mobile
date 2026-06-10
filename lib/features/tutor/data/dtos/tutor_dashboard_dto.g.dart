// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorStatsDtoImpl _$$TutorStatsDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorStatsDtoImpl(
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      pendingSessions: (json['pending_sessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completed_sessions'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TutorStatsDtoImplToJson(_$TutorStatsDtoImpl instance) =>
    <String, dynamic>{
      'total_students': instance.totalStudents,
      'total_sessions': instance.totalSessions,
      'pending_sessions': instance.pendingSessions,
      'completed_sessions': instance.completedSessions,
    };

_$TutorTodaySessionDtoImpl _$$TutorTodaySessionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorTodaySessionDtoImpl(
      id: json['id'] as String? ?? '',
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      timeRange: json['time_range'] as String?,
      student: json['student'] as String?,
      studentName: json['student_name'] as String?,
      classe: json['classe'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: json['location'] as String?,
      status: json['status'] as String? ?? '',
    );

Map<String, dynamic> _$$TutorTodaySessionDtoImplToJson(
        _$TutorTodaySessionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'duration_minutes': instance.durationMinutes,
      'time_range': instance.timeRange,
      'student': instance.student,
      'student_name': instance.studentName,
      'classe': instance.classe,
      'subject': instance.subject,
      'address': instance.address,
      'location': instance.location,
      'status': instance.status,
    };

_$TutorDashboardDtoImpl _$$TutorDashboardDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorDashboardDtoImpl(
      firstName: json['first_name'] as String? ?? '',
      stats: json['stats'] == null
          ? const TutorStatsDto()
          : TutorStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      todaySessions: (json['today_sessions'] as List<dynamic>?)
              ?.map((e) =>
                  TutorTodaySessionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorTodaySessionDto>[],
    );

Map<String, dynamic> _$$TutorDashboardDtoImplToJson(
        _$TutorDashboardDtoImpl instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'stats': instance.stats,
      'today_sessions': instance.todaySessions,
    };
