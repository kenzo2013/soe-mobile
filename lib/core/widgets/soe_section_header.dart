import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// En-tête de section : eyebrow optionnel, titre, kicker optionnel.
class SoeSectionHeader extends StatelessWidget {
  const SoeSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.kicker,
    this.action,
  });

  final String title;
  final String? eyebrow;
  final String? kicker;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child:
                  Text(eyebrow!.toUpperCase(), style: AppTypography.overline),
            ),
          Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.h2)),
              if (action != null) action!,
            ],
          ),
          if (kicker != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                kicker!,
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              ),
            ),
        ],
      ),
    );
  }
}
