import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/push/push_client.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_dialog.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';
import '../push_session.dart';

/// Around the signed-in space (RoleShell): once there, asks once whether the user wants push
/// notifications (a word on why, then the system prompt), and opens the screen of a push the
/// user tapped. Does nothing in a build without push notifications.
class PushGate extends ConsumerStatefulWidget {
  const PushGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushGate> createState() => _PushGateState();
}

class _PushGateState extends ConsumerState<PushGate> {
  @override
  void initState() {
    super.initState();
    if (!ref.read(pushClientProvider).enabled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = ref.read(pendingPushOpenProvider);
      if (pending != null) {
        _open(pending);
      } else {
        unawaited(_askPermission());
      }
    });
  }

  Future<void> _askPermission() async {
    final prompt = ref.read(pushPermissionPromptProvider);
    if (!await prompt.shouldAsk() || !mounted) return;
    final tr = Translations.of(context).push.permission;
    final accepted = await SoeConfirmDialog.show(
          context,
          title: tr.title,
          message: tr.message,
          confirmLabel: tr.allow,
          cancelLabel: tr.later,
          icon: Icons.notifications_active_outlined,
          iconColor: AppPalette.info,
          iconBgColor: AppPalette.infoBg,
        ) ??
        false;
    await prompt.answered(accepted: accepted);
  }

  /// The screen of the push in the active role (a tab root with `go`, any other with `push`),
  /// and the notification marked read, as when it is opened from the centre.
  void _open(PushOpen open) {
    ref.read(pendingPushOpenProvider.notifier).state = null;
    final route = open.routeFor(ref.read(currentRoleProvider));
    final router = GoRouter.of(context);
    if (RouteNames.tabRoots.contains(route)) {
      router.go(route);
    } else {
      unawaited(router.push(route));
    }
    final id = open.notificationId;
    if (id != null) unawaited(_markRead(id));
  }

  Future<void> _markRead(int id) async {
    try {
      await ref.read(accountApiProvider).read(id);
      ref.invalidate(unreadNotificationsProvider);
    } on Failure catch (_) {
      // Best effort: the notification stays unread in the centre.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PushOpen?>(pendingPushOpenProvider, (_, open) {
      if (open != null) _open(open);
    });
    return widget.child;
  }
}
