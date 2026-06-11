import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_badge.dart' show SoeBadge, SoeBadgeTone;
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/reservation_summary.dart';

class RecentReservationRow extends StatelessWidget {
  const RecentReservationRow({
    super.key,
    required this.reservation,
    this.onTap,
  });

  final ReservationSummary reservation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppPalette.infoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppPalette.teal,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reservation.reference,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.n700,
                        ),
                      ),
                      _statusBadge(tr, reservation.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reservation.childName} · ${reservation.subjects.join(", ")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (reservation.amount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _fcfa(reservation.amount!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.n700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(Translations tr, ReservationStatus s) {
    final (label, tone) = switch (s) {
      ReservationStatus.draft => (
          tr.parent.dashboard.reservationStatusDraft,
          SoeBadgeTone.neutral
        ),
      ReservationStatus.pending => (
          tr.parent.dashboard.reservationStatusPending,
          SoeBadgeTone.warning
        ),
      ReservationStatus.proposedPrice => (
          tr.parent.dashboard.reservationStatusProposedPrice,
          SoeBadgeTone.warning
        ),
      ReservationStatus.negotiation => (
          tr.parent.dashboard.reservationStatusNegotiation,
          SoeBadgeTone.info
        ),
      ReservationStatus.accepted => (
          tr.parent.dashboard.reservationStatusAccepted,
          SoeBadgeTone.success
        ),
      ReservationStatus.active => (
          tr.parent.dashboard.reservationStatusActive,
          SoeBadgeTone.success
        ),
      ReservationStatus.completed => (
          tr.parent.dashboard.reservationStatusCompleted,
          SoeBadgeTone.success
        ),
      ReservationStatus.rejected => (
          tr.parent.dashboard.reservationStatusRejected,
          SoeBadgeTone.danger
        ),
      ReservationStatus.cancelled => (
          tr.parent.dashboard.reservationStatusCancelled,
          SoeBadgeTone.neutral
        ),
      ReservationStatus.unknown => ('—', SoeBadgeTone.neutral),
    };
    return SoeBadge(label: label, tone: tone);
  }

  String _fcfa(int n) {
    final f = NumberFormat.decimalPattern('fr_FR');
    return '${f.format(n)} FCFA';
  }
}
