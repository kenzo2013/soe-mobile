import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soe/features/common/presentation/providers.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/presentation/providers/current_user_provider.dart';
import 'package:soe/features/tutor_space/data/tutor_api.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';

/// Fixtures and a recording fake of [TutorApi] for the day-to-day tutor screens (REP-01,
/// REP-13, REP-15 to REP-18).
DateTime get now => DateTime.now();

Map<String, dynamic> sessionJson({
  int id = 12,
  DateTime? startsAt,
  int minutes = 120,
  String state = 'planned',
  String label = 'Prévue',
  bool hasReport = false,
}) {
  final start = startsAt ?? now.add(const Duration(hours: 1, minutes: 20));
  return {
    'id': id,
    'date':
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}',
    'starts_at': start.toUtc().toIso8601String(),
    'ends_at': start.add(Duration(minutes: minutes)).toUtc().toIso8601String(),
    'subject': 'Mathématiques',
    'pupil': 'Ornella T.',
    'school_class': 'Tle D',
    'status': 'pending',
    'state': state,
    'state_label': label,
    'has_report': hasReport,
  };
}

TutorSession session({
  int id = 12,
  DateTime? startsAt,
  String state = 'planned',
  String label = 'Prévue',
}) =>
    TutorSession.fromJson(
        sessionJson(id: id, startsAt: startsAt, state: state, label: label));

TutorSessionDetail detail({
  DateTime? startsAt,
  DateTime? checkedInAt,
  DateTime? checkedOutAt,
  DateTime? reportAvailableAt,
  bool contact = true,
  bool canMove = true,
  String state = 'planned',
  String label = 'Prévue',
  bool hasReport = false,
}) {
  final start = startsAt ?? now.add(const Duration(hours: 1, minutes: 20));
  return TutorSessionDetail.fromJson({
    ...sessionJson(
        startsAt: start, state: state, label: label, hasReport: hasReport),
    'neighborhood': 'Makepe Missoke',
    'address': contact ? 'Rue 1.234' : null,
    'landmark': contact ? 'Face à la station Total' : null,
    'parent_name': contact ? 'M. Tchoua' : null,
    'parent_phone': contact ? '+237690182247' : null,
    'rate': 6500,
    'check_in': {
      'opens_at':
          start.subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
      'checked_in_at': checkedInAt?.toUtc().toIso8601String(),
      'method': checkedInAt == null ? null : 'gps',
      'checked_out_at': checkedOutAt?.toUtc().toIso8601String(),
    },
    'report_available_at':
        (reportAvailableAt ?? start.add(const Duration(minutes: 10)))
            .toUtc()
            .toIso8601String(),
    'report_due_at':
        start.add(const Duration(hours: 26)).toUtc().toIso8601String(),
    'can_move': canMove,
  });
}

TutorHome activeHome({List<Map<String, dynamic>>? actions}) =>
    TutorHome.fromJson({
      'active': true,
      'may_teach': true,
      'actions': actions ??
          [
            {
              'kind': 'assignment',
              'label': 'Affectation à confirmer',
              'title': 'Samuel · Mathématiques',
              'deadline':
                  now.add(const Duration(hours: 31)).toUtc().toIso8601String(),
              'overdue': false,
              'target_id': 3,
            },
            {
              'kind': 'disputed',
              'label': 'PV contesté',
              'title': 'Yann M.',
              'deadline': null,
              'overdue': false,
              'target_id': 9,
            },
          ],
      'today_sessions': [sessionJson()],
      'month': {
        'amount': 52500,
        'approved': 8,
        'pending_count': 1,
        'pending_amount': 7000,
        'disputed_count': 1,
        'disputed_amount': 7000,
        'payout_on': null,
      },
      'recruitment': null,
    });

TutorHome recruitmentHome() => TutorHome.fromJson({
      'active': false,
      'may_teach': false,
      'actions': <Map<String, dynamic>>[],
      'today_sessions': <Map<String, dynamic>>[],
      'month': <String, dynamic>{},
      'recruitment': {
        'stage': 'file',
        'stage_label': 'Compléter le dossier',
        'refused': false,
        'step': 1,
        'total_steps': 6,
        'missing_documents': [
          {
            'document': 'diploma',
            'label': 'Diplômes et justificatifs',
            'state': 'redo',
            'state_label': 'à refaire'
          }
        ],
      },
    });

TutorProposal proposalOf({String status = 'proposed', bool canAnswer = true}) =>
    TutorProposal.fromJson({
      'id': 3,
      'status': status,
      'status_label': status,
      'can_answer': canAnswer,
      'respond_by':
          now.add(const Duration(hours: 31)).toUtc().toIso8601String(),
      'session_rate': 7500,
      'subject': 'Mathématiques',
      'pupil': 'Samuel',
      'school_class': '1re C',
      'neighborhood': 'Bonapriso',
      'sessions_per_week': 2,
      'session_minutes': 120,
      'moments': ['Mardi après 17:00'],
      'start_date': '2026-12-07',
    });

TutorPlanning planning({List<Map<String, dynamic>> times = const []}) =>
    TutorPlanning.fromJson({
      'slot_id': 5,
      'subject': 'Mathématiques',
      'pupil': 'Samuel',
      'sessions_per_week': 2,
      'session_minutes': 120,
      'can_propose': true,
      'from_availabilities': true,
      'options': [
        'monday 16:00',
        'tuesday 17:30',
        'friday 17:30',
      ],
      'times': times,
    });

TutorReport report({bool? validated, String? disputeReason}) =>
    TutorReport.fromJson({
      'session_id': 12,
      'date': '2026-11-21',
      'start_at': '09:00',
      'end_at': '11:00',
      'topics': ['Calcul littéral'],
      'homework': 'Exercices 4 à 9 p. 62',
      'observations': null,
      'has_signature': true,
      'submitted_at': '2026-11-21T12:10:00Z',
      'late': false,
      'validated': validated,
      'dispute_reason': disputeReason,
      'auto_validates_at': '2026-11-23T12:10:00Z',
    });

/// Records the calls; each read answers its field, or throws [failure] when set.
class FakeTutorApi extends TutorApi {
  FakeTutorApi({
    this.homeValue,
    this.detailValue,
    this.reportValue,
    this.proposalValue,
    this.planningValue,
    this.sessionsValue = const [],
    this.offers = const [],
  }) : super(Dio());

  TutorHome? homeValue;
  TutorSessionDetail? detailValue;
  TutorReport? reportValue;
  TutorProposal? proposalValue;
  TutorPlanning? planningValue;
  List<TutorSession> sessionsValue;
  List<TutorOfferPreview> offers;

  /// Thrown by the next read of the home / the next action.
  Object? homeFailure;
  Object? actionFailure;

  final calls = <String>[];
  final moves = <(DateTime, String, String?)>[];
  final answers = <(bool, String?)>[];
  final proposed = <List<String>>[];
  final filters = <String?>[];

  @override
  Future<TutorHome> home() async {
    calls.add('home');
    if (homeFailure != null) throw homeFailure!;
    return homeValue!;
  }

  @override
  Future<List<TutorOfferPreview>> homeOffers({int limit = 2}) async => offers;

  @override
  Future<List<TutorSession>> sessions(DateTime from, DateTime to,
      {String? filter}) async {
    filters.add(filter);
    return sessionsValue;
  }

  @override
  Future<TutorSessionDetail> session(int id) async => detailValue!;

  @override
  Future<TutorReport?> report(int sessionId) async => reportValue;

  @override
  Future<TutorProposal> proposal(int id) async => proposalValue!;

  @override
  Future<TutorProposal> answerProposal(int id,
      {required bool accept, String? reason}) async {
    answers.add((accept, reason));
    if (actionFailure != null) throw actionFailure!;
    return proposalValue =
        proposalOf(status: accept ? 'accepted' : 'declined', canAnswer: false);
  }

  @override
  Future<TutorPlanning> planning(int slotId) async => planningValue!;

  @override
  Future<TutorPlanning> proposeTimes(int slotId, List<String> times) async {
    proposed.add(times);
    return planningValue!;
  }

  @override
  Future<TutorSessionDetail> moveSession(int id,
      {required DateTime date,
      required String startAt,
      String? comment}) async {
    moves.add((date, startAt, comment));
    if (actionFailure != null) throw actionFailure!;
    return detailValue!;
  }

  @override
  Future<TutorReport> sendReport(
    int sessionId, {
    required List<String> topics,
    required String homework,
    required String observations,
    required List<int> signature,
    String? startAt,
    String? endAt,
    String? correctionReason,
  }) async {
    calls.add('sendReport');
    if (actionFailure != null) throw actionFailure!;
    return reportValue!;
  }
}

/// The overrides of a tutor screen test: the fake API, a signed-in tutor, a still clock.
List<Override> tutorOverrides(FakeTutorApi api) => [
      tutorApiProvider.overrideWithValue(api),
      tutorClockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      currentUserProvider.overrideWith((ref) async => const User(
          id: '1',
          email: 'daniel@soe.test',
          firstName: 'Daniel',
          lastName: 'K.',
          role: UserRole.tutor)),
      // The bell of the headers: no notification server in the tests.
      unreadNotificationsProvider.overrideWith((ref) async => 0),
    ];

/// A tall phone view; wider than 390 because the test font (Ahem) draws every glyph as wide
/// as it is high, about twice the width of the app's font.
void useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 12000);
  addTearDown(tester.view.resetPhysicalSize);
}
