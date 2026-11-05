import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';
import '../widgets/notification_bell.dart';
import '../widgets/notification_visuals.dart';

/// COM-07 — the notification centre of the active role: filters (all, unread, to do), grouped
/// by day, an icon and a colour per type, « Tout marquer comme lu »; each one opens its screen.
/// A long press marks it unread or deletes it.
class NotificationsCenterPage extends ConsumerStatefulWidget {
  const NotificationsCenterPage({super.key});

  @override
  ConsumerState<NotificationsCenterPage> createState() =>
      _NotificationsCenterPageState();
}

class _NotificationsCenterPageState
    extends ConsumerState<NotificationsCenterPage> {
  String _filter = 'all';

  void _reload() => ref
    ..invalidate(notificationsProvider)
    ..invalidate(unreadNotificationsProvider);

  Future<void> _act(Future<void> Function() call, {String? message}) async {
    try {
      await call();
      _reload();
      if (mounted && message != null) SoeToast.show(context, message: message);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: accountFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    }
  }

  Future<void> _actions(AppNotification notification) async {
    final tr = Translations.of(context).accountSpace.notifications;
    final api = ref.read(accountApiProvider);
    await showAccountSheet<void>(
      context,
      title: notification.title,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notification.read)
            SoeButton(
              label: tr.markUnread,
              variant: SoeButtonVariant.outline,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                unawaited(_act(() => api.unread(notification.id)));
              },
            ),
          const SizedBox(height: 8),
          SoeButton(
            label: tr.delete,
            variant: SoeButtonVariant.dangerOutline,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              unawaited(_act(() => api.deleteNotification(notification.id),
                  message: tr.deleted));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.notifications;
    final page = ref.watch(notificationsProvider(_filter));
    final unread = ref.watch(unreadNotificationsProvider).valueOrNull ??
        page.valueOrNull?.unreadCount ??
        0;
    return AccountScaffold(
      title: tr.title,
      crumb: tr.title,
      onRefresh: () async => _reload(),
      children: [
        AccountPageTitle(tr.title),
        if (unread > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.readAll,
              variant: SoeButtonVariant.tertiary,
              size: SoeButtonSize.sm,
              onPressed: () => unawaited(_act(
                  () => ref.read(accountApiProvider).readAll(),
                  message: tr.readAllDone)),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (key, label) in [
            ('all', tr.filterAll),
            ('unread', tr.filterUnread),
            ('todo', tr.filterTodo),
          ])
            SoeChip(
              label: label,
              selected: _filter == key,
              onTap: () => setState(() => _filter = key),
            ),
        ]),
        const SizedBox(height: 16),
        AccountAsync<NotificationPage>(
          value: page,
          onRetry: _reload,
          builder: (page) {
            if (page.items.isEmpty) {
              final (title, message) = switch (_filter) {
                'unread' => (tr.emptyUnreadTitle, tr.emptyUnread),
                'todo' => (tr.emptyTodoTitle, tr.emptyTodo),
                _ => (tr.emptyTitle, tr.empty),
              };
              return SoeEmptyState(
                  icon: Icons.notifications_none,
                  title: title,
                  message: message);
            }
            final days = <String, List<AppNotification>>{};
            for (final notification in page.items) {
              days.putIfAbsent(notification.day, () => []).add(notification);
            }
            return Column(children: [
              for (final day in ['today', 'yesterday', 'earlier'])
                if (days[day] != null)
                  AccountCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: AccountCardTitle(switch (day) {
                              'today' => tr.today,
                              'yesterday' => tr.yesterday,
                              _ => tr.earlier,
                            }),
                          ),
                          for (final notification in days[day]!)
                            _NotificationRow(
                              notification: notification,
                              last: notification == days[day]!.last,
                              onTap: () => unawaited(
                                  openNotification(context, ref, notification)),
                              onLongPress: () =>
                                  unawaited(_actions(notification)),
                            ),
                        ]),
                  ),
            ]);
          },
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notification,
    required this.last,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final bool last;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.notifications;
    final visual = NotificationVisual.of(notification.type);
    final detail = [
      notificationTime(context, notification),
      if ((notification.body ?? '').isNotEmpty) notification.body!,
    ].where((part) => part.isNotEmpty).join(' · ');
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppPalette.n100)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: visual.background, shape: BoxShape.circle),
            child: Icon(visual.icon, size: 20, color: visual.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(notification.title,
                  style: AppTypography.label.copyWith(
                      color: AppPalette.text,
                      fontWeight: notification.read
                          ? FontWeight.w500
                          : FontWeight.w700)),
              if (detail.isNotEmpty)
                Text(detail,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
            ]),
          ),
          if (!notification.read) ...[
            const SizedBox(width: 8),
            SoeBadge(label: tr.newBadge, tone: SoeBadgeTone.info),
          ],
          const Icon(Icons.chevron_right, color: AppPalette.text2),
        ]),
      ),
    );
  }
}
