import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class ListPayments {
  const ListPayments(this._r);
  final PaymentsRepository _r;
  Future<Result<List<Payment>, Failure>> call() => _r.list();
}

class GetPayment {
  const GetPayment(this._r);
  final PaymentsRepository _r;
  Future<Result<Payment, Failure>> call(String id) => _r.get(id);
}

class InitiatePayment {
  const InitiatePayment(this._r);
  final PaymentsRepository _r;
  Future<Result<Payment, Failure>> call(InitiatePaymentParams params) =>
      _r.initiate(params);
}

class GetPaymentReceipt {
  const GetPaymentReceipt(this._r);
  final PaymentsRepository _r;
  Future<Result<PaymentReceipt, Failure>> call(String id) => _r.receipt(id);
}
