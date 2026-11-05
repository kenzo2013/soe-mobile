import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/service_contract.dart';

/// The legacy contracts of the API v1 (list, signature), still read by the v1 parent and tutor
/// screens. The account and common screens use the API v2 (`AccountApi`).
abstract class CommonRepository {
  Future<Result<List<ServiceContract>, Failure>> getContracts();
  Future<Result<void, Failure>> signContract(String id, File signature);
  Future<Result<void, Failure>> signAmendment(
    String contractId,
    String amendmentId,
    File signature,
  );
}
