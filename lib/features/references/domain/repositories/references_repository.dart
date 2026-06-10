import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/school_class.dart';
import '../entities/subject.dart';

abstract interface class ReferencesRepository {
  Future<Result<SchoolClassReferences, Failure>> listSchoolClasses({
    String? education,
    String? section,
  });

  Future<Result<List<Subject>, Failure>> listSubjects();
}
