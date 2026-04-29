import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// State partagé entre les écrans d'auth.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthSession session) = _Authenticated;

  /// Compte créé, utilisateur invité à confirmer son email.
  const factory AuthState.registered(User user) = _Registered;

  const factory AuthState.passwordResetSent(String email) = _PasswordResetSent;
  const factory AuthState.passwordResetSucceeded() = _PasswordResetSucceeded;
  const factory AuthState.error(Failure failure) = _Error;
}
