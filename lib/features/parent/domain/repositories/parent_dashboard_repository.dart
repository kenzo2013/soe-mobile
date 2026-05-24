import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/parent_dashboard.dart';

abstract interface class ParentDashboardRepository {
  Future<Result<ParentDashboard, Failure>> fetch();
}
