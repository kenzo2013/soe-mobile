import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession, Failure>> call({
    required String email,
    required String password,
  }) {
    final errors = <String, List<String>>{};
    if (!_isValidEmail(email)) {
      errors['email'] = const ['Email invalide.'];
    }
    if (password.isEmpty) {
      errors['password'] = const ['Le mot de passe est requis.'];
    }
    if (errors.isNotEmpty) {
      return Future.value(Err(ValidationFailure(errors)));
    }
    return _repo.login(email: email, password: password);
  }

  static bool _isValidEmail(String s) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
}
