import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession, Failure>> call({
    required RegisterParams params,
  }) {
    final errors = _validate(params);
    if (errors.isNotEmpty) {
      return Future.value(Err(ValidationFailure(errors)));
    }
    return _repo.register(params: params);
  }

  Map<String, List<String>> _validate(RegisterParams p) {
    final e = <String, List<String>>{};
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(p.email)) {
      e['email'] = const ['Email invalide.'];
    }
    if (p.password.length < 8) {
      e['password'] = const ['Au moins 8 caractères.'];
    }
    if (p.password != p.passwordConfirmation) {
      e['password_confirmation'] = const [
        'Les mots de passe ne correspondent pas.',
      ];
    }
    if (p.firstName.trim().isEmpty) {
      e['first_name'] = const ['Le prénom est requis.'];
    }
    if (p.lastName.trim().isEmpty) {
      e['last_name'] = const ['Le nom est requis.'];
    }
    if (!p.acceptCgu) {
      e['accept_cgu'] = const ['Vous devez accepter les CGU.'];
    }
    return e;
  }
}
