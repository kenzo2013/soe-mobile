import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/user.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

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
          final dest = session.user.role.apiValue == 'tutor'
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
                Text(
                  'Bon retour !',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour accéder à votre espace.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _password,
                  label: 'Mot de passe',
                  obscureText: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.passwordForgot),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pas encore de compte ? ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: AppPalette.secondary,
                          fontWeight: FontWeight.w600,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
