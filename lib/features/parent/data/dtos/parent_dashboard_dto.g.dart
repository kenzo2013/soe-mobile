// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentSummaryDtoImpl _$$StudentSummaryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$StudentSummaryDtoImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      classe: json['classe'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      section: json['section'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$StudentSummaryDtoImplToJson(
        _$StudentSummaryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'classe': instance.classe,
      'avatar_url': instance.avatarUrl,
      'section': instance.section,
      'subjects': instance.subjects,
    };

_$ReservationSummaryDtoImpl _$$ReservationSummaryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ReservationSummaryDtoImpl(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      status: json['status'] as String?,
      childName: json['child_name'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      amount: (json['amount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ReservationSummaryDtoImplToJson(
        _$ReservationSummaryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'status': instance.status,
      'child_name': instance.childName,
      'subjects': instance.subjects,
      'amount': instance.amount,
    };

_$SessionSummaryDtoImpl _$$SessionSummaryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionSummaryDtoImpl(
      id: json['id'] as String,
      startAt: json['start_at'] as String,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      subject: json['subject'] as String?,
      tutorName: json['tutor_name'] as String?,
      childName: json['child_name'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$SessionSummaryDtoImplToJson(
        _$SessionSummaryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_at': instance.startAt,
      'duration_minutes': instance.durationMinutes,
      'subject': instance.subject,
      'tutor_name': instance.tutorName,
      'child_name': instance.childName,
      'status': instance.status,
    };

_$ParentDashboardDtoImpl _$$ParentDashboardDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ParentDashboardDtoImpl(
      students: (json['students'] as List<dynamic>?)
              ?.map(
                  (e) => StudentSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StudentSummaryDto>[],
      todaySessions: (json['today_sessions'] as List<dynamic>?)
              ?.map(
                  (e) => SessionSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SessionSummaryDto>[],
      recentReservations: (json['recent_reservations'] as List<dynamic>?)
              ?.map((e) =>
                  ReservationSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReservationSummaryDto>[],
    );

Map<String, dynamic> _$$ParentDashboardDtoImplToJson(
        _$ParentDashboardDtoImpl instance) =>
    <String, dynamic>{
      'students': instance.students,
      'today_sessions': instance.todaySessions,
      'recent_reservations': instance.recentReservations,
    };
