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
import '../repositories/tutor_repositories.dart';

// ── Dashboard ────────────────────────────────────────────────
class GetTutorDashboard {
  const GetTutorDashboard(this._r);
  final TutorDashboardRepository _r;
  Future<Result<TutorDashboard, Failure>> call() => _r.get();
}

// ── Profil (lecture) ─────────────────────────────────────────
class GetTutorProfile {
  const GetTutorProfile(this._r);
  final TutorProfileRepository _r;
  Future<Result<TutorProfile, Failure>> call() => _r.profile();
}

class ListTutorTrainings {
  const ListTutorTrainings(this._r);
  final TutorProfileRepository _r;
  Future<Result<List<TutorTraining>, Failure>> call() => _r.trainings();
}

class ListTutorWorks {
  const ListTutorWorks(this._r);
  final TutorProfileRepository _r;
  Future<Result<List<TutorWork>, Failure>> call() => _r.works();
}

class ListTutorIdentities {
  const ListTutorIdentities(this._r);
  final TutorProfileRepository _r;
  Future<Result<List<TutorIdentity>, Failure>> call() => _r.identities();
}

class ListTutorTeachingCourses {
  const ListTutorTeachingCourses(this._r);
  final TutorProfileRepository _r;
  Future<Result<List<TutorTeachingCourse>, Failure>> call() =>
      _r.teachingCourses();
}

class ListTutorAvailabilities {
  const ListTutorAvailabilities(this._r);
  final TutorProfileRepository _r;
  Future<Result<List<TutorDayAvailability>, Failure>> call() =>
      _r.availabilities();
}

// ── Profil (écriture) ────────────────────────────────────────
class SaveTutorBio {
  const SaveTutorBio(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String content) => _r.saveBio(content);
}

class SaveTutorTraining {
  const SaveTutorTraining(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(TutorTrainingParams p, {String? id}) =>
      _r.saveTraining(p, id: id);
}

class DeleteTutorTraining {
  const DeleteTutorTraining(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.deleteTraining(id);
}

class SaveTutorWork {
  const SaveTutorWork(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(TutorWorkParams p, {String? id}) =>
      _r.saveWork(p, id: id);
}

class DeleteTutorWork {
  const DeleteTutorWork(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.deleteWork(id);
}

class CreateTutorIdentity {
  const CreateTutorIdentity(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(TutorIdentityParams p) =>
      _r.createIdentity(p);
}

class UpdateTutorIdentity {
  const UpdateTutorIdentity(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id, TutorIdentityParams p) =>
      _r.updateIdentity(id, p);
}

class DeleteTutorIdentity {
  const DeleteTutorIdentity(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.deleteIdentity(id);
}

class SaveTutorTeachingCourse {
  const SaveTutorTeachingCourse(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(
    TutorTeachingCourseParams p, {
    String? id,
  }) =>
      _r.saveTeachingCourse(p, id: id);
}

class DeleteTutorTeachingCourse {
  const DeleteTutorTeachingCourse(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.deleteTeachingCourse(id);
}

class CreateTutorAvailability {
  const CreateTutorAvailability(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(TutorAvailabilityParams p) =>
      _r.createAvailability(p);
}

class DeleteTutorAvailability {
  const DeleteTutorAvailability(this._r);
  final TutorProfileRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.deleteAvailability(id);
}

// ── Offres d'emploi ──────────────────────────────────────────
class ListTutorJobs {
  const ListTutorJobs(this._r);
  final TutorJobsRepository _r;
  Future<Result<List<TutorJob>, Failure>> call() => _r.list();
}

class GetTutorJob {
  const GetTutorJob(this._r);
  final TutorJobsRepository _r;
  Future<Result<TutorJob, Failure>> call(String id) => _r.get(id);
}

class ApplyToJob {
  const ApplyToJob(this._r);
  final TutorJobsRepository _r;
  Future<Result<void, Failure>> call(String jobId) => _r.apply(jobId);
}

// ── Mes cours ────────────────────────────────────────────────
class ListTutorCourses {
  const ListTutorCourses(this._r);
  final TutorCoursesRepository _r;
  Future<Result<List<TutorActiveCourse>, Failure>> call() => _r.list();
}

class GetTutorCourse {
  const GetTutorCourse(this._r);
  final TutorCoursesRepository _r;
  Future<Result<TutorCourseDetail, Failure>> call({
    required String studentId,
    String? reservationId,
  }) =>
      _r.get(studentId: studentId, reservationId: reservationId);
}

class ManageTutorSchedules {
  const ManageTutorSchedules(this._r);
  final TutorCoursesRepository _r;
  Future<Result<void, Failure>> call(Map<String, dynamic> payload) =>
      _r.manageSchedules(payload);
}

// ── Séances ──────────────────────────────────────────────────
class ListTutorSessionGroups {
  const ListTutorSessionGroups(this._r);
  final TutorSessionsRepository _r;
  Future<Result<List<TutorSessionGroup>, Failure>> call() => _r.groups();
}

class GetTutorSession {
  const GetTutorSession(this._r);
  final TutorSessionsRepository _r;
  Future<Result<TutorSessionDetail, Failure>> call(String id) => _r.get(id);
}

class UpdateTutorSession {
  const UpdateTutorSession(this._r);
  final TutorSessionsRepository _r;
  Future<Result<void, Failure>> call(String id, TutorSessionEditParams p) =>
      _r.updateSession(id, p);
}

class SubmitTutorSessionReport {
  const SubmitTutorSessionReport(this._r);
  final TutorSessionsRepository _r;
  Future<Result<void, Failure>> call(
    String sessionId,
    TutorSessionReportParams p,
  ) =>
      _r.submitReport(sessionId, p);
}

// ── Rémunérations ────────────────────────────────────────────
class GetTutorRemunerations {
  const GetTutorRemunerations(this._r);
  final TutorRemunerationsRepository _r;
  Future<Result<TutorRemunerations, Failure>> call() => _r.get();
}

// ── Infos de paiement ────────────────────────────────────────
class ListTutorPaymentMethods {
  const ListTutorPaymentMethods(this._r);
  final TutorPaymentRepository _r;
  Future<Result<List<TutorPaymentMethod>, Failure>> call() => _r.list();
}

class AddTutorMobilePayment {
  const AddTutorMobilePayment(this._r);
  final TutorPaymentRepository _r;
  Future<Result<void, Failure>> call(TutorMobilePaymentParams p,
          {String? id}) =>
      _r.addMobile(p, id: id);
}

class AddTutorBankPayment {
  const AddTutorBankPayment(this._r);
  final TutorPaymentRepository _r;
  Future<Result<void, Failure>> call(TutorBankPaymentParams p, {String? id}) =>
      _r.addBank(p, id: id);
}

class MarkTutorPaymentDefault {
  const MarkTutorPaymentDefault(this._r);
  final TutorPaymentRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.markDefault(id);
}

class DeleteTutorPaymentMethod {
  const DeleteTutorPaymentMethod(this._r);
  final TutorPaymentRepository _r;
  Future<Result<void, Failure>> call(String id) => _r.remove(id);
}

// ── Contrats ─────────────────────────────────────────────────
class ListTutorContracts {
  const ListTutorContracts(this._r);
  final TutorContractsRepository _r;
  Future<Result<List<TutorContract>, Failure>> call() => _r.list();
}

class SignTutorContract {
  const SignTutorContract(this._r);
  final TutorContractsRepository _r;
  Future<Result<void, Failure>> call(String id, File signature) =>
      _r.sign(id, signature);
}
