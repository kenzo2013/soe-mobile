// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorJobDtoImpl _$$TutorJobDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorJobDtoImpl(
      id: json['id'] as String? ?? '',
      title: _title(json, 'title') as String? ?? '',
      pricePerHour: (_price(json, 'pricePerHour') as num?)?.toInt() ?? 0,
      frequency: _frequency(json, 'frequency') as String? ?? '',
      start: _start(json, 'start') as String? ?? '',
      subjects: json['subjects'] as List<dynamic>? ?? const <dynamic>[],
      classes: json['school_classes'] as List<dynamic>? ?? const <dynamic>[],
      location: _location(json, 'location') as String? ?? '',
      createdAt: json['created_at'] as String?,
      applied: _applied(json, 'applied') as bool? ?? false,
      summary: _summary(json, 'summary') as String? ?? '',
    );

Map<String, dynamic> _$$TutorJobDtoImplToJson(_$TutorJobDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'pricePerHour': instance.pricePerHour,
      'frequency': instance.frequency,
      'start': instance.start,
      'subjects': instance.subjects,
      'school_classes': instance.classes,
      'location': instance.location,
      'created_at': instance.createdAt,
      'applied': instance.applied,
      'summary': instance.summary,
    };
