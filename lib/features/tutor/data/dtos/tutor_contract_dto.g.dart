// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_contract_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorContractDtoImpl _$$TutorContractDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorContractDtoImpl(
      id: json['id'] as String? ?? '',
      reference: _reference(json, 'reference') as String? ?? '',
      parent: _parent(json, 'parent') as String? ?? '',
      student: _student(json, 'student') as String? ?? '',
      signed: _signed(json, 'signed') as bool? ?? false,
      signedAt: json['signed_at'] as String?,
      createdAt: json['created_at'] as String?,
      monthlyAmount: (_amount(json, 'monthlyAmount') as num?)?.toInt() ?? 0,
      amendment: _amendment(json, 'amendment') as bool? ?? false,
    );

Map<String, dynamic> _$$TutorContractDtoImplToJson(
        _$TutorContractDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'parent': instance.parent,
      'student': instance.student,
      'signed': instance.signed,
      'signed_at': instance.signedAt,
      'created_at': instance.createdAt,
      'monthlyAmount': instance.monthlyAmount,
      'amendment': instance.amendment,
    };
