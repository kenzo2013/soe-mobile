import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/common/data/account_api.dart';
import 'package:soe/features/common/data/account_models.dart';
import 'package:soe/features/common/presentation/notification_target_route.dart';
import 'package:soe/features/common/presentation/pages/account_hub_page.dart';

import '../../helpers/fake_api.dart';

/// The account calls read and send the API v2 contract (soe/docs/api/v2/openapi.yml).
void main() {
  late FakeApi api;
  late AccountApi account;

  setUp(() {
    api = FakeApi();
    account = AccountApi(api.dio);
  });

  test('the password change returns the new session to keep', () async {
    api.on('PUT /account/password', (
      200,
      envelope({
        'token': 'new-jwt',
        'token_expires_at': '2026-12-05T10:00:00+01:00',
        'user': {'id': 1, 'email': 'a@example.com', 'current_role': 'parent'}
      })
    ));

    final session = await account.changePassword(
        currentPassword: 'Old1!pass',
        password: 'New1!pass',
        confirmation: 'New1!pass');

    expect(session['token'], 'new-jwt');
    expect(api.sent('PUT /account/password').single.json, {
      'current_password': 'Old1!pass',
      'password': 'New1!pass',
      'password_confirmation': 'New1!pass',
    });
  });

  test('a refused current password is a validation failure on its field',
      () async {
    api.on('PUT /account/password',
        invalid('current_password', 'Le mot de passe actuel est incorrect.'));

    await expectLater(
      account.changePassword(
          currentPassword: 'x', password: 'y', confirmation: 'y'),
      throwsA(isA<ValidationFailure>().having(
          (f) => f.errors['current_password'],
          'field',
          ['Le mot de passe actuel est incorrect.'])),
    );
  });

  test('the notification centre reads the filter, the items and the badge',
      () async {
    api.on('GET /notifications', (
      200,
      envelope([
        {
          'id': 4,
          'type': 'session_report',
          'title': 'PV d’anglais de Léa à valider',
          'body': 'validé automatiquement dans 46 h',
          'read': false,
          'todo': true,
          'day': 'today',
          'created_at': '2026-11-05T16:05:00+01:00',
          'target': {'kind': 'session_report', 'id': 12}
        },
      ], {
        'page': 1,
        'per_page': 50,
        'total_count': 1,
        'total_pages': 1,
        'filter': 'todo',
        'unread_count': 2
      })
    ));

    final page = await account.notifications(filter: 'todo');

    expect(api.sent('GET /notifications').single.query['filter'], 'todo');
    expect(page.unreadCount, 2);
    expect(page.items.single.todo, isTrue);
    expect(page.items.single.target!.kind, 'session_report');
    expect(page.items.single.target!.id, 12);
  });

  test('a preference box is sent alone', () async {
    api.on('PATCH /account/notification_preferences', (
      200,
      envelope({
        'categories': <Object>[],
        'channels': <Object>[],
        'mandatory': <Object>[]
      })
    ));

    await account.updateNotificationPreference(
        category: 'sessions', channel: 'email', value: false);

    expect(api.sent('PATCH /account/notification_preferences').single.json, {
      'preferences': {
        'sessions': {'email': false}
      }
    });
  });

  test('a report goes as multipart, the reason dropped on the emergency way',
      () async {
    api.on('POST /reports', (
      201,
      envelope({
        'id': 12,
        'reference': 'SIG-2611-0012',
        'report_type': 'safety_concern',
        'report_type_label': 'Comportement grave',
        'serious': true,
        'status': 'pending',
        'status_label': 'Reçu',
        'session': {
          'id': 5,
          'date': '2026-11-21',
          'student_first_name': 'Yann'
        },
        'created_at': '2026-11-22T10:05:00+01:00',
        'description': 'Grave',
        'photos_count': 0,
        'answer': null,
        'steps': [
          {
            'key': 'received',
            'label': 'Reçu',
            'at': '2026-11-22T10:05:00+01:00',
            'reached': true
          },
        ],
      })
    ));

    final report = await account.createReport(
        sessionId: 5,
        description: 'Grave',
        reportType: 'no_show',
        serious: true);

    final form = api.sent('POST /reports').single.data! as FormData;
    final fields = Map.fromEntries(form.fields);
    expect(fields['session_id'], '5');
    expect(fields['serious'], 'true');
    expect(fields.containsKey('report_type'), isFalse);
    expect(report.reference, 'SIG-2611-0012');
    expect(report.steps.single.reached, isTrue);
  });

  test('the deletion check lists what keeps the account', () async {
    api.on('GET /account/deletion', (
      200,
      envelope({
        'allowed': false,
        'blockers': [
          {
            'code': 'running_mission',
            'count': 2,
            'amount': null,
            'label': '2 lettres de mission actives',
            'step': 'Terminez vos missions avec votre contact SOE.'
          }
        ]
      })
    ));

    final check = await account.deletionCheck();

    expect(check.allowed, isFalse);
    expect(check.blockers.single.count, 2);
  });

  test('the help reads topics, phones and the emergency way', () {
    final help = HelpContent.fromJson({
      'default_topic': 'families',
      'topics': [
        {
          'key': 'families',
          'label': 'Familles',
          'questions': [
            {'question': 'Puis-je choisir mon répétiteur ?', 'answer': 'Non.'}
          ]
        }
      ],
      'contacts': {
        'email': 'hello@solutionofeducation.com',
        'phones': [
          {
            'key': 'cameroon',
            'label': 'Cameroun',
            'number': '+237675942344',
            'display': '+237 6 75 94 23 44',
            'whatsapp_url': 'https://wa.me/237675942344'
          }
        ]
      },
      'emergency': {'text': 'Appelez SOE.', 'phone': '+237675942344'}
    });

    expect(help.topics.single.questions.single.answer, 'Non.');
    expect(help.phones.single.display, '+237 6 75 94 23 44');
    expect(help.emergencyPhone, '+237675942344');
  });

  group('a notification opens the screen of the active role', () {
    NotificationTarget target(String kind, [int id = 7]) =>
        NotificationTarget(kind: kind, id: id);

    test('parent', () {
      expect(notificationRoute(target('session_report', 12), 'parent'),
          '/parent/space/sessions/12/report');
      expect(notificationRoute(target('contract'), 'parent'),
          '/parent/space/contracts/7');
      expect(
          notificationRoute(target('invoice'), 'parent'), '/parent/payments');
      expect(notificationRoute(target('proposal'), 'parent'), '/parent');
      expect(notificationRoute(null, 'parent'), '/parent');
    });

    test('tutor', () {
      expect(notificationRoute(target('proposal'), 'tutor'),
          '/tutor/space/proposals/7');
      expect(notificationRoute(target('earnings'), 'tutor'),
          '/tutor/remunerations');
      expect(notificationRoute(target('child'), 'tutor'), '/tutor');
    });
  });

  test('a Cameroonian number is shown in pairs', () {
    expect(formatCameroonPhone('677452109'), '+237 6 77 45 21 09');
    expect(formatCameroonPhone('+237 677 45 21 09'), '+237 6 77 45 21 09');
    expect(formatCameroonPhone('+33 7 53 95 20 24'), '+33 7 53 95 20 24');
  });
}
