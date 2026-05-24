// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorTrainingDtoImpl _$$TutorTrainingDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorTrainingDtoImpl(
      degree: json['degree'] as String,
      field: json['field'] as String,
      year: json['year'] as String?,
      institution: json['institution'] as String?,
    );

Map<String, dynamic> _$$TutorTrainingDtoImplToJson(
        _$TutorTrainingDtoImpl instance) =>
    <String, dynamic>{
      'degree': instance.degree,
      'field': instance.field,
      'year': instance.year,
      'institution': instance.institution,
    };

_$TutorWorkDtoImpl _$$TutorWorkDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorWorkDtoImpl(
      position: json['position'] as String,
      organization: json['organization'] as String,
      period: json['period'] as String?,
    );

Map<String, dynamic> _$$TutorWorkDtoImplToJson(_$TutorWorkDtoImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'organization': instance.organization,
      'period': instance.period,
    };

_$TutorAvailabilityDtoImpl _$$TutorAvailabilityDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorAvailabilityDtoImpl(
      weekday: (json['weekday'] as num?)?.toInt() ?? 1,
      timeRange: json['time_range'] as String?,
    );

Map<String, dynamic> _$$TutorAvailabilityDtoImplToJson(
        _$TutorAvailabilityDtoImpl instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'time_range': instance.timeRange,
    };

_$TutorReviewDtoImpl _$$TutorReviewDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorReviewDtoImpl(
      authorName: json['author_name'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$TutorReviewDtoImplToJson(
        _$TutorReviewDtoImpl instance) =>
    <String, dynamic>{
      'author_name': instance.authorName,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
    };

_$TutorProfileDtoImpl _$$TutorProfileDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorProfileDtoImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      category: json['category'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      sessionCount: (json['session_count'] as num?)?.toInt() ?? 0,
      trainings: (json['trainings'] as List<dynamic>?)
              ?.map((e) => TutorTrainingDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorTrainingDto>[],
      works: (json['works'] as List<dynamic>?)
              ?.map((e) => TutorWorkDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorWorkDto>[],
      availabilities: (json['availabilities'] as List<dynamic>?)
              ?.map((e) =>
                  TutorAvailabilityDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorAvailabilityDto>[],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => TutorReviewDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TutorReviewDto>[],
    );

Map<String, dynamic> _$$TutorProfileDtoImplToJson(
        _$TutorProfileDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'category': instance.category,
      'subjects': instance.subjects,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'city': instance.city,
      'experience_years': instance.experienceYears,
      'session_count': instance.sessionCount,
      'trainings': instance.trainings,
      'works': instance.works,
      'availabilities': instance.availabilities,
      'reviews': instance.reviews,
    };
