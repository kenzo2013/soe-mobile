import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/app_notification.dart';

/// Icône + couleur associées à une catégorie de notification (design).
class NotificationVisual {
  const NotificationVisual(this.icon, this.color);
  final IconData icon;
  final Color color;

  static NotificationVisual of(NotificationKind kind) => switch (kind) {
        NotificationKind.reservation => const NotificationVisual(
            Icons.description_outlined, AppPalette.warning),
        NotificationKind.payment =>
          const NotificationVisual(Icons.credit_card, AppPalette.success),
        NotificationKind.session => const NotificationVisual(
            Icons.calendar_today_outlined, AppPalette.info),
        NotificationKind.review =>
          const NotificationVisual(Icons.star_outline, AppPalette.yellow),
        NotificationKind.contract => const NotificationVisual(
            Icons.insert_drive_file_outlined, AppPalette.teal),
        NotificationKind.system => const NotificationVisual(
            Icons.notifications_outlined, AppPalette.n700),
      };
}
