import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import 'notification_bell.dart';

/// The top bar of a tab's first screen (Studio, mobile 390): today's date above the tab's
/// name, the bell on the right. It stays in place while the screen scrolls.
class TabTopBar extends StatelessWidget {
  const TabTopBar({super.key, required this.title, this.now});

  final String title;

  /// Today, injectable for the tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = toBeginningOfSentenceCase(
        DateFormat('EEEE d MMMM', locale).format(now ?? DateTime.now()));
    return Container(
      color: AppPalette.surfacePage,
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(color: AppPalette.text)),
            ],
          ),
        ),
        const NotificationBell(),
      ]),
    );
  }
}

/// The body of a tab's first screen: the safe area, the [TabTopBar], then the content.
class TabBody extends StatelessWidget {
  const TabBody({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(children: [
          TabTopBar(title: title),
          Expanded(child: child),
        ]),
      );
}
