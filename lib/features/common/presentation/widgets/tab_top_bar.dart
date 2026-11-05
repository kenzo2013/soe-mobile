import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import 'notification_bell.dart';

/// The widest a screen's content gets on a tablet (cards, lists), centred.
const double spaceContentMaxWidth = 880;

/// From this width, a screen lays its content out on two columns (tablet portrait).
const double spaceTwoColumnsWidth = 700;

/// True on a tablet-sized screen (two columns, the navigation rail).
bool spaceIsWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= spaceTwoColumnsWidth;

/// The coloured band at the top of a tab's first screen (colourful direction): navy for a
/// tutor and the account, SOE teal for a parent, rounded bottom corners. The white SOE logo
/// and the bell on top, the date as an overline, the serif title (« Bonjour Aline. »), then
/// optional [chips] (summary figures, children). The cards below overlap its bottom by
/// [overlap] (see [SpaceTabView]).
class SpaceBand extends ConsumerWidget {
  const SpaceBand({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.chips,
    this.trailing,
    this.heading,
    this.color,
    this.overlap = SpaceBand.cardOverlap,
    this.now,
  });

  /// How far the first card climbs on the band.
  static const double cardOverlap = 44;

  final String title;

  /// Above the title; null: today's date (« JEUDI 5 NOVEMBRE »).
  final String? overline;

  /// Below the title (a lead sentence).
  final String? subtitle;

  /// Below the title: summary figures, the children…
  final Widget? chips;

  /// On the right of the logo instead of the bell (« Mode répétiteur » on the account).
  final Widget? trailing;

  /// Replaces the overline and the title (the account: avatar, name, phone).
  final Widget? heading;

  /// The band's colour; null: the colour of the current role.
  final Color? color;

  /// Room kept at the bottom for the overlapping card (0: nothing overlaps).
  final double overlap;

  /// Today, injectable for the tests.
  final DateTime? now;

  /// The overline colour on a band.
  static Color softText(Color band) => band == AppPalette.parentBand
      ? AppPalette.teal100
      : AppPalette.navInactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final band = color ?? AppPalette.band(ref.watch(currentRoleProvider));
    final soft = softText(band);
    final locale = Localizations.localeOf(context).languageCode;
    final date = overline ??
        DateFormat('EEEE d MMMM', locale).format(now ?? DateTime.now());
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          color: band,
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.band)),
        ),
        padding: EdgeInsets.fromLTRB(20, top + 12, 20, 28 + overlap),
        child: _Centred(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const SoeBrandLogo(width: 57, onDark: true),
                const Spacer(),
                trailing ?? NotificationBell(band: band),
              ]),
              const SizedBox(height: 18),
              if (heading != null)
                heading!
              else ...[
                Text(date.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm
                        .copyWith(color: soft, letterSpacing: 1.04)),
                const SizedBox(height: 4),
                Semantics(
                  header: true,
                  child: Text(title,
                      style: AppTypography.h1.copyWith(
                          fontSize: 30,
                          height: 38 / 30,
                          color: AppPalette.white)),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!,
                    style: AppTypography.bodySm.copyWith(color: soft)),
              ],
              if (chips != null) ...[
                const SizedBox(height: 18),
                chips!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A summary figure of a band (« 2 à faire », « 0 séance auj. », « 4 500 FCFA ce mois »).
class BandStat extends StatelessWidget {
  const BandStat({
    super.key,
    required this.value,
    required this.label,
    this.background = AppPalette.onBandSoft,
    this.valueColor = AppPalette.white,
    this.labelColor = AppPalette.navInactive,
    this.onTap,
  });

  /// Gold: what is to do.
  const BandStat.gold(
      {super.key, required this.value, required this.label, this.onTap})
      : background = AppPalette.gold400,
        valueColor = AppPalette.ink900,
        labelColor = AppPalette.goldInk;

  /// Green: money.
  const BandStat.green(
      {super.key, required this.value, required this.label, this.onTap})
      : background = AppPalette.success,
        valueColor = AppPalette.white,
        labelColor = AppPalette.successBg;

  final String value;
  final String label;
  final Color background;
  final Color valueColor;
  final Color labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        label: '$value $label',
        excludeSemantics: true,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        maxLines: 1,
                        style: AppTypography.title.copyWith(
                            fontSize: 22,
                            height: 27 / 22,
                            fontWeight: FontWeight.w700,
                            color: valueColor)),
                  ),
                  const SizedBox(height: 2),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSm
                          .copyWith(fontSize: 12, color: labelColor)),
                ],
              ),
            ),
          ),
        ),
      );
}

/// A translucent pill of a band: a round initial and a label (« L  Léa · CM2 »).
class BandChip extends StatelessWidget {
  const BandChip({
    super.key,
    required this.label,
    this.initial,
    this.initialBackground = AppPalette.gold100,
    this.initialColor = AppPalette.gold700,
    this.onTap,
  });

  final String label;
  final String? initial;
  final Color initialBackground;
  final Color initialColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppPalette.onBandSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(initial == null ? 12 : 6, 6, 12, 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (initial != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: initialBackground, shape: BoxShape.circle),
                  child: Text(initial!,
                      style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700, color: initialColor)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.label.copyWith(color: AppPalette.white)),
              ),
            ]),
          ),
        ),
      );
}

/// The first screen of a tab: the [band], then [children] whose first card overlaps it, all
/// scrolling together and behind the floating navigation. On a tablet the content keeps
/// [spaceContentMaxWidth], centred.
class SpaceTabView extends StatelessWidget {
  const SpaceTabView({
    super.key,
    required this.band,
    required this.children,
    this.onRefresh,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final SpaceBand band;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final list = ListView(
      padding: EdgeInsets.only(bottom: insets.bottom + 24),
      children: [
        band,
        Transform.translate(
          offset: Offset(0, -band.overlap),
          child: Padding(
            padding: padding,
            child: _Centred(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: onRefresh == null
          ? list
          : RefreshIndicator(
              onRefresh: onRefresh!, edgeOffset: insets.top, child: list),
    );
  }
}

/// The content of a band or a screen, at most [spaceContentMaxWidth] wide, centred.
class _Centred extends StatelessWidget {
  const _Centred({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: spaceContentMaxWidth),
          child: child,
        ),
      );
}

/// Centres [child] at most [spaceContentMaxWidth] wide (tablet).
class SpaceCentred extends StatelessWidget {
  const SpaceCentred({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => _Centred(child: child);
}

/// The body of a tab's first screen whose content scrolls on its own (lists with filters):
/// the [SpaceBand] with the tab's name, then [child] below it.
class TabBody extends StatelessWidget {
  const TabBody(
      {super.key, required this.title, required this.child, this.chips});

  final String title;
  final Widget child;
  final Widget? chips;

  @override
  Widget build(BuildContext context) => Column(children: [
        SpaceBand(title: title, chips: chips, overlap: 0),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SafeArea(top: false, child: child),
          ),
        ),
      ]);
}

/// The band of a tab whose content scrolls on its own, without overlap.
class TabTopBar extends StatelessWidget {
  const TabTopBar({super.key, required this.title, this.now, this.chips});

  final String title;
  final Widget? chips;

  /// Today, injectable for the tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) =>
      SpaceBand(title: title, now: now, chips: chips, overlap: 0);
}
