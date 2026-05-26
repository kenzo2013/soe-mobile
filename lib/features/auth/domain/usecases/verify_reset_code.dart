import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Vérifie qu'un code de reset password est valide (sans le consommer).
///
/// `POST /users/password/verify_code`
class VerifyResetCode {
  const VerifyResetCode(this._repo);
  final AuthRepository _repo;

  Future<Result<void, Failure>> call({
    required String email,
    required String code,
  }) {
    final errors = <String, List<String>>{};
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = const ['Email invalide.'];
    }
    if (code.trim().length != 6) {
      errors['code'] = const ['Code à 6 chiffres requis.'];
    }
    if (errors.isNotEmpty) {
      return Future.value(Err(ValidationFailure(errors)));
    }
    return _repo.verifyResetCode(email: email, code: code);
  }
}
