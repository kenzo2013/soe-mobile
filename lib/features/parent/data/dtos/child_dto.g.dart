// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildDtoImpl _$$ChildDtoImplFromJson(Map<String, dynamic> json) =>
    _$ChildDtoImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String?,
      schoolClass: json['school_class'] as Map<String, dynamic>?,
      section: json['section'] as String?,
      education: json['education'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChildDtoImplToJson(_$ChildDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'age': instance.age,
      'gender': instance.gender,
      'school_class': instance.schoolClass,
      'section': instance.section,
      'education': instance.education,
      'subjects': instance.subjects,
      'avatar_url': instance.avatarUrl,
      'address': instance.address,
    };
