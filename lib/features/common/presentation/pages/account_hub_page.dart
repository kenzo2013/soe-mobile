import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../providers.dart';
import '../widgets/common_logout_sheet.dart';
import '../widgets/common_top_bar.dart';

/// 1 · Mon compte — hub (design `CommonAccountHub`). Entête dégradé + 5 tuiles
/// de navigation + CTA déconnexion.
class AccountHubPage extends ConsumerWidget {
  const AccountHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final user = ref.watch(currentUserProvider).asData?.value;
    final role = ref.watch(currentRoleProvider) ?? user?.role.apiValue;
    final addressSub = ref.watch(accountAddressProvider).maybeWhen(
          data: (a) => a.shortLabel,
          orElse: () => tr.account.hub.addressFallback,
        );
    final prefsSub = ref.watch(notificationPreferencesProvider).maybeWhen(
          data: (p) => tr.account.hub.prefsChannels(count: p.activeChannels),
          orElse: () => tr.account.hub.prefsFallback,
        );

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.account.hub.title,
        subtitle: tr.account.hub.subtitle,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(user: user),
          const SizedBox(height: 14),
          _HubTile(
            icon: Icons.person_outline,
            label: tr.account.hub.personalInfoLabel,
            sub: tr.account.hub.personalInfoSub,
            onTap: () => context.push(RouteNames.accountProfile),
          ),
          _HubTile(
            icon: Icons.lock_outline,
            label: tr.account.hub.passwordLabel,
            sub: '••••••••',
            onTap: () => context.push(RouteNames.accountPassword),
          ),
          _HubTile(
            icon: Icons.public,
            label: tr.account.hub.addressLabel,
            sub: addressSub,
            onTap: () => context.push(RouteNames.accountAddress),
          ),
          _HubTile(
            icon: Icons.group_outlined,
            label: tr.account.hub.roleLabel,
            sub: _roleLabel(tr, role),
            badge: _roleLabel(tr, role),
            onTap: () => context.push(RouteNames.accountRole),
          ),
          _HubTile(
            icon: Icons.notifications_outlined,
            label: tr.account.hub.prefsLabel,
            sub: prefsSub,
            onTap: () => context.push(RouteNames.accountNotificationPrefs),
          ),
          const SizedBox(height: 16),
          _LogoutTile(
            label: tr.account.hub.logout,
            onTap: () => showLogoutSheet(context, ref),
          ),
        ],
      ),
    );
  }

  static String _roleLabel(Translations tr, String? role) => switch (role) {
        'tutor' => tr.account.role.tutorBadge,
        'parent' => tr.account.role.parentBadge,
        _ => tr.account.role.parentBadge,
      };
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final name = user == null ? '' : user!.fullName.trim();
    final civility = user?.civility;
    final title = [civility, name]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .trim();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppPalette.brandGradient,
        border: Border.all(color: AppPalette.n300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          SoeAvatar(
            name: name.isEmpty ? '?' : name,
            imageUrl: user?.photoUrl,
            size: SoeAvatarSize.list,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? tr.account.hub.myProfile : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.phone!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.n300),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppPalette.n100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppPalette.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppPalette.n500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.dangerBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: AppPalette.danger),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
