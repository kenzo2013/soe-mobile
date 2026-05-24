import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/payment.dart';

abstract interface class PaymentsRepository {
  Future<Result<List<Payment>, Failure>> list();
  Future<Result<Payment, Failure>> get(String id);
  Future<Result<Payment, Failure>> initiate(InitiatePaymentParams params);
  Future<Result<PaymentReceipt, Failure>> receipt(String id);
}
