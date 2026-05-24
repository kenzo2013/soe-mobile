import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/session_detail.dart';
import '../entities/session_summary.dart';
import '../repositories/sessions_repository.dart';

class ListSessions {
  const ListSessions(this._r);
  final SessionsRepository _r;
  Future<Result<List<SessionSummary>, Failure>> call() => _r.list();
}

class GetSessionDetail {
  const GetSessionDetail(this._r);
  final SessionsRepository _r;
  Future<Result<SessionDetail, Failure>> call(String id) => _r.get(id);
}
