import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers.dart' show logoutUsecaseProvider;
import '../../../auth/presentation/providers/current_user_provider.dart';

/// Bottom-sheet de confirmation de déconnexion (design `CommonLogout`).
///
/// On capture le router AVANT tout `await`/`pop` (le `context` de la feuille
/// devient invalide une fois fermée). On vide les providers d'auth en RAM puis
/// on force la navigation vers `/login`, même si l'appel serveur échoue.
Future<void> showLogoutSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x80010814),
    builder: (sheetContext) => _LogoutSheet(parentRef: ref),
  );
}

class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet({required this.parentRef});
  final WidgetRef parentRef;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.n300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppPalette.dangerBg,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.logout, size: 28, color: AppPalette.danger),
            ),
            const SizedBox(height: 14),
            Text(
              tr.account.logout.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                tr.account.logout.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppPalette.n700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: tr.account.logout.cancel,
                    background: AppPalette.n100,
                    foreground: AppPalette.ink,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetButton(
                    label: tr.account.logout.confirm,
                    background: AppPalette.danger,
                    foreground: Colors.white,
                    onTap: () =>
                        _logout(context, tr.account.logout.serverFailure),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext sheetContext, String failureMessage) async {
    final router = GoRouter.of(sheetContext);
    final rootNavigator = Navigator.of(sheetContext, rootNavigator: true);

    final result = await parentRef.read(logoutUsecaseProvider).call();

    parentRef.read(authTokenProvider.notifier).state = null;
    parentRef.read(currentRoleProvider.notifier).state = null;
    parentRef.invalidate(currentUserProvider);

    if (rootNavigator.canPop()) rootNavigator.pop(); // ferme la feuille
    router.go(RouteNames.login);

    if (result.isErr && rootNavigator.context.mounted) {
      SoeToast.show(
        rootNavigator.context,
        message: failureMessage,
        tone: SoeToastTone.warning,
      );
    }
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
