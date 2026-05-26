class ParentReview {
  const ParentReview({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.subjects = const [],
  });
  final String id;
  final String tutorId;
  final String tutorName;

  /// Note 1..5 (entier) — CDC §11.5.
  final int rating;
  final String comment;
  final DateTime createdAt;
  final List<String> subjects;
}

class ReviewParams {
  const ReviewParams({
    required this.tutorId,
    required this.rating,
    required this.comment,
    this.subjectIds = const [],
  });
  final String tutorId;
  final int rating;
  final String comment;
  final List<String> subjectIds;
}
