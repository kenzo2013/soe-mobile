import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Réinitialise le mot de passe à partir du code OTP reçu par email.
///
/// `PATCH /users/password/reset_with_code`
class ResetPassword {
  const ResetPassword(this._repo);
  final AuthRepository _repo;

  Future<Result<void, Failure>> call({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) {
    final errors = <String, List<String>>{};
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = const ['Email invalide.'];
    }
    if (code.trim().length != 6) {
      errors['code'] = const ['Code à 6 chiffres requis.'];
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
    return _repo.resetPasswordWithCode(
      email: email,
      code: code,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
