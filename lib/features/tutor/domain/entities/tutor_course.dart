/// Un créneau de l'emploi du temps d'un élève.
class TutorCourseSlot {
  const TutorCourseSlot({
    required this.day,
    required this.timeRange,
    required this.subject,
  });

  final String day;
  final String timeRange;
  final String subject;
}

/// Cours actif = réservation assignée (`GET /tutors/tutoring_courses`).
class TutorActiveCourse {
  const TutorActiveCourse({
    required this.id,
    required this.reference,
    required this.student,
    required this.classe,
    required this.subjects,
    required this.schedule,
    required this.start,
  });

  final String id;
  final String reference;
  final String student;
  final String classe;
  final List<String> subjects;
  final String schedule;
  final String start;
}

/// Détail d'un cours : élève + emploi du temps.
class TutorCourseDetail {
  const TutorCourseDetail({
    required this.id,
    required this.student,
    required this.age,
    required this.gender,
    required this.classe,
    required this.subjects,
    required this.slots,
  });

  final String id;
  final String student;
  final int age;
  final String gender;
  final String classe;
  final List<String> subjects;
  final List<TutorCourseSlot> slots;
}
