import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../error/failure.dart';
import '../error/failure_message.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import 'soe_button.dart';

/// The error of a screen with « Réessayer »: orange without network (the data will come
/// back), soft red otherwise.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final offline = failure is NetworkFailure || failure is TimeoutFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: offline ? AppPalette.warningBg : AppPalette.dangerBg,
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Icon(
                offline ? Icons.wifi_off_rounded : Icons.error_outline,
                size: 28,
                color: offline ? AppPalette.warningText : AppPalette.dangerText,
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
              SoeButton(
                  label: tr.common.retry,
                  variant: SoeButtonVariant.secondary,
                  onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
