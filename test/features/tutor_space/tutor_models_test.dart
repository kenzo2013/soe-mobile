import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';

/// The tutor models read the API v2 responses (soe/docs/api/v2/openapi.yml).
void main() {
  Map<String, dynamic> session({String state = 'planned'}) => {
        'id': 12,
        'date': '2026-11-05',
        'starts_at': '2026-11-05T16:00:00+01:00',
        'ends_at': '2026-11-05T17:30:00+01:00',
        'subject': 'Anglais',
        'pupil': 'Léa N.',
        'school_class': 'CM2',
        'status': 'pending',
        'state': state,
        'state_label': 'Prévue',
        'has_report': false,
      };

  test('a home with actions, a session today and the month', () {
    final home = TutorHome.fromJson({
      'active': true,
      'may_teach': true,
      'actions': [
        {
          'kind': 'disputed',
          'label': 'PV contesté',
          'title': 'Léa N. · Anglais',
          'deadline': null,
          'overdue': false,
          'target_id': 11
        },
        {
          'kind': 'report',
          'label': 'PV à rédiger',
          'title': 'Léa N. · Anglais',
          'deadline': '2026-11-06T17:30:00+01:00',
          'overdue': false,
          'target_id': 12
        },
      ],
      'today_sessions': [session()],
      'month': {
        'amount': 24000,
        'approved': 4,
        'pending_count': 2,
        'pending_amount': 12000,
        'disputed_count': 1,
        'disputed_amount': 6000,
        'payout_on': null,
      },
      'recruitment': null,
    });

    expect(home.active, isTrue);
    expect(home.actions.first.deadline, isNull);
    expect(home.actions.last.targetId, 12);
    // The disputed report is reviewed by SOE: the gold button goes to the next action.
    expect(home.urgentIndex, 1);
    expect(home.todaySessions.single.title, 'Anglais · Léa N.');
    expect(home.todaySessions.single.date, DateTime(2026, 11, 5));
    expect(home.month.amount, 24000);
    expect(home.month.disputedCount, 1);
    expect(home.month.payoutOn, isNull);
    expect(home.recruitment, isNull);
  });

  test('a candidate home carries the recruitment', () {
    final home = TutorHome.fromJson({
      'active': false,
      'may_teach': false,
      'actions': <Object>[],
      'today_sessions': <Object>[],
      'month': {
        'amount': 0,
        'approved': 0,
        'pending_count': 0,
        'pending_amount': 0,
        'disputed_count': 0,
        'disputed_amount': 0,
        'payout_on': '2026-12-05',
      },
      'recruitment': {
        'stage': 'file',
        'stage_label': 'Compléter le dossier',
        'refused': false,
        'step': 1,
        'total_steps': 6,
        'missing_documents': [
          {
            'document': 'diploma',
            'label': 'Diplômes',
            'state': 'redo',
            'state_label': 'à refaire'
          },
        ],
      },
    });

    expect(home.urgentIndex, -1);
    expect(home.month.payoutOn, DateTime(2026, 12, 5));
    expect(home.recruitment!.totalSteps, 6);
    expect(home.recruitment!.missingDocuments.single.state, 'redo');
  });

  test('a session detail before the contract hides the family contact', () {
    final detail = TutorSessionDetail.fromJson({
      ...session(),
      'neighborhood': 'Bonapriso',
      'address': null,
      'landmark': null,
      'parent_name': null,
      'parent_phone': null,
      'rate': null,
      'check_in': {
        'opens_at': '2026-11-05T15:45:00+01:00',
        'checked_in_at': null,
        'method': null,
        'checked_out_at': null,
      },
      'report_available_at': '2026-11-05T17:00:00+01:00',
      'report_due_at': null,
    });

    expect(detail.neighborhood, 'Bonapriso');
    expect(detail.hasContact, isFalse);
    expect(detail.rate, isNull);
    expect(detail.checkedInAt, isNull);
    expect(detail.checkInMethod, isNull);
    expect(detail.reportDueAt, isNull);
    expect(detail.checkInOpensAt.isBefore(detail.session.startsAt), isTrue);
  });

  test('a session detail after the check-in, with the contact', () {
    final detail = TutorSessionDetail.fromJson({
      ...session(state: 'to_report'),
      'neighborhood': 'Bonapriso',
      'address': 'Rue 1.234',
      'landmark': 'Derrière la pharmacie',
      'parent_name': 'Mme Ekotto',
      'parent_phone': '+237675942301',
      'rate': 6000,
      'check_in': {
        'opens_at': '2026-11-05T15:45:00+01:00',
        'checked_in_at': '2026-11-05T16:02:00+01:00',
        'method': 'code',
        'checked_out_at': '2026-11-05T17:31:00+01:00',
      },
      'report_available_at': '2026-11-05T17:00:00+01:00',
      'report_due_at': '2026-11-06T17:30:00+01:00',
    });

    expect(detail.hasContact, isTrue);
    expect(detail.parentPhone, '+237675942301');
    expect(detail.rate, 6000);
    expect(detail.checkInMethod, 'code');
    expect(detail.checkedOutAt, isNotNull);
    expect(detail.session.state, 'to_report');
  });

  test('earnings by pupil, the payout and the history', () {
    final earnings = TutorEarnings.fromJson({
      'amount': 24000,
      'approved': 4,
      'pending_amount': 6000,
      'disputed_amount': 0,
      'pupils': [
        {
          'name': 'Léa',
          'approved': 4,
          'rate': 6000,
          'amount': 24000,
          'pending': 1,
          'disputed': 0
        },
        {
          'name': null,
          'approved': 2,
          'rate': null,
          'amount': 11000,
          'pending': 0,
          'disputed': 1
        },
      ],
      'payout_on': null,
      'default_method_label': 'MTN MoMo ••• 301',
      'history': [
        {
          'id': 3,
          'period': '2026-10-01',
          'paid_at': '2026-11-05T10:00:00+01:00',
          'amount': 30000,
          'sessions': 5
        },
      ],
    });

    expect(earnings.pupils.first.rate, 6000);
    expect(earnings.pupils.last.name, isNull);
    expect(earnings.pupils.last.rate, isNull);
    expect(earnings.payoutOn, isNull);
    expect(earnings.defaultMethodLabel, 'MTN MoMo ••• 301');
    expect(earnings.history.single.period, DateTime(2026, 10));
    expect(earnings.history.single.sessions, 5);
  });

  test('a planning with its options and current times', () {
    final planning = TutorPlanning.fromJson({
      'slot_id': 8,
      'subject': 'Maths',
      'pupil': 'Yann',
      'sessions_per_week': 2,
      'session_minutes': 90,
      'can_propose': true,
      'from_availabilities': false,
      'options': ['monday 16:00', 'wednesday 17:30'],
      'times': [
        {
          'day': 'monday',
          'from': '16:00',
          'to': '17:30',
          'status': 'change_requested',
          'status_label': 'Autres créneaux demandés'
        },
      ],
    });

    expect(planning.title, 'Maths · Yann');
    expect(planning.sessionsPerWeek, 2);
    expect(planning.fromAvailabilities, isFalse);
    expect(planning.options, ['monday 16:00', 'wednesday 17:30']);
    expect(planning.times.single.status, 'change_requested');
  });

  test('a report state follows the parent answer', () {
    Map<String, dynamic> report({bool? validated, String? reason}) => {
          'session_id': 12,
          'date': '2026-11-05',
          'start_at': '16:02',
          'end_at': '17:31',
          'topics': ['Fractions'],
          'homework': null,
          'observations': 'Comportement : Très bien',
          'has_signature': true,
          'submitted_at': '2026-11-05T17:40:00+01:00',
          'late': false,
          'validated': validated,
          'dispute_reason': reason,
          'auto_validates_at': null,
        };

    expect(TutorReport.fromJson(report()).state, 'waiting');
    expect(TutorReport.fromJson(report(validated: true)).state, 'approved');
    expect(
        TutorReport.fromJson(report(validated: false, reason: 'Absent')).state,
        'disputed');
    expect(TutorReport.fromJson(report()).topics, ['Fractions']);
  });
}
