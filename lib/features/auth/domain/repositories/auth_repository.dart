import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';

/// Contrat d'accès aux services d'auth — implémenté côté Data.
abstract class AuthRepository {
  /// Connecte l'utilisateur. L'API renvoie 401 + EmailNotConfirmedFailure
  /// tant que l'email n'a pas été confirmé via OTP.
  Future<Result<AuthSession, Failure>> login({
    required String email,
    required String password,
  });

  /// Inscrit l'utilisateur en mode mobile (code OTP envoyé par email).
  /// Pas de session retournée : on attend la confirmation par code.
  Future<Result<User, Failure>> register({
    required RegisterParams params,
  });

  /// Renvoie un nouveau code de confirmation par email.
  Future<Result<void, Failure>> resendConfirmationCode({
    required String email,
  });

  /// Vérifie le code de confirmation et active le compte.
  Future<Result<User, Failure>> verifyConfirmationCode({
    required String email,
    required String code,
  });

  /// Demande un code de réinitialisation par email.
  Future<Result<void, Failure>> requestPasswordReset({required String email});

  /// Vérifie qu'un code de reset est valide (sans le consommer).
  Future<Result<void, Failure>> verifyResetCode({
    required String email,
    required String code,
  });

  /// Consomme le code et change le mot de passe.
  Future<Result<void, Failure>> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });

  Future<Result<void, Failure>> logout();

  /// Récupère le profil du user connecté via le JWT en storage.
  /// Persiste le résultat pour les lectures suivantes.
  Future<Result<User, Failure>> fetchCurrentUser();
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
    this.address,
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
  final String? address;
  final String? neighborhood;
  final String? city;
  final String? country;
  final String? countryCode;
}
