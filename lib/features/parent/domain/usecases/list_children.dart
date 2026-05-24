import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/child.dart';
import '../repositories/children_repository.dart';

class ListChildren {
  const ListChildren(this._repo);
  final ChildrenRepository _repo;
  Future<Result<List<Child>, Failure>> call() => _repo.list();
}
