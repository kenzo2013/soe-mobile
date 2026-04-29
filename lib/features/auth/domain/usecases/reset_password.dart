import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Réinitialise le mot de passe à partir du token reçu par email.
///
/// PATCH /api/v1/users/password
class ResetPassword {
  const ResetPassword(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession, Failure>> call({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    final errors = <String, List<String>>{};
    if (token.trim().isEmpty) {
      errors['reset_password_token'] = const ['Token manquant.'];
    }
    if (password.length < 6) {
      errors['password'] = const ['Au moins 6 caractères.'];
    }
    if (password != passwordConfirmation) {
      errors['password_confirmation'] = const [
        'Les mots de passe ne correspondent pas.',
      ];
    }
    if (errors.isNotEmpty) {
      return Future.value(Err(ValidationFailure(errors)));
    }
    return _repo.resetPassword(
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
