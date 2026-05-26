import 'dart:typed_data';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/payment.dart';

abstract interface class PaymentsRepository {
  Future<Result<List<Payment>, Failure>> list();
  Future<Result<Payment, Failure>> get(String id);
  Future<Result<Payment, Failure>> initiate(InitiatePaymentParams params);

  /// Polling 5s après initiation (CDC §4.6).
  Future<Result<Payment, Failure>> checkStatus(String id);

  /// Reçu = juste le payment enrichi (pas d'endpoint dédié dans le CDC).
  Future<Result<PaymentReceipt, Failure>> receipt(String id);

  /// Télécharge le PDF du reçu (bytes).
  Future<Result<Uint8List, Failure>> downloadReceipt(String id);
}
