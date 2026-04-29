// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseDtoImpl _$$AuthResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthResponseDtoImpl(
      data: UserDto.fromJson(json['data'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$$AuthResponseDtoImplToJson(
        _$AuthResponseDtoImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'accessToken': instance.accessToken,
    };
