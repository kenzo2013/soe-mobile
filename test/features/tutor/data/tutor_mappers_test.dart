import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soe/features/tutor/data/datasources/tutor_remote_base.dart';
import 'package:soe/features/tutor/data/dtos/tutor_contract_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_dashboard_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_job_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_payment_method_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_remuneration_dto.dart';
import 'package:soe/features/tutor/data/dtos/tutor_session_dto.dart';
import 'package:soe/features/tutor/domain/entities/tutor_dashboard.dart';
import 'package:soe/features/tutor/domain/entities/tutor_payment_method.dart';
import 'package:soe/features/tutor/domain/entities/tutor_remuneration.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('TutorApi.deepFlat (JSON:API)', () {
    test('remonte attributes et garde id à tous les niveaux', () {
      final flat = TutorApi.deepFlat({
        'id': '1',
        'type': 'session',
        'attributes': {
          'subject': 'Maths',
          'student': {
            'id': '9',
            'attributes': {'first_name': 'Junior'},
          },
        },
      }) as Map<String, dynamic>;
      expect(flat['id'], '1');
      expect(flat['subject'], 'Maths');
      expect((flat['student'] as Map)['first_name'], 'Junior');
    });

    test('dataList déballe et aplatit une liste enveloppée', () {
      final list = TutorApi.dataList({
        'data': [
          {
            'id': 'j1',
            'attributes': {'title': 'Offre'},
          },
        ],
      });
      expect(list, hasLength(1));
      expect(list.first['title'], 'Offre');
    });
  });

  group('Mapping DTO → Entity (tolérant)', () {
    test('TutorDashboardDto formate timeRange depuis start/end ISO', () {
      final dto = TutorDashboardDto.fromJson(const {
        'first_name': 'Paul',
        'stats': {'total_students': 12},
        'today_sessions': [
          {
            'id': 's1',
            'start_at': '2026-05-14T10:00:00',
            'end_at': '2026-05-14T12:00:00',
            'subject': 'Maths',
            'status': 'confirmed',
          },
        ],
      });
      final e = dto.toEntity();
      expect(e.firstName, 'Paul');
      expect(e.stats.totalStudents, 12);
      expect(e.todaySessions.single.timeRange, '10:00 – 12:00');
      expect(
        e.todaySessions.single.status,
        TutorSessionStatus.confirmed,
      );
    });

    test('parseSessionStatus mappe les enums API et les inconnus', () {
      expect(parseSessionStatus('completed'), TutorSessionStatus.completed);
      expect(parseSessionStatus('approved'), TutorSessionStatus.completed);
      expect(parseSessionStatus('???'), TutorSessionStatus.unknown);
    });

    test('TutorJobDto normalise subjects (liste de maps) en noms', () {
      final dto = TutorJobDto.fromJson(const {
        'id': 'j1',
        'price': 4500,
        'subjects': [
          {'name': 'Maths'},
          {'name': 'Physique'},
        ],
      });
      final e = dto.toEntity();
      expect(e.pricePerHour, 4500);
      expect(e.subjects, ['Maths', 'Physique']);
    });

    test('TutorPaymentMethodDto lit le sous-objet bank_information', () {
      final dto = TutorPaymentMethodDto.fromJson(const {
        'id': 'pm3',
        'type': 'bank',
        'is_default': false,
        'bank_information': {
          'account_holder': 'Paul Mbarga',
          'iban': 'CM21...',
        },
      });
      final e = dto.toEntity();
      expect(e.kind, TutorPaymentKind.bank);
      expect(e.holder, 'Paul Mbarga');
      expect(e.iban, 'CM21...');
    });

    test('TutorContractDto déduit signé/dateLine', () {
      final dto = TutorContractDto.fromJson(const {
        'id': 'ct1',
        'reference': 'CTR-1',
        'signed': true,
        'signed_at': '2026-05-06T00:00:00',
        'monthly_amount': 84000,
      });
      final e = dto.toEntity();
      expect(e.signed, isTrue);
      expect(e.dateLine, contains('Signé le'));
      expect(e.monthlyAmount, 84000);
    });
  });

  group('Agrégations client-side', () {
    test('groupSessionsByDay regroupe par jour', () {
      final sessions = [
        TutorSessionDto.fromJson(const {
          'id': 's1',
          'start_at': '2026-05-14T10:00:00',
          'subject': 'Maths',
        }),
        TutorSessionDto.fromJson(const {
          'id': 's2',
          'start_at': '2026-05-14T15:00:00',
          'subject': 'Français',
        }),
        TutorSessionDto.fromJson(const {
          'id': 's3',
          'start_at': '2026-05-15T10:00:00',
          'subject': 'Physique',
        }),
      ];
      final groups = groupSessionsByDay(sessions);
      expect(groups, hasLength(2));
      expect(groups.first.items, hasLength(2));
    });

    test('buildRemunerations calcule le total payé et le taux moyen', () {
      final dtos = [
        TutorRemunerationDto.fromJson(const {
          'id': 'r1',
          'amount': 100000,
          'status': 'paid',
          'sessions_count': 20,
        }),
        TutorRemunerationDto.fromJson(const {
          'id': 'r2',
          'amount': 50000,
          'status': 'pending',
          'sessions_count': 10,
        }),
      ];
      final agg = buildRemunerations(dtos);
      expect(agg.summary.totalEarned, 100000); // seuls les payés
      expect(agg.summary.totalSessions, 30);
      expect(agg.items, hasLength(2));
      expect(agg.items.first.status, RemunerationStatus.paid);
    });
  });
}
