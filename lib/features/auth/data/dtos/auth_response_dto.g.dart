// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseDtoImpl _$$LoginResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginResponseDtoImpl(
      data: UserDto.fromJson(json['data'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$$LoginResponseDtoImplToJson(
        _$LoginResponseDtoImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'accessToken': instance.accessToken,
    };

_$RegisterResponseDtoImpl _$$RegisterResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterResponseDtoImpl(
      data: UserDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RegisterResponseDtoImplToJson(
        _$RegisterResponseDtoImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
