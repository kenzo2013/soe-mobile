/// Offre d'emploi proposée au tuteur (`GET /tutors/jobs`).
class TutorJob {
  const TutorJob({
    required this.id,
    required this.title,
    required this.pricePerHour,
    required this.frequency,
    required this.start,
    required this.subjects,
    required this.classes,
    required this.location,
    required this.posted,
    required this.applied,
    required this.summary,
  });

  final String id;
  final String title;
  final int pricePerHour;
  final String frequency;
  final String start;
  final List<String> subjects;
  final List<String> classes;
  final String location;
  final String posted;
  final bool applied;
  final String summary;
}
