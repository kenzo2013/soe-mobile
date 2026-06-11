import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/tutor_contracts_remote_datasource.dart';
import '../data/datasources/tutor_courses_remote_datasource.dart';
import '../data/datasources/tutor_dashboard_remote_datasource.dart';
import '../data/datasources/tutor_jobs_remote_datasource.dart';
import '../data/datasources/tutor_payment_remote_datasource.dart';
import '../data/datasources/tutor_profile_remote_datasource.dart';
import '../data/datasources/tutor_remunerations_remote_datasource.dart';
import '../data/datasources/tutor_sessions_remote_datasource.dart';
import '../data/repositories/tutor_repositories_impl.dart';
import '../domain/entities/tutor_contract.dart';
import '../domain/entities/tutor_course.dart';
import '../domain/entities/tutor_dashboard.dart';
import '../domain/entities/tutor_job.dart';
import '../domain/entities/tutor_payment_method.dart';
import '../domain/entities/tutor_profile.dart';
import '../domain/entities/tutor_remuneration.dart';
import '../domain/entities/tutor_session.dart';
import '../domain/repositories/tutor_repositories.dart';
import '../domain/usecases/tutor_usecases.dart';
import 'viewmodels/tutor_async_state.dart';
import 'viewmodels/tutor_viewmodels.dart';

// ─────────────────────────────────────────────────────────────
// DATASOURCES (Dio) — branchés sur l'API réelle (CDC §7.6).
// ─────────────────────────────────────────────────────────────
final tutorDashboardDatasourceProvider =
    Provider<TutorDashboardRemoteDatasource>(
  (ref) => TutorDashboardRemoteDatasource(ref.watch(dioProvider)),
);
final tutorProfileDatasourceProvider = Provider<TutorProfileRemoteDatasource>(
  (ref) => TutorProfileRemoteDatasource(ref.watch(dioProvider)),
);
final tutorJobsDatasourceProvider = Provider<TutorJobsRemoteDatasource>(
  (ref) => TutorJobsRemoteDatasource(ref.watch(dioProvider)),
);
final tutorCoursesDatasourceProvider = Provider<TutorCoursesRemoteDatasource>(
  (ref) => TutorCoursesRemoteDatasource(ref.watch(dioProvider)),
);
final tutorSessionsDatasourceProvider = Provider<TutorSessionsRemoteDatasource>(
  (ref) => TutorSessionsRemoteDatasource(ref.watch(dioProvider)),
);
final tutorRemunerationsDatasourceProvider =
    Provider<TutorRemunerationsRemoteDatasource>(
  (ref) => TutorRemunerationsRemoteDatasource(ref.watch(dioProvider)),
);
final tutorPaymentDatasourceProvider = Provider<TutorPaymentRemoteDatasource>(
  (ref) => TutorPaymentRemoteDatasource(ref.watch(dioProvider)),
);
final tutorContractsDatasourceProvider =
    Provider<TutorContractsRemoteDatasource>(
  (ref) => TutorContractsRemoteDatasource(ref.watch(dioProvider)),
);

// ─────────────────────────────────────────────────────────────
// REPOSITORIES
// ─────────────────────────────────────────────────────────────
final tutorDashboardRepositoryProvider = Provider<TutorDashboardRepository>(
  (ref) =>
      TutorDashboardRepositoryImpl(ref.watch(tutorDashboardDatasourceProvider)),
);
final tutorProfileRepositoryProvider = Provider<TutorProfileRepository>(
  (ref) =>
      TutorProfileRepositoryImpl(ref.watch(tutorProfileDatasourceProvider)),
);
final tutorJobsRepositoryProvider = Provider<TutorJobsRepository>(
  (ref) => TutorJobsRepositoryImpl(ref.watch(tutorJobsDatasourceProvider)),
);
final tutorCoursesRepositoryProvider = Provider<TutorCoursesRepository>(
  (ref) =>
      TutorCoursesRepositoryImpl(ref.watch(tutorCoursesDatasourceProvider)),
);
final tutorSessionsRepositoryProvider = Provider<TutorSessionsRepository>(
  (ref) =>
      TutorSessionsRepositoryImpl(ref.watch(tutorSessionsDatasourceProvider)),
);
final tutorRemunerationsRepositoryProvider =
    Provider<TutorRemunerationsRepository>(
  (ref) => TutorRemunerationsRepositoryImpl(
      ref.watch(tutorRemunerationsDatasourceProvider)),
);
final tutorPaymentRepositoryProvider = Provider<TutorPaymentRepository>(
  (ref) =>
      TutorPaymentRepositoryImpl(ref.watch(tutorPaymentDatasourceProvider)),
);
final tutorContractsRepositoryProvider = Provider<TutorContractsRepository>(
  (ref) =>
      TutorContractsRepositoryImpl(ref.watch(tutorContractsDatasourceProvider)),
);

// ─────────────────────────────────────────────────────────────
// USECASES — lecture
// ─────────────────────────────────────────────────────────────
final getTutorDashboardProvider = Provider<GetTutorDashboard>(
  (ref) => GetTutorDashboard(ref.watch(tutorDashboardRepositoryProvider)),
);
final getTutorProfileProvider = Provider<GetTutorProfile>(
  (ref) => GetTutorProfile(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorTrainingsProvider = Provider<ListTutorTrainings>(
  (ref) => ListTutorTrainings(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorWorksProvider = Provider<ListTutorWorks>(
  (ref) => ListTutorWorks(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorIdentitiesProvider = Provider<ListTutorIdentities>(
  (ref) => ListTutorIdentities(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorTeachingCoursesProvider = Provider<ListTutorTeachingCourses>(
  (ref) => ListTutorTeachingCourses(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorAvailabilitiesProvider = Provider<ListTutorAvailabilities>(
  (ref) => ListTutorAvailabilities(ref.watch(tutorProfileRepositoryProvider)),
);
final listTutorJobsProvider = Provider<ListTutorJobs>(
  (ref) => ListTutorJobs(ref.watch(tutorJobsRepositoryProvider)),
);
final getTutorJobProvider = Provider<GetTutorJob>(
  (ref) => GetTutorJob(ref.watch(tutorJobsRepositoryProvider)),
);
final listTutorCoursesProvider = Provider<ListTutorCourses>(
  (ref) => ListTutorCourses(ref.watch(tutorCoursesRepositoryProvider)),
);
final getTutorCourseProvider = Provider<GetTutorCourse>(
  (ref) => GetTutorCourse(ref.watch(tutorCoursesRepositoryProvider)),
);
final listTutorSessionGroupsProvider = Provider<ListTutorSessionGroups>(
  (ref) => ListTutorSessionGroups(ref.watch(tutorSessionsRepositoryProvider)),
);
final getTutorSessionProvider = Provider<GetTutorSession>(
  (ref) => GetTutorSession(ref.watch(tutorSessionsRepositoryProvider)),
);
final getTutorRemunerationsProvider = Provider<GetTutorRemunerations>(
  (ref) =>
      GetTutorRemunerations(ref.watch(tutorRemunerationsRepositoryProvider)),
);
final listTutorPaymentMethodsProvider = Provider<ListTutorPaymentMethods>(
  (ref) => ListTutorPaymentMethods(ref.watch(tutorPaymentRepositoryProvider)),
);
final listTutorContractsProvider = Provider<ListTutorContracts>(
  (ref) => ListTutorContracts(ref.watch(tutorContractsRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────
// USECASES — écriture
// ─────────────────────────────────────────────────────────────
final saveTutorBioProvider = Provider<SaveTutorBio>(
  (ref) => SaveTutorBio(ref.watch(tutorProfileRepositoryProvider)),
);
final saveTutorTrainingProvider = Provider<SaveTutorTraining>(
  (ref) => SaveTutorTraining(ref.watch(tutorProfileRepositoryProvider)),
);
final deleteTutorTrainingProvider = Provider<DeleteTutorTraining>(
  (ref) => DeleteTutorTraining(ref.watch(tutorProfileRepositoryProvider)),
);
final saveTutorWorkProvider = Provider<SaveTutorWork>(
  (ref) => SaveTutorWork(ref.watch(tutorProfileRepositoryProvider)),
);
final deleteTutorWorkProvider = Provider<DeleteTutorWork>(
  (ref) => DeleteTutorWork(ref.watch(tutorProfileRepositoryProvider)),
);
final createTutorIdentityProvider = Provider<CreateTutorIdentity>(
  (ref) => CreateTutorIdentity(ref.watch(tutorProfileRepositoryProvider)),
);
final updateTutorIdentityProvider = Provider<UpdateTutorIdentity>(
  (ref) => UpdateTutorIdentity(ref.watch(tutorProfileRepositoryProvider)),
);
final deleteTutorIdentityProvider = Provider<DeleteTutorIdentity>(
  (ref) => DeleteTutorIdentity(ref.watch(tutorProfileRepositoryProvider)),
);
final saveTutorTeachingCourseProvider = Provider<SaveTutorTeachingCourse>(
  (ref) => SaveTutorTeachingCourse(ref.watch(tutorProfileRepositoryProvider)),
);
final deleteTutorTeachingCourseProvider = Provider<DeleteTutorTeachingCourse>(
  (ref) => DeleteTutorTeachingCourse(ref.watch(tutorProfileRepositoryProvider)),
);
final createTutorAvailabilityProvider = Provider<CreateTutorAvailability>(
  (ref) => CreateTutorAvailability(ref.watch(tutorProfileRepositoryProvider)),
);
final deleteTutorAvailabilityProvider = Provider<DeleteTutorAvailability>(
  (ref) => DeleteTutorAvailability(ref.watch(tutorProfileRepositoryProvider)),
);
final applyToJobProvider = Provider<ApplyToJob>(
  (ref) => ApplyToJob(ref.watch(tutorJobsRepositoryProvider)),
);
final manageTutorSchedulesProvider = Provider<ManageTutorSchedules>(
  (ref) => ManageTutorSchedules(ref.watch(tutorCoursesRepositoryProvider)),
);
final updateTutorSessionProvider = Provider<UpdateTutorSession>(
  (ref) => UpdateTutorSession(ref.watch(tutorSessionsRepositoryProvider)),
);
final submitTutorSessionReportProvider = Provider<SubmitTutorSessionReport>(
  (ref) => SubmitTutorSessionReport(ref.watch(tutorSessionsRepositoryProvider)),
);
final addTutorMobilePaymentProvider = Provider<AddTutorMobilePayment>(
  (ref) => AddTutorMobilePayment(ref.watch(tutorPaymentRepositoryProvider)),
);
final addTutorBankPaymentProvider = Provider<AddTutorBankPayment>(
  (ref) => AddTutorBankPayment(ref.watch(tutorPaymentRepositoryProvider)),
);
final markTutorPaymentDefaultProvider = Provider<MarkTutorPaymentDefault>(
  (ref) => MarkTutorPaymentDefault(ref.watch(tutorPaymentRepositoryProvider)),
);
final deleteTutorPaymentMethodProvider = Provider<DeleteTutorPaymentMethod>(
  (ref) => DeleteTutorPaymentMethod(ref.watch(tutorPaymentRepositoryProvider)),
);
final signTutorContractProvider = Provider<SignTutorContract>(
  (ref) => SignTutorContract(ref.watch(tutorContractsRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────
// VIEWMODELS — lecture
// ─────────────────────────────────────────────────────────────
final tutorDashboardViewModelProvider = StateNotifierProvider.autoDispose<
    TutorDashboardViewModel, AsyncItemState<TutorDashboard>>(
  (ref) =>
      TutorDashboardViewModel(ref.watch(getTutorDashboardProvider))..load(),
);

final tutorProfileViewModelProvider = StateNotifierProvider.autoDispose<
    TutorProfileViewModel, AsyncItemState<TutorProfile>>(
  (ref) => TutorProfileViewModel(ref.watch(getTutorProfileProvider))..load(),
);

final tutorTrainingsViewModelProvider = StateNotifierProvider.autoDispose<
    TutorTrainingsViewModel, AsyncListState<TutorTraining>>(
  (ref) =>
      TutorTrainingsViewModel(ref.watch(listTutorTrainingsProvider))..load(),
);

final tutorWorksViewModelProvider = StateNotifierProvider.autoDispose<
    TutorWorksViewModel, AsyncListState<TutorWork>>(
  (ref) => TutorWorksViewModel(ref.watch(listTutorWorksProvider))..load(),
);

final tutorIdentitiesViewModelProvider = StateNotifierProvider.autoDispose<
    TutorIdentitiesViewModel, AsyncListState<TutorIdentity>>(
  (ref) =>
      TutorIdentitiesViewModel(ref.watch(listTutorIdentitiesProvider))..load(),
);

final tutorTeachingCoursesViewModelProvider = StateNotifierProvider.autoDispose<
    TutorTeachingCoursesViewModel, AsyncListState<TutorTeachingCourse>>(
  (ref) =>
      TutorTeachingCoursesViewModel(ref.watch(listTutorTeachingCoursesProvider))
        ..load(),
);

final tutorAvailabilitiesViewModelProvider = StateNotifierProvider.autoDispose<
    TutorAvailabilitiesViewModel, AsyncListState<TutorDayAvailability>>(
  (ref) =>
      TutorAvailabilitiesViewModel(ref.watch(listTutorAvailabilitiesProvider))
        ..load(),
);

final tutorJobsListViewModelProvider = StateNotifierProvider.autoDispose<
    TutorJobsListViewModel, AsyncListState<TutorJob>>(
  (ref) => TutorJobsListViewModel(ref.watch(listTutorJobsProvider))..load(),
);

final tutorJobDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorJobDetailViewModel, AsyncItemState<TutorJob>, String>(
  (ref, id) =>
      TutorJobDetailViewModel(ref.watch(getTutorJobProvider))..load(id),
);

final tutorActiveCoursesViewModelProvider = StateNotifierProvider.autoDispose<
    TutorActiveCoursesViewModel, AsyncListState<TutorActiveCourse>>(
  (ref) =>
      TutorActiveCoursesViewModel(ref.watch(listTutorCoursesProvider))..load(),
);

final tutorCourseDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorCourseDetailViewModel, AsyncItemState<TutorCourseDetail>,
        ({String studentId, String? reservationId})>(
  (ref, key) => TutorCourseDetailViewModel(
    ref.watch(getTutorCourseProvider),
    reservationId: key.reservationId,
  )..load(key.studentId),
);

final tutorSessionsListViewModelProvider = StateNotifierProvider.autoDispose<
    TutorSessionsListViewModel, AsyncListState<TutorSessionGroup>>(
  (ref) => TutorSessionsListViewModel(ref.watch(listTutorSessionGroupsProvider))
    ..load(),
);

final tutorSessionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorSessionDetailViewModel, AsyncItemState<TutorSessionDetail>,
        String>(
  (ref, id) =>
      TutorSessionDetailViewModel(ref.watch(getTutorSessionProvider))..load(id),
);

final tutorRemunerationsViewModelProvider = StateNotifierProvider.autoDispose<
    TutorRemunerationsViewModel, AsyncItemState<TutorRemunerations>>(
  (ref) => TutorRemunerationsViewModel(ref.watch(getTutorRemunerationsProvider))
    ..load(),
);

final tutorPaymentMethodsViewModelProvider = StateNotifierProvider.autoDispose<
    TutorPaymentMethodsViewModel, AsyncListState<TutorPaymentMethod>>(
  (ref) =>
      TutorPaymentMethodsViewModel(ref.watch(listTutorPaymentMethodsProvider))
        ..load(),
);

final tutorContractsViewModelProvider = StateNotifierProvider.autoDispose<
    TutorContractsViewModel, AsyncListState<TutorContract>>(
  (ref) =>
      TutorContractsViewModel(ref.watch(listTutorContractsProvider))..load(),
);

// ─────────────────────────────────────────────────────────────
// VIEWMODEL — action générique (mutations / formulaires)
// Clé = identifiant logique de l'action (ex: 'bio', 'candidacy:$id').
// ─────────────────────────────────────────────────────────────
final tutorActionViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorActionViewModel, TutorActionState, String>(
  (ref, _) => TutorActionViewModel(),
);
