import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/tutor_profile.dart';

abstract interface class TutorProfileRepository {
  /// CDC §4.3 : le profil est scopé par enfant
  /// (GET /parents/students/:student_id/tutor_information/:tutor_id).
  Future<Result<TutorProfile, Failure>> getPublic({
    required String studentId,
    required String tutorId,
  });
}
