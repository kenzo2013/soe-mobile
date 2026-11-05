import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';
import '../widgets/common_logout_sheet.dart';
import '../widgets/tab_top_bar.dart';

/// « +237 6 77 45 21 09 » from the 9 stored digits (any spelling with 237); else as stored.
String formatCameroonPhone(String? phone) {
  final raw = phone ?? '';
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('237')) digits = digits.substring(3);
  if (!RegExp(r'^[26]\d{8}$').hasMatch(digits)) return raw;
  final pairs = [
    for (var i = 1; i < digits.length; i += 2) digits.substring(i, i + 2)
  ];
  return '+237 ${digits[0]} ${pairs.join(' ')}';
}

/// COM-01 opened on its own (`/account`), over the tabs.
class AccountHubPage extends StatelessWidget {
  const AccountHubPage({super.key});

  @override
  Widget build(BuildContext context) => const AccountHubView();
}

/// COM-01 — Mon compte: the account card (mode, e-mail, name, phone, place), the account pages,
/// the links of the active space, help and report, sign-out and the language. Also the « Plus »
/// tab of both spaces.
class AccountHubView extends ConsumerWidget {
  const AccountHubView({super.key, this.spaceLinks = const []});

  /// The rows of the active space (requests, contracts…), shown in their own card.
  final List<Widget> spaceLinks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    final address = ref.watch(accountAddressProvider).valueOrNull;
    final place = address?.place ?? '';
    final neighborhood = address?.neighborhood ?? '';

    void open(String route) => unawaited(context.push(route));

    final initials = user == null
        ? ''
        : [user.firstName, user.lastName]
            .where((part) => part.isNotEmpty)
            .map((part) => part.characters.first.toUpperCase())
            .join();
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(tr.hub.title,
              style: AppTypography.labelSm
                  .copyWith(color: AppPalette.navInactive)),
        ),
        const SizedBox(height: 10),
        if (user != null)
          Row(children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppPalette.gold400, shape: BoxShape.circle),
              child: Text(initials,
                  style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.w600, color: AppPalette.ink900)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tutor ? tr.hub.modeTutor : tr.hub.modeParent} · ${user.email}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.overline
                          .copyWith(fontSize: 11, color: AppPalette.gold100),
                    ),
                    const SizedBox(height: 2),
                    Text(user.fullName,
                        style: AppTypography.h2
                            .copyWith(fontSize: 26, color: AppPalette.white)),
                    Text(
                      [formatCameroonPhone(user.phone), place]
                          .where((part) => part.isNotEmpty)
                          .join(' · '),
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.navInactive),
                    ),
                  ]),
            ),
          ]),
      ],
    );

    final tiles = [
      (
        Icons.person_outline,
        tr.hub.personal,
        tr.hub.personalText,
        AppPalette.teal500,
        AppPalette.white,
        RouteNames.accountProfile
      ),
      (
        Icons.lock_outline,
        tr.hub.security,
        tr.hub.securityText,
        AppPalette.success,
        AppPalette.white,
        RouteNames.accountSecurity
      ),
      (
        Icons.location_on_outlined,
        tr.hub.address,
        neighborhood.isEmpty
            ? tr.hub.noAddress
            : tutor
                ? tr.hub.addressTutor(neighborhood: neighborhood)
                : tr.hub.addressParent(neighborhood: neighborhood),
        AppPalette.gold400,
        AppPalette.ink900,
        RouteNames.accountAddress
      ),
      (
        Icons.notifications_none,
        tr.hub.notifications,
        tr.hub.notificationsText,
        AppPalette.orange,
        AppPalette.white,
        RouteNames.accountNotificationPrefs
      ),
    ];

    return SpaceTabView(
      band: SpaceBand(
          title: tr.hub.title, heading: heading, color: AppPalette.navy),
      onRefresh: () async {
        ref
          ..invalidate(currentUserProvider)
          ..invalidate(accountAddressProvider)
          ..invalidate(unreadNotificationsProvider);
      },
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 640 ? 4 : 2;
          final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            for (final (i, (icon, title, text, tile, ink, route))
                in tiles.indexed)
              SizedBox(
                width: width,
                child: SoeCard(
                  raised: i < columns,
                  padding: const EdgeInsets.all(14),
                  onTap: () => open(route),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: tile,
                              borderRadius: BorderRadius.circular(14)),
                          child: Icon(icon, size: 20, color: ink),
                        ),
                        const SizedBox(height: 10),
                        Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                                fontSize: 15, color: AppPalette.text)),
                        const SizedBox(height: 2),
                        Text(text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      ]),
                ),
              ),
          ]);
        }),
        const SizedBox(height: 14),
        if (spaceLinks.isNotEmpty) AccountRowsCard(rows: spaceLinks),
        AccountRowsCard(rows: [
          if (user?.multiRole ?? false)
            AccountRow(
              icon: Icons.swap_horiz,
              title: tr.hub.switchSpace,
              onTap: () => open(RouteNames.accountRoles),
            ),
          AccountRow(
            icon: Icons.badge_outlined,
            title: tr.hub.roles,
            subtitle: tutor ? tr.hub.rolesTutor : tr.hub.rolesParent,
            onTap: () => open(RouteNames.accountRoles),
          ),
          AccountRow(
            icon: Icons.chat_bubble_outline,
            title: tr.hub.help,
            subtitle: tr.hub.helpText,
            onTap: () => open(RouteNames.help),
          ),
          AccountRow(
            icon: Icons.outlined_flag,
            title: tr.hub.report,
            subtitle: tr.hub.reportText,
            iconBackground: AppPalette.warningBg,
            iconColor: AppPalette.warningText,
            divider: false,
            onTap: () => open(RouteNames.reportNew),
          ),
        ]),
        SoeButton(
          label: tr.hub.signOut,
          variant: SoeButtonVariant.danger,
          fullWidth: true,
          onPressed: () => unawaited(showLogoutSheet(context, ref)),
        ),
      ],
    );
  }
}
