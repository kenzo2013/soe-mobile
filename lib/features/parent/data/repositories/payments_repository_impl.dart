import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';
import '../dtos/payment_dto.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._ds);
  final PaymentsRemoteDatasource _ds;

  Future<Result<T, Failure>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<List<Payment>, Failure>> list() =>
      _guard(() async => (await _ds.list()).map((e) => e.toEntity()).toList());

  @override
  Future<Result<Payment, Failure>> get(String id) =>
      _guard(() async => (await _ds.get(id)).toEntity());

  @override
  Future<Result<Payment, Failure>> initiate(InitiatePaymentParams params) =>
      _guard(() async =>
          (await _ds.initiate(initiatePaymentToJson(params))).toEntity());

  @override
  Future<Result<Payment, Failure>> checkStatus(String id) =>
      _guard(() async => (await _ds.checkStatus(id)).toEntity());

  @override
  Future<Result<PaymentReceipt, Failure>> receipt(String id) =>
      _guard(() async {
        final payment = (await _ds.get(id)).toEntity();
        return PaymentReceipt(payment: payment);
      });

  @override
  Future<Result<Uint8List, Failure>> downloadReceipt(String id) =>
      _guard(() async => Uint8List.fromList(await _ds.downloadReceipt(id)));
}
