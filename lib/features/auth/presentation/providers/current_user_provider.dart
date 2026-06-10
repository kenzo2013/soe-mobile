import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/user.dart';
import '../providers.dart' show authRepositoryProvider;

/// Expose le user connecté.
///
/// Stratégie :
/// 1. Lit `StorageKeys.currentUser` (persisté au login depuis ce commit)
/// 2. Si vide mais qu'un token est présent → fetch `/current_user` via le
///    repo, puis persiste pour les lectures suivantes. Couvre les sessions
///    démarrées avant l'ajout de la persistance du user.
/// 3. Sinon retourne `null`.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final storage = ref.watch(secureStorageProvider);

  // Recalcule à chaque changement de token (login / logout / switch de rôle) :
  // sinon le provider sert un `null` mis en cache au logout même après une
  // reconnexion réussie.
  ref.watch(authTokenProvider);

  // 1) cache local
  final raw = await storage.read(StorageKeys.currentUser);
  if (raw != null && raw.isNotEmpty) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return User(
        id: j['id']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        firstName: j['first_name']?.toString() ?? '',
        lastName: j['last_name']?.toString() ?? '',
        role: UserRoleX.fromApi(j['role']?.toString() ?? 'parent'),
        civility: j['civility']?.toString(),
        phone: j['phone']?.toString(),
        lang: j['lang']?.toString(),
        photoUrl: j['photo_url']?.toString(),
        multiRole: j['multi_role'] == true,
      );
    } catch (_) {
      // JSON corrompu → on tombe sur le fallback API
    }
  }

  // 2) fallback API si on a un token
  final token = await storage.read(StorageKeys.authToken);
  if (token == null || token.isEmpty) return null;

  final result = await ref.read(authRepositoryProvider).fetchCurrentUser();
  return result.valueOrNull;
});
