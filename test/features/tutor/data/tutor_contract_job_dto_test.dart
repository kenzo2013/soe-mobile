import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soe/features/tutor/data/dtos/tutor_contract_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_job_dto.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('TutorContractDto · branches non couvertes', () {
    test('non signé → dateLine "Reçu ..." depuis created_at', () {
      final dto = TutorContractDto.fromJson(const {
        'id': 'ct1',
        'created_at': '2026-05-06T00:00:00',
      });
      final e = dto.toEntity();
      expect(e.signed, isFalse);
      expect(e.dateLine, startsWith('Reçu'));
    });

    test('reference fallback : ref puis id', () {
      expect(
        TutorContractDto.fromJson(const {'id': '9', 'ref': 'R-9'})
            .toEntity()
            .reference,
        'R-9',
      );
      expect(
        TutorContractDto.fromJson(const {'id': '9'}).toEntity().reference,
        '9',
      );
    });

    test('parent / student depuis maps first+last name', () {
      final dto = TutorContractDto.fromJson(const {
        'id': 'ct1',
        'parent': {'first_name': 'Paul', 'last_name': 'Mbarga'},
        'student': {'first_name': 'Junior', 'last_name': 'Kamga'},
      });
      final e = dto.toEntity();
      expect(e.parent, 'Paul Mbarga');
      expect(e.student, 'Junior Kamga');
    });

    test('parent via `client`, student via `child`', () {
      final dto = TutorContractDto.fromJson(const {
        'id': 'ct1',
        'client': {'name': 'Société X'},
        'child': {'full_name': 'Ada Lovelace'},
      });
      final e = dto.toEntity();
      expect(e.parent, 'Société X');
      expect(e.student, 'Ada Lovelace');
    });

    test('parent_name / student_name (chaînes plates)', () {
      final dto = TutorContractDto.fromJson(const {
        'id': 'ct1',
        'parent_name': 'Marc',
        'student_name': 'Léa',
      });
      final e = dto.toEntity();
      expect(e.parent, 'Marc');
      expect(e.student, 'Léa');
    });

    test('signed dérivé de signature_status == "signed"', () {
      expect(
        TutorContractDto.fromJson(const {
          'id': 'ct1',
          'signature_status': 'signed',
          'signed_at': '2026-05-06T00:00:00',
        }).toEntity().signed,
        isTrue,
      );
      expect(
        TutorContractDto.fromJson(const {
          'id': 'ct1',
          'status': 'pending',
        }).toEntity().signed,
        isFalse,
      );
    });

    test('signed via is_signed bool', () {
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'is_signed': true})
            .toEntity()
            .signed,
        isTrue,
      );
    });

    test('monthlyAmount tolère string décimale et fallbacks', () {
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'amount': '84000.0'})
            .toEntity()
            .monthlyAmount,
        84000,
      );
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'total': 90000})
            .toEntity()
            .monthlyAmount,
        90000,
      );
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1'}).toEntity().monthlyAmount,
        0,
      );
    });

    test('amendment dérivé de is_amendment / amendments_count / liste', () {
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'is_amendment': true})
            .toEntity()
            .amendment,
        isTrue,
      );
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'amendments_count': 2})
            .toEntity()
            .amendment,
        isTrue,
      );
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1', 'amendments_count': 0})
            .toEntity()
            .amendment,
        isFalse,
      );
      expect(
        TutorContractDto.fromJson(const {
          'id': 'ct1',
          'amendments': [
            {'x': 1},
          ],
        }).toEntity().amendment,
        isTrue,
      );
      expect(
        TutorContractDto.fromJson(const {'id': 'ct1'}).toEntity().amendment,
        isFalse,
      );
    });
  });

  group('TutorJobDto · branches non couvertes', () {
    test('title fallback name puis description', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'name': 'Cours maths'})
            .toEntity()
            .title,
        'Cours maths',
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'description': 'Desc'})
            .toEntity()
            .title,
        'Desc',
      );
    });

    test('price fallbacks (price_per_hour / proposed_price / amount)', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'price_per_hour': 5000})
            .toEntity()
            .pricePerHour,
        5000,
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'proposed_price': '6000.0'})
            .toEntity()
            .pricePerHour,
        6000,
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1'}).toEntity().pricePerHour,
        0,
      );
    });

    test('frequency numérique → "N×/sem"', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'frequency': 3})
            .toEntity()
            .frequency,
        '3×/sem',
      );
    });

    test('frequency chaîne conservée, absente → vide', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'frequency': 'hebdo'})
            .toEntity()
            .frequency,
        'hebdo',
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1'}).toEntity().frequency,
        '',
      );
    });

    test('start formaté via shortDate, sinon vide', () {
      final e = TutorJobDto.fromJson(const {
        'id': 'j1',
        'estimated_start_date': '2026-05-02T00:00:00',
      }).toEntity();
      expect(e.start, isNotEmpty);
      expect(
        TutorJobDto.fromJson(const {'id': 'j1'}).toEntity().start,
        '',
      );
    });

    test('location : neighborhood + city', () {
      expect(
        TutorJobDto.fromJson(const {
          'id': 'j1',
          'city': 'Douala',
          'neighborhood': 'Bonapriso',
        }).toEntity().location,
        'Bonapriso, Douala',
      );
    });

    test('location : city seule, puis address.city, puis vide', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'location': 'Yaoundé'})
            .toEntity()
            .location,
        'Yaoundé',
      );
      expect(
        TutorJobDto.fromJson(const {
          'id': 'j1',
          'address': {'city': 'Garoua'},
        }).toEntity().location,
        'Garoua',
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1'}).toEntity().location,
        '',
      );
    });

    test('applied fallbacks (already_applied / has_applied)', () {
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'already_applied': true})
            .toEntity()
            .applied,
        isTrue,
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1', 'has_applied': true})
            .toEntity()
            .applied,
        isTrue,
      );
      expect(
        TutorJobDto.fromJson(const {'id': 'j1'}).toEntity().applied,
        isFalse,
      );
    });

    test('summary vide → retombe sur le titre', () {
      final e = TutorJobDto.fromJson(const {
        'id': 'j1',
        'title': 'Cours maths',
      }).toEntity();
      expect(e.summary, 'Cours maths');
    });

    test('summary explicite conservé (et fallback description)', () {
      expect(
        TutorJobDto.fromJson(const {
          'id': 'j1',
          'title': 'T',
          'summary': 'Un résumé',
        }).toEntity().summary,
        'Un résumé',
      );
      expect(
        TutorJobDto.fromJson(const {
          'id': 'j1',
          'title': 'T',
          'details': 'Détails',
        }).toEntity().summary,
        'Détails',
      );
    });

    test('classes normalisées via TutorApi.names', () {
      final e = TutorJobDto.fromJson(const {
        'id': 'j1',
        'school_classes': [
          {'name': '4ème'},
          {'label': '3ème'},
          'CM2',
        ],
      }).toEntity();
      expect(e.classes, ['4ème', '3ème', 'CM2']);
    });
  });
}
