import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'soe_button.dart';

/// Dialog confirm SOE — icône cerclée + titre + body + 2 actions.
///
/// Usage : `final ok = await SoeConfirmDialog.show(context, ...) ?? false;`.
class SoeConfirmDialog extends StatelessWidget {
  const SoeConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.help_outline,
    this.iconColor = AppPalette.warning,
    this.iconBgColor = AppPalette.warningBg,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.destructive = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool destructive = false,
    IconData icon = Icons.help_outline,
    Color iconColor = AppPalette.warning,
    Color iconBgColor = AppPalette.warningBg,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => SoeConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
      backgroundColor: AppPalette.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SoeButton(
                    label: cancelLabel,
                    variant: SoeButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SoeButton(
                    label: confirmLabel,
                    variant: destructive
                        ? SoeButtonVariant.danger
                        : SoeButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
