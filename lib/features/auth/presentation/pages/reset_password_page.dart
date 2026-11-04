import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-10, step 3 — the new password (4 rules), then signed in.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirmation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = await ref
        .read(passwordResetControllerProvider.notifier)
        .reset(_password.text, _confirmation.text);
    if (session != null && mounted)
      context.go(homeForRole(session.user.role.apiValue));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth;
    final state = ref.watch(passwordResetControllerProvider);
    if (state.verifiedToken == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouteNames.passwordForgot);
      });
      return const SizedBox.shrink();
    }
    final missing = [
      if (!PasswordRules.allMet(_password.text))
        tr.password.password.toLowerCase(),
      if (_confirmation.text.isEmpty) tr.password.confirmation.toLowerCase(),
    ];
    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
          label: tr.reset.passwordSubmit,
          onPressed: missing.isEmpty ? _submit : null,
          loading: state.busy,
          fullWidth: true,
        ),
        hint: missing.isEmpty ? null : tr.missing(fields: missing.join(', ')),
      ),
      children: [
        AuthHeading(
            title: tr.reset.passwordHeading, lead: tr.reset.passwordLead),
        AuthErrorText(failure: state.failure),
        SoePasswordField(
            controller: _password,
            label: tr.password.password,
            errorText: state.fieldError('password')),
        const SizedBox(height: 8),
        PasswordRules(password: _password.text),
        SoePasswordField(
          controller: _confirmation,
          label: tr.password.confirmation,
          errorText: state.fieldError('password_confirmation'),
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
