import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/contract.dart';
import '../entities/parent_invitation.dart';
import '../entities/parent_program.dart';
import '../entities/parent_review.dart';

abstract interface class ReviewsRepository {
  Future<Result<List<ParentReview>, Failure>> list();
  Future<Result<ParentReview, Failure>> create(ReviewParams params);
}

abstract interface class ProgramsRepository {
  Future<Result<List<ParentProgram>, Failure>> list();
}

abstract interface class InvitationsRepository {
  Future<Result<List<ParentInvitation>, Failure>> list();
  Future<Result<ParentInvitation, Failure>> invite(InviteParams params);
}

abstract interface class ContractsRepository {
  Future<Result<List<Contract>, Failure>> list();
  Future<Result<Contract, Failure>> sign(String id);
}
