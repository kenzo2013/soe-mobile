import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum SoeAlertTone { success, warning, danger, info }

/// Alerte inline SOE — badge rond + titre + body, bordure gauche colorée.
class SoeAlert extends StatelessWidget {
  const SoeAlert({
    super.key,
    required this.title,
    required this.body,
    this.tone = SoeAlertTone.info,
  });

  final String title;
  final String body;
  final SoeAlertTone tone;

  @override
  Widget build(BuildContext context) {
    final spec = _spec(tone);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: AppRadius.rMd,
        border: Border(left: BorderSide(color: spec.fg, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: spec.fg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(spec.icon, size: 16, color: AppPalette.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: spec.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTypography.label.copyWith(color: AppPalette.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _AlertSpec _spec(SoeAlertTone t) => switch (t) {
        SoeAlertTone.success => const _AlertSpec(
            bg: AppPalette.successBg,
            fg: AppPalette.success,
            icon: Icons.check,
          ),
        SoeAlertTone.warning => const _AlertSpec(
            bg: AppPalette.warningBg,
            fg: AppPalette.warning,
            icon: Icons.access_time,
          ),
        SoeAlertTone.danger => const _AlertSpec(
            bg: AppPalette.dangerBg,
            fg: AppPalette.danger,
            icon: Icons.close,
          ),
        SoeAlertTone.info => const _AlertSpec(
            bg: AppPalette.infoBg,
            fg: AppPalette.teal,
            icon: Icons.info_outline,
          ),
      };
}

class _AlertSpec {
  const _AlertSpec({required this.bg, required this.fg, required this.icon});
  final Color bg;
  final Color fg;
  final IconData icon;
}
