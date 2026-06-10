import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

extension UserDtoX on UserDto {
  User toEntity() => User(
        id: id,
        email: attributes.email,
        firstName: attributes.firstName,
        lastName: attributes.lastName,
        role: UserRoleX.fromApi(attributes.role),
        civility: attributes.civility,
        phone: attributes.phone,
        lang: attributes.lang,
        photoUrl: attributes.avatarUrl,
        multiRole: attributes.multiRole ?? false,
      );
}
