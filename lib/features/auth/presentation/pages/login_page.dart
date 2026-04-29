import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
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
    final state = ref.watch(loginViewModelProvider);

    ref.listen<AuthState>(loginViewModelProvider, (prev, next) {
      next.whenOrNull(
        authenticated: (session) {
          final dest = session.user.role == UserRole.tutor
              ? RouteNames.tutorDashboard
              : RouteNames.parentDashboard;
          context.go(dest);
        },
        error: (failure) => _showError(context, failure),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text('Bon retour !', style: AppTypography.h1),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour accéder à votre espace.',
                  style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 32),
                SoeTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'prenom@soe.com',
                  leadingIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                SoePasswordField(
                  controller: _password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSubmit(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SoeButton(
                    label: 'Mot de passe oublié ?',
                    variant: SoeButtonVariant.link,
                    size: SoeButtonSize.sm,
                    onPressed: () => context.push(RouteNames.passwordForgot),
                  ),
                ),
                const SizedBox(height: 8),
                SoeButton(
                  label: 'Se connecter',
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _onSubmit,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style:
                          AppTypography.bodySm.copyWith(color: AppPalette.n700),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        "S'inscrire",
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

  void _showError(BuildContext context, Failure f) {
    final msg = switch (f) {
      UnauthorizedFailure() => 'Email ou mot de passe incorrect.',
      NetworkFailure() => 'Pas de connexion réseau.',
      ValidationFailure(:final message) =>
        message ?? 'Certains champs sont invalides.',
      _ => 'Une erreur est survenue, réessayez.',
    };
    SoeToast.show(context, message: msg, tone: SoeToastTone.danger);
  }
}
