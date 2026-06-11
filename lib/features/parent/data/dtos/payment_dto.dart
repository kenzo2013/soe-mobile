import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment.dart';

part 'payment_dto.freezed.dart';
part 'payment_dto.g.dart';

@freezed
abstract class PaymentDto with _$PaymentDto {
  const factory PaymentDto({
    required String id,
    String? reference,
    @Default(0) int amount,
    String? method,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'reservation_ref') String? reservationRef,
    String? phone,
  }) = _PaymentDto;
  factory PaymentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentDtoFromJson(json);
}

@freezed
abstract class PaymentReceiptDto with _$PaymentReceiptDto {
  const factory PaymentReceiptDto({
    required PaymentDto payment,
    @JsonKey(name: 'pdf_url') String? pdfUrl,
    @JsonKey(name: 'tutor_name') String? tutorName,
    @JsonKey(name: 'child_name') String? childName,
  }) = _PaymentReceiptDto;
  factory PaymentReceiptDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentReceiptDtoFromJson(json);
}

extension PaymentDtoX on PaymentDto {
  Payment toEntity() => Payment(
        id: id,
        reference: reference ?? '#$id',
        amount: amount,
        method: _parseMethod(method),
        status: _parseStatus(status),
        createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
        reservationRef: reservationRef,
        phone: phone,
      );
}

extension PaymentReceiptDtoX on PaymentReceiptDto {
  PaymentReceipt toEntity() => PaymentReceipt(
        payment: payment.toEntity(),
        pdfUrl: pdfUrl,
        tutorName: tutorName,
        childName: childName,
      );
}

/// Payload `POST /parents/payments/create_online` (CDC §4.6).
/// Pas de wrapper `payment:` ici (à la différence des autres ressources).
Map<String, dynamic> initiatePaymentToJson(InitiatePaymentParams p) {
  final period =
      '${p.paymentPeriod.year.toString().padLeft(4, '0')}-${p.paymentPeriod.month.toString().padLeft(2, '0')}-${p.paymentPeriod.day.toString().padLeft(2, '0')}';
  return {
    'reservation_id': p.reservationId,
    'channel': switch (p.method) {
      PaymentMethod.mtnMomo => 'cm.mtn',
      PaymentMethod.orangeMoney => 'cm.orange',
      PaymentMethod.unknown => 'cm.mtn',
    },
    'phone_number': p.phone,
    'amount': p.amount,
    'payment_period': period,
  };
}

/// CDC §11.5 : payment_method = orange_money | mtn_money | bank_transfer | cash
// L'API renvoie des libellés variés ("MTN Money", "mtn_momo", "cm.mtn"…).
PaymentMethod _parseMethod(String? raw) {
  final v = (raw ?? '').toLowerCase();
  if (v.contains('mtn')) return PaymentMethod.mtnMomo;
  if (v.contains('orange')) return PaymentMethod.orangeMoney;
  return PaymentMethod.unknown;
}

/// CDC §11.5 : payment.status = pending | processing | completed | failed
PaymentStatus _parseStatus(String? raw) => switch (raw) {
      'pending' => PaymentStatus.pending,
      'processing' => PaymentStatus.processing,
      'completed' => PaymentStatus.completed,
      'failed' => PaymentStatus.failed,
      _ => PaymentStatus.unknown,
    };
