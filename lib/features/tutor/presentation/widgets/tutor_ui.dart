import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/tutor_dashboard.dart' show TutorSessionStatus;

/// Helpers UI partagés du flux tuteur (formatage, badges, tuiles, états).

String fcfa(int n) => '${NumberFormat.decimalPattern("fr_FR").format(n)} FCFA';

/// Spec d'un badge de statut : (libellé, fond, texte).
typedef BadgeSpec = (String label, Color bg, Color fg);

BadgeSpec sessionStatusSpec(Translations tr, TutorSessionStatus s) =>
    switch (s) {
      TutorSessionStatus.confirmed => (
          tr.tutor.status.confirmed,
          AppPalette.successBg,
          AppPalette.success
        ),
      TutorSessionStatus.completed => (
          tr.tutor.status.completed,
          AppPalette.successBg,
          AppPalette.success
        ),
      TutorSessionStatus.inProgress => (
          tr.tutor.status.inProgress,
          AppPalette.warningBg,
          AppPalette.warning
        ),
      TutorSessionStatus.pending => (
          tr.tutor.status.pending,
          AppPalette.warningBg,
          AppPalette.warning
        ),
      TutorSessionStatus.unknown => ('—', AppPalette.n100, AppPalette.n700),
    };

/// Petit badge pilule réutilisable.
class TutorPillBadge extends StatelessWidget {
  const TutorPillBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.dot = true,
  });

  final String label;
  final Color bg;
  final Color fg;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille de matière / tag (fond clair).
class TutorTagChip extends StatelessWidget {
  const TutorTagChip({
    super.key,
    required this.label,
    this.bg,
    this.fg,
  });

  final String label;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? AppPalette.n100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg ?? AppPalette.ink,
        ),
      ),
    );
  }
}

/// Bordure pointillée « Ajouter … ».
class TutorAddTile extends StatelessWidget {
  const TutorAddTile({
    super.key,
    required this.label,
    this.icon = Icons.add,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DottedBorderBox(
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppPalette.teal),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Conteneur à bordure pointillée (CustomPaint léger via DecoratedBox stylé).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Bordure pleine adoucie : on évite une dépendance externe pour le
    // pointillé ; visuellement proche du dashed du design.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppPalette.n500,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}

/// Loader centré standard.
class TutorLoading extends StatelessWidget {
  const TutorLoading({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppPalette.teal));
}
