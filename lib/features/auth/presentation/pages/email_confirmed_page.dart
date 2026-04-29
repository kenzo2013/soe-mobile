import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';

/// Affichée après que le user a cliqué sur le lien de confirmation email
/// (deep link `soe://auth/email-confirmed?confirmed=true`).
class EmailConfirmedPage extends ConsumerWidget {
  const EmailConfirmedPage({super.key, this.success = true});

  final bool success;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
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
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppPalette.white.withValues(alpha: .08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppPalette.white.withValues(alpha: .14),
                          width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color:
                            success ? AppPalette.success : AppPalette.danger,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (success ? AppPalette.success : AppPalette.danger)
                                    .withValues(alpha: .45),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        success ? Icons.check : Icons.close,
                        color: AppPalette.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    success
                        ? tr.emailConfirmed.title
                        : tr.emailConfirmed.errorTitle,
                    style: AppTypography.h1.copyWith(color: AppPalette.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    success
                        ? tr.emailConfirmed.subtitle
                        : tr.emailConfirmed.errorBody,
                    style: AppTypography.body.copyWith(
                      color: AppPalette.white.withValues(alpha: .78),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (success) ...[
                    const SizedBox(height: 24),
                    _StepDone(label: tr.emailConfirmed.stepProfileCreated, done: true),
                    const SizedBox(height: 8),
                    _StepDone(label: tr.emailConfirmed.stepEmailVerified, done: true),
                    const SizedBox(height: 8),
                    _StepDone(label: tr.emailConfirmed.stepDashboard, active: true),
                  ],
                  const Spacer(flex: 2),
                  SoeButton(
                    label: success
                        ? tr.emailConfirmed.primary
                        : tr.role.signIn,
                    variant: SoeButtonVariant.onBrand,
                    size: SoeButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => context.go(RouteNames.login),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepDone extends StatelessWidget {
  const _StepDone({
    required this.label,
    this.done = false,
    this.active = false,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppPalette.success
                : AppPalette.white.withValues(alpha: .08),
            border: Border.all(
              color: done
                  ? AppPalette.success
                  : active
                      ? AppPalette.yellow
                      : AppPalette.white.withValues(alpha: .3),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 12, color: AppPalette.white)
              : active
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppPalette.yellow,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: done
                ? AppPalette.white.withValues(alpha: .8)
                : AppPalette.white,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
