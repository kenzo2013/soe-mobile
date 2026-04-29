import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

enum SoeStatTone { success, info, danger }

/// Carte statistique colorée — dashboard.
///
/// Fond plein selon `tone`, icône carrée plus foncée, valeur en display.
class SoeStatCard extends StatelessWidget {
  const SoeStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tone = SoeStatTone.info,
    this.previousLabel,
    this.previousValue,
    this.delta,
    this.deltaUp,
  });

  final String title;
  final String value;
  final IconData icon;
  final SoeStatTone tone;
  final String? previousLabel;
  final String? previousValue;
  final String? delta;
  final bool? deltaUp;

  @override
  Widget build(BuildContext context) {
    final spec = _spec(tone);
    return ClipRRect(
      borderRadius: AppRadius.rLg,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: spec.bg,
          borderRadius: AppRadius.rLg,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0x10FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: spec.deep,
                        borderRadius: AppRadius.rSm,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 20, color: AppPalette.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppPalette.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppPalette.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                if (previousLabel != null || delta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (previousLabel != null && previousValue != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                previousLabel!,
                                style: const TextStyle(
                                  color: Color(0xBFFFFFFF),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                previousValue!,
                                style: const TextStyle(
                                  color: AppPalette.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (delta != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                delta!,
                                style: const TextStyle(
                                  color: AppPalette.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                deltaUp == false
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 14,
                                color: AppPalette.white,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static _StatSpec _spec(SoeStatTone t) => switch (t) {
        SoeStatTone.success =>
          const _StatSpec(bg: AppPalette.success, deep: Color(0xFF076021)),
        SoeStatTone.info =>
          const _StatSpec(bg: AppPalette.teal, deep: AppPalette.tealDeep),
        SoeStatTone.danger =>
          const _StatSpec(bg: AppPalette.danger, deep: Color(0xFFC72B2B)),
      };
}

class _StatSpec {
  const _StatSpec({required this.bg, required this.deep});
  final Color bg;
  final Color deep;
}
