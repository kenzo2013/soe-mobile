/// Statut d'une séance affichée sur le tableau de bord.
enum TutorSessionStatus { confirmed, pending, inProgress, completed, unknown }

/// Une séance du jour (résumé) — affichée sur le dashboard.
class TutorTodaySession {
  const TutorTodaySession({
    required this.id,
    required this.timeRange,
    required this.student,
    required this.classe,
    required this.subject,
    required this.address,
    required this.status,
  });

  final String id;
  final String timeRange;
  final String student;
  final String classe;
  final String subject;
  final String address;
  final TutorSessionStatus status;
}

/// Statistiques agrégées du tuteur.
class TutorStats {
  const TutorStats({
    required this.totalStudents,
    required this.totalSessions,
    required this.pendingSessions,
    required this.completedSessions,
  });

  final int totalStudents;
  final int totalSessions;
  final int pendingSessions;
  final int completedSessions;
}

/// Données du tableau de bord tuteur (`GET /tutors`).
class TutorDashboard {
  const TutorDashboard({
    required this.firstName,
    required this.stats,
    required this.todaySessions,
  });

  final String firstName;
  final TutorStats stats;
  final List<TutorTodaySession> todaySessions;
}
