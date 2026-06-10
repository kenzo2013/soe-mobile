import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers.dart' show logoutUsecaseProvider;
import '../../../auth/presentation/providers/current_user_provider.dart';

class ParentDrawer extends ConsumerWidget {
  const ParentDrawer({
    super.key,
    required this.activeRoute,
  });

  final String activeRoute;

  static List<_DrawerItem> _itemsOf(Translations tr) => <_DrawerItem>[
        _DrawerItem(
          route: RouteNames.parentDashboard,
          icon: Icons.home_outlined,
          label: tr.parent.drawer.home,
        ),
        _DrawerItem(
          route: RouteNames.parentStudents,
          icon: Icons.groups_outlined,
          label: tr.parent.drawer.children,
        ),
        _DrawerItem(
          route: RouteNames.parentReservations,
          icon: Icons.description_outlined,
          label: tr.parent.drawer.reservations,
        ),
        _DrawerItem(
          route: RouteNames.parentSessions,
          icon: Icons.calendar_month_outlined,
          label: tr.parent.drawer.sessions,
        ),
        _DrawerItem(
          route: RouteNames.parentPayments,
          icon: Icons.credit_card_outlined,
          label: tr.parent.drawer.payments,
        ),
        _DrawerItem(
          route: '/parent/reviews',
          icon: Icons.star_outline,
          label: tr.parent.drawer.reviews,
        ),
        _DrawerItem(
          route: '/parent/programs',
          icon: Icons.menu_book_outlined,
          label: tr.parent.drawer.programs,
        ),
        _DrawerItem(
          route: '/parent/invitations',
          icon: Icons.mail_outline,
          label: tr.parent.drawer.invitations,
        ),
        _DrawerItem(
          route: '/parent/contracts',
          icon: Icons.article_outlined,
          label: tr.parent.drawer.contracts,
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final items = _itemsOf(tr);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final name = user == null ? '' : '${user.firstName} ${user.lastName}'.trim();
    final roleLine = user == null
        ? tr.parent.drawer.notConnected
        : (user.role.name == "parent"
            ? tr.parent.drawer.parentAccount
            : tr.parent.drawer.tutorAccount);
    return Drawer(
      width: 296,
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const SoeBrandLogo(
                    width: 96,
                    onDark: true,
                    variant: SoeBrandLogoVariant.full,
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    SoeAvatar(
                      name: name.isEmpty ? '?' : name,
                      imageUrl: user?.photoUrl,
                      size: SoeAvatarSize.list,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? '—' : name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? roleLine,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final active = it.route == activeRoute;
                    return _DrawerRow(
                      item: it,
                      active: active,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (!active) context.go(it.route);
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _drawerSecondary(
                      icon: Icons.settings_outlined,
                      label: tr.parent.drawer.account,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.account);
                      },
                    ),
                    const SizedBox(height: 8),
                    _drawerSecondary(
                      icon: Icons.logout,
                      label: tr.parent.drawer.logout,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerSecondary({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modale de confirmation déconnexion + appel Logout usecase.
  ///
  /// On capture le router avant tout `pop()` / `await`, car le `context`
  /// du drawer devient invalide dès que le drawer est fermé — sinon
  /// `context.go(login)` ne s'exécute jamais.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final tr = Translations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _LogoutConfirmDialog(),
    );
    if (confirmed != true) return;

    final result = await ref.read(logoutUsecaseProvider).call();

    // Clear les Riverpod StateProviders qui mémorisent l'auth en RAM —
    // sinon AuthGuard.isAuthenticated() retourne encore true (il lit
    // authTokenProvider, pas le storage) et redirige /login → /parent
    // immédiatement après le router.go(login).
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentRoleProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);

    // Ferme le drawer si encore ouvert.
    if (rootNavigator.canPop()) rootNavigator.pop();

    // On force la nav même en cas d'échec serveur (le storage local est
    // déjà nettoyé par AuthRepositoryImpl.logout()).
    router.go(RouteNames.login);

    if (result is Err && rootNavigator.context.mounted) {
      SoeToast.show(
        rootNavigator.context,
        message: tr.parent.drawer.logoutServerError,
        tone: SoeToastTone.warning,
      );
    }
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Dialog(
      backgroundColor: AppPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icone hero
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppPalette.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 30,
                color: AppPalette.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr.parent.drawer.logoutConfirmTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr.parent.drawer.logoutConfirmBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppPalette.n700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.ink,
                      side: const BorderSide(color: AppPalette.n300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      tr.common.cancel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      tr.parent.drawer.logoutConfirm,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.route,
    required this.icon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final String label;
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _DrawerItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Stack(
        children: [
          Material(
            color: active
                ? AppPalette.yellow.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: active ? AppPalette.yellow : Colors.white,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (active)
            Positioned(
              left: 0,
              top: 8,
              bottom: 8,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppPalette.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
