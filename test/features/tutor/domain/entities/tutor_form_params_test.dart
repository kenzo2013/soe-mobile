import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor/domain/entities/tutor_form_params.dart';

void main() {
  group('TutorTrainingParams', () {
    test('porte tous les champs', () {
      const p = TutorTrainingParams(
        category: 'diploma',
        level: 'master',
        domain: 'sciences',
        specialty: 'maths',
        date: '2020-06-01',
      );
      expect(p.category, 'diploma');
      expect(p.level, 'master');
      expect(p.domain, 'sciences');
      expect(p.specialty, 'maths');
      expect(p.date, '2020-06-01');
    });
  });

  group('TutorWorkParams', () {
    test('current=true sans dates optionnelles', () {
      const p = TutorWorkParams(
        title: 'Prof',
        company: 'SOE',
        current: true,
      );
      expect(p.current, isTrue);
      expect(p.since, isNull);
      expect(p.until, isNull);
    });

    test('expérience passée avec since/until', () {
      const p = TutorWorkParams(
        title: 'Prof',
        company: 'SOE',
        current: false,
        since: '2018',
        until: '2020',
      );
      expect(p.current, isFalse);
      expect(p.since, '2018');
      expect(p.until, '2020');
    });
  });

  group('TutorIdentityParams', () {
    test('porte la liste de fichiers', () {
      final files = [File('/tmp/a.jpg'), File('/tmp/b.png')];
      final p = TutorIdentityParams(
        documentType: 'id_card',
        birthday: '1990-01-01',
        expirationDate: '2030-01-01',
        images: files,
      );
      expect(p.documentType, 'id_card');
      expect(p.birthday, '1990-01-01');
      expect(p.expirationDate, '2030-01-01');
      expect(p.images, hasLength(2));
    });
  });

  group('TutorTeachingCourseParams', () {
    test('porte schoolClassId + subjectIds', () {
      const p = TutorTeachingCourseParams(
        schoolClassId: 'sc1',
        subjectIds: ['m1', 'm2'],
      );
      expect(p.schoolClassId, 'sc1');
      expect(p.subjectIds, ['m1', 'm2']);
    });
  });

  group('TutorAvailabilityParams', () {
    test('porte weekday + créneau', () {
      const p = TutorAvailabilityParams(
        weekday: 1,
        startTime: '08:00',
        endTime: '10:00',
      );
      expect(p.weekday, 1);
      expect(p.startTime, '08:00');
      expect(p.endTime, '10:00');
    });
  });

  group('TutorSessionEditParams', () {
    test('tous les champs optionnels → null par défaut', () {
      const p = TutorSessionEditParams();
      expect(p.startAt, isNull);
      expect(p.endAt, isNull);
      expect(p.note, isNull);
    });

    test('champs fournis', () {
      const p = TutorSessionEditParams(
        startAt: '2026-05-14T10:00:00',
        endAt: '2026-05-14T12:00:00',
        note: 'reporté',
      );
      expect(p.startAt, '2026-05-14T10:00:00');
      expect(p.endAt, '2026-05-14T12:00:00');
      expect(p.note, 'reporté');
    });
  });

  group('TutorSessionReportParams', () {
    test('porte le contenu + signature', () {
      final sig = File('/tmp/sign.png');
      final p = TutorSessionReportParams(
        date: '2026-05-14',
        startAt: '10:00',
        endAt: '12:00',
        proceedings: 'Cours sur les fractions',
        signature: sig,
      );
      expect(p.date, '2026-05-14');
      expect(p.startAt, '10:00');
      expect(p.endAt, '12:00');
      expect(p.proceedings, 'Cours sur les fractions');
      expect(p.signature.path, '/tmp/sign.png');
    });
  });

  group('TutorMobilePaymentParams', () {
    test('opérateur mtn', () {
      const p = TutorMobilePaymentParams(
        phone: '+237600000000',
        operator: TutorMobileOperator.mtn,
      );
      expect(p.phone, '+237600000000');
      expect(p.operator, TutorMobileOperator.mtn);
    });

    test('opérateur orange', () {
      const p = TutorMobilePaymentParams(
        phone: '690000000',
        operator: TutorMobileOperator.orange,
      );
      expect(p.operator, TutorMobileOperator.orange);
    });

    test('enum TutorMobileOperator a deux valeurs', () {
      expect(TutorMobileOperator.values, hasLength(2));
    });
  });

  group('TutorBankPaymentParams', () {
    test('champs requis + valeurs par défaut des optionnels', () {
      const p = TutorBankPaymentParams(
        accountHolder: 'Paul Mbarga',
        bankName: 'Afriland',
        iban: 'CM21...',
        bic: 'CCEICMCX',
      );
      expect(p.accountHolder, 'Paul Mbarga');
      expect(p.bankName, 'Afriland');
      expect(p.iban, 'CM21...');
      expect(p.bic, 'CCEICMCX');
      expect(p.accountNumber, '');
      expect(p.key, '');
      expect(p.bankCode, '');
      expect(p.agencyCode, '');
    });

    test('optionnels surchargés', () {
      const p = TutorBankPaymentParams(
        accountHolder: 'Paul',
        bankName: 'B',
        iban: 'I',
        bic: 'X',
        accountNumber: '12345',
        key: '76',
        bankCode: '10005',
        agencyCode: '00100',
      );
      expect(p.accountNumber, '12345');
      expect(p.key, '76');
      expect(p.bankCode, '10005');
      expect(p.agencyCode, '00100');
    });
  });
}
