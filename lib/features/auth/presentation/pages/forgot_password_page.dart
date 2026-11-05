import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-10, step 1 — the e-mail or phone of the account. Same answer whether it exists or not.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _login = TextEditingController();

  @override
  void dispose() {
    _login.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (await ref
            .read(passwordResetControllerProvider.notifier)
            .request(_login.text.trim()) &&
        mounted) {
      unawaited(context.push(RouteNames.passwordForgotSent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth;
    final state = ref.watch(passwordResetControllerProvider);
    final ready = _login.text.trim().isNotEmpty;
    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
            label: tr.reset.submit,
            onPressed: ready ? _submit : null,
            loading: state.busy,
            fullWidth: true),
        hint: ready ? null : tr.reset.missing,
      ),
      children: [
        AuthHeading(title: tr.reset.heading, lead: tr.reset.lead),
        AuthErrorText(failure: state.failure),
        SoeTextField(
          controller: _login,
          label: tr.signIn.login,
          hint: tr.signIn.loginHint,
          leadingIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: state.fieldError('login'),
          onChanged: (_) => setState(() {}),
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
