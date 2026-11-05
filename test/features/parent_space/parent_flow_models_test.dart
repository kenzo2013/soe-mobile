import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/parent_space/data/parent_flow_models.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';

/// The models of the parent flows read the API v2 responses (soe/docs/api/v2/openapi.yml).
void main() {
  test('a request draft with its children, needs and options', () {
    final draft = ParentRequestDraft.fromJson({
      'child_ids': [3],
      'complete': false,
      'children': [
        {'id': 3, 'first_name': 'Yann', 'school_class': '4e', 'selected': true},
        {
          'id': 4,
          'first_name': 'Léa',
          'school_class': 'CM2',
          'selected': false
        },
      ],
      'needs': [
        {
          'child_id': 3,
          'subject_ids': [1, 2],
          'subjects': ['Mathématiques', 'Physique-chimie'],
          'missing': ['start_on'],
          'objective': 'regular',
          'start_on': null,
          'sessions_per_week': 2,
          'session_minutes': 120,
          'moments': ['saturday_morning'],
          'gender': 'no_preference',
        }
      ],
      'options': {
        'objectives': [
          {'value': 'regular', 'label': 'Suivi régulier'}
        ],
        'moments': [
          {'value': 'saturday_morning', 'label': 'Samedi matin'}
        ],
        'genders': [
          {'value': 'no_preference', 'label': 'Indifférent'}
        ],
        'sessions_per_week': [1, 2, 3, 4],
        'session_minutes': [
          {'value': 120, 'label': '2 h'}
        ],
      },
    });
    expect(draft.started, isTrue);
    expect(draft.children.first.selected, isTrue);
    final need = draft.needOf(3);
    expect(need.complete, isFalse);
    expect(need.missing, ['start_on']);
    expect(draft.labelOf(draft.objectives, need.objective), 'Suivi régulier');
    expect(draft.labelOf(draft.sessionMinutes, need.sessionMinutes), '2 h');
    expect(draft.sessionsPerWeek, [1, 2, 3, 4]);
    expect(draft.needOf(99).subjectIds, isEmpty);

    final input = need.copyWith(startOn: DateTime(2026, 11, 16)).toInput();
    expect(input['start_on'], '2026-11-16');
    expect(input['subject_ids'], [1, 2]);
  });

  test('a request detail with rights, needs and the replacement history', () {
    final detail = ParentRequestDetail.fromJson({
      'id': 7,
      'reference': 'DEM-2610-31',
      'stage': 'tutor_presented',
      'step': 'contract',
      'step_label': 'Contrat à signer',
      'children': ['Yann'],
      'action': 'tutor',
      'quote_amount': 64000,
      'contract_id': 9,
      'contract_status': 'sent',
      'can_cancel': true,
      'need_editable': false,
      'tutors_presented': true,
      'needs': [
        {
          'id': 11,
          'child_id': 3,
          'child': 'Yann',
          'subjects': ['Maths']
        }
      ],
      'history': [
        {
          'action': 'replacement.requested',
          'label': 'Remplacement demandé',
          'actor': 'you',
          'at': '2026-11-26T16:55:00+01:00'
        },
        {
          'action': 'reservation.created',
          'label': 'Demande créée',
          'actor': 'you',
          'at': '2026-10-28T20:15:00+01:00'
        },
      ],
    });
    expect(detail.request.stage, 'tutor_presented');
    expect(detail.canCancel, isTrue);
    expect(detail.needs.single.id, 11);
    expect(detail.replacementEvents.single.label, 'Remplacement demandé');
  });

  test('a proposed tutor reads the checks object of the API', () {
    final tutor = ParentTutorProfile.fromJson({
      'id': 5,
      'name': 'Daniel E.',
      'contract_signed': false,
      'slots': [
        {'id': 21, 'subject': 'Maths', 'child': 'Yann'}
      ],
      'checks': {
        'identity': true,
        'diplomas': true,
        'interview': false,
        'test': false
      },
      'rating': 4.8,
      'reviews_count': 12,
      'trainings': ['Ingénieur'],
      'experiences': <String>[],
      'subjects': ['Maths'],
      'presentation': null,
      'availabilities': [
        {
          'day': 'monday',
          'ranges': ['16:00 - 18:00']
        }
      ],
    });
    expect(tutor.checks, ['identity', 'diplomas']);
    expect(tutor.initials, 'DE');
    expect(tutor.slots.single.id, 21);
    expect(tutor.availabilities.single.ranges, ['16:00 - 18:00']);
  });

  test('references, co-parents, invitations, reviews and amendments', () {
    final refs = ParentReferences.fromJson({
      'subjects': [
        {'id': 1, 'name': 'Maths', 'abbr': 'MATHS'}
      ],
      'school_classes': [
        {
          'id': 1,
          'name': 'CM2',
          'education': 'primary',
          'section': 'francophone'
        },
        {
          'id': 2,
          'name': 'Form 1',
          'education': 'secondary',
          'section': 'anglophone'
        },
      ],
      'sections': [
        {'key': 'francophone', 'label': 'Francophone'}
      ],
      'cities': [
        {
          'name': 'Douala',
          'neighborhoods': ['Bonapriso']
        }
      ],
    });
    expect(refs.classesOf('francophone').map((item) => item.name), ['CM2']);
    expect(refs.cities.single.neighborhoods, ['Bonapriso']);

    final coParent = ParentCoParent.fromJson({
      'id': 2,
      'first_name': 'Paul',
      'last_name': 'Mbarga',
      'email': 'paul@example.com',
      'children': ['Léa', 'Yann'],
      'can_answer_reports': true,
    });
    expect(coParent.name, 'Paul Mbarga');

    final invitation = ParentInvitation.fromJson({
      'id': 4,
      'first_name': 'Jean',
      'last_name': 'Mbarga',
      'state': 'sent',
      'expires_at': '2020-01-01T00:00:00Z',
      'can_answer_reports': false,
    });
    expect(invitation.expired, isTrue);

    final tutor = ParentReviewTutor.fromJson({
      'id': 5,
      'name': 'Aline N.',
      'active_review_id': null,
      'subjects': [
        {'id': 3, 'name': 'Anglais'}
      ],
      'approved_sessions': 8,
      'sessions_required': 4,
      'eligible': true,
      'since': '2026-10-05',
      'courses': 'Anglais · Léa',
    });
    expect(tutor.eligible, isTrue);
    expect(tutor.subjects.single.name, 'Anglais');

    final amendment = ParentAmendment.fromJson({
      'id': 1,
      'reference': 'AV-1',
      'contract_id': 9,
      'signed': false,
      'can_sign': true,
    });
    expect(amendment.canSign, isTrue);
  });

  test('payments and contracts carry the history and list fields', () {
    final payment = ParentPayment.fromJson({
      'id': 1,
      'amount': 64000,
      'method': 'mtn',
      'state': 'success',
      'receipt_number': 'REC-1',
      'status': 'completed',
      'status_label': 'Payé',
      'method_label': 'MTN MoMo',
      'period': '2026-11-01',
    });
    expect(payment.hasReceipt, isTrue);
    expect(payment.period, DateTime(2026, 11));

    final contract = ParentContract.fromJson({
      'id': 9,
      'reference': 'CTR-9',
      'status': 'sent',
      'status_label': 'À signer',
      'legacy': true,
      'can_sign': true,
      'amendments_count': 2,
      'amendments_to_sign': 1,
    });
    expect(contract.legacy, isTrue);
    expect(contract.amendmentsToSign, 1);

    final child = ParentChild.fromJson({
      'id': 3,
      'first_name': 'Léa',
      'last_name': 'Mbarga',
      'birthdate': '2016-03-14',
      'section': 'francophone',
      'editable': true,
      'address': {'neighborhood': 'Bonapriso', 'address': 'rue Njo-Njo'},
      'courses': [
        {
          'subject': 'Anglais',
          'tutor_name': 'Aline N.',
          'stage': 'active',
          'reservation_id': 7
        }
      ],
    });
    expect(child.fullName, 'Léa Mbarga');
    expect(child.address!.label, 'Bonapriso, rue Njo-Njo');
    expect(child.courses.single.active, isTrue);
  });
}
