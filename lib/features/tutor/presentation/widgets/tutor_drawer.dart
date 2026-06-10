import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../auth/presentation/providers.dart' show logoutUsecaseProvider;
import '../../../auth/presentation/providers/current_user_provider.dart';

/// Drawer latéral du flux tuteur (menu burger). Reprend le pattern du
/// `ParentDrawer` avec les 8 sections tuteur.
class TutorDrawer extends ConsumerWidget {
  const TutorDrawer({super.key, required this.activeRoute});

  final String activeRoute;

  static const _items = <_DrawerItem>[
    _DrawerItem(
      route: RouteNames.tutorDashboard,
      icon: Icons.home_outlined,
      label: 'Tableau de bord',
    ),
    _DrawerItem(
      route: RouteNames.tutorProfile,
      icon: Icons.person_outline,
      label: 'Mon profil',
    ),
    _DrawerItem(
      route: RouteNames.tutorJobs,
      icon: Icons.work_outline,
      label: "Offres d'emploi",
    ),
    _DrawerItem(
      route: RouteNames.tutorCourses,
      icon: Icons.menu_book_outlined,
      label: 'Mes cours',
    ),
    _DrawerItem(
      route: RouteNames.tutorSessions,
      icon: Icons.calendar_month_outlined,
      label: 'Séances',
    ),
    _DrawerItem(
      route: RouteNames.tutorRemunerations,
      icon: Icons.payments_outlined,
      label: 'Rémunérations',
    ),
    _DrawerItem(
      route: RouteNames.tutorPayment,
      icon: Icons.credit_card_outlined,
      label: 'Infos de paiement',
    ),
    _DrawerItem(
      route: RouteNames.tutorContracts,
      icon: Icons.article_outlined,
      label: 'Contrats',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final name =
        user == null ? '' : '${user.firstName} ${user.lastName}'.trim();
    return Drawer(
      width: 296,
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SoeBrandLogo(
                    width: 96,
                    onDark: true,
                    variant: SoeBrandLogoVariant.full,
                  ),
                ),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    SoeAvatar(
                      name: name.isEmpty ? 'Paul Mbarga' : name,
                      imageUrl: user?.photoUrl,
                      size: SoeAvatarSize.list,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Paul Mbarga' : name,
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
                            'Tuteur · ${user?.email ?? 'Doctorant'}',
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
              _divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final it = _items[i];
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
              _divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _secondary(
                      icon: Icons.settings_outlined,
                      label: 'Mon compte',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.account);
                      },
                    ),
                    const SizedBox(height: 8),
                    _secondary(
                      icon: Icons.logout,
                      label: 'Déconnexion',
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

  Widget _divider() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.08));

  Widget _secondary({
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

  /// On capture le router AVANT tout `pop()` / `await` (le `context` du drawer
  /// devient invalide une fois fermé). On vide les providers d'auth en RAM
  /// (sinon l'AuthGuard relit `authTokenProvider` = encore `true` et renvoie
  /// /login → /tutor), PUIS on ferme le drawer via le root navigator, PUIS on
  /// force la nav vers /login (même si l'appel serveur a échoué).
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    final result = await ref.read(logoutUsecaseProvider).call();

    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentRoleProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);

    if (rootNavigator.canPop()) rootNavigator.pop();
    router.go(RouteNames.login);

    if (result.isErr && rootNavigator.context.mounted) {
      SoeToast.show(
        rootNavigator.context,
        message: 'Déconnecté (échec serveur)',
        tone: SoeToastTone.warning,
      );
    }
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
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
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
