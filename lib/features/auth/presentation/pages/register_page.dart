import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/auth_text_field.dart';

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
      appBar: AppBar(title: const Text('Inscription')),
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
                DropdownButtonFormField<String>(
                  initialValue: _civility,
                  decoration: const InputDecoration(labelText: 'Civilité'),
                  items: const [
                    DropdownMenuItem(value: 'Mr', child: Text('Monsieur')),
                    DropdownMenuItem(value: 'Mme', child: Text('Madame')),
                  ],
                  onChanged: (v) => setState(() => _civility = v ?? 'Mr'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _firstName,
                  label: 'Prénom',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _lastName,
                  label: 'Nom',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _phone,
                  label: 'Téléphone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _password,
                  label: 'Mot de passe',
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 8) ? '8 caractères min.' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordConfirm,
                  label: 'Confirmer le mot de passe',
                  obscureText: true,
                  validator: (v) =>
                      v != _password.text ? 'Ne correspond pas' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acceptCgu,
                  onChanged: (v) => setState(() => _acceptCgu = v ?? false),
                  title: const Text('J\'accepte les CGU'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Créer mon compte'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez accepter les CGU.')),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.value, required this.onChanged});
  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.parent, label: Text('Parent')),
        ButtonSegment(value: UserRole.tutor, label: Text('Tuteur')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
