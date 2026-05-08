import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/lang_pill.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/user.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(loginViewModelProvider);

    ref.listen<AuthState>(loginViewModelProvider, (prev, next) {
      next.whenOrNull(
        authenticated: (session) {
          final dest = session.user.role == UserRole.tutor
              ? RouteNames.tutorDashboard
              : RouteNames.parentDashboard;
          context.go(dest);
        },
        error: (failure) => _showError(context, failure, tr),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppPalette.teal,
        body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [LangPill(dark: true)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SoeBrandLogo(width: 150, onDark: true),
                  const SizedBox(height: 14),
                  Text(
                    tr.login.welcome,
                    style: AppTypography.h2
                        .copyWith(color: AppPalette.white, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: AppRadius.rXxl,
                      boxShadow: AppShadows.lg,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            tr.login.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.h3
                                .copyWith(color: AppPalette.teal),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr.login.subtitleGeneric,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm
                                .copyWith(color: AppPalette.n700),
                          ),
                          const SizedBox(height: 18),
                          SoeTextField(
                            controller: _email,
                            label: tr.login.email,
                            hint: tr.login.emailHint,
                            leadingIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? tr.errors.emailInvalid
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          SoePasswordField(
                            controller: _password,
                            label: tr.login.password,
                            hint: tr.login.passwordHint,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onSubmit(),
                            validator: (v) => (v == null || v.isEmpty)
                                ? tr.errors.required
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SoeButton(
                              label: tr.login.forgotPassword,
                              variant: SoeButtonVariant.link,
                              size: SoeButtonSize.sm,
                              onPressed: () =>
                                  context.push(RouteNames.passwordForgot),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SoeButton(
                            label: isLoading
                                ? tr.login.loading
                                : tr.login.submit,
                            size: SoeButtonSize.lg,
                            fullWidth: true,
                            loading: isLoading,
                            onPressed: isLoading ? null : _onSubmit,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppPalette.n300),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  tr.common.or,
                                  style: AppTypography.caption
                                      .copyWith(color: AppPalette.n500),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppPalette.n300),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                '${tr.login.noAccount} ',
                                style: AppTypography.bodySm
                                    .copyWith(color: AppPalette.n700),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go(RouteNames.roleChoice),
                                child: Text(
                                  tr.login.signUp,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppPalette.teal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr.common.copyright,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.white.withValues(alpha: .7)),
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
    ref.read(loginViewModelProvider.notifier).submit(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  void _showError(BuildContext context, Failure f, Translations tr) {
    final msg = switch (f) {
      EmailNotConfirmedFailure() => tr.errors.emailNotConfirmed,
      InvalidCredentialsFailure() ||
      UnauthorizedFailure() =>
        tr.errors.invalidCredentials,
      NetworkFailure() => tr.errors.network,
      ValidationFailure() => tr.errors.validation,
      _ => tr.errors.unknown,
    };
    SoeToast.show(context, message: msg, tone: SoeToastTone.danger);
  }
}
