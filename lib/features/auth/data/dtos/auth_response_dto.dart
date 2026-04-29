import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_dto.dart';

part 'auth_response_dto.freezed.dart';
part 'auth_response_dto.g.dart';

/// Réponse `POST /users/login` — `{"data": <user>, "accessToken": "..."}`.
@freezed
class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required UserDto data,
    @JsonKey(name: 'accessToken') required String accessToken,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}

/// Réponse `POST /users/register` — `{"status": {...}, "data": <user>}`.
/// Aucun `accessToken` à ce stade : confirmation email requise avant login.
@freezed
class RegisterResponseDto with _$RegisterResponseDto {
  const factory RegisterResponseDto({
    required UserDto data,
  }) = _RegisterResponseDto;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);
}
