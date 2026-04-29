import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

enum SoeBadgeTone { success, warning, danger, info, neutral }

/// Badge SOE — design system officiel.
///
/// Variante `solid` pour les statuts proéminents.
class SoeBadge extends StatelessWidget {
  const SoeBadge({
    super.key,
    required this.label,
    this.tone = SoeBadgeTone.neutral,
    this.icon,
    this.solid = false,
  });

  final String label;
  final SoeBadgeTone tone;
  final IconData? icon;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final spec = _spec(tone);
    final bg = solid ? spec.solidBg : spec.bg;
    final fg = solid ? AppPalette.white : spec.fg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeSpec _spec(SoeBadgeTone tone) => switch (tone) {
        SoeBadgeTone.success => const _BadgeSpec(
            bg: AppPalette.successBg,
            fg: AppPalette.success,
            solidBg: AppPalette.success,
          ),
        SoeBadgeTone.warning => const _BadgeSpec(
            bg: AppPalette.warningBg,
            fg: AppPalette.warning,
            solidBg: AppPalette.warning,
          ),
        SoeBadgeTone.danger => const _BadgeSpec(
            bg: AppPalette.dangerBg,
            fg: AppPalette.danger,
            solidBg: AppPalette.danger,
          ),
        SoeBadgeTone.info => const _BadgeSpec(
            bg: AppPalette.infoBg,
            fg: AppPalette.teal,
            solidBg: AppPalette.teal,
          ),
        SoeBadgeTone.neutral => const _BadgeSpec(
            bg: AppPalette.n300,
            fg: AppPalette.n700,
            solidBg: AppPalette.n700,
          ),
      };
}

class _BadgeSpec {
  const _BadgeSpec({
    required this.bg,
    required this.fg,
    required this.solidBg,
  });
  final Color bg;
  final Color fg;
  final Color solidBg;
}

// ─── Badges métier — mappings depuis les enums API ────────────────────

/// Statuts de réservation (cahier des charges §11.1).
enum ReservationStatus {
  pending,
  active,
  allCompleted,
  allCancelled,
  allOnHold,
}

/// Statuts de devis.
enum QuoteStatus { draft, proposedPrice, accepted, rejected, negotiation }

/// Statuts de séance.
enum SessionStatus { pending, completed, approved, rejected }

/// Statuts de paiement.
enum PaymentStatus { pending, processing, completed, failed }

/// Helpers pour exposer un `SoeBadge` à partir des statuts métier.
extension ReservationStatusBadge on ReservationStatus {
  SoeBadge toBadge() {
    final tone = switch (this) {
      ReservationStatus.pending => SoeBadgeTone.warning,
      ReservationStatus.active => SoeBadgeTone.success,
      ReservationStatus.allCompleted => SoeBadgeTone.info,
      ReservationStatus.allCancelled => SoeBadgeTone.danger,
      ReservationStatus.allOnHold => SoeBadgeTone.neutral,
    };
    final label = switch (this) {
      ReservationStatus.pending => 'En attente',
      ReservationStatus.active => 'Active',
      ReservationStatus.allCompleted => 'Terminée',
      ReservationStatus.allCancelled => 'Annulée',
      ReservationStatus.allOnHold => 'En pause',
    };
    return SoeBadge(label: label, tone: tone);
  }
}

extension QuoteStatusBadge on QuoteStatus {
  SoeBadge toBadge() {
    final tone = switch (this) {
      QuoteStatus.draft => SoeBadgeTone.neutral,
      QuoteStatus.proposedPrice => SoeBadgeTone.warning,
      QuoteStatus.accepted => SoeBadgeTone.success,
      QuoteStatus.rejected => SoeBadgeTone.danger,
      QuoteStatus.negotiation => SoeBadgeTone.info,
    };
    final label = switch (this) {
      QuoteStatus.draft => 'Brouillon',
      QuoteStatus.proposedPrice => 'Prix proposé',
      QuoteStatus.accepted => 'Accepté',
      QuoteStatus.rejected => 'Rejeté',
      QuoteStatus.negotiation => 'Négociation',
    };
    return SoeBadge(label: label, tone: tone);
  }
}

extension SessionStatusBadge on SessionStatus {
  SoeBadge toBadge() {
    final tone = switch (this) {
      SessionStatus.pending => SoeBadgeTone.warning,
      SessionStatus.completed => SoeBadgeTone.info,
      SessionStatus.approved => SoeBadgeTone.success,
      SessionStatus.rejected => SoeBadgeTone.danger,
    };
    final label = switch (this) {
      SessionStatus.pending => 'En attente',
      SessionStatus.completed => 'Effectuée',
      SessionStatus.approved => 'Validée',
      SessionStatus.rejected => 'Rejetée',
    };
    return SoeBadge(label: label, tone: tone);
  }
}

extension PaymentStatusBadge on PaymentStatus {
  SoeBadge toBadge() {
    final tone = switch (this) {
      PaymentStatus.pending => SoeBadgeTone.warning,
      PaymentStatus.processing => SoeBadgeTone.info,
      PaymentStatus.completed => SoeBadgeTone.success,
      PaymentStatus.failed => SoeBadgeTone.danger,
    };
    final label = switch (this) {
      PaymentStatus.pending => 'En attente',
      PaymentStatus.processing => 'En cours',
      PaymentStatus.completed => 'Payé',
      PaymentStatus.failed => 'Échoué',
    };
    return SoeBadge(label: label, tone: tone);
  }
}
