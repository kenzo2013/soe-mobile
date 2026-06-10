/// Créneau hebdomadaire d'un programme (`schedules[]`).
class ProgramSchedule {
  const ProgramSchedule({required this.day, required this.timeSlot});

  /// Jour localisé (`localized_day`, ex. « Lundi »).
  final String day;

  /// Plage horaire formatée (`time_slot`, ex. « 16:00 - 18:00 »).
  final String timeSlot;
}

/// Une ligne de programme = un élève (un `tutoring_request`) au sein d'une
/// réservation : matières, période, fréquence, tuteur(s) et planning.
class ProgramLine {
  const ProgramLine({
    required this.studentName,
    required this.schoolClass,
    required this.subjects,
    required this.tutors,
    required this.schedules,
    required this.frequency,
    this.startDate,
    this.endDate,
  });

  final String studentName;
  final String schoolClass;
  final List<String> subjects;
  final List<String> tutors;
  final List<ProgramSchedule> schedules;

  /// Séances par semaine.
  final int frequency;

  /// Dates formatées pour l'affichage (ex. « 10 mai 2026 »).
  final String? startDate;
  final String? endDate;
}

/// Programme proposé = une réservation assignée + son emploi du temps
/// (`GET /parents/proposed_programs`, CDC §6).
class ParentProgram {
  const ParentProgram({
    required this.id,
    required this.reference,
    required this.quoteStatus,
    required this.totalAmount,
    required this.lines,
  });

  final String id;
  final String reference;

  /// Statut du devis (`quote_status` : accepted / proposed / pending / …).
  final String quoteStatus;

  /// Montant mensuel total (FCFA).
  final int totalAmount;

  /// Une ligne par élève concerné par la réservation.
  final List<ProgramLine> lines;
}
