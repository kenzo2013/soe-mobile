// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_remuneration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorRemunerationDtoImpl _$$TutorRemunerationDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorRemunerationDtoImpl(
      id: json['id'] as String? ?? '',
      period: _period(json, 'period') as String? ?? '',
      amount: (_amount(json, 'amount') as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      sessions: (_sessions(json, 'sessions') as num?)?.toInt() ?? 0,
      paidAt: json['paid_at'] as String?,
      method: json['payment_method'] as String?,
    );

Map<String, dynamic> _$$TutorRemunerationDtoImplToJson(
        _$TutorRemunerationDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period': instance.period,
      'amount': instance.amount,
      'status': instance.status,
      'sessions': instance.sessions,
      'paid_at': instance.paidAt,
      'payment_method': instance.method,
    };
