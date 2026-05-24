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

Map<String, dynamic> initiatePaymentToJson(InitiatePaymentParams p) => {
      'reservation_id': p.reservationId,
      'amount': p.amount,
      'method': switch (p.method) {
        PaymentMethod.mtnMomo => 'mtn_momo',
        PaymentMethod.orangeMoney => 'orange_money',
        PaymentMethod.unknown => 'unknown',
      },
      'phone': p.phone,
    };

PaymentMethod _parseMethod(String? raw) => switch (raw) {
      'mtn_momo' || 'MTN MoMo' || 'mtn' => PaymentMethod.mtnMomo,
      'orange_money' || 'Orange Money' || 'orange' => PaymentMethod.orangeMoney,
      _ => PaymentMethod.unknown,
    };

PaymentStatus _parseStatus(String? raw) => switch (raw) {
      'pending' => PaymentStatus.pending,
      'processing' => PaymentStatus.processing,
      'completed' => PaymentStatus.completed,
      'failed' => PaymentStatus.failed,
      'cancelled' => PaymentStatus.cancelled,
      _ => PaymentStatus.unknown,
    };
