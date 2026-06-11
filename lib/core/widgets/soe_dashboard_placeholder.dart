import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers.dart';
import '../providers/core_providers.dart';
import '../routing/route_names.dart';
import '../storage/storage_keys.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../../i18n/translations.g.dart';
import 'soe_brand_logo.dart';
import 'soe_button.dart';
import 'soe_toast.dart';

/// Page placeholder pour les dashboards parent / tuteur en attendant
/// l'implémentation des vraies vues. Affiche un message clair, un encart
/// sur le rôle courant et un bouton de déconnexion fonctionnel.
class SoeDashboardPlaceholder extends ConsumerWidget {
  const SoeDashboardPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.roleLabel,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String roleLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SoeBrandLogo(width: 96),
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppPalette.infoBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: AppPalette.teal),
              ),
              const SizedBox(height: 24),
              Text(title, style: AppTypography.h1, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppPalette.successBg,
                  borderRadius: AppRadius.rPill,
                ),
                child: Text(
                  roleLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: AppPalette.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              SoeButton(
                label: tr.dashboardPlaceholder.logout,
                icon: Icons.logout,
                variant: SoeButtonVariant.secondary,
                size: SoeButtonSize.lg,
                fullWidth: true,
                onPressed: () => _logout(context, ref, tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
    Translations tr,
  ) async {
    await ref.read(logoutUsecaseProvider).call();
    final storage = ref.read(secureStorageProvider);
    await storage.delete(StorageKeys.authToken);
    await storage.delete(StorageKeys.currentRole);
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentRoleProvider.notifier).state = null;
    if (!context.mounted) return;
    SoeToast.show(
      context,
      message: tr.dashboardPlaceholder.loggedOut,
      tone: SoeToastTone.success,
    );
    context.go(RouteNames.login);
  }
}
