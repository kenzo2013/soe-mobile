import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/image_url.dart';
import '../../domain/entities/tutor_contract.dart';
import '../../domain/entities/tutor_course.dart';
import '../../domain/entities/tutor_dashboard.dart';
import '../../domain/entities/tutor_form_params.dart';
import '../../domain/entities/tutor_job.dart';
import '../../domain/entities/tutor_payment_method.dart';
import '../../domain/entities/tutor_profile.dart';
import '../../domain/entities/tutor_remuneration.dart';
import '../../domain/entities/tutor_session.dart';
import '../../domain/repositories/tutor_repositories.dart';
import '../datasources/tutor_contracts_remote_datasource.dart';
import '../datasources/tutor_courses_remote_datasource.dart';
import '../datasources/tutor_dashboard_remote_datasource.dart';
import '../datasources/tutor_jobs_remote_datasource.dart';
import '../datasources/tutor_payment_remote_datasource.dart';
import '../datasources/tutor_profile_remote_datasource.dart';
import '../datasources/tutor_remunerations_remote_datasource.dart';
import '../datasources/tutor_sessions_remote_datasource.dart';
import '../dtos/tutor_contract_dto.dart';
import '../dtos/tutor_course_dto.dart';
import '../dtos/tutor_dashboard_dto.dart';
import '../dtos/tutor_job_dto.dart';
import '../dtos/tutor_payment_method_dto.dart';
import '../dtos/tutor_profile_dto.dart';
import '../dtos/tutor_remuneration_dto.dart';
import '../dtos/tutor_session_dto.dart';
import 'tutor_repo_guard.dart';

class TutorDashboardRepositoryImpl implements TutorDashboardRepository {
  const TutorDashboardRepositoryImpl(this._ds);
  final TutorDashboardRemoteDatasource _ds;

  @override
  Future<Result<TutorDashboard, Failure>> get() =>
      tutorGuard(() async => (await _ds.get()).toEntity());
}

class TutorProfileRepositoryImpl implements TutorProfileRepository {
  const TutorProfileRepositoryImpl(this._ds);
  final TutorProfileRemoteDatasource _ds;

  @override
  Future<Result<TutorProfile, Failure>> profile() => tutorGuard(() async {
        final user = await _ds.currentUser();
        final desc = await _ds.description();
        // Complétion calculée sur les 6 sections réelles (en parallèle).
        // NB : la bio est détectée via l'`id` de la description (présent même
        // si l'API ne renvoie pas le texte) plutôt que via son contenu.
        final lists = await Future.wait<List<dynamic>>([
          _ds.trainings(),
          _ds.works(),
          _ds.identities(),
          _ds.teachingCourses(),
          _ds.availabilities(),
        ]);
        final hasBio = desc != null;
        final filled = [
          hasBio,
          lists[0].isNotEmpty, // formations
          lists[1].isNotEmpty, // expériences
          lists[2].isNotEmpty, // pièces d'identité
          lists[3].isNotEmpty, // matières
          lists[4].isNotEmpty, // disponibilités
        ].where((e) => e).length;
        final completion = (filled / 6 * 100).round();
        return TutorProfile(
          firstName: user['first_name']?.toString() ?? '',
          lastName: user['last_name']?.toString() ?? '',
          email: user['email']?.toString() ?? '',
          phone: user['phone']?.toString() ?? '',
          city: user['city']?.toString() ?? '',
          category: user['category']?.toString() ?? desc?.category ?? 'Tuteur',
          rating: (user['rating'] as num?)?.toDouble() ?? 0,
          reviews: (user['review_count'] as num?)?.toInt() ?? 0,
          bio: desc?.content ?? '',
          completion: completion,
          avatarUrl: ImageUrl.resolve(
            (user['avatar_url'] ?? user['photo_url'])?.toString(),
          ),
        );
      });

  @override
  Future<Result<void, Failure>> saveBio(String content) => tutorGuard(() async {
        final existing = await _ds.description();
        await _ds.saveDescription(content: content, id: existing?.id);
      });

  @override
  Future<Result<List<TutorTraining>, Failure>> trainings() => tutorGuard(
        () async => (await _ds.trainings()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<void, Failure>> saveTraining(
    TutorTrainingParams p, {
    String? id,
  }) =>
      // Noms réels backend : level_of_study / field_of_training / obtained_at.
      // Obligatoires : category + level_of_study.
      tutorGuard(() => _ds.saveTraining({
            'category': p.category,
            'level_of_study': p.level,
            'field_of_training': p.domain,
            'specialty': p.specialty,
            'obtained_at': p.date,
          }, id: id));

  @override
  Future<Result<void, Failure>> deleteTraining(String id) =>
      tutorGuard(() => _ds.deleteTraining(id));

  @override
  Future<Result<List<TutorWork>, Failure>> works() => tutorGuard(
        () async => (await _ds.works()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<void, Failure>> saveWork(TutorWorkParams p, {String? id}) =>
      // `position`/`organization` = noms réels du modèle (cf. parent
      // tutor_profile) ; on garde `title`/`company` en alias par sécurité.
      tutorGuard(() => _ds.saveWork({
            'title': p.title,
            'position': p.title,
            'company': p.company,
            'organization': p.company,
            'enterprise': p.company,
            'current_position': p.current,
            if (p.since != null) ...{
              'since': p.since,
              'start_year': p.since,
            },
            if (p.until != null) ...{
              'until': p.until,
              'end_year': p.until,
            },
          }, id: id));

  @override
  Future<Result<void, Failure>> deleteWork(String id) =>
      tutorGuard(() => _ds.deleteWork(id));

  @override
  Future<Result<List<TutorIdentity>, Failure>> identities() => tutorGuard(
        () async => (await _ds.identities()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<void, Failure>> createIdentity(TutorIdentityParams p) =>
      // Noms réels backend : birthdate / expires_on (format YYYY-MM-DD).
      tutorGuard(() => _ds.createIdentity({
            'document_type': p.documentType,
            'birthdate': p.birthday,
            'expires_on': p.expirationDate,
          }, p.images));

  @override
  Future<Result<void, Failure>> updateIdentity(
    String id,
    TutorIdentityParams p,
  ) =>
      tutorGuard(() => _ds.updateIdentity(
          id,
          {
            'document_type': p.documentType,
            'birthdate': p.birthday,
            'expires_on': p.expirationDate,
          },
          p.images));

  @override
  Future<Result<void, Failure>> deleteIdentity(String id) =>
      tutorGuard(() => _ds.deleteIdentity(id));

  @override
  Future<Result<List<TutorTeachingCourse>, Failure>> teachingCourses() =>
      tutorGuard(
        () async =>
            (await _ds.teachingCourses()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<void, Failure>> saveTeachingCourse(
    TutorTeachingCourseParams p, {
    String? id,
  }) =>
      tutorGuard(() => _ds.saveTeachingCourse({
            'school_class_id': p.schoolClassId,
            'subject_ids': p.subjectIds,
          }, id: id));

  @override
  Future<Result<void, Failure>> deleteTeachingCourse(String id) =>
      tutorGuard(() => _ds.deleteTeachingCourse(id));

  @override
  Future<Result<List<TutorDayAvailability>, Failure>> availabilities() =>
      tutorGuard(() async => groupAvailabilities(await _ds.availabilities()));

  @override
  Future<Result<void, Failure>> createAvailability(
    TutorAvailabilityParams p,
  ) =>
      // Structure réelle backend : { day: "lundi", time_availabilities_attributes:
      // [{ from: "HH:MM:SS", to: "HH:MM:SS" }] } — un jour par requête.
      tutorGuard(() => _ds.createAvailability({
            'day': _dayName(p.weekday),
            'time_availabilities_attributes': [
              {'from': _hms(p.startTime), 'to': _hms(p.endTime)},
            ],
          }));

  @override
  Future<Result<void, Failure>> deleteAvailability(String id) =>
      tutorGuard(() => _ds.deleteAvailability(id));

  /// 1=lundi … 7=dimanche (jour attendu par l'API en français minuscule).
  static String _dayName(int weekday) => const [
        'lundi',
        'mardi',
        'mercredi',
        'jeudi',
        'vendredi',
        'samedi',
        'dimanche',
      ][(weekday - 1).clamp(0, 6)];

  /// `HH:MM` → `HH:MM:SS` (l'API attend les secondes).
  static String _hms(String t) {
    final parts = t.split(':');
    return switch (parts.length) {
      2 => '$t:00',
      1 => '$t:00:00',
      _ => t,
    };
  }
}

class TutorJobsRepositoryImpl implements TutorJobsRepository {
  const TutorJobsRepositoryImpl(this._ds);
  final TutorJobsRemoteDatasource _ds;

  @override
  Future<Result<List<TutorJob>, Failure>> list() => tutorGuard(
        () async => (await _ds.list()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<TutorJob, Failure>> get(String id) =>
      tutorGuard(() async => (await _ds.get(id)).toEntity());

  @override
  Future<Result<void, Failure>> apply(String jobId) =>
      tutorGuard(() => _ds.apply(jobId));
}

class TutorCoursesRepositoryImpl implements TutorCoursesRepository {
  const TutorCoursesRepositoryImpl(this._ds);
  final TutorCoursesRemoteDatasource _ds;

  @override
  Future<Result<List<TutorActiveCourse>, Failure>> list() => tutorGuard(
        () async => (await _ds.list()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<TutorCourseDetail, Failure>> get({
    required String studentId,
    String? reservationId,
  }) =>
      tutorGuard(() async => (await _ds.studentDetail(
            studentId: studentId,
            reservationId: reservationId,
          ))
              .toEntity());

  @override
  Future<Result<void, Failure>> manageSchedules(Map<String, dynamic> payload) =>
      tutorGuard(() => _ds.manageSchedules(payload));
}

class TutorSessionsRepositoryImpl implements TutorSessionsRepository {
  const TutorSessionsRepositoryImpl(this._ds);
  final TutorSessionsRemoteDatasource _ds;

  @override
  Future<Result<List<TutorSessionGroup>, Failure>> groups() =>
      tutorGuard(() async => groupSessionsByDay(await _ds.list()));

  @override
  Future<Result<TutorSessionDetail, Failure>> get(String id) =>
      tutorGuard(() async => (await _ds.detail(id)).toEntity());

  @override
  Future<Result<void, Failure>> updateSession(
    String id,
    TutorSessionEditParams p,
  ) =>
      tutorGuard(() => _ds.update(id, {
            if (p.startAt != null) 'start_at': p.startAt,
            if (p.endAt != null) 'end_at': p.endAt,
            if (p.note != null) 'note': p.note,
          }));

  @override
  Future<Result<void, Failure>> submitReport(
    String sessionId,
    TutorSessionReportParams p,
  ) =>
      tutorGuard(() => _ds.submitReport(
            sessionId,
            {
              'date': p.date,
              'start_at': p.startAt,
              'end_at': p.endAt,
              'proceedings': p.proceedings,
            },
            signature: p.signature,
          ));
}

class TutorRemunerationsRepositoryImpl implements TutorRemunerationsRepository {
  const TutorRemunerationsRepositoryImpl(this._ds);
  final TutorRemunerationsRemoteDatasource _ds;

  @override
  Future<Result<TutorRemunerations, Failure>> get() =>
      tutorGuard(() async => buildRemunerations(await _ds.list()));
}

class TutorPaymentRepositoryImpl implements TutorPaymentRepository {
  const TutorPaymentRepositoryImpl(this._ds);
  final TutorPaymentRemoteDatasource _ds;

  @override
  Future<Result<List<TutorPaymentMethod>, Failure>> list() async {
    final r = await tutorGuard(
      () async => (await _ds.list()).map((e) => e.toEntity()).toList(),
    );
    // L'API n'expose pas (encore) de GET index pour payment_informations
    // (CDC §7.6 : seulement POST/PATCH/DELETE) → 404. On dégrade en liste vide
    // pour garder l'écran utilisable (formulaires d'ajout).
    return switch (r) {
      Err(failure: NotFoundFailure()) => const Ok([]),
      _ => r,
    };
  }

  @override
  Future<Result<void, Failure>> addMobile(
    TutorMobilePaymentParams p, {
    String? id,
  }) {
    final payload = {
      'type': 'mobile_payment',
      'mobile_payment': {
        'phone': p.phone,
        'mobile_operator': p.operator == TutorMobileOperator.mtn
            ? 'MTN Money'
            : 'Orange Money',
      },
    };
    return tutorGuard(
      () => id == null ? _ds.create(payload) : _ds.update(id, payload),
    );
  }

  @override
  Future<Result<void, Failure>> addBank(
    TutorBankPaymentParams p, {
    String? id,
  }) {
    final payload = {
      'type': 'bank',
      'bank_information': {
        'account_holder': p.accountHolder,
        'bank_name': p.bankName,
        'iban': p.iban,
        'bic': p.bic,
        // Champs requis par l'API (révélés au test : « Numéro de compte »,
        // « Clé » obligatoires) — absents du CDC §5.7.
        'account_number': p.accountNumber,
        'key': p.key,
        'rib_key': p.key,
        'bank_code': p.bankCode,
        'agency_code': p.agencyCode,
      },
    };
    return tutorGuard(
      () => id == null ? _ds.create(payload) : _ds.update(id, payload),
    );
  }

  @override
  Future<Result<void, Failure>> markDefault(String id) =>
      tutorGuard(() => _ds.markDefault(id));

  @override
  Future<Result<void, Failure>> remove(String id) =>
      tutorGuard(() => _ds.delete(id));
}

class TutorContractsRepositoryImpl implements TutorContractsRepository {
  const TutorContractsRepositoryImpl(this._ds);
  final TutorContractsRemoteDatasource _ds;

  @override
  Future<Result<List<TutorContract>, Failure>> list() => tutorGuard(
        () async => (await _ds.list()).map((e) => e.toEntity()).toList(),
      );

  @override
  Future<Result<void, Failure>> sign(String id, File signature) =>
      tutorGuard(() => _ds.sign(id, signature: signature));
}
