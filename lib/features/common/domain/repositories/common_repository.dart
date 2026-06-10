import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/account_address.dart';
import '../entities/app_notification.dart';
import '../entities/notification_preferences.dart';

/// Contrat des écrans communs (CDC §6) — Mon compte, rôle, préférences,
/// notifications. Implémenté côté Data.
abstract class CommonRepository {
  // ── Mon compte ────────────────────────────────────────────
  /// `PATCH /current_user` (multipart si [photo] fourni).
  Future<Result<User, Failure>> updateProfile(UpdateProfileParams params);

  /// `PATCH /current_user/update_password`.
  Future<Result<void, Failure>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  });

  /// `GET /common/address`.
  Future<Result<AccountAddress, Failure>> getAddress();

  /// `PATCH /common/address`.
  Future<Result<AccountAddress, Failure>> updateAddress(AccountAddress address);

  // ── Rôle ──────────────────────────────────────────────────
  /// `PATCH /role_switch` — bascule le rôle actif (multi-rôle).
  Future<Result<void, Failure>> switchRole(String role);

  /// `POST /role_addition` — demande l'ajout d'un nouveau rôle.
  Future<Result<void, Failure>> addRole(String role);

  // ── Préférences de notification ───────────────────────────
  Future<Result<NotificationPreferences, Failure>> getNotificationPreferences();

  /// Sauvegarde l'ensemble des préférences (sauvegarde automatique au toggle).
  Future<Result<NotificationPreferences, Failure>>
      updateNotificationPreferences(NotificationPreferences prefs);

  // ── Centre de notifications ───────────────────────────────
  Future<Result<List<AppNotification>, Failure>> getNotifications({
    bool unreadOnly = false,
  });
  Future<Result<void, Failure>> markNotificationRead(String id);
  Future<Result<void, Failure>> markAllNotificationsRead();
  Future<Result<void, Failure>> deleteNotification(String id);
}

/// Paramètres de mise à jour du profil. Tous optionnels : seuls les champs
/// non nuls sont envoyés.
class UpdateProfileParams {
  const UpdateProfileParams({
    this.civility,
    this.firstName,
    this.lastName,
    this.phone,
    this.lang,
    this.photo,
  });

  final String? civility;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? lang;
  final File? photo;
}
