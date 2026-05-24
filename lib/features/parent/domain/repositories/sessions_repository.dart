import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/session_detail.dart';
import '../entities/session_summary.dart';

abstract interface class SessionsRepository {
  Future<Result<List<SessionSummary>, Failure>> list();
  Future<Result<SessionDetail, Failure>> get(String id);
}
