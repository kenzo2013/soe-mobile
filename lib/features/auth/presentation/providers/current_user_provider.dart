import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/user.dart';

/// Lit le user persisté en SecureStorage (écrit par AuthRepositoryImpl
/// après login/register). Retourne `null` si pas de session.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final raw = await storage.read(StorageKeys.currentUser);
  if (raw == null || raw.isEmpty) return null;
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
    );
  } catch (_) {
    return null;
  }
});
