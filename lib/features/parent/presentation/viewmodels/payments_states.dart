import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/payment.dart';

part 'payments_states.freezed.dart';

@freezed
sealed class PaymentsListState with _$PaymentsListState {
  const factory PaymentsListState.initial() = _PLInit;
  const factory PaymentsListState.loading() = _PLLoading;
  const factory PaymentsListState.loaded(List<Payment> items) = _PLLoaded;
  const factory PaymentsListState.error(Failure failure) = _PLError;
}

@freezed
sealed class CheckoutState with _$CheckoutState {
  const factory CheckoutState.idle() = _CIdle;
  const factory CheckoutState.processing(Payment payment) = _CProcessing;
  const factory CheckoutState.completed(Payment payment) = _CCompleted;
  const factory CheckoutState.error(Failure failure) = _CError;
}

@freezed
sealed class PaymentReceiptState with _$PaymentReceiptState {
  const factory PaymentReceiptState.initial() = _RInit;
  const factory PaymentReceiptState.loading() = _RLoading;
  const factory PaymentReceiptState.loaded(PaymentReceipt receipt) = _RLoaded;
  const factory PaymentReceiptState.error(Failure failure) = _RError;
}
