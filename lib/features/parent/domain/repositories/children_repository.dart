import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/child.dart';

abstract interface class ChildrenRepository {
  Future<Result<List<Child>, Failure>> list();
  Future<Result<Child, Failure>> get(String id);
  Future<Result<Child, Failure>> create(ChildFormParams params);
  Future<Result<Child, Failure>> update(String id, ChildFormParams params);
  Future<Result<void, Failure>> delete(String id);
}
