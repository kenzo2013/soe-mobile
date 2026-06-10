// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_payment_method_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorPaymentMethodDtoImpl _$$TutorPaymentMethodDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorPaymentMethodDtoImpl(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isDefault: _isDefault(json, 'isDefault') as bool? ?? false,
      operator: _operator(json, 'operator') as String?,
      phone: _phone(json, 'phone') as String?,
      bank: _bank(json, 'bank') as String?,
      holder: _holder(json, 'holder') as String?,
      iban: _iban(json, 'iban') as String?,
      accountNumber: _accountNumber(json, 'accountNumber') as String?,
      bankCode: _bankCode(json, 'bankCode') as String?,
      branchCode: _branchCode(json, 'branchCode') as String?,
      bic: _bic(json, 'bic') as String?,
      key: _key(json, 'key') as String?,
    );

Map<String, dynamic> _$$TutorPaymentMethodDtoImplToJson(
        _$TutorPaymentMethodDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'isDefault': instance.isDefault,
      'operator': instance.operator,
      'phone': instance.phone,
      'bank': instance.bank,
      'holder': instance.holder,
      'iban': instance.iban,
      'accountNumber': instance.accountNumber,
      'bankCode': instance.bankCode,
      'branchCode': instance.branchCode,
      'bic': instance.bic,
      'key': instance.key,
    };
