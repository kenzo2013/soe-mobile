import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/auth/data/dtos/auth_response_dto.dart';
import 'package:soe/features/auth/data/dtos/user_dto.dart';
import 'package:soe/features/auth/data/mappers/user_mapper.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

void main() {
  Map<String, dynamic> userJson({Map<String, dynamic> attributes = const {}}) =>
      {
        'id': '31',
        'type': 'user',
        'attributes': <String, dynamic>{
          'email': 'jean@soe.cm',
          'first_name': 'Jean',
          'last_name': 'Dupont',
          'role': 'tutor',
          ...attributes,
        },
      };

  group('LoginResponseDto', () {
    test('compose data + accessToken et mappe vers User', () {
      final dto = LoginResponseDto(
        data: UserDto.fromJson(userJson()),
        accessToken: 'jwt-abc',
      );

      expect(dto.accessToken, 'jwt-abc');
      final user = dto.data.toEntity();
      expect(user.id, '31');
      expect(user.email, 'jean@soe.cm');
      expect(user.firstName, 'Jean');
      expect(user.lastName, 'Dupont');
      expect(user.role, UserRole.tutor);
    });
  });

  group('UserDto.fromJson / toEntity', () {
    test('mappe tous les champs optionnels présents', () {
      final dto = UserDto.fromJson(userJson(attributes: {
        'civility': 'M',
        'phone': '+237600000000',
        'lang': 'fr',
        'avatar_url': 'https://cdn/soe/avatar.png',
        'multi_role': true,
      }));

      final user = dto.toEntity();
      expect(user.civility, 'M');
      expect(user.phone, '+237600000000');
      expect(user.lang, 'fr');
      expect(user.photoUrl, 'https://cdn/soe/avatar.png');
      expect(user.multiRole, isTrue);
    });

    test('multiRole par défaut false quand absent', () {
      final dto = UserDto.fromJson(userJson());
      final user = dto.toEntity();
      expect(user.multiRole, isFalse);
      expect(user.civility, isNull);
      expect(user.phone, isNull);
      expect(user.photoUrl, isNull);
    });

    test('role inconnu retombe sur parent', () {
      final dto = UserDto.fromJson(userJson(attributes: {'role': 'wizard'}));
      expect(dto.toEntity().role, UserRole.parent);
    });

    test('mappe les rôles admin', () {
      expect(
        UserDto.fromJson(userJson(attributes: {'role': 'simple_admin'}))
            .toEntity()
            .role,
        UserRole.simpleAdmin,
      );
      expect(
        UserDto.fromJson(userJson(attributes: {'role': 'super_admin'}))
            .toEntity()
            .role,
        UserRole.superAdmin,
      );
    });

    test('fullName est dérivé de first/last name', () {
      final user = UserDto.fromJson(userJson()).toEntity();
      expect(user.fullName, 'Jean Dupont');
    });
  });

  group('RegisterResponseDto / ConfirmationResponseDto', () {
    test('RegisterResponseDto lit data', () {
      final dto = RegisterResponseDto.fromJson({'data': userJson()});
      expect(dto.data.toEntity().email, 'jean@soe.cm');
    });

    test('ConfirmationResponseDto lit data', () {
      final dto = ConfirmationResponseDto.fromJson({'data': userJson()});
      expect(dto.data.toEntity().id, '31');
    });
  });
}
