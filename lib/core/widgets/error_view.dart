import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
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
    final tr = Translations.of(context);
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
              _label(tr, failure),
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SoeButton(label: tr.common.retry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }

  String _label(Translations tr, Failure f) => switch (f) {
        NetworkFailure() => tr.errors.network,
        TimeoutFailure() => tr.errors.timeout,
        UnauthorizedFailure() => tr.errors.unauthorized,
        InvalidCredentialsFailure() => tr.errors.invalidCredentials,
        EmailNotConfirmedFailure() => tr.errors.emailNotConfirmed,
        ForbiddenFailure() => tr.errors.forbidden,
        NotFoundFailure() => tr.errors.notFound,
        ConflictFailure(:final message) => message ?? tr.errors.conflict,
        ValidationFailure(:final message) => message ?? tr.errors.validation,
        ServerFailure(:final message) => message ?? tr.errors.server,
        CancelledFailure() => tr.errors.cancelled,
        UnknownFailure() => tr.errors.unknown,
      };
}
