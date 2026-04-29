import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';

/// Contrat d'accès aux services d'auth — implémenté côté Data.
abstract class AuthRepository {
  /// Connecte l'utilisateur. L'API renvoie 401 + EmailNotConfirmedFailure
  /// tant que l'email n'a pas été activé via le lien de confirmation.
  Future<Result<AuthSession, Failure>> login({
    required String email,
    required String password,
  });

  /// Inscrit l'utilisateur. L'API SOE NE retourne PAS de jeton après register :
  /// le user doit confirmer son email puis appeler `login`. On expose donc
  /// uniquement le `User` créé.
  Future<Result<User, Failure>> register({
    required RegisterParams params,
  });

  /// Demande l'envoi d'un email de réinitialisation.
  Future<Result<void, Failure>> requestPasswordReset({required String email});

  /// Confirme la réinitialisation depuis le lien email.
  /// `token` provient du deep link `?reset_password_token=...`.
  Future<Result<AuthSession, Failure>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<Result<void, Failure>> logout();
}

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.acceptCgu,
    this.civility,
    this.phone,
    this.lang = 'fr',
    this.neighborhood,
    this.city,
    this.country,
    this.countryCode,
  });

  final String email;
  final String password;
  final String passwordConfirmation;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool acceptCgu;
  final String? civility;
  final String? phone;
  final String lang;
  final String? neighborhood;
  final String? city;
  final String? country;
  final String? countryCode;
}
