import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/service_contract.dart';
import '../../domain/repositories/common_repository.dart';
import '../datasources/common_remote_datasource.dart';

class CommonRepositoryImpl implements CommonRepository {
  const CommonRepositoryImpl({required CommonRemoteDatasource remote})
      : _remote = remote;

  final CommonRemoteDatasource _remote;

  @override
  Future<Result<List<ServiceContract>, Failure>> getContracts() =>
      _guard(_remote.getContracts);

  @override
  Future<Result<void, Failure>> signContract(String id, File signature) =>
      _guard(() => _remote.signContract(id, signature));

  @override
  Future<Result<void, Failure>> signAmendment(
    String contractId,
    String amendmentId,
    File signature,
  ) =>
      _guard(() => _remote.signAmendment(contractId, amendmentId, signature));

  Future<Result<T, Failure>> _guard<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } on Object catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
