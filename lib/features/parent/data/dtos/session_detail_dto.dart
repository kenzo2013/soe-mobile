import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/session_detail.dart';
import '../../domain/entities/session_summary.dart';

part 'session_detail_dto.freezed.dart';
part 'session_detail_dto.g.dart';

@freezed
abstract class SessionTaskDto with _$SessionTaskDto {
  const factory SessionTaskDto({
    required String id,
    required String title,
    @Default(false) bool done,
    @JsonKey(name: 'due_date') String? dueDate,
  }) = _SessionTaskDto;
  factory SessionTaskDto.fromJson(Map<String, dynamic> json) =>
      _$SessionTaskDtoFromJson(json);
}

@freezed
abstract class SessionReportDto with _$SessionReportDto {
  const factory SessionReportDto({
    @Default('') String summary,
    @Default(<String>[]) List<String> attachments,
    double? rating,
    @JsonKey(name: 'submitted_at') String? submittedAt,
  }) = _SessionReportDto;
  factory SessionReportDto.fromJson(Map<String, dynamic> json) =>
      _$SessionReportDtoFromJson(json);
}

@freezed
abstract class SessionDetailDto with _$SessionDetailDto {
  const factory SessionDetailDto({
    required String id,
    @JsonKey(name: 'start_at') required String startAt,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    String? subject,
    @JsonKey(name: 'tutor_name') String? tutorName,
    @JsonKey(name: 'tutor_id') String? tutorId,
    @JsonKey(name: 'child_name') String? childName,
    String? status,
    String? location,
    String? notes,
    SessionReportDto? report,
    @Default(<SessionTaskDto>[]) List<SessionTaskDto> tasks,
  }) = _SessionDetailDto;
  factory SessionDetailDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDetailDtoFromJson(json);
}

extension SessionDetailDtoX on SessionDetailDto {
  SessionDetail toEntity() => SessionDetail(
        id: id,
        startAt: DateTime.tryParse(startAt) ?? DateTime.now(),
        durationMinutes: durationMinutes,
        subject: subject ?? '',
        tutorName: tutorName ?? '',
        tutorId: tutorId,
        childName: childName ?? '',
        status: _parseSessionStatus(status),
        location: location,
        notes: notes,
        report: report == null
            ? null
            : SessionReport(
                summary: report!.summary,
                attachments: report!.attachments,
                rating: report!.rating,
                submittedAt: DateTime.tryParse(report!.submittedAt ?? ''),
              ),
        tasks: tasks
            .map((t) => SessionTask(
                  id: t.id,
                  title: t.title,
                  done: t.done,
                  dueDate: DateTime.tryParse(t.dueDate ?? ''),
                ))
            .toList(),
      );
}

SessionStatus _parseSessionStatus(String? raw) => switch (raw) {
      'pending' => SessionStatus.pending,
      'completed' => SessionStatus.completed,
      'approved' => SessionStatus.approved,
      'rejected' => SessionStatus.rejected,
      _ => SessionStatus.unknown,
    };
