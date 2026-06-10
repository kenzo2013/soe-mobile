import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../domain/entities/app_notification.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';
import '../widgets/notification_visuals.dart';

/// 8 · Détail notification (design `CommonNotifDetail`).
class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({super.key, required this.notification});

  final AppNotification? notification;

  static const _kindLabel = {
    NotificationKind.reservation: 'Réservation',
    NotificationKind.session: 'Séance',
    NotificationKind.payment: 'Paiement',
    NotificationKind.review: 'Avis',
    NotificationKind.contract: 'Contrat',
    NotificationKind.system: 'Système',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const CommonTopBar(title: 'Notification', subtitle: 'Détail'),
      body: n == null
          ? const Center(child: Text('Notification introuvable'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DetailCard(notification: n, kindLabel: _kindLabel[n.kind]!),
                const SizedBox(height: 24),
                SoeButton(
                  label: 'Supprimer',
                  variant: SoeButtonVariant.danger,
                  fullWidth: true,
                  onPressed: () => runCommonAction(
                    context,
                    ref,
                    actionKey: 'notif_detail_del:${n.id}',
                    successMessage: 'Notification supprimée',
                    op: () => ref
                        .read(commonRepositoryProvider)
                        .deleteNotification(n.id),
                    onSuccess: () => ref.invalidate(notificationsProvider),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.notification, required this.kindLabel});
  final AppNotification notification;
  final String kindLabel;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final v = NotificationVisual.of(n.kind);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.n300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: v.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(v.icon, size: 22, color: v.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: v.color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        kindLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: v.color,
                        ),
                      ),
                    ),
                    if (n.timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        n.timeLabel,
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
          const SizedBox(height: 14),
          Text(
            n.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
              height: 1.3,
            ),
          ),
          if (n.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              n.body,
              style: const TextStyle(
                fontSize: 13,
                color: AppPalette.n700,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
