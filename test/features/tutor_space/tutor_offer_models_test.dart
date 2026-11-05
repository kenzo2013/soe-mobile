import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/data/tutor_offer_api.dart';
import 'package:soe/features/tutor_space/data/tutor_offer_models.dart';
import 'package:soe/features/tutor_space/data/tutor_student_models.dart';

/// Answers every request with [body] (or [status] as an error) and records the request.
class _FakeServer extends Interceptor {
  _FakeServer(this.body, {this.status = 200});

  final Map<String, dynamic> body;
  final int status;
  RequestOptions? last;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    last = options;
    final response = Response<dynamic>(
        requestOptions: options, statusCode: status, data: body);
    if (status >= 400) {
      handler.reject(DioException.badResponse(
          statusCode: status, requestOptions: options, response: response));
    } else {
      handler.resolve(response);
    }
  }
}

TutorOfferApi _api(_FakeServer server) => TutorOfferApi(
    Dio(BaseOptions(baseUrl: 'https://api.test'))..interceptors.add(server));

const _offerJson = {
  'id': 7,
  'reference': 'OFF-2611-07',
  'subjects': ['Mathématiques', 'Physique'],
  'school_classes': ['3e'],
  'neighborhood': 'Bonamoussadi',
  'description': 'Élève de 3e.',
  'start_date': '2026-11-16',
  'session_rate': 6500,
  'published_at': '2026-11-02T08:00:00Z',
  'applied': true,
  'application_status': 'sent',
  'applied_at': '2026-11-24T09:00:00Z',
  'can_apply': false,
};

void main() {
  group('TutorOffer', () {
    test('parses an offer and its application', () {
      final offer = TutorOffer.fromJson(_offerJson);
      expect(offer.id, 7);
      expect(offer.title('et'), 'Mathématiques et Physique · 3e');
      expect(offer.neighborhood, 'Bonamoussadi');
      expect(offer.startDate, DateTime(2026, 11, 16));
      expect(offer.sessionRate, 6500);
      expect(offer.applied, isTrue);
      expect(offer.canApply, isFalse);
      expect(offer.appliedAt, isNotNull);
    });

    test('tolerates a minimal offer', () {
      final offer = TutorOffer.fromJson(const {'id': 1});
      expect(offer.title('et'), '');
      expect(offer.sessionRate, isNull);
      expect(offer.canApply, isFalse);
    });
  });

  test('TutorApplication parses the answer and the offer', () {
    final application = TutorApplication.fromJson(const {
      'id': 3,
      'status': 'selected',
      'status_label': 'Retenue',
      'sent_at': '2026-11-12T10:00:00Z',
      'offer_id': 7,
      'reference': 'OFF-2611-07',
      'subjects': ['SVT'],
      'school_class': '2nde',
      'neighborhood': 'Bépanda',
    });
    expect(application.status, 'selected');
    expect(application.statusLabel, 'Retenue');
    expect(application.offerId, 7);
    expect(application.title('et'), 'SVT · 2nde');
  });

  test('TutorOfferFilters builds the query and compares by value', () {
    const filters = TutorOfferFilters();
    expect(filters.query, {'mine': '1', 'zone': '1'});
    final chosen =
        filters.copyWith(mine: false, zone: false, schoolClassId: () => 4);
    expect(chosen.query, {'mine': '0', 'zone': '0', 'school_class_id': 4});
    expect(chosen.copyWith(schoolClassId: () => null).schoolClassId, isNull);
    expect(const TutorOfferPageKey(TutorOfferFilters(), 2),
        const TutorOfferPageKey(TutorOfferFilters(), 2));
  });

  group('pupils', () {
    test('TutorPupil parses a card', () {
      final pupil = TutorPupil.fromJson(const {
        'id': 5,
        'pupil': 'Yann M.',
        'school_class': '4e',
        'subjects': ['Maths'],
        'neighborhood': 'Bonapriso',
        'state': 'active',
        'state_label': 'Actif',
        'times': [
          {'day': 'wednesday', 'from': '16:00', 'to': '18:00'}
        ],
        'start_date': '2026-12-07',
      });
      expect(pupil.state, 'active');
      expect(pupil.times.single.hours, '16:00 – 18:00');
      expect(pupil.startDate, DateTime(2026, 12, 7));
    });

    test('TutorPupilFile hides the parents to call before the contract', () {
      Map<String, dynamic> json({required bool shared}) => {
            'id': 5,
            'pupil': 'Samuel',
            'contact_shared': shared,
            'address': shared ? 'Rue Njo-Njo' : null,
            'parents': shared
                ? [
                    {'name': 'Mireille Mbarga', 'phone': '+237677452109'},
                    {'name': 'M. Mbarga', 'phone': null},
                  ]
                : <Map<String, dynamic>>[],
            'reports': [
              {
                'session_id': 9,
                'date': '2026-11-25',
                'topics': ['Pythagore'],
                'state': 'report_sent',
                'state_label': 'En attente du parent'
              }
            ],
            'slots_to_plan': [
              {'slot_id': 12, 'subject': 'Maths'}
            ],
          };
      final shared = TutorPupilFile.fromJson(json(shared: true));
      expect(shared.callableParents.single.name, 'Mireille Mbarga');
      expect(shared.reports.single.sessionId, 9);
      expect(shared.slotsToPlan.single.slotId, 12);
      final hidden = TutorPupilFile.fromJson(json(shared: false));
      expect(hidden.contactShared, isFalse);
      expect(hidden.address, isNull);
      expect(hidden.callableParents, isEmpty);
    });
  });

  group('TutorOfferApi', () {
    test('reads a page of offers with the filters', () async {
      final server = _FakeServer({
        'data': [_offerJson],
        'meta': {
          'page': 1,
          'per_page': 20,
          'total_count': 21,
          'total_pages': 2
        },
      });
      final page = await _api(server).offers(
          const TutorOfferFilters(zone: false, schoolClassId: 3),
          page: 1);
      expect(server.last!.path, '/tutor/offers');
      expect(server.last!.queryParameters, {
        'mine': '1',
        'zone': '0',
        'school_class_id': 3,
        'page': 1,
        'per_page': 20,
      });
      expect(page.items.single.reference, 'OFF-2611-07');
      expect(page.hasMore, isTrue);
    });

    test('applies with the trimmed message, or none', () async {
      final server = _FakeServer({
        'data': {'id': 1, 'status': 'sent', 'offer_id': 7},
      });
      final application = await _api(server).apply(7, message: '  Bonjour ');
      expect(server.last!.path, '/tutor/offers/7/apply');
      expect(server.last!.data, {'message': 'Bonjour'});
      expect(application.status, 'sent');
      await _api(server).apply(7, message: '   ');
      expect(server.last!.data, isEmpty);
    });

    test('maps a conflict to a ConflictFailure', () async {
      final server = _FakeServer({
        'data': null,
        'errors': [
          {
            'code': 'conflict',
            'message': 'Vous avez déjà postulé à cette offre.'
          }
        ],
      }, status: 409);
      await expectLater(_api(server).apply(7), throwsA(isA<ConflictFailure>()));
    });

    test('reads the pupils and a pupil file', () async {
      final server = _FakeServer({
        'data': [
          {'id': 5, 'pupil': 'Yann M.', 'state': 'active'}
        ],
      });
      final pupils = await _api(server).students();
      expect(server.last!.path, '/tutor/students');
      expect(pupils.single.pupil, 'Yann M.');
      final fileServer = _FakeServer({
        'data': {'id': 5, 'pupil': 'Yann M.', 'contact_shared': true},
      });
      final file = await _api(fileServer).student(5);
      expect(fileServer.last!.path, '/tutor/students/5');
      expect(file.contactShared, isTrue);
    });
  });
}
