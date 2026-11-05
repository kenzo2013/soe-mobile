import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import 'space_app_bar.dart';
import 'tab_top_bar.dart';

/// Shared bits of the account and common screens (COM-01 to COM-10): the header with its
/// breadcrumb and bell, cards, rows and the async body.

/// The message of a failed action: the server's text when it has one (conflict, validation,
/// rate limit, code), else the shared error texts.
String accountFailureMessage(BuildContext context, Failure failure) =>
    switch (failure) {
      ConflictFailure(:final message) when message != null => message,
      ValidationFailure(:final message) when message != null => message,
      RateLimitedFailure(:final message) when message != null => message,
      _ => failureMessage(failure, Translations.of(context)),
    };

/// The first message the server gave for [field] (422), if any.
String? fieldError(Object? error, String field) =>
    error is ValidationFailure ? error.errors[field]?.firstOrNull : null;

abstract final class AccountFormat {
  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String day(BuildContext context, DateTime date) =>
      toBeginningOfSentenceCase(
          DateFormat('EEE d MMM', _locale(context)).format(date)) ??
      '';

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String dateTime(BuildContext context, DateTime date) =>
      '${day(context, date)}, ${time(date)}';
}

/// A screen of the account: header (back, breadcrumb, title, bell), a scrolling body and an
/// optional sticky action at the bottom.
class AccountScaffold extends StatelessWidget {
  const AccountScaffold({
    super.key,
    required this.title,
    required this.children,
    this.crumb,
    this.bottom,
    this.onRefresh,
  });

  /// The header title (the page name).
  final String title;

  /// The breadcrumb above the title (« Compte › Sécurité »); none on the hub.
  final String? crumb;
  final List<Widget> children;
  final Widget? bottom;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        for (final child in children) SpaceCentred(child: child),
      ],
    );
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AccountHeader(title: title, crumb: crumb),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: onRefresh == null
                ? list
                : RefreshIndicator(onRefresh: onRefresh!, child: list),
          ),
          if (bottom != null)
            Container(
              decoration: const BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SpaceCentred(child: bottom!),
            ),
        ]),
      ),
    );
  }
}

/// The header of the account screens: the compact coloured bar with the way back, the
/// breadcrumb (« Compte » by default) and the title, the bell.
class AccountHeader extends StatelessWidget implements PreferredSizeWidget {
  const AccountHeader({super.key, required this.title, this.crumb});

  final String title;
  final String? crumb;

  @override
  Size get preferredSize => const Size.fromHeight(SpaceAppBar.barHeight);

  @override
  Widget build(BuildContext context) => SpaceAppBar(
      title: title,
      crumb: crumb ?? Translations.of(context).accountSpace.crumb);
}

/// The page title in Literata, with an optional lead text.
class AccountPageTitle extends StatelessWidget {
  const AccountPageTitle(this.title, {super.key, this.subtitle, this.overline});

  final String title;
  final String? subtitle;
  final String? overline;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (overline != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(overline!.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal500)),
            ),
          Text(title,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: AppTypography.body.copyWith(color: AppPalette.text2)),
          ],
        ]),
      );
}

/// A card of the Studio: white with a soft shadow, or « soft » (tinted, no shadow) for the
/// secondary blocks.
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.child,
    this.soft = false,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final bool soft;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color ?? (soft ? AppPalette.gold50 : AppPalette.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: soft || color != null ? null : AppShadows.card,
        ),
        child: child,
      );
}

/// A card title in Literata.
class AccountCardTitle extends StatelessWidget {
  const AccountCardTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
          if (trailing != null) trailing!,
        ]),
      );
}

/// A row of a list card: round icon, title, subtitle and a chevron (or [trailing]).
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppPalette.teal500,
    this.iconBackground = AppPalette.teal50,
    this.divider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackground;
  final bool divider;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: divider
                ? const Border(bottom: BorderSide(color: AppPalette.n100))
                : null,
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          AppTypography.label.copyWith(color: AppPalette.text)),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right, color: AppPalette.text2),
          ]),
        ),
      );
}

/// A list card holding [AccountRow]s (no inner padding: the rows have theirs).
class AccountRowsCard extends StatelessWidget {
  const AccountRowsCard({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => AccountCard(
        padding: EdgeInsets.zero,
        child: Column(children: rows),
      );
}

/// A « label … value » line (context of a report, contacts).
class AccountInfoLine extends StatelessWidget {
  const AccountInfoLine(
      {super.key, required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppPalette.n100)),
        ),
        child: Row(children: [
          Text(label,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: AppTypography.labelSm.copyWith(color: AppPalette.text)),
          ),
        ]),
      );
}

/// A form label with an optional hint on the right (« Facultatif »).
class AccountFieldLabel extends StatelessWidget {
  const AccountFieldLabel(this.label, {super.key, this.hint});

  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTypography.label.copyWith(color: AppPalette.text)),
          const SizedBox(width: 8),
          Expanded(
            child: hint == null
                ? const SizedBox.shrink()
                : Text(hint!,
                    textAlign: TextAlign.end,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
          ),
        ]),
      );
}

/// A two-option switch filled in teal for the selected one (civility, city).
class AccountSegmented<T> extends StatelessWidget {
  const AccountSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<({T value, String label})> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppPalette.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: option.value == selected,
                child: GestureDetector(
                  onTap: () => onChanged(option.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: option.value == selected
                          ? AppPalette.teal500
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(option.label,
                        style: AppTypography.labelSm.copyWith(
                            color: option.value == selected
                                ? AppPalette.white
                                : AppPalette.text2)),
                  ),
                ),
              ),
            ),
        ]),
      );
}

/// Loading skeletons, the error view with « Réessayer », or the content.
class AccountAsync<T> extends StatelessWidget {
  const AccountAsync({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => value.when(
        skipLoadingOnRefresh: true,
        data: builder,
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Column(children: [
            SoeSkeleton(height: 28, width: 200),
            SizedBox(height: 16),
            SoeSkeleton(height: 96),
            SizedBox(height: 12),
            SoeSkeleton(height: 96),
          ]),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.only(top: 24),
          child: ErrorView(failure: asFailure(error), onRetry: onRetry),
        ),
      );
}

/// A bottom sheet of the Studio (handle, Literata title, close button).
Future<T?> showAccountSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext sheetContext) builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppPalette.n300,
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTypography.h3
                                .copyWith(color: AppPalette.teal800)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: AppTypography.bodySm
                                  .copyWith(color: AppPalette.text2)),
                        ],
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: Translations.of(sheetContext).common.close,
                    style: IconButton.styleFrom(
                        backgroundColor: AppPalette.surfaceSoft),
                    icon: const Icon(Icons.close, color: AppPalette.text2),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ]),
                const SizedBox(height: 16),
                builder(sheetContext),
              ],
            ),
          ),
        ),
      ),
    );
