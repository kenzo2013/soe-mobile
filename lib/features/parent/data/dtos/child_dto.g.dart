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
      classe: json['classe'] as String?,
      section: json['section'] as String?,
      educationLevel: json['education_level'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$$ChildDtoImplToJson(_$ChildDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'age': instance.age,
      'gender': instance.gender,
      'classe': instance.classe,
      'section': instance.section,
      'education_level': instance.educationLevel,
      'subjects': instance.subjects,
      'avatar_url': instance.avatarUrl,
      'address': instance.address,
    };
