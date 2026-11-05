import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

import '../../helpers/fake_api.dart';
import 'account_test_app.dart';

Map<String, dynamic> _notification(int id,
        {String day = 'today',
        bool read = false,
        String type = 'session_report',
        Map<String, dynamic>? target}) =>
    {
      'id': id,
      'type': type,
      'title': 'Notification $id',
      'body': 'détail $id',
      'read': read,
      'todo': !read,
      'day': day,
      'created_at': '2026-11-05T16:05:00+01:00',
      'target': target,
    };

Map<String, dynamic> _listMeta(int unread, [String filter = 'all']) => {
      'page': 1,
      'per_page': 50,
      'total_count': 2,
      'total_pages': 1,
      'filter': filter,
      'unread_count': unread,
    };

/// The text field showing [value].
Finder _field(String value) => find.byWidgetPredicate(
    (widget) => widget is EditableText && widget.controller.text == value);

FakeApi _apiWithAddress() => FakeApi()
  ..on('GET /account/address', (
    200,
    envelope({
      'neighborhood': 'Bonapriso',
      'city': 'Douala',
      'landmark': 'Portail bleu',
      'latitude': 4.03,
      'longitude': 9.69,
      'check_in_radius_meters': 150
    })
  ));

void main() {
  group('COM-01 Mon compte', () {
    testWidgets('the account card, the pages, help, sign-out and the language',
        (tester) async {
      await pumpAccountApp(tester, api: _apiWithAddress(), location: '/more');

      expect(
          find.text('MODE PARENT · MIREILLE.MBARGA@GMAIL.COM'), findsOneWidget);
      expect(find.text('Mireille Mbarga'), findsOneWidget);
      expect(
          find.text('+237 6 77 45 21 09 · Bonapriso, Douala'), findsOneWidget);
      expect(
          find.text('Bonapriso · sert aussi au pointage GPS'), findsOneWidget);
      for (final label in [
        'Informations personnelles',
        'Sécurité',
        'Rôles',
        'Aide et contact SOE',
        'Signaler un problème',
        'Se déconnecter',
        'Langue',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Changer d’espace'), findsNothing);
    });

    testWidgets('a section opens its page', (tester) async {
      final api = _apiWithAddress()
        ..on('GET /help', (
          200,
          envelope({
            'default_topic': 'families',
            'topics': [
              {
                'key': 'families',
                'label': 'Familles',
                'questions': [
                  {
                    'question': 'Puis-je choisir mon répétiteur ?',
                    'answer': 'Non : SOE le choisit et vous le présente.'
                  }
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
            'emergency': {
              'text': 'Appelez SOE immédiatement.',
              'phone': '+237675942344'
            }
          })
        ));
      await pumpAccountApp(tester, api: api, location: '/more');

      await tester.tap(find.text('Aide et contact SOE'));
      await tester.pumpAndSettle();

      expect(find.text('Aide et contact'), findsOneWidget);
      expect(find.text('Familles'), findsOneWidget);
      await tester.tap(find.text('Puis-je choisir mon répétiteur ?'));
      await tester.pumpAndSettle();
      expect(find.text('Non : SOE le choisit et vous le présente.'),
          findsOneWidget);
      expect(find.text('+237 6 75 94 23 44'), findsOneWidget);
      expect(find.text('Appelez SOE immédiatement.'), findsOneWidget);
    });

    testWidgets('a multi-role account switches space from its card',
        (tester) async {
      final api = _apiWithAddress()
        ..on('GET /account/roles', (
          200,
          envelope({
            'current_role': 'parent',
            'roles': [
              {'role': 'parent', 'label': 'Parent'},
              {'role': 'tutor', 'label': 'Répétiteur'}
            ],
            'addable_role': null,
            'preferred_role': null
          })
        ));
      await pumpAccountApp(tester,
          api: api, location: '/more', user: accountUser(multiRole: true));

      await tester.tap(find.text('Changer d’espace'));
      await tester.pumpAndSettle();

      expect(find.text('Mes rôles'), findsOneWidget);
      expect(find.text('Rôle actif'), findsOneWidget);
      expect(find.text('Passer à ce rôle'), findsOneWidget);
      expect(find.text('Espace à l’ouverture'), findsOneWidget);
    });
  });

  group('COM-07 notifications', () {
    testWidgets('the bell shows a dot while something is unread',
        (tester) async {
      final api = _apiWithAddress()
        ..on('GET /notifications/unread_count',
            (200, envelope({'unread_count': 2})));
      await pumpAccountApp(tester, api: api, location: '/more');

      expect(find.byKey(const Key('notification-bell-dot')), findsOneWidget);
    });

    testWidgets('grouped by day; a tap marks it read and opens its screen',
        (tester) async {
      final api = FakeApi()
        ..on('GET /notifications', (
          200,
          envelope([
            _notification(4, target: {'kind': 'session', 'id': 12}),
            _notification(3, day: 'earlier', read: true, type: 'payment'),
          ], _listMeta(1))
        ))
        ..on('POST /notifications/4/read', (
          200,
          {
            'data': _notification(4,
                read: true, target: {'kind': 'session', 'id': 12}),
            'meta': {'unread_count': 0}
          }
        ));
      await pumpAccountApp(tester, api: api, location: '/notifications');

      expect(find.text('Aujourd’hui'), findsOneWidget);
      expect(find.text('Plus tôt'), findsOneWidget);
      expect(find.text('Nouveau'), findsOneWidget);

      await tester.tap(find.text('Notification 4'));
      await tester.pumpAndSettle();

      expect(api.sent('POST /notifications/4/read'), hasLength(1));
      expect(find.text('screen /parent/space/sessions/12'), findsOneWidget);
    });

    testWidgets('the filters ask the server; « Tout marquer comme lu »',
        (tester) async {
      final api = FakeApi()
        ..routes['GET /notifications'] = ((request) => (
              200,
              envelope(
                  request.query['filter'] == 'todo'
                      ? <Map<String, dynamic>>[]
                      : [_notification(4)],
                  _listMeta(1, request.query['filter'] as String))
            ))
        ..on('GET /notifications/unread_count',
            (200, envelope({'unread_count': 1})))
        ..on('POST /notifications/read_all',
            (200, envelope({'unread_count': 0})));
      await pumpAccountApp(tester, api: api, location: '/notifications');

      await tester.tap(find.text('À faire'));
      await tester.pumpAndSettle();
      expect(find.text('Rien à faire'), findsOneWidget);

      await tester.tap(find.text('Tout marquer comme lu'));
      await tester.pumpAndSettle();
      expect(api.sent('POST /notifications/read_all'), hasLength(1));
    });
  });

  group('COM-03 security', () {
    testWidgets('a changed password keeps the new token on this device',
        (tester) async {
      final storage = MemoryStorage();
      final api = FakeApi()
        ..on('PUT /account/password', (
          200,
          envelope({
            'token': 'new-jwt',
            'token_expires_at': '2026-12-05T10:00:00+01:00',
            'user': {
              'id': 1,
              'email': 'mireille.mbarga@gmail.com',
              'first_name': 'Mireille',
              'last_name': 'Mbarga',
              'roles': ['parent'],
              'current_role': 'parent',
              'has_photo': false
            }
          })
        ));
      await pumpAccountApp(tester,
          api: api, location: '/account/security', storage: storage);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Old1!pass');
      await tester.enterText(fields.at(1), 'New1!pass');
      await tester.enterText(fields.at(2), 'New1!pass');
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();

      expect(api.sent('PUT /account/password'), hasLength(1));
      expect(storage.values[StorageKeys.authToken], 'new-jwt');
    });

    testWidgets('a mismatch is caught before sending', (tester) async {
      final api = FakeApi();
      await pumpAccountApp(tester, api: api, location: '/account/security');

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'Old1!pass');
      await tester.enterText(fields.at(1), 'New1!pass');
      await tester.enterText(fields.at(2), 'Other1!pass');
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();

      expect(api.sent('PUT /account/password'), isEmpty);
      expect(
          find.text(
              'La confirmation ne correspond pas au nouveau mot de passe.'),
          findsOneWidget);
    });

    testWidgets('the deletion is blocked with the way to clear it',
        (tester) async {
      final api = FakeApi()
        ..on('GET /account/deletion', (
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
              },
              {
                'code': 'disputed_report',
                'count': 1,
                'amount': null,
                'label': 'un PV contesté en cours d’examen',
                'step': 'Attendez la décision sur le PV contesté.'
              }
            ]
          })
        ));
      await pumpAccountApp(tester,
          api: api,
          location: '/account/security/deletion',
          role: 'tutor',
          user: accountUser(role: UserRole.tutor));

      expect(
          find.text('Suppression impossible pour le moment'), findsOneWidget);
      expect(
          find.text(
              'Vous avez 2 lettres de mission actives et un PV contesté en cours d’examen.'),
          findsOneWidget);
      expect(find.text('Attendez la décision sur le PV contesté.'),
          findsOneWidget);
      expect(find.text('Supprimer définitivement'), findsNothing);
    });

    testWidgets('the deletion needs the password and « définitive »',
        (tester) async {
      final storage = MemoryStorage()..values[StorageKeys.authToken] = 'jwt';
      final api = FakeApi()
        ..on('GET /account/deletion',
            (200, envelope({'allowed': true, 'blockers': <Object>[]})))
        ..on('POST /account/deletion', (204, null));
      await pumpAccountApp(tester,
          api: api, location: '/account/security/deletion', storage: storage);

      expect(find.text('Ce qui sera supprimé'), findsOneWidget);
      expect(find.text('Les fiches de vos enfants et vos co-parents.'),
          findsOneWidget);

      await tester.tap(find.text('Supprimer définitivement'));
      await tester.pumpAndSettle();
      expect(api.sent('POST /account/deletion'), isEmpty);

      await tester.enterText(find.byType(EditableText), 'Secret1!');
      await tester
          .tap(find.text('Je comprends que la suppression est définitive.'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer définitivement'));
      await tester.pumpAndSettle();

      expect(api.sent('POST /account/deletion').single.json,
          {'password': 'Secret1!', 'confirmed': true});
      expect(storage.values.containsKey(StorageKeys.authToken), isFalse);
      expect(find.text('screen /login'), findsOneWidget);
    });
  });

  group('COM-02, COM-04, COM-06', () {
    testWidgets('a new e-mail asks the password, then the 6-digit code',
        (tester) async {
      final api = FakeApi()
        ..on('POST /account/contact_change', (
          201,
          envelope({
            'id': 3,
            'field': 'email',
            'value': 'new@example.com',
            'code_sent_to': 'new@example.com',
            'code_sent_at': '2026-11-05T10:00:00+01:00',
            'expires_at': '2026-11-05T10:15:00+01:00',
            'resend_in': 60
          })
        ));
      await pumpAccountApp(tester, api: api, location: '/account/profile');

      expect(find.text('Mot de passe actuel'), findsNothing);
      await tester.enterText(
          _field('mireille.mbarga@gmail.com'), 'new@example.com');
      await tester.pumpAndSettle();
      expect(find.text('Mot de passe actuel'), findsWidgets);

      await tester.enterText(find.byType(EditableText).last, 'Secret1!');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(api.sent('PATCH /me'), isEmpty);
      expect(api.sent('POST /account/contact_change').single.json, {
        'field': 'email',
        'contact_value': 'new@example.com',
        'current_password': 'Secret1!',
      });
      expect(find.text('Confirmez votre nouvelle adresse'), findsOneWidget);
      expect(find.textContaining('Renvoyer dans'), findsOneWidget);
    });

    testWidgets('the profile sends the fields changed', (tester) async {
      final api = FakeApi()
        ..on('PATCH /me', (
          200,
          envelope({
            'id': 1,
            'email': 'mireille.mbarga@gmail.com',
            'first_name': 'Mireille',
            'last_name': 'Mbarga-Eto',
            'roles': ['parent'],
            'current_role': 'parent',
            'civility': 'mrs',
            'lang': 'fr',
            'has_photo': false
          })
        ));
      await pumpAccountApp(tester, api: api, location: '/account/profile');

      await tester.enterText(_field('Mbarga'), 'Mbarga-Eto');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(api.sent('PATCH /me').single.json, {
        'civility': 'mrs',
        'first_name': 'Mireille',
        'last_name': 'Mbarga-Eto',
        'lang': 'fr',
      });
      expect(find.text('Vos informations sont enregistrées.'), findsOneWidget);
    });

    testWidgets('the address saves the fields and the pin', (tester) async {
      final api = _apiWithAddress()
        ..on('GET /references', (
          200,
          envelope({
            'subjects': <Object>[],
            'school_classes': <Object>[],
            'educations': <Object>[],
            'sections': <Object>[],
            'cities': [
              {'name': 'Douala', 'neighborhoods': <Object>[]},
              {'name': 'Yaoundé', 'neighborhoods': <Object>[]}
            ]
          })
        ))
        ..on('PATCH /account/address', (
          200,
          envelope({
            'neighborhood': 'Bastos',
            'city': 'Yaoundé',
            'landmark': 'Portail bleu',
            'latitude': 4.03,
            'longitude': 9.69,
            'check_in_radius_meters': 150
          })
        ));
      await pumpAccountApp(tester, api: api, location: '/account/address');

      expect(find.text('Adresse des cours'), findsOneWidget);
      expect(find.byKey(const Key('address-pin')), findsOneWidget);
      expect(find.textContaining('moins de 150 m'), findsOneWidget);

      await tester.enterText(_field('Bonapriso'), 'Bastos');
      await tester.tap(find.text('Yaoundé'));
      await tester.tap(find.text('Enregistrer l’adresse'));
      await tester.pumpAndSettle();

      expect(api.sent('PATCH /account/address').single.json, {
        'neighborhood': 'Bastos',
        'city': 'Yaoundé',
        'landmark': 'Portail bleu',
        'latitude': 4.03,
        'longitude': 9.69,
      });
    });

    testWidgets('a box of the grid is saved at once; SMS is not available',
        (tester) async {
      Map<String, dynamic> prefs(bool email) => envelope({
            'categories': [
              {
                'key': 'sessions',
                'label': 'Séances',
                'channels': {'app': true, 'email': email}
              }
            ],
            'channels': [
              {'key': 'app', 'label': 'App', 'available': true},
              {'key': 'email', 'label': 'E-mail', 'available': true},
              {'key': 'sms', 'label': 'SMS', 'available': false},
            ],
            'mandatory': [
              {
                'key': 'verification_code',
                'title': 'Code de vérification',
                'text': 'Sécurité du compte'
              }
            ]
          });
      final api = FakeApi()
        ..on('GET /account/notification_preferences', (200, prefs(false)))
        ..on('PATCH /account/notification_preferences', (200, prefs(true)));
      await pumpAccountApp(tester,
          api: api, location: '/account/notification-preferences');

      expect(find.text('Code de vérification'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Séances par SMS'));
      await tester.pumpAndSettle();
      expect(api.sent('PATCH /account/notification_preferences'), isEmpty);

      await tester.tap(find.bySemanticsLabel('Séances par E-mail'));
      await tester.pumpAndSettle();
      expect(api.sent('PATCH /account/notification_preferences').single.json, {
        'preferences': {
          'sessions': {'email': true}
        }
      });
      expect(find.textContaining('Enregistré à'), findsOneWidget);
    });
  });

  group('COM-09 report a problem', () {
    FakeApi reportApi() => FakeApi()
      ..on('GET /reports/reasons', (
        200,
        envelope({
          'reasons': [
            {'key': 'repeated_lateness', 'label': 'Retard'},
            {'key': 'no_show', 'label': 'Absence'},
          ],
          'serious_reason': {
            'key': 'safety_concern',
            'label': 'Comportement grave'
          },
          'description_max': 500,
          'photos_max': 3,
          'recent_days': 30,
          'emergency_phone': '+237 6 75 94 23 44'
        })
      ))
      ..on('GET /reports/sessions', (
        200,
        envelope([
          {
            'id': 5,
            'date': '2026-11-21',
            'start_at': '09:00',
            'end_at': '11:00',
            'student_first_name': 'Yann',
            'label': 'Sam. 21 nov. · Yann'
          }
        ], {
          'page': 1,
          'per_page': 50,
          'total_count': 1,
          'total_pages': 1
        })
      ))
      ..on('POST /reports', (
        201,
        envelope({
          'id': 12,
          'reference': 'SIG-2611-0012',
          'report_type': 'repeated_lateness',
          'report_type_label': 'Retard',
          'serious': false,
          'status': 'pending',
          'status_label': 'Reçu',
          'session': {
            'id': 5,
            'date': '2026-11-21',
            'student_first_name': 'Yann'
          },
          'created_at': '2026-11-22T10:05:00+01:00',
          'description': 'Arrivé à 9:30.',
          'photos_count': 0,
          'answer': null,
          'steps': [
            {
              'key': 'received',
              'label': 'Reçu',
              'at': '2026-11-22T10:05:00+01:00',
              'reached': true
            },
            {
              'key': 'in_progress',
              'label': 'En cours de traitement par SOE',
              'at': null,
              'reached': false
            },
            {
              'key': 'resolved',
              'label': 'Résolu',
              'at': null,
              'reached': false
            },
          ]
        })
      ));

    testWidgets(
        'prefilled session, a reason, a description, then the follow-up',
        (tester) async {
      final api = reportApi();
      api.routes['GET /reports/12'] = (_) => api.routes['POST /reports']!(
          RecordedRequest('GET', '/reports/12', null, const {}));
      await pumpAccountApp(tester,
          api: api, location: '/account/reports/new?session_id=5');

      expect(find.text('Votre message va à SOE, jamais au répétiteur.'),
          findsOneWidget);
      expect(find.text('Un comportement grave (sécurité de l’enfant) ?'),
          findsOneWidget);
      expect(find.text('Contexte'), findsOneWidget);

      await tester.tap(find.text('Retard'));
      await tester.enterText(find.byType(EditableText), 'Arrivé à 9:30.');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer à SOE'));
      await tester.pumpAndSettle();

      final form = api.sent('POST /reports').single.data;
      expect(form, isNotNull);
      expect(find.text('Signalement SIG-2611-0012'), findsOneWidget);
      expect(find.text('En cours de traitement par SOE'), findsOneWidget);
      expect(find.text('À venir'), findsNWidgets(2));
    });

    testWidgets('the emergency way replaces the reasons', (tester) async {
      await pumpAccountApp(tester,
          api: reportApi(), location: '/account/reports/new');

      expect(find.text('Quelle séance ?'), findsOneWidget);
      await tester.tap(find.text('Signaler un comportement grave').last);
      await tester.pumpAndSettle();

      expect(find.text('Comportement grave'), findsOneWidget);
      expect(find.text('Retard'), findsNothing);
    });
  });
}
