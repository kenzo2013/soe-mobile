import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/mappers/notification_mapper.dart';
import '../../domain/entities/app_notification.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';
import '../widgets/notification_visuals.dart';

/// 7 · Centre de notifications (design `CommonNotifsList`).
class NotificationsCenterPage extends ConsumerStatefulWidget {
  const NotificationsCenterPage({super.key});

  @override
  ConsumerState<NotificationsCenterPage> createState() =>
      _NotificationsCenterPageState();
}

class _NotificationsCenterPageState
    extends ConsumerState<NotificationsCenterPage> {
  bool _unreadOnly = false;

  Future<void> _markAllRead() async {
    final tr = Translations.of(context);
    await runCommonAction(
      context,
      ref,
      actionKey: 'notif_all_read',
      successMessage: tr.notifications.center.markedAllRead,
      popOnSuccess: false,
      op: () => ref.read(commonRepositoryProvider).markAllNotificationsRead(),
      onSuccess: () => ref.invalidate(notificationsProvider),
    );
  }

  Future<void> _open(AppNotification n) async {
    if (!n.read) {
      // Marque lu en arrière-plan puis rafraîchit.
      await ref.read(commonRepositoryProvider).markNotificationRead(n.id);
      ref.invalidate(notificationsProvider);
    }
    if (mounted) {
      unawaited(context.push(RouteNames.notificationDetail(n.id), extra: n));
    }
  }

  Future<void> _delete(AppNotification n) async {
    final tr = Translations.of(context);
    await runCommonAction(
      context,
      ref,
      actionKey: 'notif_del:${n.id}',
      successMessage: tr.notifications.center.deleted,
      popOnSuccess: false,
      op: () => ref.read(commonRepositoryProvider).deleteNotification(n.id),
      onSuccess: () => ref.invalidate(notificationsProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final async = ref.watch(notificationsProvider);
    final unreadCount =
        async.asData?.value.where((n) => !n.read).length ?? 0;

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.notifications.center.title,
        subtitle: unreadCount <= 1
            ? tr.notifications.center.unreadOne(count: unreadCount)
            : tr.notifications.center.unreadOther(count: unreadCount),
        action: Material(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: unreadCount == 0 ? null : _markAllRead,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppPalette.n300),
              ),
              child: const Icon(Icons.done_all, size: 18, color: AppPalette.teal),
            ),
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (all) {
          final items = _unreadOnly ? all.where((n) => !n.read).toList() : all;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _FilterChip(
                      label: tr.notifications.center.filterAll,
                      count: all.length,
                      selected: !_unreadOnly,
                      onTap: () => setState(() => _unreadOnly = false),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: tr.notifications.center.filterUnread,
                      count: unreadCount,
                      selected: _unreadOnly,
                      onTap: () => setState(() => _unreadOnly = true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? SoeEmptyState(
                        icon: Icons.notifications_none,
                        title: tr.notifications.center.emptyTitle,
                        message: tr.notifications.center.emptyMessage,
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(notificationsProvider),
                        child: _GroupedList(
                          items: items,
                          onOpen: _open,
                          onDelete: _delete,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.items,
    required this.onOpen,
    required this.onDelete,
  });
  final List<AppNotification> items;
  final ValueChanged<AppNotification> onOpen;
  final ValueChanged<AppNotification> onDelete;

  @override
  Widget build(BuildContext context) {
    // Groupe par jour en conservant l'ordre d'arrivée.
    final groups = <String, List<AppNotification>>{};
    for (final n in items) {
      groups.putIfAbsent(NotificationMapper.dayGroup(n.createdAt), () => [])
          .add(n);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 6),
            child: Text(
              entry.key.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppPalette.teal,
                letterSpacing: 1,
              ),
            ),
          ),
          for (final n in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _NotificationTile(
                notification: n,
                onTap: () => onOpen(n),
                onDelete: () => onDelete(n),
              ),
            ),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final v = NotificationVisual.of(n.kind);
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppPalette.dangerBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppPalette.danger),
      ),
      child: Material(
        color: n.read ? AppPalette.white : AppPalette.n300,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: n.read ? AppPalette.n300 : AppPalette.teal,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: v.color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(v.icon, size: 16, color: v.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    n.read ? FontWeight.w600 : FontWeight.w700,
                                color: AppPalette.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            n.timeLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppPalette.n700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppPalette.teal : AppPalette.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppPalette.teal : AppPalette.n300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppPalette.ink,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppPalette.n100,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppPalette.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
