// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentDtoImpl _$$PaymentDtoImplFromJson(Map<String, dynamic> json) =>
    _$PaymentDtoImpl(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      method: json['method'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      reservationRef: json['reservation_ref'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$PaymentDtoImplToJson(_$PaymentDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'amount': instance.amount,
      'method': instance.method,
      'status': instance.status,
      'created_at': instance.createdAt,
      'reservation_ref': instance.reservationRef,
      'phone': instance.phone,
    };

_$PaymentReceiptDtoImpl _$$PaymentReceiptDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentReceiptDtoImpl(
      payment: PaymentDto.fromJson(json['payment'] as Map<String, dynamic>),
      pdfUrl: json['pdf_url'] as String?,
      tutorName: json['tutor_name'] as String?,
      childName: json['child_name'] as String?,
    );

Map<String, dynamic> _$$PaymentReceiptDtoImplToJson(
        _$PaymentReceiptDtoImpl instance) =>
    <String, dynamic>{
      'payment': instance.payment,
      'pdf_url': instance.pdfUrl,
      'tutor_name': instance.tutorName,
      'child_name': instance.childName,
    };
