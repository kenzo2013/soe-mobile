import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';

/// Affichée après confirmation du code OTP de validation de compte.
/// L'utilisateur voit son compte activé, puis se connecte avec ses
/// credentials (l'API SOE ne renvoie pas de token au register — login
/// explicite requis, cf. CDC §4.1).
class EmailConfirmedPage extends ConsumerStatefulWidget {
  const EmailConfirmedPage({super.key});

  @override
  ConsumerState<EmailConfirmedPage> createState() =>
      _EmailConfirmedPageState();
}

class _EmailConfirmedPageState extends ConsumerState<EmailConfirmedPage> {
  bool _dashboardReady = false;

  @override
  void initState() {
    super.initState();
    // Petit délai pour donner du sens à l'animation "Préparation du
    // dashboard…" (cosmétique, le user peut quand même appuyer sur le
    // bouton avant la fin).
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _dashboardReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
          width: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // Cercle succès
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppPalette.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.success.withValues(alpha: 0.35),
                          offset: const Offset(0, 12),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Bienvenue sur SOE !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Votre email a été confirmé. Nous préparons votre espace parent…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Checklist
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChecklistRow(
                        label: 'Profil créé',
                        state: _RowState.done,
                      ),
                      const SizedBox(height: 14),
                      _ChecklistRow(
                        label: 'Email vérifié',
                        state: _RowState.done,
                      ),
                      const SizedBox(height: 14),
                      _ChecklistRow(
                        label: 'Préparation du dashboard',
                        state: _dashboardReady
                            ? _RowState.done
                            : _RowState.inProgress,
                        bold: !_dashboardReady,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SoeButton(
                      label: 'Se connecter',
                      icon: Icons.login,
                      fullWidth: true,
                      onPressed: () => context.go(RouteNames.login),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _RowState { done, inProgress }

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.state,
    this.bold = false,
  });
  final String label;
  final _RowState state;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _RowState.done;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppPalette.success : Colors.transparent,
            border: Border.all(
              color: isDone ? AppPalette.success : AppPalette.warning,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppPalette.warning,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
