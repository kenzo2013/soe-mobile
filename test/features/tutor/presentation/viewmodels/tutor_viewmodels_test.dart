import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/tutor/domain/entities/tutor_contract.dart';
import 'package:soe/features/tutor/domain/entities/tutor_course.dart';
import 'package:soe/features/tutor/domain/entities/tutor_dashboard.dart';
import 'package:soe/features/tutor/domain/entities/tutor_job.dart';
import 'package:soe/features/tutor/domain/entities/tutor_payment_method.dart';
import 'package:soe/features/tutor/domain/entities/tutor_profile.dart';
import 'package:soe/features/tutor/domain/entities/tutor_remuneration.dart';
import 'package:soe/features/tutor/domain/entities/tutor_session.dart';
import 'package:soe/features/tutor/domain/usecases/tutor_usecases.dart';
import 'package:soe/features/tutor/presentation/viewmodels/tutor_async_state.dart';
import 'package:soe/features/tutor/presentation/viewmodels/tutor_viewmodels.dart';

// ── Mocks des usecases ───────────────────────────────────────
class _MockGetTutorDashboard extends Mock implements GetTutorDashboard {}

class _MockGetTutorProfile extends Mock implements GetTutorProfile {}

class _MockListTutorTrainings extends Mock implements ListTutorTrainings {}

class _MockListTutorWorks extends Mock implements ListTutorWorks {}

class _MockListTutorIdentities extends Mock implements ListTutorIdentities {}

class _MockListTutorTeachingCourses extends Mock
    implements ListTutorTeachingCourses {}

class _MockListTutorAvailabilities extends Mock
    implements ListTutorAvailabilities {}

class _MockListTutorJobs extends Mock implements ListTutorJobs {}

class _MockGetTutorJob extends Mock implements GetTutorJob {}

class _MockListTutorCourses extends Mock implements ListTutorCourses {}

class _MockGetTutorCourse extends Mock implements GetTutorCourse {}

class _MockListTutorSessionGroups extends Mock
    implements ListTutorSessionGroups {}

class _MockGetTutorSession extends Mock implements GetTutorSession {}

class _MockGetTutorRemunerations extends Mock
    implements GetTutorRemunerations {}

class _MockListTutorPaymentMethods extends Mock
    implements ListTutorPaymentMethods {}

class _MockListTutorContracts extends Mock implements ListTutorContracts {}

const _failure = NetworkFailure();

// ── Fixtures ─────────────────────────────────────────────────
const _dashboard = TutorDashboard(
  firstName: 'Paul',
  stats: TutorStats(
    totalStudents: 12,
    totalSessions: 48,
    pendingSessions: 3,
    completedSessions: 45,
  ),
  todaySessions: [],
);
const _profile = TutorProfile(
  firstName: 'Paul',
  lastName: 'Mbarga',
  email: 'p@soe.cm',
  phone: '+237',
  city: 'Yaoundé',
  category: 'Doctorant',
  rating: 4.9,
  reviews: 23,
  bio: 'Bio',
  completion: 100,
);
const _training = TutorTraining(
  id: 'tr1',
  category: 'Universitaire',
  level: 'Master',
  domain: 'Maths',
  specialty: 'Algèbre',
  date: '2022',
);
const _work = TutorWork(
  id: 'w1',
  title: 'Tuteur',
  company: 'SOE',
  current: true,
  since: '2023',
);
const _identity = TutorIdentity(
  id: 'i1',
  type: 'CNI',
  expires: '2029',
  dob: '1995',
  photoUrls: ['https://x/a.jpg', 'https://x/b.jpg'],
  status: TutorIdentityStatus.approved,
);
const _teaching = TutorTeachingCourse(id: 'tc1', classe: '4ème', subjects: []);
const _availability =
    TutorDayAvailability(dayKey: 'mon', label: 'Lun', slots: []);
const _job = TutorJob(
  id: 'j1',
  title: 'Maths',
  pricePerHour: 4500,
  frequency: '3×/sem',
  start: '2026',
  subjects: [],
  classes: [],
  location: 'Yaoundé',
  posted: 'il y a 2j',
  applied: false,
  summary: '',
);
const _activeCourse = TutorActiveCourse(
  id: 'crs1',
  reference: 'RES-1024',
  student: 'Junior',
  classe: '4ème',
  subjects: [],
  schedule: 'Lun',
  start: '2026',
);
const _courseDetail = TutorCourseDetail(
  id: 'crs1',
  student: 'Junior',
  age: 13,
  gender: 'Garçon',
  classe: '4ème',
  subjects: [],
  slots: [],
);
const _sessionGroup = TutorSessionGroup(day: "Aujourd'hui", items: []);
const _sessionDetail = TutorSessionDetail(
  id: 's1',
  subject: 'Maths',
  dateLine: 'Jeudi',
  timeRange: '10:00 – 12:00',
  student: 'Junior',
  classe: '4ème',
  reservationRef: 'RES-1024',
  status: TutorSessionStatus.completed,
  editable: false,
  editableReason: 'Non',
  reportAvailable: true,
  reportReason: 'Oui',
);
const _remunerations = TutorRemunerations(
  summary: TutorEarningsSummary(
    year: 2026,
    totalEarned: 509000,
    totalSessions: 107,
    totalStudents: 4,
    averageRate: 4757,
  ),
  items: [],
);
const _paymentMethod = TutorPaymentMethod(
  id: 'pm1',
  kind: TutorPaymentKind.mobile,
  isDefault: true,
  operator: 'MTN MoMo',
  phone: '+237',
);
const _contract = TutorContract(
  id: 'ct1',
  reference: 'CTR-2026-042',
  parent: 'Marie',
  student: 'Junior',
  signed: false,
  dateLine: 'Reçu',
  monthlyAmount: 162000,
  amendment: false,
);

// ── Helpers : vérifient les 4 états ──────────────────────────
/// Liste (VM hérités d'AsyncListViewModel).
Future<void> verifyList<T>(
  AsyncListViewModel<T> okVm,
  AsyncListViewModel<T> errVm,
) async {
  expect(okVm.state, isA<AsyncListInitial<T>>());
  final f = okVm.load();
  expect(okVm.state, isA<AsyncListLoading<T>>());
  await f;
  expect(okVm.state, isA<AsyncListLoaded<T>>());

  await errVm.load();
  expect(errVm.state, isA<AsyncListError<T>>());
}

/// Objet unique (AsyncObjectViewModel).
Future<void> verifyObject<T>(
  AsyncObjectViewModel<T> okVm,
  AsyncObjectViewModel<T> errVm,
) async {
  expect(okVm.state, isA<AsyncItemInitial<T>>());
  final f = okVm.load();
  expect(okVm.state, isA<AsyncItemLoading<T>>());
  await f;
  expect(okVm.state, isA<AsyncItemLoaded<T>>());

  await errVm.load();
  expect(errVm.state, isA<AsyncItemError<T>>());
}

/// Élément paramétré par id (AsyncItemViewModel).
Future<void> verifyItem<T>(
  AsyncItemViewModel<T> okVm,
  AsyncItemViewModel<T> errVm,
) async {
  expect(okVm.state, isA<AsyncItemInitial<T>>());
  final f = okVm.load('id');
  expect(okVm.state, isA<AsyncItemLoading<T>>());
  await f;
  expect(okVm.state, isA<AsyncItemLoaded<T>>());

  await errVm.load('id');
  expect(errVm.state, isA<AsyncItemError<T>>());
}

void main() {
  // ── Objets uniques ─────────────────────────────────────────
  test('TutorDashboardViewModel · 4 états', () async {
    final ok = _MockGetTutorDashboard();
    final err = _MockGetTutorDashboard();
    when(ok.call).thenAnswer((_) async => const Ok(_dashboard));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyObject(
        TutorDashboardViewModel(ok), TutorDashboardViewModel(err));
  });

  test('TutorProfileViewModel · 4 états', () async {
    final ok = _MockGetTutorProfile();
    final err = _MockGetTutorProfile();
    when(ok.call).thenAnswer((_) async => const Ok(_profile));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyObject(TutorProfileViewModel(ok), TutorProfileViewModel(err));
  });

  test('TutorRemunerationsViewModel · 4 états', () async {
    final ok = _MockGetTutorRemunerations();
    final err = _MockGetTutorRemunerations();
    when(ok.call).thenAnswer((_) async => const Ok(_remunerations));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyObject(
        TutorRemunerationsViewModel(ok), TutorRemunerationsViewModel(err));
  });

  // ── Listes ─────────────────────────────────────────────────
  test('TutorTrainingsViewModel · 4 états', () async {
    final ok = _MockListTutorTrainings();
    final err = _MockListTutorTrainings();
    when(ok.call).thenAnswer((_) async => const Ok([_training]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(TutorTrainingsViewModel(ok), TutorTrainingsViewModel(err));
  });

  test('TutorWorksViewModel · 4 états', () async {
    final ok = _MockListTutorWorks();
    final err = _MockListTutorWorks();
    when(ok.call).thenAnswer((_) async => const Ok([_work]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(TutorWorksViewModel(ok), TutorWorksViewModel(err));
  });

  test('TutorIdentitiesViewModel · 4 états', () async {
    final ok = _MockListTutorIdentities();
    final err = _MockListTutorIdentities();
    when(ok.call).thenAnswer((_) async => const Ok([_identity]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorIdentitiesViewModel(ok), TutorIdentitiesViewModel(err));
  });

  test('TutorTeachingCoursesViewModel · 4 états', () async {
    final ok = _MockListTutorTeachingCourses();
    final err = _MockListTutorTeachingCourses();
    when(ok.call).thenAnswer((_) async => const Ok([_teaching]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorTeachingCoursesViewModel(ok), TutorTeachingCoursesViewModel(err));
  });

  test('TutorAvailabilitiesViewModel · 4 états', () async {
    final ok = _MockListTutorAvailabilities();
    final err = _MockListTutorAvailabilities();
    when(ok.call).thenAnswer((_) async => const Ok([_availability]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorAvailabilitiesViewModel(ok), TutorAvailabilitiesViewModel(err));
  });

  test('TutorJobsListViewModel · 4 états', () async {
    final ok = _MockListTutorJobs();
    final err = _MockListTutorJobs();
    when(ok.call).thenAnswer((_) async => const Ok([_job]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(TutorJobsListViewModel(ok), TutorJobsListViewModel(err));
  });

  test('TutorActiveCoursesViewModel · 4 états', () async {
    final ok = _MockListTutorCourses();
    final err = _MockListTutorCourses();
    when(ok.call).thenAnswer((_) async => const Ok([_activeCourse]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorActiveCoursesViewModel(ok), TutorActiveCoursesViewModel(err));
  });

  test('TutorSessionsListViewModel · 4 états', () async {
    final ok = _MockListTutorSessionGroups();
    final err = _MockListTutorSessionGroups();
    when(ok.call).thenAnswer((_) async => const Ok([_sessionGroup]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorSessionsListViewModel(ok), TutorSessionsListViewModel(err));
  });

  test('TutorPaymentMethodsViewModel · 4 états', () async {
    final ok = _MockListTutorPaymentMethods();
    final err = _MockListTutorPaymentMethods();
    when(ok.call).thenAnswer((_) async => const Ok([_paymentMethod]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(
        TutorPaymentMethodsViewModel(ok), TutorPaymentMethodsViewModel(err));
  });

  test('TutorContractsViewModel · 4 états', () async {
    final ok = _MockListTutorContracts();
    final err = _MockListTutorContracts();
    when(ok.call).thenAnswer((_) async => const Ok([_contract]));
    when(err.call).thenAnswer((_) async => const Err(_failure));
    await verifyList(TutorContractsViewModel(ok), TutorContractsViewModel(err));
  });

  // ── Éléments par id ────────────────────────────────────────
  test('TutorJobDetailViewModel · 4 états', () async {
    final ok = _MockGetTutorJob();
    final err = _MockGetTutorJob();
    when(() => ok.call(any())).thenAnswer((_) async => const Ok(_job));
    when(() => err.call(any())).thenAnswer((_) async => const Err(_failure));
    await verifyItem(TutorJobDetailViewModel(ok), TutorJobDetailViewModel(err));
  });

  test('TutorCourseDetailViewModel · 4 états', () async {
    final ok = _MockGetTutorCourse();
    final err = _MockGetTutorCourse();
    when(() => ok(studentId: any(named: 'studentId')))
        .thenAnswer((_) async => const Ok(_courseDetail));
    when(() => err(studentId: any(named: 'studentId')))
        .thenAnswer((_) async => const Err(_failure));
    await verifyItem(
        TutorCourseDetailViewModel(ok), TutorCourseDetailViewModel(err));
  });

  test('TutorSessionDetailViewModel · 4 états', () async {
    final ok = _MockGetTutorSession();
    final err = _MockGetTutorSession();
    when(() => ok.call(any()))
        .thenAnswer((_) async => const Ok(_sessionDetail));
    when(() => err.call(any())).thenAnswer((_) async => const Err(_failure));
    await verifyItem(
        TutorSessionDetailViewModel(ok), TutorSessionDetailViewModel(err));
  });

  // ── VM d'action (mutations) ────────────────────────────────
  group('TutorActionViewModel', () {
    test('idle → submitting → success', () async {
      final vm = TutorActionViewModel();
      expect(vm.state, isA<TutorActionIdle>());
      final f = vm.run(() async => const Ok(null));
      expect(vm.state, isA<TutorActionSubmitting>());
      final ok = await f;
      expect(ok, isTrue);
      expect(vm.state, isA<TutorActionSuccess>());
    });

    test('idle → submitting → error', () async {
      final vm = TutorActionViewModel();
      final ok = await vm.run(() async => const Err(_failure));
      expect(ok, isFalse);
      expect(vm.state, isA<TutorActionError>());
    });

    test('ignore les soumissions concurrentes', () async {
      final vm = TutorActionViewModel();
      final f1 = vm.run(() async => const Ok(null));
      final ok2 = await vm.run(() async => const Ok(null));
      expect(ok2, isFalse); // déjà en cours
      await f1;
      expect(vm.state, isA<TutorActionSuccess>());
    });
  });
}
