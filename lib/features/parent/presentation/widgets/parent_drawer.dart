import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';

class ParentDrawer extends ConsumerWidget {
  const ParentDrawer({
    super.key,
    required this.activeRoute,
  });

  final String activeRoute;

  static const _items = <_DrawerItem>[
    _DrawerItem(
      route: RouteNames.parentDashboard,
      icon: Icons.home_outlined,
      label: 'Accueil',
    ),
    _DrawerItem(
      route: RouteNames.parentStudents,
      icon: Icons.groups_outlined,
      label: 'Mes enfants',
    ),
    _DrawerItem(
      route: RouteNames.parentReservations,
      icon: Icons.description_outlined,
      label: 'Réservations',
    ),
    _DrawerItem(
      route: RouteNames.parentSessions,
      icon: Icons.calendar_month_outlined,
      label: 'Séances',
    ),
    _DrawerItem(
      route: RouteNames.parentPayments,
      icon: Icons.credit_card_outlined,
      label: 'Paiements',
    ),
    _DrawerItem(
      route: '/parent/reviews',
      icon: Icons.star_outline,
      label: 'Avis',
    ),
    _DrawerItem(
      route: '/parent/programs',
      icon: Icons.menu_book_outlined,
      label: 'Programmes',
    ),
    _DrawerItem(
      route: '/parent/invitations',
      icon: Icons.mail_outline,
      label: 'Invitations',
    ),
    _DrawerItem(
      route: '/parent/contracts',
      icon: Icons.article_outlined,
      label: 'Contrats',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final name = user == null ? '' : '${user.firstName} ${user.lastName}'.trim();
    final roleLine = user == null
        ? 'Non connecté'
        : 'Compte ${user.role.name == "parent" ? "parent" : "tuteur"}';
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
                      label: 'Paramètres',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _drawerSecondary(
                      icon: Icons.logout,
                      label: 'Déconnexion',
                      onTap: () {},
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
