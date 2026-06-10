import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_dashboard.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_dashboard_dto.freezed.dart';
part 'tutor_dashboard_dto.g.dart';

@freezed
abstract class TutorStatsDto with _$TutorStatsDto {
  const factory TutorStatsDto({
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'total_sessions') @Default(0) int totalSessions,
    @JsonKey(name: 'pending_sessions') @Default(0) int pendingSessions,
    @JsonKey(name: 'completed_sessions') @Default(0) int completedSessions,
  }) = _TutorStatsDto;
  factory TutorStatsDto.fromJson(Map<String, dynamic> json) =>
      _$TutorStatsDtoFromJson(json);
}

/// Séance du jour. Champs tolérants : on accepte les variantes probables
/// (`start_at`/`end_at`/`duration_minutes`, `student`/`student_name`,
/// `address`/`location`, `classe`/`school_class`).
@freezed
abstract class TutorTodaySessionDto with _$TutorTodaySessionDto {
  const factory TutorTodaySessionDto({
    @Default('') String id,
    @JsonKey(name: 'start_at') String? startAt,
    @JsonKey(name: 'end_at') String? endAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'time_range') String? timeRange,
    String? student,
    @JsonKey(name: 'student_name') String? studentName,
    @Default('') String classe,
    @Default('') String subject,
    @Default('') String address,
    String? location,
    @Default('') String status,
  }) = _TutorTodaySessionDto;
  factory TutorTodaySessionDto.fromJson(Map<String, dynamic> json) =>
      _$TutorTodaySessionDtoFromJson(json);
}

@freezed
abstract class TutorDashboardDto with _$TutorDashboardDto {
  const factory TutorDashboardDto({
    @JsonKey(name: 'first_name') @Default('') String firstName,
    @Default(TutorStatsDto()) TutorStatsDto stats,
    @JsonKey(name: 'today_sessions')
    @Default(<TutorTodaySessionDto>[])
    List<TutorTodaySessionDto> todaySessions,
  }) = _TutorDashboardDto;
  factory TutorDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$TutorDashboardDtoFromJson(json);
}

/// Enums API §11.5 (Session) : pending | completed | approved | rejected,
/// + tolérance aux libellés du dashboard (`confirmed`, `in_progress`).
TutorSessionStatus parseSessionStatus(String? raw) => switch (raw) {
      'confirmed' => TutorSessionStatus.confirmed,
      'in_progress' => TutorSessionStatus.inProgress,
      'pending' => TutorSessionStatus.pending,
      'completed' || 'approved' => TutorSessionStatus.completed,
      _ => TutorSessionStatus.unknown,
    };

extension TutorStatsDtoX on TutorStatsDto {
  TutorStats toEntity() => TutorStats(
        totalStudents: totalStudents,
        totalSessions: totalSessions,
        pendingSessions: pendingSessions,
        completedSessions: completedSessions,
      );
}

extension TutorTodaySessionDtoX on TutorTodaySessionDto {
  TutorTodaySession toEntity() => TutorTodaySession(
        id: id,
        timeRange: timeRange ??
            TutorApi.timeRange(startAt,
                endIso: endAt, minutes: durationMinutes),
        student: student ?? studentName ?? '',
        classe: classe,
        subject: subject,
        address: address.isNotEmpty ? address : (location ?? ''),
        status: parseSessionStatus(status),
      );
}

extension TutorDashboardDtoX on TutorDashboardDto {
  TutorDashboard toEntity() => TutorDashboard(
        firstName: firstName,
        stats: stats.toEntity(),
        todaySessions: todaySessions.map((e) => e.toEntity()).toList(),
      );
}
