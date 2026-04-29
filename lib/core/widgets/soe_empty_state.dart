import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'soe_button.dart';

/// État vide SOE — icône cerclée + titre + body + CTA optionnel.
class SoeEmptyState extends StatelessWidget {
  const SoeEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

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
                color: AppPalette.infoBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 28, color: AppPalette.teal),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              SoeButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bandeau plein écran — utilisé typiquement pour les "succès" globaux.
class SoeFullStatusView extends StatelessWidget {
  const SoeFullStatusView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor = AppPalette.success,
    this.iconBgColor = AppPalette.successBg,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.rPill,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 48, color: iconColor),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTypography.h2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppPalette.n700),
            textAlign: TextAlign.center,
          ),
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: 24),
            SoeButton(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction,
              size: SoeButtonSize.lg,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
