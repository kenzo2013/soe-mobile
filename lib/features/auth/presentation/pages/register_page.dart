import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  UserRole _role = UserRole.parent;
  String _civility = 'Mr';
  bool _acceptCgu = false;

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _password,
      _passwordConfirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);

    ref.listen<AuthState>(registerViewModelProvider, (prev, next) {
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
      appBar: const SoeAppBar(title: 'Inscription'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RoleSelector(
                  value: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Civilité',
                    style: AppTypography.label.copyWith(
                      color: AppPalette.n700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _civility,
                  items: const [
                    DropdownMenuItem(value: 'Mr', child: Text('Monsieur')),
                    DropdownMenuItem(value: 'Mme', child: Text('Madame')),
                  ],
                  onChanged: (v) => setState(() => _civility = v ?? 'Mr'),
                ),
                const SizedBox(height: 16),
                SoeTextField(
                  controller: _firstName,
                  label: 'Prénom',
                  leadingIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                SoeTextField(
                  controller: _lastName,
                  label: 'Nom',
                  leadingIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                SoeTextField(
                  controller: _email,
                  label: 'Email',
                  leadingIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                SoeTextField(
                  controller: _phone,
                  label: 'Téléphone',
                  leadingIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                SoePasswordField(
                  controller: _password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                SoePasswordField(
                  controller: _passwordConfirm,
                  label: 'Confirmer le mot de passe',
                  hint: 'Identique au mot de passe',
                  validator: (v) =>
                      v != _password.text ? 'Ne correspond pas' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acceptCgu,
                  onChanged: (v) => setState(() => _acceptCgu = v ?? false),
                  activeColor: AppPalette.teal,
                  title: const Text("J'accepte les CGU"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                SoeButton(
                  label: 'Créer mon compte',
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _onSubmit,
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
    if (!_acceptCgu) {
      SoeToast.show(
        context,
        message: 'Vous devez accepter les CGU.',
        tone: SoeToastTone.warning,
      );
      return;
    }
    ref.read(registerViewModelProvider.notifier).submit(
          RegisterParams(
            email: _email.text.trim(),
            password: _password.text,
            passwordConfirmation: _passwordConfirm.text,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            role: _role,
            acceptCgu: _acceptCgu,
            civility: _civility,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          ),
        );
  }

  void _showError(BuildContext context, Failure f) {
    final msg = switch (f) {
      ConflictFailure(:final message) =>
        message ?? 'Cet email est déjà utilisé.',
      ValidationFailure(:final message) => message ?? 'Vérifiez les champs.',
      NetworkFailure() => 'Pas de connexion réseau.',
      _ => 'Une erreur est survenue.',
    };
    SoeToast.show(context, message: msg, tone: SoeToastTone.danger);
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.value, required this.onChanged});
  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppPalette.teal,
        selectedForegroundColor: AppPalette.white,
      ),
      segments: const [
        ButtonSegment(value: UserRole.parent, label: Text('Parent')),
        ButtonSegment(value: UserRole.tutor, label: Text('Tuteur')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
