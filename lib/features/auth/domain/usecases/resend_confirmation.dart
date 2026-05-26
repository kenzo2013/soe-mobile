import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Renvoie un code de confirmation par email.
///
/// `POST /users/confirmation` (client_type=mobile)
class ResendConfirmation {
  const ResendConfirmation(this._repo);
  final AuthRepository _repo;

  Future<Result<void, Failure>> call({required String email}) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return Future.value(
        const Err(ValidationFailure(<String, List<String>>{
          'email': ['Email invalide.'],
        })),
      );
    }
    return _repo.resendConfirmationCode(email: email);
  }
}
