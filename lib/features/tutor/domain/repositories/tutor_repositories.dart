import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/tutor_contract.dart';
import '../entities/tutor_course.dart';
import '../entities/tutor_dashboard.dart';
import '../entities/tutor_form_params.dart';
import '../entities/tutor_job.dart';
import '../entities/tutor_payment_method.dart';
import '../entities/tutor_profile.dart';
import '../entities/tutor_remuneration.dart';
import '../entities/tutor_session.dart';

abstract interface class TutorDashboardRepository {
  Future<Result<TutorDashboard, Failure>> get();
}

abstract interface class TutorProfileRepository {
  Future<Result<TutorProfile, Failure>> profile();
  Future<Result<void, Failure>> saveBio(String content);

  Future<Result<List<TutorTraining>, Failure>> trainings();
  Future<Result<void, Failure>> saveTraining(
    TutorTrainingParams params, {
    String? id,
  });
  Future<Result<void, Failure>> deleteTraining(String id);

  Future<Result<List<TutorWork>, Failure>> works();
  Future<Result<void, Failure>> saveWork(TutorWorkParams params, {String? id});
  Future<Result<void, Failure>> deleteWork(String id);

  Future<Result<List<TutorIdentity>, Failure>> identities();
  Future<Result<void, Failure>> createIdentity(TutorIdentityParams params);
  Future<Result<void, Failure>> updateIdentity(
    String id,
    TutorIdentityParams params,
  );
  Future<Result<void, Failure>> deleteIdentity(String id);

  Future<Result<List<TutorTeachingCourse>, Failure>> teachingCourses();
  Future<Result<void, Failure>> saveTeachingCourse(
    TutorTeachingCourseParams params, {
    String? id,
  });
  Future<Result<void, Failure>> deleteTeachingCourse(String id);

  Future<Result<List<TutorDayAvailability>, Failure>> availabilities();
  Future<Result<void, Failure>> createAvailability(
    TutorAvailabilityParams params,
  );
  Future<Result<void, Failure>> deleteAvailability(String id);
}

abstract interface class TutorJobsRepository {
  Future<Result<List<TutorJob>, Failure>> list();
  Future<Result<TutorJob, Failure>> get(String id);
  Future<Result<void, Failure>> apply(String jobId);
}

abstract interface class TutorCoursesRepository {
  Future<Result<List<TutorActiveCourse>, Failure>> list();
  Future<Result<TutorCourseDetail, Failure>> get({
    required String studentId,
    String? reservationId,
  });
  Future<Result<void, Failure>> manageSchedules(Map<String, dynamic> payload);
}

abstract interface class TutorSessionsRepository {
  Future<Result<List<TutorSessionGroup>, Failure>> groups();
  Future<Result<TutorSessionDetail, Failure>> get(String id);
  Future<Result<void, Failure>> updateSession(
    String id,
    TutorSessionEditParams params,
  );
  Future<Result<void, Failure>> submitReport(
    String sessionId,
    TutorSessionReportParams params,
  );
}

abstract interface class TutorRemunerationsRepository {
  Future<Result<TutorRemunerations, Failure>> get();
}

abstract interface class TutorPaymentRepository {
  Future<Result<List<TutorPaymentMethod>, Failure>> list();
  Future<Result<void, Failure>> addMobile(
    TutorMobilePaymentParams params, {
    String? id,
  });
  Future<Result<void, Failure>> addBank(
    TutorBankPaymentParams params, {
    String? id,
  });
  Future<Result<void, Failure>> markDefault(String id);
  Future<Result<void, Failure>> remove(String id);
}

abstract interface class TutorContractsRepository {
  Future<Result<List<TutorContract>, Failure>> list();
  Future<Result<void, Failure>> sign(String id, File signature);
}
