import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';

/// The parent models read the API v2 responses (soe/docs/api/v2/openapi.yml).
void main() {
  test('a home with an action, a session, a request and an invoice', () {
    final home = ParentHome.fromJson({
      'actions': [
        {
          'kind': 'report',
          'label': 'PV à valider',
          'deadline': '2026-11-07T20:40:00+01:00',
          'overdue': false,
          'target_id': 12
        },
      ],
      'week_sessions': [
        {
          'id': 12,
          'date': '2026-11-05',
          'starts_at': '2026-11-05T16:00:00+01:00',
          'ends_at': '2026-11-05T17:30:00+01:00',
          'child': {'id': 3, 'first_name': 'Léa'},
          'subject': 'Anglais',
          'tutor_name': 'Aline N.',
          'status': 'pending',
          'status_label': 'Prévue',
        },
      ],
      'requests': [
        {
          'id': 7,
          'reference': 'RES-1',
          'step': 'contract',
          'step_label': 'Contrat à signer',
          'children': ['Yann']
        },
      ],
      'children': [
        {'id': 3, 'first_name': 'Léa', 'school_class': 'CM2'},
      ],
      'invoice': {
        'id': 9,
        'number': 'FAC-1',
        'period': '2026-11-01',
        'amount': 42000,
        'balance_due': 32000,
        'due_on': '2026-11-05',
        'status': 'overdue',
        'status_label': 'En retard',
        'lines': [
          {'student': 'Léa', 'subject': 'Anglais', 'amount': 42000},
        ],
      },
      'advisor': {
        'first_name': 'Carine',
        'last_name': 'Ekotto',
        'phone': '+237675942301'
      },
    });

    expect(home.actions.single.targetId, 12);
    expect(home.weekSessions.single.title, 'Anglais · Léa');
    expect(home.requests.single.step, 'contract');
    expect(home.invoice!.payable, isTrue);
    expect(home.invoice!.balanceDue, 32000);
    expect(home.invoice!.lines.single.label, 'Anglais · Léa');
    expect(home.advisorName, 'Carine Ekotto');
  });

  test('a report keeps the free text when there is no topic', () {
    final report = ParentReport.fromJson({
      'session_id': 12,
      'child_first_name': 'Léa',
      'topics': <String>[],
      'proceedings': 'Fractions',
      'validated': null,
      'can_answer': true,
    });

    expect(report.topics, ['Fractions']);
    expect(report.canAnswer, isTrue);
    expect(report.validated, isNull);
  });

  test('a payment state', () {
    expect(
        ParentPayment.fromJson({'id': 1, 'amount': 42000, 'state': 'checking'})
            .state,
        'checking');
  });
}
