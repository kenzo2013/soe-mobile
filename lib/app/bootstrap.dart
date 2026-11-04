import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env/env.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/providers/core_providers.dart';
import '../core/storage/preferences_storage.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/storage_keys.dart';
import 'app.dart';

/// Point d'entrée commun à tous les flavors. Initialise les services
/// avant `runApp`, capture les erreurs uncaught.
Future<void> bootstrap() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        Env.ensureConfigured();
      } on StateError catch (error) {
        // Shown on screen (a release build prints nothing): fix the run command and restart.
        runApp(ConfigurationErrorApp(message: error.message));
        return;
      }

      final prefs = await PreferencesStorage.create();
      final secure = SecureStorage();
      final initialToken = await secure.read(StorageKeys.authToken);
      final initialRole = await secure.read(StorageKeys.currentRole);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      runApp(
        ProviderScope(
          overrides: [
            preferencesStorageProvider.overrideWithValue(prefs),
            secureStorageProvider.overrideWithValue(secure),
            authTokenProvider.overrideWith((ref) => initialToken),
            currentRoleProvider.overrideWith((ref) => initialRole),
          ],
          child: const SoeApp(),
        ),
      );
    },
    (error, stack) {
      // En prod, brancher Sentry/Crashlytics ici.
      debugPrint('Uncaught: $error\n$stack');
    },
  );
}

/// Developer-facing screen shown when the build has no API URL (no env file).
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: AppPalette.dangerBg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(message,
                style:
                    AppTypography.body.copyWith(color: AppPalette.dangerText)),
          ),
        ),
      ),
    );
  }
}
