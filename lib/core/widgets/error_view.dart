import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import 'soe_button.dart';

/// Vue d'erreur générique avec retry. À utiliser dans toutes les pages.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppPalette.dangerBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline,
                size: 28,
                color: AppPalette.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _label(failure),
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SoeButton(label: 'Réessayer', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }

  String _label(Failure f) => switch (f) {
        NetworkFailure() => 'Pas de connexion réseau.',
        TimeoutFailure() => 'Le serveur met trop de temps à répondre.',
        UnauthorizedFailure() => 'Session expirée, veuillez vous reconnecter.',
        ForbiddenFailure() => 'Accès non autorisé.',
        NotFoundFailure() => 'Ressource introuvable.',
        ConflictFailure(:final message) => message ?? 'Conflit détecté.',
        ValidationFailure(:final message) =>
          message ?? 'Certains champs sont invalides.',
        ServerFailure(:final message) =>
          message ?? 'Erreur serveur, réessayez plus tard.',
        CancelledFailure() => 'Opération annulée.',
        UnknownFailure() => 'Une erreur inattendue est survenue.',
      };
}
