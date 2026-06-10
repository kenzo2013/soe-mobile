// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_course_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorActiveCourseDtoImpl _$$TutorActiveCourseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorActiveCourseDtoImpl(
      id: json['id'] as String? ?? '',
      reference: _reference(json, 'reference') as String? ?? '',
      studentId: json['student_id'] as String?,
      student: _student(json, 'student') as String? ?? '',
      classe: _classe(json, 'classe') as String? ?? '',
      subjects: json['subjects'] as List<dynamic>? ?? const <dynamic>[],
      schedule: _schedule(json, 'schedule') as String? ?? '',
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$TutorActiveCourseDtoImplToJson(
        _$TutorActiveCourseDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'student_id': instance.studentId,
      'student': instance.student,
      'classe': instance.classe,
      'subjects': instance.subjects,
      'schedule': instance.schedule,
      'created_at': instance.createdAt,
    };

_$TutorCourseSlotDtoImpl _$$TutorCourseSlotDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorCourseSlotDtoImpl(
      day: json['day'] as String? ?? '',
      timeRange: json['time_range'] as String?,
      subject: json['subject'] as String? ?? '',
    );

Map<String, dynamic> _$$TutorCourseSlotDtoImplToJson(
        _$TutorCourseSlotDtoImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'time_range': instance.timeRange,
      'subject': instance.subject,
    };

_$TutorCourseDetailDtoImpl _$$TutorCourseDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorCourseDetailDtoImpl(
      id: json['id'] as String? ?? '',
      student: _student(json, 'student') as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      classe: _classe(json, 'classe') as String? ?? '',
      subjects: json['subjects'] as List<dynamic>? ?? const <dynamic>[],
      slots: (json['slots'] as List<dynamic>?)
              ?.map(
                  (e) => TutorCourseSlotDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorCourseSlotDto>[],
    );

Map<String, dynamic> _$$TutorCourseDetailDtoImplToJson(
        _$TutorCourseDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'age': instance.age,
      'gender': instance.gender,
      'classe': instance.classe,
      'subjects': instance.subjects,
      'slots': instance.slots,
    };
