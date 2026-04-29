import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
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
    final state = ref.watch(forgotPasswordViewModelProvider);

    ref.listen<AuthState>(forgotPasswordViewModelProvider, (prev, next) {
      next.whenOrNull(
        passwordResetSent: (_) {
          SoeToast.show(
            context,
            message: 'Un email vous a été envoyé.',
            tone: SoeToastTone.success,
          );
          Navigator.of(context).maybePop();
        },
        error: (failure) => SoeToast.show(
          context,
          message: _label(failure),
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      appBar: const SoeAppBar(title: 'Mot de passe oublié'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Saisissez votre email, nous vous enverrons un lien de réinitialisation.',
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 24),
              SoeTextField(
                controller: _email,
                label: 'Email',
                hint: 'prenom@soe.com',
                leadingIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _onSubmit(),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 24),
              SoeButton(
                label: 'Envoyer',
                size: SoeButtonSize.lg,
                fullWidth: true,
                loading: isLoading,
                onPressed: isLoading ? null : _onSubmit,
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
