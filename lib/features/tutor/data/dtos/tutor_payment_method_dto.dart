import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_payment_method.dart';

part 'tutor_payment_method_dto.freezed.dart';
part 'tutor_payment_method_dto.g.dart';

/// Méthode de paiement (`GET /tutors/payment_informations`).
/// Forme tolérante : champs type-spécifiques imbriqués sous `details` (format
/// JSON:API réel, juin 2026) ou sous `mobile_payment` / `bank_information`.
@freezed
abstract class TutorPaymentMethodDto with _$TutorPaymentMethodDto {
  const factory TutorPaymentMethodDto({
    @Default('') String id,
    @Default('') String type,
    @JsonKey(readValue: _isDefault) @Default(false) bool isDefault,
    @JsonKey(readValue: _operator) String? operator,
    @JsonKey(readValue: _phone) String? phone,
    @JsonKey(readValue: _bank) String? bank,
    @JsonKey(readValue: _holder) String? holder,
    @JsonKey(readValue: _iban) String? iban,
    @JsonKey(readValue: _accountNumber) String? accountNumber,
    @JsonKey(readValue: _bankCode) String? bankCode,
    @JsonKey(readValue: _branchCode) String? branchCode,
    @JsonKey(readValue: _bic) String? bic,
    @JsonKey(readValue: _key) String? key,
  }) = _TutorPaymentMethodDto;
  factory TutorPaymentMethodDto.fromJson(Map<String, dynamic> json) =>
      _$TutorPaymentMethodDtoFromJson(json);
}

TutorPaymentKind _parseKind(String? raw) => switch (raw) {
      'mobile_payment' || 'mobile' => TutorPaymentKind.mobile,
      'bank' || 'bank_information' || 'bank_transfer' => TutorPaymentKind.bank,
      _ => TutorPaymentKind.unknown,
    };

extension TutorPaymentMethodDtoX on TutorPaymentMethodDto {
  TutorPaymentMethod toEntity() => TutorPaymentMethod(
        id: id,
        kind: _parseKind(type),
        isDefault: isDefault,
        operator: operator,
        phone: phone,
        bank: bank,
        holder: holder,
        iban: iban,
        accountNumber: accountNumber,
        bankCode: bankCode,
        branchCode: branchCode,
        bic: bic,
        key: key,
      );
}

// Source des champs type-spécifiques : `details` (réel) puis les anciens
// wrappers, puis la racine.
Map<dynamic, dynamic>? _details(Map<dynamic, dynamic> j) =>
    j['details'] is Map ? j['details'] as Map : null;
Map<dynamic, dynamic>? _mobile(Map<dynamic, dynamic> j) =>
    j['mobile_payment'] is Map ? j['mobile_payment'] as Map : null;
Map<dynamic, dynamic>? _bankInfo(Map<dynamic, dynamic> j) =>
    j['bank_information'] is Map ? j['bank_information'] as Map : null;

Object? _isDefault(Map<dynamic, dynamic> j, String _) =>
    j['default'] ?? j['is_default'];
Object? _operator(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['mobile_operator'] ??
    _mobile(j)?['mobile_operator'] ??
    j['mobile_operator'] ??
    j['operator'];
Object? _phone(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['phone'] ?? _mobile(j)?['phone'] ?? j['phone'];
Object? _bank(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['bank_name'] ??
    _bankInfo(j)?['bank_name'] ??
    j['bank_name'] ??
    j['bank'];
Object? _holder(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['account_holder'] ??
    _bankInfo(j)?['account_holder'] ??
    j['account_holder'];
Object? _iban(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['iban'] ?? _bankInfo(j)?['iban'] ?? j['iban'];
Object? _accountNumber(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['account_number'] ??
    _bankInfo(j)?['account_number'] ??
    j['account_number'];
Object? _bankCode(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['bank_code'] ?? _bankInfo(j)?['bank_code'] ?? j['bank_code'];
Object? _branchCode(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['branch_code'] ??
    _details(j)?['agency_code'] ??
    j['branch_code'] ??
    j['agency_code'];
Object? _bic(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['bic'] ?? _bankInfo(j)?['bic'] ?? j['bic'];
Object? _key(Map<dynamic, dynamic> j, String _) =>
    _details(j)?['key'] ?? _details(j)?['rib_key'] ?? j['key'];
