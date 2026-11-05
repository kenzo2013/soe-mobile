import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';
import '../widgets/common_logout_sheet.dart';

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

    return AccountScaffold(
      title: tr.hub.title,
      onRefresh: () async {
        ref
          ..invalidate(currentUserProvider)
          ..invalidate(accountAddressProvider)
          ..invalidate(unreadNotificationsProvider);
      },
      children: [
        if (user != null)
          AccountCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${tutor ? tr.hub.modeTutor : tr.hub.modeParent} · ${user.email}'
                    .toUpperCase(),
                style:
                    AppTypography.overline.copyWith(color: AppPalette.teal500),
              ),
              const SizedBox(height: 6),
              Text(user.fullName,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 6),
              Text(
                [formatCameroonPhone(user.phone), place]
                    .where((part) => part.isNotEmpty)
                    .join(' · '),
                style: AppTypography.body.copyWith(color: AppPalette.text2),
              ),
              if (user.multiRole) ...[
                const SizedBox(height: 8),
                SoeButton(
                  label: tr.hub.switchSpace,
                  icon: Icons.swap_horiz,
                  variant: SoeButtonVariant.tertiary,
                  size: SoeButtonSize.sm,
                  onPressed: () => open(RouteNames.accountRoles),
                ),
              ],
            ]),
          ),
        AccountRowsCard(rows: [
          AccountRow(
            icon: Icons.person_outline,
            title: tr.hub.personal,
            subtitle: tr.hub.personalText,
            onTap: () => open(RouteNames.accountProfile),
          ),
          AccountRow(
            icon: Icons.lock_outline,
            title: tr.hub.security,
            subtitle: tr.hub.securityText,
            onTap: () => open(RouteNames.accountSecurity),
          ),
          AccountRow(
            icon: Icons.location_on_outlined,
            title: tr.hub.address,
            subtitle: neighborhood.isEmpty
                ? tr.hub.noAddress
                : tutor
                    ? tr.hub.addressTutor(neighborhood: neighborhood)
                    : tr.hub.addressParent(neighborhood: neighborhood),
            onTap: () => open(RouteNames.accountAddress),
          ),
          AccountRow(
            icon: Icons.swap_horiz,
            title: tr.hub.roles,
            subtitle: tutor ? tr.hub.rolesTutor : tr.hub.rolesParent,
            onTap: () => open(RouteNames.accountRoles),
          ),
          AccountRow(
            icon: Icons.notifications_none,
            title: tr.hub.notifications,
            subtitle: tr.hub.notificationsText,
            divider: false,
            onTap: () => open(RouteNames.accountNotificationPrefs),
          ),
        ]),
        if (spaceLinks.isNotEmpty) AccountRowsCard(rows: spaceLinks),
        AccountRowsCard(rows: [
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
            divider: false,
            onTap: () => open(RouteNames.reportNew),
          ),
        ]),
        AccountCard(
          soft: true,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.hub.signOut,
              variant: SoeButtonVariant.dangerOutline,
              size: SoeButtonSize.md,
              onPressed: () => unawaited(showLogoutSheet(context, ref)),
            ),
          ),
        ),
      ],
    );
  }
}
