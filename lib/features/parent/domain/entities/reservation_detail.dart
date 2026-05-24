import 'reservation_summary.dart';

class TutorMini {
  const TutorMini({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.category,
    this.rating,
    this.reviewCount,
    this.avatarUrl,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final String? avatarUrl;
  String get fullName => '$firstName $lastName';
}

class ReservationDetail {
  const ReservationDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.childId,
    required this.childName,
    required this.subjects,
    required this.frequency,
    required this.estimatedStartDate,
    required this.preferredTutorGender,
    required this.location,
    this.amount,
    this.amountPerSession,
    this.sessionCount,
    this.programText,
    this.tutor,
    this.createdAt,
  });

  final String id;
  final String reference;
  final ReservationStatus status;
  final String childId;
  final String childName;
  final List<String> subjects;
  final int frequency;
  final DateTime estimatedStartDate;
  final String preferredTutorGender;
  final String location;
  final int? amount;
  final int? amountPerSession;
  final int? sessionCount;
  final String? programText;
  final TutorMini? tutor;
  final DateTime? createdAt;
}

enum TutorGenderPref { noPreference, male, female }

class NewReservationParams {
  const NewReservationParams({
    required this.childId,
    required this.subjects,
    required this.frequency,
    required this.estimatedStartDate,
    required this.preferredTutorGender,
    this.location,
  });

  final String childId;
  final List<String> subjects;
  final int frequency;
  final DateTime estimatedStartDate;
  final TutorGenderPref preferredTutorGender;
  final String? location;
}
