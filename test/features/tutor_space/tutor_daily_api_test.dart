import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/data/tutor_api.dart';

/// Answers every request with [status] and [body]; keeps the last request.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;
  RequestOptions? last;
  String? sentBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    if (requestStream != null) {
      sentBody = utf8.decode(
          await requestStream.fold<List<int>>([], (all, c) => all..addAll(c)));
    }
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

(TutorApi, _FakeAdapter) _api(int status, Map<String, dynamic> body) {
  final adapter = _FakeAdapter(status, body);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v2'))
    ..httpClientAdapter = adapter;
  return (TutorApi(dio), adapter);
}

Map<String, dynamic> _detail() => {
      'id': 12,
      'date': '2026-11-20',
      'starts_at': '2026-11-20T15:00:00+01:00',
      'ends_at': '2026-11-20T17:00:00+01:00',
      'subject': 'Maths',
      'pupil': 'Léa N.',
      'status': 'pending',
      'state': 'planned',
      'state_label': 'Prévue',
      'neighborhood': 'Bonapriso',
      'check_in': <String, dynamic>{},
      'can_move': true,
    };

void main() {
  group('TutorApi (REP-01, REP-16, REP-17)', () {
    test('moves a session: date and start time, the comment for the family',
        () async {
      final (api, adapter) = _api(200, {'data': _detail()});
      final detail = await api.moveSession(12,
          date: DateTime(2026, 11, 20), startAt: '15:00', comment: 'Conseil');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/tutor/sessions/12/move');
      expect(jsonDecode(adapter.sentBody!), {
        'date': '2026-11-20',
        'start_at': '15:00',
        'comment': 'Conseil',
      });
      expect(detail.canMove, isTrue);
      expect(detail.minutes, 120);
    });

    test('a move refused on a field is a validation failure with its message',
        () async {
      final (api, _) = _api(422, {
        'errors': [
          {
            'code': 'invalid',
            'message': 'Une séance se déplace dans le même mois.',
            'field': 'date'
          }
        ]
      });
      await expectLater(
        api.moveSession(12, date: DateTime(2026, 12, 2), startAt: '15:00'),
        throwsA(isA<ValidationFailure>().having(
            (f) => f.errors['date'], 'date', [
          'Une séance se déplace dans le même mois.'
        ]).having((f) => f.message, 'message',
            'Une séance se déplace dans le même mois.')),
      );
    });

    test('a move refused for a state change is a conflict with its message',
        () async {
      final (api, _) = _api(409, {
        'errors': [
          {
            'code': 'conflict',
            'message': 'Vous avez déjà une séance à cette heure-là.'
          }
        ]
      });
      await expectLater(
        api.moveSession(12, date: DateTime(2026, 11, 20), startAt: '15:00'),
        throwsA(isA<ConflictFailure>().having((f) => f.message, 'message',
            'Vous avez déjà une séance à cette heure-là.')),
      );
    });

    test('reads the sessions of a period with a filter', () async {
      final (api, adapter) = _api(200, {
        'data': [_detail()],
        'meta': {'page': 1, 'per_page': 100, 'total_count': 1, 'total_pages': 1}
      });
      final sessions = await api.sessions(
          DateTime(2026, 11, 1), DateTime(2026, 11, 30),
          filter: 'disputed');
      expect(adapter.last!.path, '/tutor/sessions');
      expect(adapter.last!.queryParameters['from'], '2026-11-01');
      expect(adapter.last!.queryParameters['to'], '2026-11-30');
      expect(adapter.last!.queryParameters['filter'], 'disputed');
      expect(sessions.single.id, 12);
    });

    test('the home carries the web offers and the recruitment texts', () async {
      final (api, _) = _api(200, {
        'data': {
          'active': false,
          'may_teach': false,
          'actions': <Map<String, dynamic>>[],
          'today_sessions': <Map<String, dynamic>>[],
          'month': <String, dynamic>{},
          'offers': [
            {
              'id': 4,
              'subjects': ['Mathématiques'],
              'school_classes': ['3e'],
              'neighborhood': 'Bonamoussadi',
              'session_rate': 6500,
            },
          ],
          'offers_title': 'Offres près de chez vous',
          'offers_note': 'Vous pouvez postuler avant la validation.',
          'recruitment': {
            'stage': 'file',
            'stage_label': 'Compléter le dossier',
            'refused': false,
            'step': 1,
            'total_steps': 6,
            'missing_documents': <Map<String, dynamic>>[],
            'sections_complete': 5,
            'sections_total': 7,
            'missing_sections': [
              {
                'section': 'presentation',
                'label': 'Présentation',
                'reason': 'à compléter.'
              }
            ],
            'delay_label': 'Délai communiqué par SOE (à confirmer).',
            'journey': [
              {'stage': 'file', 'label': 'Dossier complet', 'state': 'current'}
            ],
          },
        },
        'meta': <String, dynamic>{},
      });
      final home = await api.home();
      expect(home.offers!.single.title, 'Mathématiques · 3e');
      expect(home.offers!.single.sessionRate, 6500);
      expect(home.offersNote, 'Vous pouvez postuler avant la validation.');
      final recruitment = home.recruitment!;
      expect(recruitment.sectionsComplete, 5);
      expect(recruitment.missingSections.single.label, 'Présentation');
      expect(recruitment.journey.single.state, 'current');
      expect(recruitment.delayLabel, contains('à confirmer'));
    });

    test('no network is a network failure (the home shows « Hors connexion »)',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v2'))
        ..httpClientAdapter = _ThrowingAdapter();
      await expectLater(TutorApi(dio).home(), throwsA(isA<NetworkFailure>()));
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<List<int>>? requestStream, Future<void>? cancelFuture) =>
      throw DioException.connectionError(
          requestOptions: options, reason: 'offline');

  @override
  void close({bool force = false}) {}
}
