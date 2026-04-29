// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDtoImpl _$$UserDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      civility: json['civility'] as String?,
      phone: json['phone'] as String?,
      lang: json['lang'] as String?,
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$$UserDtoImplToJson(_$UserDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'civility': instance.civility,
      'phone': instance.phone,
      'lang': instance.lang,
      'photo_url': instance.photoUrl,
    };
