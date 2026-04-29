import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../widgets/auth_text_field.dart';

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
    final state = ref.watch(forgotPasswordViewModelProvider);

    ref.listen<AuthState>(forgotPasswordViewModelProvider, (prev, next) {
      next.whenOrNull(
        passwordResetSent: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Un email vous a été envoyé.')),
          );
          Navigator.of(context).maybePop();
        },
        error: (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_label(failure))),
        ),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Saisissez votre email, nous vous enverrons un lien de réinitialisation.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _onSubmit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Envoyer'),
              ),
            ],
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

  String _label(Failure f) => switch (f) {
        NetworkFailure() => 'Pas de connexion réseau.',
        ValidationFailure(:final message) => message ?? 'Email invalide.',
        _ => 'Une erreur est survenue.',
      };
}
