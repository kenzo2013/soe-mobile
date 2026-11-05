import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/data/tutor_file_api.dart';
import 'package:soe/features/tutor_space/data/tutor_file_models.dart';
import 'package:soe/features/tutor_space/presentation/widgets/tutor_file_availability_form.dart';

import 'tutor_file_fixtures.dart';

/// Records the requests and answers with a canned envelope (or an error status).
class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, {this.status = 200});

  final Map<String, dynamic> body;
  final int status;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

(TutorFileApi, _Adapter) _api(Map<String, dynamic> data, {int status = 200}) {
  final adapter = _Adapter(
      status == 200
          ? {'data': data, 'meta': <String, dynamic>{}}
          : {
              'errors': [
                {'code': 'conflict', 'message': 'Pièce vérifiée.'}
              ]
            },
      status: status);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v2'))
    ..httpClientAdapter = adapter;
  return (TutorFileApi(dio), adapter);
}

/// The recruitment models read the API v2 responses (soe/docs/api/v2/openapi.yml).
void main() {
  group('models', () {
    test('a file being filled, with a document to redo and the badge', () {
      final file = TutorFile.fromJson(fileJson());
      expect(file.filling, isTrue);
      expect(file.step, 1);
      expect(file.totalSteps, 6);
      expect(file.completeCount, 5);
      expect(file.sections, hasLength(7));
      expect(file.section('diplomas')!.state, 'redo');
      expect(file.section('presentation')!.isComplete, isFalse);
      expect(file.badge.map((b) => b.item),
          ['identity', 'diplomas', 'interview', 'test']);
      expect(file.toRedo.single.section, TutorFileSections.diplomas);
      expect(file.toRedo.single.reason, 'Relevé illisible.');
      expect(file.completeExcept('presentation'), isTrue);
      expect(file.completeExcept('diplomas'), isFalse);
    });

    test('a section and its content, by section', () {
      final identity = TutorFileSection.fromJson(sectionJson('identity',
          content: {
            'document_type': 'cni',
            'birthdate': '1996-04-12',
            'expires_on': '2030-01-01',
            'images_count': 2,
          },
          state: 'redo',
          redoReason: 'Photo floue.'));
      expect(identity.toRedo, isTrue);
      expect(identity.redoReason, 'Photo floue.');
      expect(identity.identity.documentType, 'cni');
      expect(identity.identity.birthdate, DateTime(1996, 4, 12));
      expect(identity.identity.imagesCount, 2);

      final diplomas =
          TutorFileSection.fromJson(sectionJson('diplomas', content: {
        'items': [
          {
            'id': 3,
            'category': 'Licence',
            'level_of_study': 'Bac+3',
            'field_of_training': 'Maths',
            'speciality': null,
            'obtained_at': '2019-07-01',
            'documents_count': 2,
          }
        ],
        'max': 10,
      }));
      expect(diplomas.diplomas.single.title, 'Licence · Maths');
      expect(diplomas.diplomas.single.obtainedAt!.year, 2019);
      expect(diplomas.diplomasMax, 10);

      final presentation = TutorFileSection.fromJson(sectionJson('presentation',
          content: {'bio': 'Bonjour', 'bio_max': 500, 'has_photo': true}));
      expect(presentation.presentation.bioMax, 500);
      expect(presentation.presentation.hasPhoto, isTrue);
    });

    test('the interview and the charter', () {
      final interview = TutorInterview.fromJson({
        'stage': 'test',
        'interview_at': '2026-12-02T11:00:00+01:00',
        'interview_passed': true,
        'bring': ['Votre pièce d’identité originale.'],
        'test_score': null,
        'test_passed': false,
      });
      expect(interview.interviewAt, isNotNull);
      expect(interview.testScore, isNull);
      expect(TutorJourney.reached(interview.stage, 'test'), isTrue);
      expect(TutorJourney.reached('documents_check', 'interview'), isFalse);
      expect(TutorJourney.reached('refused', 'file'), isFalse);

      final charter = TutorCharter.fromJson(charterJson(canSign: true));
      expect(charter.canSign, isTrue);
      expect(charter.signedAt, isNull);
      expect(charter.articles.first.title, 'Ponctualité et présence');
    });
  });

  group('availability grid', () {
    TutorAvailabilityContent content(Map<String, List<List<String>>> days) =>
        TutorAvailabilityContent(
          days: {
            for (final e in days.entries)
              e.key: [
                for (final r in e.value) TutorTimeRange(from: r[0], to: r[1])
              ],
          },
          opensAt: '07:00',
          closesAt: '21:30',
        );

    test('three blocks between the opening and the closing', () {
      final grid = TutorAvailabilityGrid(content({}));
      expect(grid.blocks, [(420, 720), (720, 960), (960, 1290)]);
      expect(grid.selectedCount, 0);
    });

    test('touching blocks merge: never more than two ranges a day', () {
      final grid = TutorAvailabilityGrid(content({}))
        ..toggle('monday', 0)
        ..toggle('monday', 1)
        ..toggle('tuesday', 0)
        ..toggle('tuesday', 2);
      expect(grid.rangesOf('monday'),
          [const TutorTimeRange(from: '07:00', to: '16:00')]);
      expect(grid.rangesOf('tuesday'), hasLength(2));
      grid
        ..toggle('wednesday', 0)
        ..toggle('wednesday', 1)
        ..toggle('wednesday', 2);
      expect(grid.rangesOf('wednesday'),
          [const TutorTimeRange(from: '07:00', to: '21:30')]);
      final json = grid.toJson();
      expect(json.keys, hasLength(7));
      expect(json['sunday'], isEmpty);
    });

    test('ranges on file: cells overlapping them, alignment, copy and clear',
        () {
      final grid = TutorAvailabilityGrid(content({
        'monday': [
          ['16:00', '19:00']
        ],
      }));
      expect(grid.cells['monday'], [false, false, true]);
      expect(grid.aligned, isFalse);
      grid.copyMonday();
      expect(grid.cells['sunday'], [false, false, true]);
      expect(grid.selectedCount, 7);
      grid.clear();
      expect(grid.selectedCount, 0);

      final aligned = TutorAvailabilityGrid(content({
        'saturday': [
          ['07:00', '12:00']
        ],
      }));
      expect(aligned.aligned, isTrue);
    });
  });

  group('api', () {
    test('reads the file and sends it', () async {
      final (api, adapter) = _api(fileJson());
      final file = await api.file();
      expect(file.sections, hasLength(7));
      await api.submit();
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.path, '/tutor/file/submit');
    });

    test('a section without files is sent as JSON', () async {
      final (api, adapter) = _api(sectionJson('availability', content: {
        'days': <dynamic>[],
        'opens_at': '07:00',
        'closes_at': '21:30',
      }));
      await api.updateSection('availability', {
        'days': {
          'monday': [
            {'from': '16:00', 'to': '19:00'}
          ]
        },
      });
      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/tutor/file/availability');
      expect(request.data, isA<Map<String, Object?>>());
    });

    test('the identity photos go as multipart images[]', () async {
      final (api, adapter) = _api(sectionJson('identity', content: {
        'document_type': 'cni',
        'birthdate': '1996-04-12',
        'expires_on': '2030-01-01',
        'images_count': 2,
      }));
      await api.updateSection(
        'identity',
        {
          'document_type': 'cni',
          'birthdate': '1996-04-12',
          'expires_on': '2030-01-01',
          'subject_ids': [1, 2],
        },
        files: const [
          TutorUpload(bytes: [1, 2, 3], filename: 'front.jpg'),
          TutorUpload(bytes: [4, 5], filename: 'back.png'),
        ],
        filesField: 'images[]',
      );
      final form = adapter.requests.single.data as FormData;
      expect(form.files.map((f) => f.key), ['images[]', 'images[]']);
      expect(form.files.last.value.contentType.toString(), 'image/png');
      expect(form.fields.map((f) => '${f.key}=${f.value}'),
          contains('document_type=cni'));
      expect(form.fields.where((f) => f.key == 'subject_ids[]'), hasLength(2));
    });

    test('removes an item and signs the charter', () async {
      final (api, adapter) = _api(sectionJson('experiences', content: {
        'items': <dynamic>[],
      }));
      await api.deleteItem('experiences', 4);
      expect(adapter.requests.single.method, 'DELETE');
      expect(adapter.requests.single.path, '/tutor/file/experiences/items/4');

      final (charterApi, charterAdapter) = _api(charterJson(canSign: false));
      final charter = await charterApi.signCharter([1, 2, 3]);
      expect(charter.articles, isNotEmpty);
      final form = charterAdapter.requests.single.data as FormData;
      expect(form.fields.map((f) => '${f.key}=${f.value}'),
          contains('read_confirmed=1'));
      expect(form.files.single.key, 'signature');
    });

    test('a 409 becomes a ConflictFailure with the server message', () async {
      final (api, _) = _api(const {}, status: 409);
      await expectLater(
        api.updateSection('identity', const {}),
        throwsA(isA<ConflictFailure>()),
      );
    });
  });
}
