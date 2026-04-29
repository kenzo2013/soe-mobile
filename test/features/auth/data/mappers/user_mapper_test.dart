import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/auth/data/dtos/user_dto.dart';
import 'package:soe/features/auth/data/mappers/user_mapper.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

void main() {
  test('parses real JSON:API user payload from /users/register', () {
    final json = <String, dynamic>{
      'id': '31',
      'type': 'user',
      'attributes': {
        'email': 'soe-test@example.com',
        'first_name': 'Test',
        'last_name': 'Soe',
        'phone': '+237699000000',
        'civility': 'Mr',
        'role': 'parent',
        'lang': 'fr',
        'status': 'active',
        'reference': 'soe-p75247',
        'full_name': 'Soe Test',
        'multi_role': false,
        'avatar_url': null,
      },
    };

    final dto = UserDto.fromJson(json);
    final e = dto.toEntity();
    expect(e.id, '31');
    expect(e.email, 'soe-test@example.com');
    expect(e.firstName, 'Test');
    expect(e.lastName, 'Soe');
    expect(e.role, UserRole.parent);
    expect(e.civility, 'Mr');
    expect(e.phone, '+237699000000');
    expect(e.lang, 'fr');
  });

  test('maps role tutor', () {
    const dto = UserDto(
      id: '7',
      attributes: UserAttributesDto(
        email: 'a@b.com',
        firstName: 'A',
        lastName: 'B',
        role: 'tutor',
      ),
    );
    expect(dto.toEntity().role, UserRole.tutor);
  });

  test('falls back to parent on unknown role', () {
    const dto = UserDto(
      id: '7',
      attributes: UserAttributesDto(
        email: 'a@b.com',
        firstName: 'A',
        lastName: 'B',
        role: 'unknown',
      ),
    );
    expect(dto.toEntity().role, UserRole.parent);
  });
}
