import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Confirme le compte avec un code OTP reçu par email.
///
/// `POST /users/confirmation/verify_code`
class VerifyConfirmationCode {
  const VerifyConfirmationCode(this._repo);
  final AuthRepository _repo;

  Future<Result<User, Failure>> call({
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
    return _repo.verifyConfirmationCode(email: email, code: code);
  }
}
