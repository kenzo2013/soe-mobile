import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Icon and colours of a notification, by its type (COM-07: an icon and a colour per type).
class NotificationVisual {
  const NotificationVisual(this.icon, this.foreground, this.background);

  final IconData icon;
  final Color foreground;
  final Color background;

  static const _gold = (AppPalette.gold700, AppPalette.gold50);
  static const _success = (AppPalette.successText, AppPalette.successBg);
  static const _info = (AppPalette.teal800, AppPalette.teal50);

  static NotificationVisual of(String? type) {
    final (icon, tone) = switch (type) {
      'session_report' => (Icons.description_outlined, _gold),
      'contract' || 'amendment' => (Icons.draw_outlined, _gold),
      'payment' => (Icons.account_balance_wallet_outlined, _success),
      'remuneration' || 'compensation' => (Icons.payments_outlined, _success),
      'reservation' => (Icons.description_outlined, _info),
      'sessions' => (Icons.calendar_today_outlined, _info),
      'job' => (Icons.work_outline, _info),
      'student' => (Icons.people_outline, _info),
      'review' => (Icons.star_outline, _info),
      'account' => (Icons.person_outline, _info),
      _ => (Icons.notifications_none, _info),
    };
    return NotificationVisual(icon, tone.$1, tone.$2);
  }
}
