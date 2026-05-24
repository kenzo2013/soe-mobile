class TutorTraining {
  const TutorTraining({
    required this.degree,
    required this.field,
    required this.year,
    this.institution,
  });
  final String degree;
  final String field;
  final String year;
  final String? institution;
}

class TutorWork {
  const TutorWork({
    required this.position,
    required this.organization,
    required this.period,
  });
  final String position;
  final String organization;
  final String period;
}

class TutorAvailability {
  const TutorAvailability({required this.weekday, required this.timeRange});
  final int weekday; // 1=Lundi … 7=Dimanche
  final String timeRange;
}

class TutorReview {
  const TutorReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
  final String author;
  final double rating;
  final String comment;
  final DateTime date;
}

class TutorProfile {
  const TutorProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.subjects,
    this.bio,
    this.avatarUrl,
    this.city,
    this.experienceYears = 0,
    this.sessionCount = 0,
    this.trainings = const [],
    this.works = const [],
    this.availabilities = const [],
    this.reviews = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final double rating;
  final int reviewCount;
  final String category;
  final List<String> subjects;
  final String? bio;
  final String? avatarUrl;
  final String? city;
  final int experienceYears;
  final int sessionCount;
  final List<TutorTraining> trainings;
  final List<TutorWork> works;
  final List<TutorAvailability> availabilities;
  final List<TutorReview> reviews;

  String get fullName => '$firstName $lastName';
}
