class ParentReview {
  const ParentReview({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    required this.score,
    required this.comment,
    required this.createdAt,
  });
  final String id;
  final String tutorId;
  final String tutorName;
  final String subject;
  final int score;
  final String comment;
  final DateTime createdAt;
}

class ReviewParams {
  const ReviewParams({
    required this.tutorId,
    required this.score,
    required this.comment,
    this.subject,
  });
  final String tutorId;
  final int score;
  final String comment;
  final String? subject;
}
