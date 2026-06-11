import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/tutor/domain/entities/tutor_contract.dart';
import 'package:soe/features/tutor/domain/entities/tutor_course.dart';
import 'package:soe/features/tutor/domain/entities/tutor_dashboard.dart';
import 'package:soe/features/tutor/domain/entities/tutor_form_params.dart';
import 'package:soe/features/tutor/domain/entities/tutor_job.dart';
import 'package:soe/features/tutor/domain/entities/tutor_payment_method.dart';
import 'package:soe/features/tutor/domain/entities/tutor_profile.dart';
import 'package:soe/features/tutor/domain/entities/tutor_remuneration.dart';
import 'package:soe/features/tutor/domain/entities/tutor_session.dart';
import 'package:soe/features/tutor/domain/repositories/tutor_repositories.dart';
import 'package:soe/features/tutor/domain/usecases/tutor_usecases.dart';

class _MockDashboardRepo extends Mock implements TutorDashboardRepository {}

class _MockProfileRepo extends Mock implements TutorProfileRepository {}

class _MockJobsRepo extends Mock implements TutorJobsRepository {}

class _MockCoursesRepo extends Mock implements TutorCoursesRepository {}

class _MockSessionsRepo extends Mock implements TutorSessionsRepository {}

class _MockRemunerationsRepo extends Mock
    implements TutorRemunerationsRepository {}

class _MockPaymentRepo extends Mock implements TutorPaymentRepository {}

class _MockContractsRepo extends Mock implements TutorContractsRepository {}

// ── Fixtures ────────────────────────────────────────────────────
TutorDashboard _dashboard() => const TutorDashboard(
      firstName: 'Jean',
      stats: TutorStats(
        totalStudents: 1,
        totalSessions: 2,
        pendingSessions: 0,
        completedSessions: 1,
      ),
      todaySessions: [],
    );

TutorProfile _profile() => const TutorProfile(
      firstName: 'Jean',
      lastName: 'Dupont',
      email: 'a@b.com',
      phone: '600',
      city: 'Douala',
      category: 'cat',
      rating: 4.5,
      reviews: 3,
      bio: 'bio',
      completion: 80,
    );

TutorJob _job() => const TutorJob(
      id: 'j1',
      title: 'Maths',
      pricePerHour: 5000,
      frequency: 'weekly',
      start: '2026-01-01',
      subjects: ['Maths'],
      classes: ['4e'],
      location: 'Douala',
      posted: 'hier',
      applied: false,
      summary: 'résumé',
    );

TutorActiveCourse _activeCourse() => const TutorActiveCourse(
      id: 'c1',
      reference: 'ref',
      student: 'Paul',
      classe: '4e',
      subjects: ['Maths'],
      schedule: 'Lun',
      start: '2026-01-01',
    );

TutorCourseDetail _courseDetail() => const TutorCourseDetail(
      id: 'c1',
      student: 'Paul',
      age: 14,
      gender: 'M',
      classe: '4e',
      subjects: ['Maths'],
      slots: [],
    );

TutorSessionGroup _sessionGroup() =>
    const TutorSessionGroup(day: 'Lun', items: []);

TutorSessionDetail _sessionDetail() => const TutorSessionDetail(
      id: 's1',
      subject: 'Maths',
      dateLine: 'Lun 1 jan',
      timeRange: '10h-11h',
      student: 'Paul',
      classe: '4e',
      reservationRef: 'ref',
      status: TutorSessionStatus.confirmed,
      editable: true,
      editableReason: '',
      reportAvailable: false,
      reportReason: '',
    );

TutorRemunerations _remunerations() => const TutorRemunerations(
      summary: TutorEarningsSummary(
        year: 2026,
        totalEarned: 100000,
        totalSessions: 10,
        totalStudents: 3,
        averageRate: 5000,
      ),
      items: [],
    );

TutorPaymentMethod _paymentMethod() => const TutorPaymentMethod(
      id: 'p1',
      kind: TutorPaymentKind.mobile,
      isDefault: true,
    );

TutorContract _contract() => const TutorContract(
      id: 'k1',
      reference: 'ref',
      parent: 'Parent',
      student: 'Paul',
      signed: false,
      dateLine: 'Lun',
      monthlyAmount: 50000,
      amendment: false,
    );

const _err = NetworkFailure();

void main() {
  setUpAll(() {
    registerFallbackValue(const TutorTrainingParams(
      category: 'c',
      level: 'l',
      domain: 'd',
      specialty: 's',
      date: '2026',
    ));
    registerFallbackValue(const TutorWorkParams(
      title: 't',
      company: 'co',
      current: true,
    ));
    registerFallbackValue(TutorIdentityParams(
      documentType: 'cni',
      birthday: '2000',
      expirationDate: '2030',
      images: [File('x.png')],
    ));
    registerFallbackValue(const TutorTeachingCourseParams(
      schoolClassId: 'sc1',
      subjectIds: ['sub1'],
    ));
    registerFallbackValue(const TutorAvailabilityParams(
      weekday: 1,
      startTime: '08:00',
      endTime: '10:00',
    ));
    registerFallbackValue(const TutorSessionEditParams());
    registerFallbackValue(TutorSessionReportParams(
      date: '2026',
      startAt: '08:00',
      endAt: '10:00',
      proceedings: 'ok',
      signature: File('sig.png'),
    ));
    registerFallbackValue(const TutorMobilePaymentParams(
      phone: '600',
      operator: TutorMobileOperator.mtn,
    ));
    registerFallbackValue(const TutorBankPaymentParams(
      accountHolder: 'Jean',
      bankName: 'Bank',
      iban: 'IBAN',
      bic: 'BIC',
    ));
    registerFallbackValue(File('fallback.png'));
    registerFallbackValue(<String, dynamic>{});
  });

  // ── Dashboard ──────────────────────────────────────────────
  group('GetTutorDashboard', () {
    late _MockDashboardRepo repo;
    late GetTutorDashboard usecase;
    setUp(() {
      repo = _MockDashboardRepo();
      usecase = GetTutorDashboard(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.get()).thenAnswer((_) async => Ok(_dashboard()));
      final r = await usecase();
      expect(r, isA<Ok<TutorDashboard, Failure>>());
      verify(() => repo.get()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.get()).thenAnswer((_) async => const Err(_err));
      final r = await usecase();
      expect(
          (r as Err<TutorDashboard, Failure>).failure, isA<NetworkFailure>());
    });
  });

  // ── Profil lecture ─────────────────────────────────────────
  group('GetTutorProfile', () {
    late _MockProfileRepo repo;
    late GetTutorProfile usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = GetTutorProfile(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.profile()).thenAnswer((_) async => Ok(_profile()));
      expect(await usecase(), isA<Ok<TutorProfile, Failure>>());
      verify(() => repo.profile()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.profile()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ListTutorTrainings', () {
    late _MockProfileRepo repo;
    late ListTutorTrainings usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = ListTutorTrainings(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.trainings())
          .thenAnswer((_) async => const Ok(<TutorTraining>[]));
      expect(await usecase(), isA<Ok<List<TutorTraining>, Failure>>());
      verify(() => repo.trainings()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.trainings()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ListTutorWorks', () {
    late _MockProfileRepo repo;
    late ListTutorWorks usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = ListTutorWorks(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.works()).thenAnswer((_) async => const Ok(<TutorWork>[]));
      expect(await usecase(), isA<Ok<List<TutorWork>, Failure>>());
      verify(() => repo.works()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.works()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ListTutorIdentities', () {
    late _MockProfileRepo repo;
    late ListTutorIdentities usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = ListTutorIdentities(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.identities())
          .thenAnswer((_) async => const Ok(<TutorIdentity>[]));
      expect(await usecase(), isA<Ok<List<TutorIdentity>, Failure>>());
      verify(() => repo.identities()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.identities()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ListTutorTeachingCourses', () {
    late _MockProfileRepo repo;
    late ListTutorTeachingCourses usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = ListTutorTeachingCourses(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.teachingCourses())
          .thenAnswer((_) async => const Ok(<TutorTeachingCourse>[]));
      expect(await usecase(), isA<Ok<List<TutorTeachingCourse>, Failure>>());
      verify(() => repo.teachingCourses()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.teachingCourses())
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ListTutorAvailabilities', () {
    late _MockProfileRepo repo;
    late ListTutorAvailabilities usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = ListTutorAvailabilities(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.availabilities())
          .thenAnswer((_) async => const Ok(<TutorDayAvailability>[]));
      expect(await usecase(), isA<Ok<List<TutorDayAvailability>, Failure>>());
      verify(() => repo.availabilities()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.availabilities())
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Profil écriture ────────────────────────────────────────
  group('SaveTutorBio', () {
    late _MockProfileRepo repo;
    late SaveTutorBio usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = SaveTutorBio(repo);
    });

    test('returns Ok and forwards content', () async {
      when(() => repo.saveBio(any())).thenAnswer((_) async => const Ok(null));
      expect(await usecase('hello'), isA<Ok<void, Failure>>());
      verify(() => repo.saveBio('hello')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.saveBio(any())).thenAnswer((_) async => const Err(_err));
      expect((await usecase('x') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('SaveTutorTraining', () {
    late _MockProfileRepo repo;
    late SaveTutorTraining usecase;
    final params = const TutorTrainingParams(
      category: 'c',
      level: 'l',
      domain: 'd',
      specialty: 's',
      date: '2026',
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = SaveTutorTraining(repo);
    });

    test('returns Ok and forwards params + id', () async {
      when(() => repo.saveTraining(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params, id: 't1'), isA<Ok<void, Failure>>());
      verify(() => repo.saveTraining(params, id: 't1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.saveTraining(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorTraining', () {
    late _MockProfileRepo repo;
    late DeleteTutorTraining usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = DeleteTutorTraining(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.deleteTraining(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('t1'), isA<Ok<void, Failure>>());
      verify(() => repo.deleteTraining('t1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.deleteTraining(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('t1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('SaveTutorWork', () {
    late _MockProfileRepo repo;
    late SaveTutorWork usecase;
    final params = const TutorWorkParams(
      title: 't',
      company: 'co',
      current: true,
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = SaveTutorWork(repo);
    });

    test('returns Ok and forwards params + id', () async {
      when(() => repo.saveWork(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params, id: 'w1'), isA<Ok<void, Failure>>());
      verify(() => repo.saveWork(params, id: 'w1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.saveWork(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorWork', () {
    late _MockProfileRepo repo;
    late DeleteTutorWork usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = DeleteTutorWork(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.deleteWork(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('w1'), isA<Ok<void, Failure>>());
      verify(() => repo.deleteWork('w1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.deleteWork(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('w1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('CreateTutorIdentity', () {
    late _MockProfileRepo repo;
    late CreateTutorIdentity usecase;
    final params = TutorIdentityParams(
      documentType: 'cni',
      birthday: '2000',
      expirationDate: '2030',
      images: [File('x.png')],
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = CreateTutorIdentity(repo);
    });

    test('returns Ok and forwards params', () async {
      when(() => repo.createIdentity(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params), isA<Ok<void, Failure>>());
      verify(() => repo.createIdentity(params)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.createIdentity(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('UpdateTutorIdentity', () {
    late _MockProfileRepo repo;
    late UpdateTutorIdentity usecase;
    final params = TutorIdentityParams(
      documentType: 'cni',
      birthday: '2000',
      expirationDate: '2030',
      images: [File('x.png')],
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = UpdateTutorIdentity(repo);
    });

    test('returns Ok and forwards id + params', () async {
      when(() => repo.updateIdentity(any(), any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('i1', params), isA<Ok<void, Failure>>());
      verify(() => repo.updateIdentity('i1', params)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.updateIdentity(any(), any()))
          .thenAnswer((_) async => const Err(_err));
      expect(
          (await usecase('i1', params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorIdentity', () {
    late _MockProfileRepo repo;
    late DeleteTutorIdentity usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = DeleteTutorIdentity(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.deleteIdentity(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('i1'), isA<Ok<void, Failure>>());
      verify(() => repo.deleteIdentity('i1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.deleteIdentity(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('i1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('SaveTutorTeachingCourse', () {
    late _MockProfileRepo repo;
    late SaveTutorTeachingCourse usecase;
    final params = const TutorTeachingCourseParams(
      schoolClassId: 'sc1',
      subjectIds: ['sub1'],
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = SaveTutorTeachingCourse(repo);
    });

    test('returns Ok and forwards params + id', () async {
      when(() => repo.saveTeachingCourse(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params, id: 'tc1'), isA<Ok<void, Failure>>());
      verify(() => repo.saveTeachingCourse(params, id: 'tc1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.saveTeachingCourse(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorTeachingCourse', () {
    late _MockProfileRepo repo;
    late DeleteTutorTeachingCourse usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = DeleteTutorTeachingCourse(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.deleteTeachingCourse(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('tc1'), isA<Ok<void, Failure>>());
      verify(() => repo.deleteTeachingCourse('tc1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.deleteTeachingCourse(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('tc1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('CreateTutorAvailability', () {
    late _MockProfileRepo repo;
    late CreateTutorAvailability usecase;
    final params = const TutorAvailabilityParams(
      weekday: 1,
      startTime: '08:00',
      endTime: '10:00',
    );
    setUp(() {
      repo = _MockProfileRepo();
      usecase = CreateTutorAvailability(repo);
    });

    test('returns Ok and forwards params', () async {
      when(() => repo.createAvailability(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params), isA<Ok<void, Failure>>());
      verify(() => repo.createAvailability(params)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.createAvailability(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorAvailability', () {
    late _MockProfileRepo repo;
    late DeleteTutorAvailability usecase;
    setUp(() {
      repo = _MockProfileRepo();
      usecase = DeleteTutorAvailability(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.deleteAvailability(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('a1'), isA<Ok<void, Failure>>());
      verify(() => repo.deleteAvailability('a1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.deleteAvailability(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('a1') as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Offres d'emploi ────────────────────────────────────────
  group('ListTutorJobs', () {
    late _MockJobsRepo repo;
    late ListTutorJobs usecase;
    setUp(() {
      repo = _MockJobsRepo();
      usecase = ListTutorJobs(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.list()).thenAnswer((_) async => Ok(<TutorJob>[_job()]));
      expect(await usecase(), isA<Ok<List<TutorJob>, Failure>>());
      verify(() => repo.list()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.list()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('GetTutorJob', () {
    late _MockJobsRepo repo;
    late GetTutorJob usecase;
    setUp(() {
      repo = _MockJobsRepo();
      usecase = GetTutorJob(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.get(any())).thenAnswer((_) async => Ok(_job()));
      expect(await usecase('j1'), isA<Ok<TutorJob, Failure>>());
      verify(() => repo.get('j1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.get(any())).thenAnswer((_) async => const Err(_err));
      expect((await usecase('j1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('ApplyToJob', () {
    late _MockJobsRepo repo;
    late ApplyToJob usecase;
    setUp(() {
      repo = _MockJobsRepo();
      usecase = ApplyToJob(repo);
    });

    test('returns Ok and forwards jobId', () async {
      when(() => repo.apply(any())).thenAnswer((_) async => const Ok(null));
      expect(await usecase('j1'), isA<Ok<void, Failure>>());
      verify(() => repo.apply('j1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.apply(any())).thenAnswer((_) async => const Err(_err));
      expect((await usecase('j1') as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Mes cours ──────────────────────────────────────────────
  group('ListTutorCourses', () {
    late _MockCoursesRepo repo;
    late ListTutorCourses usecase;
    setUp(() {
      repo = _MockCoursesRepo();
      usecase = ListTutorCourses(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.list())
          .thenAnswer((_) async => Ok(<TutorActiveCourse>[_activeCourse()]));
      expect(await usecase(), isA<Ok<List<TutorActiveCourse>, Failure>>());
      verify(() => repo.list()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.list()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('GetTutorCourse', () {
    late _MockCoursesRepo repo;
    late GetTutorCourse usecase;
    setUp(() {
      repo = _MockCoursesRepo();
      usecase = GetTutorCourse(repo);
    });

    test('returns Ok and forwards args', () async {
      when(() => repo.get(
            studentId: any(named: 'studentId'),
            reservationId: any(named: 'reservationId'),
          )).thenAnswer((_) async => Ok(_courseDetail()));
      expect(
        await usecase(studentId: 'st1', reservationId: 'r1'),
        isA<Ok<TutorCourseDetail, Failure>>(),
      );
      verify(() => repo.get(studentId: 'st1', reservationId: 'r1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.get(
            studentId: any(named: 'studentId'),
            reservationId: any(named: 'reservationId'),
          )).thenAnswer((_) async => const Err(_err));
      expect((await usecase(studentId: 'st1') as Err).failure,
          isA<NetworkFailure>());
    });
  });

  group('ManageTutorSchedules', () {
    late _MockCoursesRepo repo;
    late ManageTutorSchedules usecase;
    setUp(() {
      repo = _MockCoursesRepo();
      usecase = ManageTutorSchedules(repo);
    });

    test('returns Ok and forwards payload', () async {
      when(() => repo.manageSchedules(any()))
          .thenAnswer((_) async => const Ok(null));
      final payload = {'a': 1};
      expect(await usecase(payload), isA<Ok<void, Failure>>());
      verify(() => repo.manageSchedules(payload)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.manageSchedules(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase({}) as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Séances ────────────────────────────────────────────────
  group('ListTutorSessionGroups', () {
    late _MockSessionsRepo repo;
    late ListTutorSessionGroups usecase;
    setUp(() {
      repo = _MockSessionsRepo();
      usecase = ListTutorSessionGroups(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.groups())
          .thenAnswer((_) async => Ok(<TutorSessionGroup>[_sessionGroup()]));
      expect(await usecase(), isA<Ok<List<TutorSessionGroup>, Failure>>());
      verify(() => repo.groups()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.groups()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('GetTutorSession', () {
    late _MockSessionsRepo repo;
    late GetTutorSession usecase;
    setUp(() {
      repo = _MockSessionsRepo();
      usecase = GetTutorSession(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.get(any())).thenAnswer((_) async => Ok(_sessionDetail()));
      expect(await usecase('s1'), isA<Ok<TutorSessionDetail, Failure>>());
      verify(() => repo.get('s1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.get(any())).thenAnswer((_) async => const Err(_err));
      expect((await usecase('s1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('UpdateTutorSession', () {
    late _MockSessionsRepo repo;
    late UpdateTutorSession usecase;
    final params = const TutorSessionEditParams(note: 'n');
    setUp(() {
      repo = _MockSessionsRepo();
      usecase = UpdateTutorSession(repo);
    });

    test('returns Ok and forwards id + params', () async {
      when(() => repo.updateSession(any(), any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('s1', params), isA<Ok<void, Failure>>());
      verify(() => repo.updateSession('s1', params)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.updateSession(any(), any()))
          .thenAnswer((_) async => const Err(_err));
      expect(
          (await usecase('s1', params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('SubmitTutorSessionReport', () {
    late _MockSessionsRepo repo;
    late SubmitTutorSessionReport usecase;
    final params = TutorSessionReportParams(
      date: '2026',
      startAt: '08:00',
      endAt: '10:00',
      proceedings: 'ok',
      signature: File('sig.png'),
    );
    setUp(() {
      repo = _MockSessionsRepo();
      usecase = SubmitTutorSessionReport(repo);
    });

    test('returns Ok and forwards sessionId + params', () async {
      when(() => repo.submitReport(any(), any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('s1', params), isA<Ok<void, Failure>>());
      verify(() => repo.submitReport('s1', params)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.submitReport(any(), any()))
          .thenAnswer((_) async => const Err(_err));
      expect(
          (await usecase('s1', params) as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Rémunérations ──────────────────────────────────────────
  group('GetTutorRemunerations', () {
    late _MockRemunerationsRepo repo;
    late GetTutorRemunerations usecase;
    setUp(() {
      repo = _MockRemunerationsRepo();
      usecase = GetTutorRemunerations(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.get()).thenAnswer((_) async => Ok(_remunerations()));
      expect(await usecase(), isA<Ok<TutorRemunerations, Failure>>());
      verify(() => repo.get()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.get()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Infos de paiement ──────────────────────────────────────
  group('ListTutorPaymentMethods', () {
    late _MockPaymentRepo repo;
    late ListTutorPaymentMethods usecase;
    setUp(() {
      repo = _MockPaymentRepo();
      usecase = ListTutorPaymentMethods(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.list())
          .thenAnswer((_) async => Ok(<TutorPaymentMethod>[_paymentMethod()]));
      expect(await usecase(), isA<Ok<List<TutorPaymentMethod>, Failure>>());
      verify(() => repo.list()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.list()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('AddTutorMobilePayment', () {
    late _MockPaymentRepo repo;
    late AddTutorMobilePayment usecase;
    final params = const TutorMobilePaymentParams(
      phone: '600',
      operator: TutorMobileOperator.mtn,
    );
    setUp(() {
      repo = _MockPaymentRepo();
      usecase = AddTutorMobilePayment(repo);
    });

    test('returns Ok and forwards params + id', () async {
      when(() => repo.addMobile(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params, id: 'm1'), isA<Ok<void, Failure>>());
      verify(() => repo.addMobile(params, id: 'm1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.addMobile(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('AddTutorBankPayment', () {
    late _MockPaymentRepo repo;
    late AddTutorBankPayment usecase;
    final params = const TutorBankPaymentParams(
      accountHolder: 'Jean',
      bankName: 'Bank',
      iban: 'IBAN',
      bic: 'BIC',
    );
    setUp(() {
      repo = _MockPaymentRepo();
      usecase = AddTutorBankPayment(repo);
    });

    test('returns Ok and forwards params + id', () async {
      when(() => repo.addBank(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase(params, id: 'b1'), isA<Ok<void, Failure>>());
      verify(() => repo.addBank(params, id: 'b1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.addBank(any(), id: any(named: 'id')))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase(params) as Err).failure, isA<NetworkFailure>());
    });
  });

  group('MarkTutorPaymentDefault', () {
    late _MockPaymentRepo repo;
    late MarkTutorPaymentDefault usecase;
    setUp(() {
      repo = _MockPaymentRepo();
      usecase = MarkTutorPaymentDefault(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.markDefault(any()))
          .thenAnswer((_) async => const Ok(null));
      expect(await usecase('p1'), isA<Ok<void, Failure>>());
      verify(() => repo.markDefault('p1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.markDefault(any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('p1') as Err).failure, isA<NetworkFailure>());
    });
  });

  group('DeleteTutorPaymentMethod', () {
    late _MockPaymentRepo repo;
    late DeleteTutorPaymentMethod usecase;
    setUp(() {
      repo = _MockPaymentRepo();
      usecase = DeleteTutorPaymentMethod(repo);
    });

    test('returns Ok and forwards id', () async {
      when(() => repo.remove(any())).thenAnswer((_) async => const Ok(null));
      expect(await usecase('p1'), isA<Ok<void, Failure>>());
      verify(() => repo.remove('p1')).called(1);
    });

    test('propagates error', () async {
      when(() => repo.remove(any())).thenAnswer((_) async => const Err(_err));
      expect((await usecase('p1') as Err).failure, isA<NetworkFailure>());
    });
  });

  // ── Contrats ───────────────────────────────────────────────
  group('ListTutorContracts', () {
    late _MockContractsRepo repo;
    late ListTutorContracts usecase;
    setUp(() {
      repo = _MockContractsRepo();
      usecase = ListTutorContracts(repo);
    });

    test('returns Ok on success', () async {
      when(() => repo.list())
          .thenAnswer((_) async => Ok(<TutorContract>[_contract()]));
      expect(await usecase(), isA<Ok<List<TutorContract>, Failure>>());
      verify(() => repo.list()).called(1);
    });

    test('propagates error', () async {
      when(() => repo.list()).thenAnswer((_) async => const Err(_err));
      expect((await usecase() as Err).failure, isA<NetworkFailure>());
    });
  });

  group('SignTutorContract', () {
    late _MockContractsRepo repo;
    late SignTutorContract usecase;
    setUp(() {
      repo = _MockContractsRepo();
      usecase = SignTutorContract(repo);
    });

    test('returns Ok and forwards id + signature', () async {
      when(() => repo.sign(any(), any()))
          .thenAnswer((_) async => const Ok(null));
      final sig = File('sig.png');
      expect(await usecase('k1', sig), isA<Ok<void, Failure>>());
      verify(() => repo.sign('k1', sig)).called(1);
    });

    test('propagates error', () async {
      when(() => repo.sign(any(), any()))
          .thenAnswer((_) async => const Err(_err));
      expect((await usecase('k1', File('sig.png')) as Err).failure,
          isA<NetworkFailure>());
    });
  });
}
