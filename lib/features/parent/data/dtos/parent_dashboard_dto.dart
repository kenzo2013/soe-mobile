import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/parent_dashboard.dart';
import '../../domain/entities/reservation_summary.dart';
import '../../domain/entities/session_summary.dart';
import '../../domain/entities/student_summary.dart';

part 'parent_dashboard_dto.freezed.dart';
part 'parent_dashboard_dto.g.dart';

@freezed
abstract class StudentSummaryDto with _$StudentSummaryDto {
  const factory StudentSummaryDto({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'classe') String? classe,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? section,
    @Default(<String>[]) List<String> subjects,
  }) = _StudentSummaryDto;

  factory StudentSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$StudentSummaryDtoFromJson(json);
}

extension StudentSummaryDtoX on StudentSummaryDto {
  StudentSummary toEntity() => StudentSummary(
        id: id,
        firstName: firstName,
        lastName: lastName,
        classe: classe ?? '',
        avatarUrl: avatarUrl,
        section: section,
        subjects: subjects,
      );
}

@freezed
abstract class ReservationSummaryDto with _$ReservationSummaryDto {
  const factory ReservationSummaryDto({
    required String id,
    @JsonKey(name: 'reference') String? reference,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'child_name') String? childName,
    @Default(<String>[]) List<String> subjects,
    @JsonKey(name: 'amount') int? amount,
  }) = _ReservationSummaryDto;

  factory ReservationSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationSummaryDtoFromJson(json);
}

extension ReservationSummaryDtoX on ReservationSummaryDto {
  ReservationSummary toEntity() => ReservationSummary(
        id: id,
        reference: reference ?? '#$id',
        status: _parseReservationStatus(status),
        childName: childName ?? '',
        subjects: subjects,
        amount: amount,
      );
}

@freezed
abstract class SessionSummaryDto with _$SessionSummaryDto {
  const factory SessionSummaryDto({
    required String id,
    @JsonKey(name: 'start_at') required String startAt,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    @JsonKey(name: 'subject') String? subject,
    @JsonKey(name: 'tutor_name') String? tutorName,
    @JsonKey(name: 'child_name') String? childName,
    @JsonKey(name: 'status') String? status,
  }) = _SessionSummaryDto;

  factory SessionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryDtoFromJson(json);
}

extension SessionSummaryDtoX on SessionSummaryDto {
  SessionSummary toEntity() => SessionSummary(
        id: id,
        startAt: DateTime.tryParse(startAt) ?? DateTime.now(),
        durationMinutes: durationMinutes,
        subject: subject ?? '',
        tutorName: tutorName ?? '',
        childName: childName ?? '',
        status: _parseSessionStatus(status),
      );
}

@freezed
abstract class ParentDashboardDto with _$ParentDashboardDto {
  const factory ParentDashboardDto({
    @Default(<StudentSummaryDto>[]) List<StudentSummaryDto> students,
    @JsonKey(name: 'today_sessions')
    @Default(<SessionSummaryDto>[])
    List<SessionSummaryDto> todaySessions,
    @JsonKey(name: 'recent_reservations')
    @Default(<ReservationSummaryDto>[])
    List<ReservationSummaryDto> recentReservations,
  }) = _ParentDashboardDto;

  factory ParentDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$ParentDashboardDtoFromJson(json);
}

extension ParentDashboardDtoX on ParentDashboardDto {
  ParentDashboard toEntity() => ParentDashboard(
        students: students.map((e) => e.toEntity()).toList(),
        todaySessions: todaySessions.map((e) => e.toEntity()).toList(),
        recentReservations:
            recentReservations.map((e) => e.toEntity()).toList(),
      );
}

ReservationStatus _parseReservationStatus(String? raw) => switch (raw) {
      'draft' => ReservationStatus.draft,
      'pending' => ReservationStatus.pending,
      'proposed_price' => ReservationStatus.proposedPrice,
      'negotiation' => ReservationStatus.negotiation,
      'accepted' => ReservationStatus.accepted,
      'active' => ReservationStatus.active,
      'completed' => ReservationStatus.completed,
      'rejected' => ReservationStatus.rejected,
      'cancelled' => ReservationStatus.cancelled,
      _ => ReservationStatus.unknown,
    };

SessionStatus _parseSessionStatus(String? raw) => switch (raw) {
      'pending' => SessionStatus.pending,
      'completed' => SessionStatus.completed,
      'approved' => SessionStatus.approved,
      'rejected' => SessionStatus.rejected,
      _ => SessionStatus.unknown,
    };
