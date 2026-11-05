import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import 'notification_bell.dart';
import 'tab_top_bar.dart';

/// The header of a screen opened from a tab (colourful direction): a compact band in the
/// role's colour (navy for a tutor, SOE teal for a parent) with rounded bottom corners, the
/// way back, the breadcrumb « Planning › Séance » above the screen's name, the bell.
class SpaceAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SpaceAppBar({
    super.key,
    required this.title,
    this.section,
    this.crumb,
    this.close = false,
    this.bell = true,
    this.actions = const [],
    this.color,
  });

  /// The screen's name (« Séance »).
  final String title;

  /// Where the screen comes from (« Planning »): the breadcrumb reads « Planning › Séance ».
  final String? section;

  /// A breadcrumb given whole (« Compte › Sécurité »), instead of [section].
  final String? crumb;

  /// A cross instead of the back arrow (a form that is abandoned).
  final bool close;

  /// The bell, hidden on the forms that must not be left by mistake.
  final bool bell;

  /// Buttons before the bell (the PDF of a contract), drawn white.
  final List<Widget> actions;

  /// The band's colour; null: the colour of the current role.
  final Color? color;

  static const double barHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final band = color ?? AppPalette.band(ref.watch(currentRoleProvider));
    final soft = SpaceBand.softText(band);
    final canPop = Navigator.of(context).canPop();
    final material = MaterialLocalizations.of(context);
    final breadcrumb = crumb ?? (section == null ? null : '$section › $title');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: band,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
              child: IconTheme(
                data: const IconThemeData(color: AppPalette.white),
                child: Row(children: [
                  if (canPop)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        tooltip: close
                            ? material.closeButtonTooltip
                            : material.backButtonTooltip,
                        style: IconButton.styleFrom(
                            backgroundColor: AppPalette.onBandSoft,
                            fixedSize: const Size(40, 40)),
                        icon: Icon(
                            close ? Icons.close : Icons.arrow_back_rounded,
                            size: 22,
                            color: AppPalette.white),
                        onPressed: () => context.pop(),
                      ),
                    )
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (breadcrumb != null)
                          Text(breadcrumb,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.caption.copyWith(color: soft)),
                        Semantics(
                          header: true,
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(
                                  fontSize: 17, color: AppPalette.white)),
                        ),
                      ],
                    ),
                  ),
                  ...actions,
                  if (bell) ...[
                    const SizedBox(width: 4),
                    NotificationBell(band: band),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
