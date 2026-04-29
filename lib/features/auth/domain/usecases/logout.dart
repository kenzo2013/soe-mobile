import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class Logout {
  const Logout(this._repo);
  final AuthRepository _repo;

  Future<Result<void, Failure>> call() => _repo.logout();
}
