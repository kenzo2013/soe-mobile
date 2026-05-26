import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/parent_invitation.dart';
import '../../domain/entities/parent_program.dart';
import '../../domain/entities/parent_review.dart';
import '../../domain/repositories/misc_repositories.dart';
import '../datasources/misc_remote_datasource.dart';

Future<Result<T, Failure>> _guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on DioException catch (e) {
    return Err(ExceptionMapper.fromDio(e));
  }
}

class ReviewsRepositoryImpl implements ReviewsRepository {
  const ReviewsRepositoryImpl(this._ds);
  final MiscRemoteDatasource _ds;
  @override
  Future<Result<List<ParentReview>, Failure>> list() =>
      _guard(_ds.listReviews);
  @override
  Future<Result<ParentReview, Failure>> create(ReviewParams params) =>
      _guard(() => _ds.createReview(params));
}

class ProgramsRepositoryImpl implements ProgramsRepository {
  const ProgramsRepositoryImpl(this._ds);
  final MiscRemoteDatasource _ds;
  @override
  Future<Result<List<ParentProgram>, Failure>> list() =>
      _guard(_ds.listPrograms);
}

class InvitationsRepositoryImpl implements InvitationsRepository {
  const InvitationsRepositoryImpl(this._ds);
  final MiscRemoteDatasource _ds;
  @override
  Future<Result<List<ParentInvitation>, Failure>> list() =>
      _guard(_ds.listInvitations);
  @override
  Future<Result<ParentInvitation, Failure>> invite(InviteParams params) =>
      _guard(() => _ds.invite(params));
}

class ContractsRepositoryImpl implements ContractsRepository {
  const ContractsRepositoryImpl(this._ds);
  final MiscRemoteDatasource _ds;
  @override
  Future<Result<List<Contract>, Failure>> list() => _guard(_ds.listContracts);
  @override
  Future<Result<Contract, Failure>> sign(String id, List<int> signatureBytes) =>
      _guard(() => _ds.signContract(id, signatureBytes));
}
