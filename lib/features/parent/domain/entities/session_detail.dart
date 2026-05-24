import 'session_summary.dart';

class SessionTask {
  const SessionTask({
    required this.id,
    required this.title,
    this.done = false,
    this.dueDate,
  });
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
}

class SessionReport {
  const SessionReport({
    required this.summary,
    this.attachments = const [],
    this.rating,
    this.submittedAt,
  });
  final String summary;
  final List<String> attachments;
  final double? rating;
  final DateTime? submittedAt;
}

class SessionDetail {
  const SessionDetail({
    required this.id,
    required this.startAt,
    required this.durationMinutes,
    required this.subject,
    required this.tutorName,
    required this.childName,
    required this.status,
    this.location,
    this.notes,
    this.report,
    this.tasks = const [],
  });

  final String id;
  final DateTime startAt;
  final int durationMinutes;
  final String subject;
  final String tutorName;
  final String childName;
  final SessionStatus status;
  final String? location;
  final String? notes;
  final SessionReport? report;
  final List<SessionTask> tasks;
}
