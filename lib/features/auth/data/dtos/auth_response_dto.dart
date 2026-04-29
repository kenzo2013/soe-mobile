import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_dto.dart';

part 'auth_response_dto.freezed.dart';
part 'auth_response_dto.g.dart';

@freezed
class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required UserDto data,
    @JsonKey(name: 'accessToken') required String accessToken,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}
