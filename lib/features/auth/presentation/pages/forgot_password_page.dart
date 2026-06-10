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
import '../viewmodels/auth_state.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(forgotPasswordViewModelProvider);

    ref.listen<AuthState>(forgotPasswordViewModelProvider, (prev, next) {
      next.whenOrNull(
        passwordResetSent: (email) {
          context.go(
            '${RouteNames.passwordForgotSent}?email=${Uri.encodeComponent(email)}',
          );
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                  ],
                ),
                const SizedBox(height: 18),
                Text(tr.forgotPassword.title, style: AppTypography.h1),
                const SizedBox(height: 8),
                Text(
                  tr.forgotPassword.subtitle,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 24),
                SoeTextField(
                  controller: _email,
                  label: tr.forgotPassword.email,
                  hint: tr.forgotPassword.emailHint,
                  leadingIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSubmit(),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? tr.errors.emailInvalid
                      : null,
                ),
                const SizedBox(height: 22),
                SoeButton(
                  label: tr.forgotPassword.submit,
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _onSubmit,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    children: [
                      Text(
                        '${tr.forgotPassword.back} ',
                        style: AppTypography.bodySm
                            .copyWith(color: AppPalette.n700),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.login),
                        child: Text(
                          tr.forgotPassword.backLink,
                          style: AppTypography.bodySm.copyWith(
                            color: AppPalette.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(forgotPasswordViewModelProvider.notifier)
        .submit(email: _email.text.trim());
  }

  String _label(Failure f, Translations tr) => switch (f) {
        NetworkFailure() => tr.errors.network,
        ValidationFailure(:final message) =>
          message ?? tr.errors.emailInvalid,
        NotFoundFailure() => tr.errors.notFound,
        _ => tr.errors.unknown,
      };
}
