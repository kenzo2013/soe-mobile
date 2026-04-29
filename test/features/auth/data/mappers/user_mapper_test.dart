import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/auth/data/dtos/user_dto.dart';
import 'package:soe/features/auth/data/mappers/user_mapper.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

void main() {
  test('round-trip: UserDto -> User preserves fields', () {
    const dto = UserDto(
      id: '1',
      email: 'a@b.com',
      firstName: 'Jean',
      lastName: 'Dupont',
      role: 'parent',
      civility: 'Mr',
      phone: '+237699000000',
      lang: 'fr',
      photoUrl: 'https://x/p.jpg',
    );
    final e = dto.toEntity();
    expect(e.id, '1');
    expect(e.email, 'a@b.com');
    expect(e.firstName, 'Jean');
    expect(e.lastName, 'Dupont');
    expect(e.role, UserRole.parent);
    expect(e.civility, 'Mr');
    expect(e.phone, '+237699000000');
    expect(e.lang, 'fr');
    expect(e.photoUrl, 'https://x/p.jpg');
  });

  test('maps role tutor', () {
    const dto = UserDto(
      id: '1',
      email: 'a@b.com',
      firstName: 'A',
      lastName: 'B',
      role: 'tutor',
    );
    expect(dto.toEntity().role, UserRole.tutor);
  });

  test('falls back to parent on unknown role', () {
    const dto = UserDto(
      id: '1',
      email: 'a@b.com',
      firstName: 'A',
      lastName: 'B',
      role: 'unknown',
    );
    expect(dto.toEntity().role, UserRole.parent);
  });
}
