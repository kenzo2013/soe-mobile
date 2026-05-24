import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/parent_dashboard.dart';
import '../repositories/parent_dashboard_repository.dart';

class GetParentDashboard {
  const GetParentDashboard(this._repo);
  final ParentDashboardRepository _repo;

  Future<Result<ParentDashboard, Failure>> call() => _repo.fetch();
}
