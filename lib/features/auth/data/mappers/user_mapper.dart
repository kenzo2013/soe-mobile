import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

extension UserDtoX on UserDto {
  User toEntity() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: UserRoleX.fromApi(role),
        civility: civility,
        phone: phone,
        lang: lang,
        photoUrl: photoUrl,
      );
}
