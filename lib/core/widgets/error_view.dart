import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../error/failure.dart';
import '../error/failure_message.dart';
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
              failureMessage(failure, tr),
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
}
