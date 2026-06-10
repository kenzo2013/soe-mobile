import 'tutor_dashboard.dart' show TutorSessionStatus;

export 'tutor_dashboard.dart' show TutorSessionStatus;

/// Séance (résumé) dans la liste groupée par jour (`GET /tutors/sessions`).
class TutorSession {
  const TutorSession({
    required this.id,
    required this.timeRange,
    required this.student,
    required this.subject,
    required this.status,
    required this.editable,
    required this.reportAvailable,
    required this.reportSubmitted,
  });

  final String id;
  final String timeRange;
  final String student;

  /// Ex: `Mathématiques · 4ème`.
  final String subject;
  final TutorSessionStatus status;

  /// `true` si la séance peut encore être modifiée (> 24h).
  final bool editable;

  /// `true` si le rapport peut/doit être soumis.
  final bool reportAvailable;
  final bool reportSubmitted;
}

/// Groupe de séances par jour.
class TutorSessionGroup {
  const TutorSessionGroup({required this.day, required this.items});
  final String day;
  final List<TutorSession> items;
}

/// Détail d'une séance (`GET /tutors/sessions/:id/details`).
class TutorSessionDetail {
  const TutorSessionDetail({
    required this.id,
    required this.subject,
    required this.dateLine,
    required this.timeRange,
    required this.student,
    required this.classe,
    required this.reservationRef,
    required this.status,
    required this.editable,
    required this.editableReason,
    required this.reportAvailable,
    required this.reportReason,
  });

  final String id;
  final String subject;
  final String dateLine;
  final String timeRange;
  final String student;
  final String classe;
  final String reservationRef;
  final TutorSessionStatus status;
  final bool editable;
  final String editableReason;
  final bool reportAvailable;
  final String reportReason;
}
