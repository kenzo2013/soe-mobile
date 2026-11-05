import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/account_models.dart';
import '../notification_target_route.dart';
import '../providers.dart';
import 'account_ui.dart';
import 'notification_visuals.dart';

/// The bell of the headers (COM-07): a red dot while something is unread; a tap opens the
/// panel of the latest unread notifications and « Tout voir ».
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.bell;
    final count = ref.watch(unreadNotificationsProvider).valueOrNull ?? 0;
    return Semantics(
      button: true,
      label: count == 0 ? tr.label : tr.labelUnread(n: count),
      excludeSemantics: true,
      child: InkResponse(
        onTap: () => unawaited(showNotificationPanel(context, ref)),
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
              color: AppPalette.surfaceSoft, shape: BoxShape.circle),
          child: Stack(alignment: Alignment.center, children: [
            const Icon(Icons.notifications_none,
                size: 22, color: AppPalette.teal800),
            if (count > 0)
              Positioned(
                top: 7,
                right: 8,
                child: Container(
                  key: const Key('notification-bell-dot'),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppPalette.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.white, width: 1.5),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// The panel of the bell: the three latest unread notifications.
Future<void> showNotificationPanel(BuildContext context, WidgetRef ref) {
  final tr = Translations.of(context).accountSpace.bell;
  return showAccountSheet<void>(
    context,
    title: tr.title,
    builder: (sheetContext) => _Panel(outerContext: context, outerRef: ref),
  ).then((_) => null);
}

class _Panel extends ConsumerWidget {
  const _Panel({required this.outerContext, required this.outerRef});

  /// The screen under the sheet: it navigates once the sheet is closed.
  final BuildContext outerContext;
  final WidgetRef outerRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.bell;
    final page = ref.watch(notificationsProvider('unread'));
    final count = page.valueOrNull?.unreadCount ??
        ref.watch(unreadNotificationsProvider).valueOrNull ??
        0;
    final latest = page.valueOrNull?.items.take(3).toList() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(count == 0 ? tr.noneUnread : tr.unread(n: count),
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        if (page.isLoading && latest.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (latest.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(tr.empty,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          )
        else
          for (final notification in latest)
            _PanelRow(
              notification: notification,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(
                    openNotification(outerContext, outerRef, notification));
              },
            ),
        const SizedBox(height: 16),
        SoeButton(
          label: tr.seeAll,
          variant: SoeButtonVariant.outline,
          fullWidth: true,
          onPressed: () {
            Navigator.of(context).pop();
            unawaited(outerContext.push(RouteNames.notifications));
          },
        ),
      ],
    );
  }
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = NotificationVisual.of(notification.type);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppPalette.n100))),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppPalette.n100,
            child: Icon(visual.icon, size: 18, color: AppPalette.teal800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(notification.title,
                  style:
                      AppTypography.labelSm.copyWith(color: AppPalette.text)),
              Text(notificationTime(context, notification),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppPalette.text2),
        ]),
      ),
    );
  }
}

/// « 16:05 » today, « Hier » yesterday, « Lun. 2 nov. » before.
String notificationTime(BuildContext context, AppNotification notification) {
  final at = notification.createdAt;
  if (at == null) return '';
  return switch (notification.day) {
    'today' => AccountFormat.time(at),
    'yesterday' =>
      Translations.of(context).accountSpace.notifications.yesterday,
    _ => AccountFormat.day(context, at),
  };
}

/// Opens a notification: marks it read on the server (which answers its target screen), then
/// opens that screen in the active role.
Future<void> openNotification(
    BuildContext context, WidgetRef ref, AppNotification notification) async {
  var target = notification.target;
  try {
    target = (await ref.read(accountApiProvider).read(notification.id)).target;
  } on Object catch (_) {
    // Offline: the screen still opens from the target already known.
  }
  ref
    ..invalidate(unreadNotificationsProvider)
    ..invalidate(notificationsProvider);
  if (!context.mounted) return;
  final route = notificationRoute(target, ref.read(currentRoleProvider));
  if (RouteNames.tabRoots.contains(route)) {
    context.go(route);
  } else {
    unawaited(context.push(route));
  }
}
