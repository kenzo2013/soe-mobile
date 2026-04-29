import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

enum SoeToastTone { success, warning, danger, info }

/// Toast SOE — fond ink, badge rond coloré, texte blanc.
///
/// Usage : `SoeToast.show(context, message: '...', tone: SoeToastTone.success);`
abstract final class SoeToast {
  static void show(
    BuildContext context, {
    required String message,
    SoeToastTone tone = SoeToastTone.success,
    Duration? duration,
  }) {
    final tone0 = _spec(tone);
    // Erreurs / avertissements : 6 s (l'utilisateur doit lire le détail).
    // Succès / info : 3 s.
    final fallbackDuration =
        (tone == SoeToastTone.danger || tone == SoeToastTone.warning)
            ? const Duration(seconds: 6)
            : const Duration(seconds: 3);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration ?? fallbackDuration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: _ToastBody(
              icon: tone0.icon, color: tone0.color, message: message),
        ),
      );
  }

  static _ToastSpec _spec(SoeToastTone t) => switch (t) {
        SoeToastTone.success => const _ToastSpec(
            color: AppPalette.success,
            icon: Icons.check,
          ),
        SoeToastTone.warning => const _ToastSpec(
            color: AppPalette.warning,
            icon: Icons.access_time,
          ),
        SoeToastTone.danger => const _ToastSpec(
            color: AppPalette.danger,
            icon: Icons.close,
          ),
        SoeToastTone.info => const _ToastSpec(
            color: AppPalette.teal,
            icon: Icons.info_outline,
          ),
      };
}

class _ToastSpec {
  const _ToastSpec({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}

class _ToastBody extends StatelessWidget {
  const _ToastBody({
    required this.icon,
    required this.color,
    required this.message,
  });
  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppPalette.ink,
        borderRadius: AppRadius.rMd,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: AppPalette.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppPalette.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
