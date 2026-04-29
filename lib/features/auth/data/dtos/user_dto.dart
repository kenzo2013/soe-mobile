import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// DTO utilisateur — format JSON:API renvoyé par l'API SOE.
///
/// La réponse a la forme :
/// ```json
/// {
///   "id": "31",
///   "type": "user",
///   "attributes": { "email": ..., "first_name": ..., "address": {...} }
///  }
/// ```
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required UserAttributesDto attributes,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
class UserAttributesDto with _$UserAttributesDto {
  const factory UserAttributesDto({
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String role,
    String? civility,
    String? phone,
    String? lang,
    String? status,
    String? reference,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'multi_role') bool? multiRole,
  }) = _UserAttributesDto;

  factory UserAttributesDto.fromJson(Map<String, dynamic> json) =>
      _$UserAttributesDtoFromJson(json);
}
