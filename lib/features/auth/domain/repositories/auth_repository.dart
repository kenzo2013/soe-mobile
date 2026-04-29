import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../entities/user.dart';

/// Contrat d'accès aux services d'auth — implémenté côté Data.
abstract class AuthRepository {
  Future<Result<AuthSession, Failure>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthSession, Failure>> register({
    required RegisterParams params,
  });

  Future<Result<void, Failure>> requestPasswordReset({required String email});

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
