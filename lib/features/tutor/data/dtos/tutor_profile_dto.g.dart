// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorDescriptionDtoImpl _$$TutorDescriptionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorDescriptionDtoImpl(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$TutorDescriptionDtoImplToJson(
        _$TutorDescriptionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'category': instance.category,
    };

_$TutorTrainingDtoImpl _$$TutorTrainingDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorTrainingDtoImpl(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: _levelRead(json, 'level') as String? ?? '',
      domain: _domainRead(json, 'domain') as String? ?? '',
      specialty: _speciality(json, 'specialty') as String? ?? '',
      date: _trainingDate(json, 'date') as String? ?? '',
    );

Map<String, dynamic> _$$TutorTrainingDtoImplToJson(
        _$TutorTrainingDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'level': instance.level,
      'domain': instance.domain,
      'specialty': instance.specialty,
      'date': instance.date,
    };

_$TutorWorkDtoImpl _$$TutorWorkDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorWorkDtoImpl(
      id: json['id'] as String? ?? '',
      title: _workTitle(json, 'title') as String? ?? '',
      company: _workCompany(json, 'company') as String? ?? '',
      current: json['current_position'] as bool? ?? false,
      since: json['since'] as String? ?? '',
      until: json['until'] as String?,
    );

Map<String, dynamic> _$$TutorWorkDtoImplToJson(_$TutorWorkDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'company': instance.company,
      'current_position': instance.current,
      'since': instance.since,
      'until': instance.until,
    };

_$TutorIdentityDtoImpl _$$TutorIdentityDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorIdentityDtoImpl(
      id: json['id'] as String? ?? '',
      type: _docType(json, 'type') as String? ?? '',
      expirationDate: _expiresRead(json, 'expirationDate') as String?,
      birthday: _birthRead(json, 'birthday') as String?,
      imageUrls: json['image_urls'] as List<dynamic>? ?? const <dynamic>[],
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$TutorIdentityDtoImplToJson(
        _$TutorIdentityDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'expirationDate': instance.expirationDate,
      'birthday': instance.birthday,
      'image_urls': instance.imageUrls,
      'status': instance.status,
    };

_$TutorTeachingCourseDtoImpl _$$TutorTeachingCourseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorTeachingCourseDtoImpl(
      id: json['id'] as String? ?? '',
      classe: _className(json, 'classe') as String? ?? '',
      subjects: json['subjects'] as List<dynamic>? ?? const <dynamic>[],
    );

Map<String, dynamic> _$$TutorTeachingCourseDtoImplToJson(
        _$TutorTeachingCourseDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classe': instance.classe,
      'subjects': instance.subjects,
    };

_$TutorAvailabilitySlotDtoImpl _$$TutorAvailabilitySlotDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorAvailabilitySlotDtoImpl(
      id: json['id'] as String?,
      day: json['day'] as String? ?? '',
      timeAvailabilities:
          _timeSlots(json, 'timeAvailabilities') as List<dynamic>? ??
              const <dynamic>[],
    );

Map<String, dynamic> _$$TutorAvailabilitySlotDtoImplToJson(
        _$TutorAvailabilitySlotDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'timeAvailabilities': instance.timeAvailabilities,
    };
