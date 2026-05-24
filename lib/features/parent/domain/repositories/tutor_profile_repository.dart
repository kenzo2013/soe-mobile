import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/tutor_profile.dart';

abstract interface class TutorProfileRepository {
  Future<Result<TutorProfile, Failure>> getPublic(String tutorId);
}
