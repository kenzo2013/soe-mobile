enum PaymentStatus { pending, processing, completed, failed, cancelled, unknown }

enum PaymentMethod { mtnMomo, orangeMoney, unknown }

class Payment {
  const Payment({
    required this.id,
    required this.reference,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.reservationRef,
    this.phone,
  });
  final String id;
  final String reference;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? reservationRef;
  final String? phone;
}

class PaymentReceipt {
  const PaymentReceipt({
    required this.payment,
    this.pdfUrl,
    this.tutorName,
    this.childName,
  });
  final Payment payment;
  final String? pdfUrl;
  final String? tutorName;
  final String? childName;
}

class InitiatePaymentParams {
  const InitiatePaymentParams({
    required this.reservationId,
    required this.method,
    required this.phone,
    required this.amount,
    required this.paymentPeriod,
  });
  final String reservationId;
  final PaymentMethod method;
  final String phone;
  final int amount;

  /// Période facturée au format ISO date (`yyyy-MM-dd`). Ex: 2026-05-01.
  /// CDC §4.6 — paramètre `payment_period`.
  final DateTime paymentPeriod;
}
