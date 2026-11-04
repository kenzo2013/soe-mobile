import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/auth_flow.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-09 — sign-in with the e-mail or the phone. An unverified account goes to the code.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The button and its hint follow both fields (the password field has no onChanged).
    _login.addListener(_refresh);
    _password.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _ready => _login.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_ready) return;
    final outcome = await ref
        .read(signInControllerProvider.notifier)
        .submit(_login.text.trim(), _password.text);
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case SignedIn(:final session):
        context.go(homeForRole(session.user.role.apiValue));
      case ConfirmationRequired():
        context.go(RouteNames.emailSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.signIn;
    final state = ref.watch(signInControllerProvider);
    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
          label: tr.submit,
          onPressed: _ready ? _submit : null,
          loading: state.busy,
          variant: SoeButtonVariant.secondary,
          fullWidth: true,
        ),
        hint: _ready ? null : tr.missing,
      ),
      children: [
        AuthHeading(title: tr.heading, lead: tr.lead),
        AuthErrorText(failure: state.failure),
        SoeTextField(
          controller: _login,
          label: tr.login,
          hint: tr.loginHint,
          leadingIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        SoePasswordField(
          controller: _password,
          label: tr.password,
          hint: tr.passwordHint,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(RouteNames.passwordForgot),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(tr.forgot,
                style:
                    AppTypography.labelSm.copyWith(color: AppPalette.teal500)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tr.noAccount,
                style: AppTypography.bodySm.copyWith(color: AppPalette.ink700)),
            TextButton(
              onPressed: () => context.go(RouteNames.roleChoice),
              child: Text(tr.signUp,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.teal500)),
            ),
          ],
        ),
      ],
    );
  }
}
