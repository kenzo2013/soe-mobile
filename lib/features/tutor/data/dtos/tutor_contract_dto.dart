import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_contract.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_contract_dto.freezed.dart';
part 'tutor_contract_dto.g.dart';

@freezed
abstract class TutorContractDto with _$TutorContractDto {
  const factory TutorContractDto({
    @Default('') String id,
    @JsonKey(readValue: _reference) @Default('') String reference,
    @JsonKey(readValue: _parent) @Default('') String parent,
    @JsonKey(readValue: _student) @Default('') String student,
    @JsonKey(readValue: _signed) @Default(false) bool signed,
    @JsonKey(name: 'signed_at') String? signedAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(readValue: _amount) @Default(0) int monthlyAmount,
    @JsonKey(readValue: _amendment) @Default(false) bool amendment,
  }) = _TutorContractDto;
  factory TutorContractDto.fromJson(Map<String, dynamic> json) =>
      _$TutorContractDtoFromJson(json);
}

extension TutorContractDtoX on TutorContractDto {
  TutorContract toEntity() => TutorContract(
        id: id,
        reference: reference,
        parent: parent,
        student: student,
        signed: signed,
        dateLine: signed
            ? 'Signé le ${TutorApi.shortDate(signedAt)}'
            : 'Reçu ${TutorApi.relative(createdAt)}',
        monthlyAmount: monthlyAmount,
        amendment: amendment,
      );
}

Object? _reference(Map<dynamic, dynamic> j, String _) =>
    j['reference'] ?? j['ref'] ?? (j['id']?.toString());

Object? _parent(Map<dynamic, dynamic> j, String _) {
  final p = j['parent'] ?? j['client'];
  if (p is Map) {
    final full = '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
    return full.isNotEmpty ? full : (p['full_name'] ?? p['name'] ?? '');
  }
  return j['parent_name'] ?? p ?? '';
}

Object? _student(Map<dynamic, dynamic> j, String _) {
  final s = j['student'] ?? j['child'];
  if (s is Map) {
    final full = '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();
    return full.isNotEmpty ? full : (s['full_name'] ?? s['name'] ?? '');
  }
  return j['student_name'] ?? s ?? '';
}

Object? _signed(Map<dynamic, dynamic> j, String _) {
  final s = j['signed'] ?? j['is_signed'];
  if (s is bool) return s;
  final status = (j['signature_status'] ?? j['status'])?.toString();
  return status == 'signed';
}

Object? _amount(Map<dynamic, dynamic> j, String _) {
  return TutorApi.amount(j['monthly_amount'] ?? j['amount'] ?? j['total']);
}

Object? _amendment(Map<dynamic, dynamic> j, String _) {
  final a = j['amendment'] ?? j['is_amendment'];
  if (a is bool) return a;
  final count = j['amendments_count'] ?? j['amendments'];
  if (count is int) return count > 0;
  if (count is List) return count.isNotEmpty;
  return false;
}
