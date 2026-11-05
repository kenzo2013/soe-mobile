import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import 'notification_bell.dart';

/// The header of a screen opened from a tab (Studio, mobile 390): the way back, the breadcrumb
/// « Planning › Séance » above the screen's name, the bell on the right.
class SpaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpaceAppBar({
    super.key,
    required this.title,
    this.section,
    this.close = false,
    this.bell = true,
    this.actions = const [],
  });

  /// The screen's name (« Séance »).
  final String title;

  /// Where the screen comes from (« Planning »): the breadcrumb reads « Planning › Séance ».
  final String? section;

  /// A cross instead of the back arrow (a form that is abandoned).
  final bool close;

  /// The bell, hidden on the forms that must not be left by mistake.
  final bool bell;

  /// Buttons before the bell (the PDF of a contract).
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final material = MaterialLocalizations.of(context);
    return Material(
      color: AppPalette.surfacePage,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
            child: Row(children: [
              if (canPop)
                IconButton(
                  tooltip: close
                      ? material.closeButtonTooltip
                      : material.backButtonTooltip,
                  icon: Icon(close ? Icons.close : Icons.chevron_left,
                      color: AppPalette.text),
                  onPressed: () => context.pop(),
                )
              else
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (section != null)
                      Text('$section › $title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label
                            .copyWith(color: AppPalette.text)),
                  ],
                ),
              ),
              ...actions,
              if (bell) const NotificationBell(),
            ]),
          ),
        ),
      ),
    );
  }
}
