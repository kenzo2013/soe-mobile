// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDtoImpl _$$UserDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoImpl(
      id: json['id'] as String,
      attributes: UserAttributesDto.fromJson(
          json['attributes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserDtoImplToJson(_$UserDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attributes': instance.attributes,
    };

_$UserAttributesDtoImpl _$$UserAttributesDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$UserAttributesDtoImpl(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      civility: json['civility'] as String?,
      phone: json['phone'] as String?,
      lang: json['lang'] as String?,
      status: json['status'] as String?,
      reference: json['reference'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      multiRole: json['multi_role'] as bool?,
    );

Map<String, dynamic> _$$UserAttributesDtoImplToJson(
        _$UserAttributesDtoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'civility': instance.civility,
      'phone': instance.phone,
      'lang': instance.lang,
      'status': instance.status,
      'reference': instance.reference,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'multi_role': instance.multiRole,
    };
