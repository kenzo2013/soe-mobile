import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/payments_usecases.dart';
import 'payments_states.dart';

class PaymentsListViewModel extends StateNotifier<PaymentsListState> {
  PaymentsListViewModel(this._list) : super(const PaymentsListState.initial());
  final ListPayments _list;
  Future<void> load() async {
    state = const PaymentsListState.loading();
    final r = await _list();
    state = switch (r) {
      Ok(:final value) => PaymentsListState.loaded(value),
      Err(:final failure) => PaymentsListState.error(failure),
    };
  }

  Future<void> refresh() => load();
}

class CheckoutViewModel extends StateNotifier<CheckoutState> {
  CheckoutViewModel(this._initiate) : super(const CheckoutState.idle());
  final InitiatePayment _initiate;

  Future<void> submit(InitiatePaymentParams params) async {
    state = CheckoutState.processing(Payment(
      id: '',
      reference: '#…',
      amount: params.amount,
      method: params.method,
      status: PaymentStatus.processing,
      createdAt: DateTime.now(),
      phone: params.phone,
    ));
    final r = await _initiate(params);
    state = switch (r) {
      Ok(:final value) => CheckoutState.completed(value),
      Err(:final failure) => CheckoutState.error(failure),
    };
  }

  void reset() => state = const CheckoutState.idle();
}

class PaymentReceiptViewModel extends StateNotifier<PaymentReceiptState> {
  PaymentReceiptViewModel(this._get) : super(const PaymentReceiptState.initial());
  final GetPaymentReceipt _get;
  Future<void> load(String id) async {
    state = const PaymentReceiptState.loading();
    final r = await _get(id);
    state = switch (r) {
      Ok(:final value) => PaymentReceiptState.loaded(value),
      Err(:final failure) => PaymentReceiptState.error(failure),
    };
  }
}
