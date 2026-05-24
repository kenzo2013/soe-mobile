// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorMiniDtoImpl _$$TutorMiniDtoImplFromJson(Map<String, dynamic> json) =>
    _$TutorMiniDtoImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$$TutorMiniDtoImplToJson(_$TutorMiniDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'category': instance.category,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'avatar_url': instance.avatarUrl,
    };

_$ReservationDetailDtoImpl _$$ReservationDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ReservationDetailDtoImpl(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      status: json['status'] as String?,
      childId: json['child_id'] as String?,
      childName: json['child_name'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      frequency: (json['frequency'] as num?)?.toInt() ?? 1,
      estimatedStartDate: json['estimated_start_date'] as String?,
      preferredTutorGender: json['preferred_tutor_gender'] as String?,
      location: json['location'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      amountPerSession: (json['amount_per_session'] as num?)?.toInt(),
      sessionCount: (json['session_count'] as num?)?.toInt(),
      programText: json['program_text'] as String?,
      tutor: json['tutor'] == null
          ? null
          : TutorMiniDto.fromJson(json['tutor'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$ReservationDetailDtoImplToJson(
        _$ReservationDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'status': instance.status,
      'child_id': instance.childId,
      'child_name': instance.childName,
      'subjects': instance.subjects,
      'frequency': instance.frequency,
      'estimated_start_date': instance.estimatedStartDate,
      'preferred_tutor_gender': instance.preferredTutorGender,
      'location': instance.location,
      'amount': instance.amount,
      'amount_per_session': instance.amountPerSession,
      'session_count': instance.sessionCount,
      'program_text': instance.programText,
      'tutor': instance.tutor,
      'created_at': instance.createdAt,
    };
