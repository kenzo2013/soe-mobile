import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/tutor_profile.dart';
import '../repositories/tutor_profile_repository.dart';

class GetTutorProfile {
  const GetTutorProfile(this._repo);
  final TutorProfileRepository _repo;

  Future<Result<TutorProfile, Failure>> call({
    required String studentId,
    required String tutorId,
  }) =>
      _repo.getPublic(studentId: studentId, tutorId: tutorId);
}
