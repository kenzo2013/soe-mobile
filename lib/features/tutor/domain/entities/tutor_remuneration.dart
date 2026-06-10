enum RemunerationStatus { paid, pending, unknown }

/// Versement de rémunération (`GET /tutors/remunerations`).
class TutorRemuneration {
  const TutorRemuneration({
    required this.id,
    required this.period,
    required this.amount,
    required this.status,
    required this.sessions,
    this.paidOn,
    this.method,
  });

  final String id;
  final String period;
  final int amount;
  final RemunerationStatus status;
  final int sessions;
  final String? paidOn;
  final String? method;
}

/// Résumé annuel affiché dans le hero de l'écran rémunérations.
class TutorEarningsSummary {
  const TutorEarningsSummary({
    required this.year,
    required this.totalEarned,
    required this.totalSessions,
    required this.totalStudents,
    required this.averageRate,
  });

  final int year;
  final int totalEarned;
  final int totalSessions;
  final int totalStudents;
  final int averageRate;
}

/// Agrégat retourné par l'écran rémunérations.
class TutorRemunerations {
  const TutorRemunerations({required this.summary, required this.items});
  final TutorEarningsSummary summary;
  final List<TutorRemuneration> items;
}
