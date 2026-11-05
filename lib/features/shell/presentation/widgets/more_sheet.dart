import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../../../common/presentation/widgets/common_logout_sheet.dart';
import '../../../common/presentation/widgets/more_entry.dart';
import '../../../parent_space/presentation/widgets/parent_more_links.dart';
import '../../../tutor_space/presentation/widgets/tutor_more_links.dart';

/// « Plus » on a phone (PAR-01 and REP-01, variant « Menu Plus »): a sheet over the open tab
/// with the entries of the space, the account, the other space and the sign-out.
Future<void> showMoreSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppPalette.white,
      barrierColor: const Color(0x8001202F),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (sheetContext) =>
          _MoreSheet(outerContext: context, outerRef: ref),
    );

class _MoreSheet extends ConsumerWidget {
  const _MoreSheet({required this.outerContext, required this.outerRef});

  /// The tab under the sheet: it navigates once the sheet is closed.
  final BuildContext outerContext;
  final WidgetRef outerRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    final entries = tutor
        ? tutorMoreEntries(context, ref)
        : parentMoreEntries(context, ref);

    void open(String route) {
      Navigator.of(context).pop();
      unawaited(outerContext.push(route));
    }

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppPalette.teal100,
                  borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Text(tr.shell.more.tab,
                    style:
                        AppTypography.h2.copyWith(color: AppPalette.teal800)),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                style: IconButton.styleFrom(
                    backgroundColor: AppPalette.surfaceSoft),
                icon: const Icon(Icons.close, color: AppPalette.teal800),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
            const SizedBox(height: 8),
            for (final (i, entry) in entries.indexed)
              _MoreRow(entry: entry, tint: i, onTap: () => open(entry.route)),
            _MoreRow(
              entry: (
                icon: Icons.person_outline,
                label: tr.shell.more.account,
                hint: null,
                route: RouteNames.account
              ),
              tint: entries.length,
              onTap: () => open(RouteNames.account),
            ),
            _MoreRow(
              entry: (
                icon: Icons.swap_horiz,
                label: tutor ? tr.shell.more.toParent : tr.shell.more.toTutor,
                hint: tr.shell.more.sameAccount,
                route: RouteNames.accountRoles
              ),
              tint: entries.length + 1,
              onTap: () => open(RouteNames.accountRoles),
            ),
            _MoreRow(
              entry: (
                icon: Icons.logout,
                label: tr.accountSpace.hub.signOut,
                hint: null,
                route: ''
              ),
              danger: true,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(showLogoutSheet(outerContext, outerRef));
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow(
      {required this.entry,
      required this.onTap,
      this.danger = false,
      this.tint = 0});

  final MoreEntry entry;
  final VoidCallback onTap;
  final bool danger;

  /// The row's place: the icon tiles go round the colours of the direction.
  final int tint;

  static const _tints = [
    (AppPalette.teal50, AppPalette.teal500),
    (AppPalette.successBg, AppPalette.successText),
    (AppPalette.gold50, AppPalette.gold700),
    (AppPalette.warningBg, AppPalette.warningText),
  ];

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppPalette.dangerText : AppPalette.text;
    final tile = danger
        ? (AppPalette.dangerBg, AppPalette.dangerText)
        : _tints[tint % _tints.length];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppPalette.teal50))),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: tile.$1, borderRadius: BorderRadius.circular(14)),
            child: Icon(entry.icon, size: 20, color: tile.$2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.label,
                  style:
                      AppTypography.label.copyWith(fontSize: 15, color: color)),
              if (entry.hint != null)
                Text(entry.hint!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppPalette.ink400),
        ]),
      ),
    );
  }
}
