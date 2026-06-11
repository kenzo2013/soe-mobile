import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

void main() {
  User base({
    String id = '1',
    String email = 'a@b.c',
    String firstName = 'Paul',
    String lastName = 'Mbarga',
    UserRole role = UserRole.parent,
  }) =>
      User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );

  group('User · getters', () {
    test('fullName concatène prénom + nom', () {
      expect(base().fullName, 'Paul Mbarga');
    });

    test('multiRole défaut false, champs optionnels nullables', () {
      final u = base();
      expect(u.multiRole, isFalse);
      expect(u.civility, isNull);
      expect(u.phone, isNull);
      expect(u.lang, isNull);
      expect(u.photoUrl, isNull);
    });

    test('champs optionnels conservés quand fournis', () {
      const u = User(
        id: '1',
        email: 'a@b.c',
        firstName: 'Paul',
        lastName: 'Mbarga',
        role: UserRole.tutor,
        civility: 'M.',
        phone: '+237600000000',
        lang: 'fr',
        photoUrl: 'https://x/y.png',
        multiRole: true,
      );
      expect(u.civility, 'M.');
      expect(u.phone, '+237600000000');
      expect(u.lang, 'fr');
      expect(u.photoUrl, 'https://x/y.png');
      expect(u.multiRole, isTrue);
    });
  });

  group('User · égalité & hashCode', () {
    test('égaux sur id/email/prénom/nom/rôle', () {
      expect(base(), equals(base()));
      expect(base().hashCode, base().hashCode);
    });

    test('identical → true', () {
      final u = base();
      expect(u == u, isTrue);
    });

    test('différents si id diffère', () {
      expect(base(id: '1'), isNot(equals(base(id: '2'))));
    });

    test('différents si role diffère', () {
      expect(
        base(role: UserRole.parent),
        isNot(equals(base(role: UserRole.tutor))),
      );
    });

    test('différents si email diffère', () {
      expect(base(email: 'a@b.c'), isNot(equals(base(email: 'x@y.z'))));
    });

    test('égalité ignore les champs optionnels (phone/photoUrl)', () {
      const a = User(
        id: '1',
        email: 'a@b.c',
        firstName: 'Paul',
        lastName: 'Mbarga',
        role: UserRole.parent,
        phone: '111',
      );
      const b = User(
        id: '1',
        email: 'a@b.c',
        firstName: 'Paul',
        lastName: 'Mbarga',
        role: UserRole.parent,
        phone: '222',
      );
      expect(a, equals(b));
    });

    test('not equals avec un autre type', () {
      // ignore: unrelated_type_equality_checks
      expect(base() == 'user', isFalse);
    });
  });

  group('UserRoleX.apiValue', () {
    test('mappe chaque rôle vers sa valeur API', () {
      expect(UserRole.parent.apiValue, 'parent');
      expect(UserRole.tutor.apiValue, 'tutor');
      expect(UserRole.simpleAdmin.apiValue, 'simple_admin');
      expect(UserRole.superAdmin.apiValue, 'super_admin');
    });
  });

  group('UserRoleX.fromApi', () {
    test('mappe les valeurs connues', () {
      expect(UserRoleX.fromApi('parent'), UserRole.parent);
      expect(UserRoleX.fromApi('tutor'), UserRole.tutor);
      expect(UserRoleX.fromApi('simple_admin'), UserRole.simpleAdmin);
      expect(UserRoleX.fromApi('super_admin'), UserRole.superAdmin);
    });

    test('valeur inconnue → parent (fallback)', () {
      expect(UserRoleX.fromApi(''), UserRole.parent);
      expect(UserRoleX.fromApi('???'), UserRole.parent);
    });

    test('round-trip apiValue → fromApi', () {
      for (final r in UserRole.values) {
        expect(UserRoleX.fromApi(r.apiValue), r);
      }
    });
  });
}
