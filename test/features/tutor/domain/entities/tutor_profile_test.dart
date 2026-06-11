import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor/domain/entities/tutor_profile.dart';

void main() {
  group('TutorProfile', () {
    TutorProfile profile({String? avatarUrl}) => TutorProfile(
          firstName: 'Paul',
          lastName: 'Mbarga',
          email: 'paul@soe.cm',
          phone: '+237600000000',
          city: 'Douala',
          category: 'certifié',
          rating: 4.5,
          reviews: 12,
          bio: 'Prof de maths',
          completion: 80,
          avatarUrl: avatarUrl,
        );

    test('fullName concatène prénom + nom', () {
      expect(profile().fullName, 'Paul Mbarga');
    });

    test('avatarUrl optionnel défaut null', () {
      expect(profile().avatarUrl, isNull);
    });

    test('avatarUrl conservé si fourni', () {
      expect(
          profile(avatarUrl: 'https://x/a.png').avatarUrl, 'https://x/a.png');
    });

    test('champs numériques conservés', () {
      final p = profile();
      expect(p.rating, 4.5);
      expect(p.reviews, 12);
      expect(p.completion, 80);
    });
  });

  group('TutorIdentity', () {
    test('photos = nombre d\'URLs', () {
      const id = TutorIdentity(
        id: 'i1',
        type: 'id_card',
        expires: '2030',
        dob: '1990',
        photoUrls: ['a', 'b', 'c'],
        status: TutorIdentityStatus.approved,
      );
      expect(id.photos, 3);
      expect(id.status, TutorIdentityStatus.approved);
    });

    test('photos = 0 si aucune URL', () {
      const id = TutorIdentity(
        id: 'i1',
        type: 'passport',
        expires: '2030',
        dob: '1990',
        photoUrls: [],
        status: TutorIdentityStatus.pending,
      );
      expect(id.photos, 0);
    });

    test('enum TutorIdentityStatus a 4 valeurs', () {
      expect(TutorIdentityStatus.values, hasLength(4));
    });
  });

  group('TutorDayAvailability', () {
    test('isAvailable true quand des créneaux existent', () {
      const day = TutorDayAvailability(
        dayKey: 'mon',
        label: 'Lun',
        slots: [TutorTimeSlot(from: '08:00', to: '10:00')],
        recordId: 'r1',
      );
      expect(day.isAvailable, isTrue);
      expect(day.recordId, 'r1');
      expect(day.slots.single.from, '08:00');
      expect(day.slots.single.to, '10:00');
    });

    test('isAvailable false quand aucun créneau, recordId null par défaut', () {
      const day = TutorDayAvailability(
        dayKey: 'sun',
        label: 'Dim',
        slots: [],
      );
      expect(day.isAvailable, isFalse);
      expect(day.recordId, isNull);
    });
  });

  group('TutorTeachingCourse / TutorTraining / TutorWork', () {
    test('TutorTeachingCourse porte ses champs', () {
      const c = TutorTeachingCourse(
        id: 'c1',
        classe: '4ème',
        subjects: ['Maths', 'Physique'],
      );
      expect(c.classe, '4ème');
      expect(c.subjects, ['Maths', 'Physique']);
    });

    test('TutorWork until optionnel', () {
      const w = TutorWork(
        id: 'w1',
        title: 'Prof',
        company: 'SOE',
        current: true,
        since: '2018',
      );
      expect(w.until, isNull);
      expect(w.current, isTrue);
    });

    test('TutorTraining porte ses champs', () {
      const t = TutorTraining(
        id: 't1',
        category: 'diploma',
        level: 'master',
        domain: 'sciences',
        specialty: 'maths',
        date: '2020',
      );
      expect(t.level, 'master');
      expect(t.specialty, 'maths');
    });
  });
}
