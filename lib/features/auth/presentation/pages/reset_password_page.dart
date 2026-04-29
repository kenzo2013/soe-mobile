import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/user.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/reset_password_viewmodel.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});
  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(resetPasswordViewModelProvider);

    ref.listen<AuthState>(resetPasswordViewModelProvider, (prev, next) {
      next.whenOrNull(
        authenticated: (session) {
          SoeToast.show(
            context,
            message: tr.resetPassword.successToast,
            tone: SoeToastTone.success,
          );
          final dest = session.user.role == UserRole.tutor
              ? RouteNames.tutorDashboard
              : RouteNames.parentDashboard;
          context.go(dest);
        },
        error: (failure) => SoeToast.show(
          context,
          message: _label(failure, tr),
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SoeAppBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppPalette.n300,
                    borderRadius: AppRadius.rLg,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.lock_outline,
                      size: 28, color: AppPalette.teal),
                ),
                const SizedBox(height: 18),
                Text(tr.resetPassword.title, style: AppTypography.h1),
                const SizedBox(height: 8),
                Text(
                  tr.resetPassword.subtitle,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 22),
                SoePasswordField(
                  controller: _password,
                  label: tr.resetPassword.password,
                  hint: tr.resetPassword.passwordHint,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 6) ? tr.errors.passwordTooShort : null,
                ),
                const SizedBox(height: 12),
                SoePasswordField(
                  controller: _confirm,
                  label: tr.resetPassword.confirm,
                  hint: tr.resetPassword.confirmHint,
                  validator: (v) =>
                      v != _password.text ? tr.errors.passwordMismatch : null,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppPalette.infoBg,
                    borderRadius: AppRadius.rMd,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check,
                          size: 16, color: AppPalette.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.resetPassword.info,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.n700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SoeButton(
                  label: tr.resetPassword.submit,
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          ref.read(resetPasswordViewModelProvider.notifier).submit(
                                token: widget.token,
                                password: _password.text,
                                passwordConfirmation: _confirm.text,
                              );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(Failure f, Translations tr) => switch (f) {
        ValidationFailure(:final message) =>
          message ?? tr.errors.validation,
        UnauthorizedFailure() => tr.errors.unauthorized,
        NetworkFailure() => tr.errors.network,
        _ => tr.errors.unknown,
      };
}
