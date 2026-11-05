import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/lang_segmented.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../i18n/translations.g.dart';
import '../../../parent_space/presentation/parent_space_routes.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/widgets/common_logout_sheet.dart';

/// « Plus » (PAR-01 / REP-01, variant « Menu Plus »): the account, notifications, the
/// switch to the other space for a multi-role account, the language and sign-out.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).shell.more;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final role = ref.watch(currentRoleProvider);

    return Scaffold(
      backgroundColor: AppPalette.n100,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(tr.title,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 16),
            if (user != null)
              _Group(children: [
                ListTile(
                  leading:
                      SoeAvatar(name: '${user.firstName} ${user.lastName}'),
                  title: Text('${user.firstName} ${user.lastName}',
                      style: AppTypography.label),
                  subtitle: Text(role == 'tutor' ? tr.tutorRole : tr.parentRole,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.n700)),
                ),
              ]),
            _Group(children: [
              _Link(
                  icon: Icons.person_outline,
                  label: tr.account,
                  route: RouteNames.account),
              if (role == 'parent')
                _Link(
                    icon: Icons.assignment_outlined,
                    label: Translations.of(context).parentSpace.requests.title,
                    route: ParentSpaceRoutes.requests),
              _Link(
                  icon: Icons.notifications_none,
                  label: tr.notifications,
                  route: RouteNames.notifications),
              if (user?.multiRole ?? false)
                _Link(
                    icon: Icons.swap_horiz,
                    label: tr.switchRole,
                    route: RouteNames.accountRole),
            ]),
            _Group(children: [
              ListTile(
                leading: const Icon(Icons.translate, color: AppPalette.teal),
                title: Text(tr.language, style: AppTypography.label),
                trailing: const LangSegmented(),
              ),
            ]),
            _Group(children: [
              ListTile(
                leading: const Icon(Icons.logout, color: AppPalette.dangerText),
                title: Text(tr.signOut,
                    style: AppTypography.label
                        .copyWith(color: AppPalette.dangerText)),
                onTap: () => unawaited(showLogoutSheet(context, ref)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.n300),
        ),
        child: Column(children: children),
      );
}

class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppPalette.teal),
        title: Text(label, style: AppTypography.label),
        trailing: const Icon(Icons.chevron_right, color: AppPalette.n500),
        onTap: () => unawaited(context.push(route)),
      );
}
