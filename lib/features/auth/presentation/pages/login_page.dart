import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/auth_flow.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controllers.dart';
import '../providers/current_user_provider.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-09 — sign-in with the e-mail or the phone. An unverified account goes to the code.
/// After a refused session (AUT-11 « Session expirée »), the account is kept: only the
/// password is asked, « Changer de compte » goes back to the plain sign-in.
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

  /// The account of the expired session (AUT-11), or null for a plain sign-in.
  User? get _expiredUser => ref.read(sessionExpiredProvider)
      ? ref.read(currentUserProvider).valueOrNull
      : null;

  String _loginValue() => _expiredUser?.email ?? _login.text.trim();

  bool get _ready => _loginValue().isNotEmpty && _password.text.isNotEmpty;

  /// « Changer de compte »: the kept account is forgotten, the plain sign-in comes back.
  Future<void> _changeAccount() async {
    await ref.read(secureStorageProvider).delete(StorageKeys.currentUser);
    ref.read(sessionExpiredProvider.notifier).state = false;
    ref.invalidate(currentUserProvider);
  }

  Future<void> _submit() async {
    if (!_ready) return;
    final outcome = await ref
        .read(signInControllerProvider.notifier)
        .submit(_loginValue(), _password.text);
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
    final expired = ref.watch(sessionExpiredProvider)
        ? ref.watch(currentUserProvider).valueOrNull
        : null;
    if (expired != null) return _expiredView(context, expired, state);
    return AuthScaffold(
      children: [
        AuthHeading(title: tr.heading, lead: tr.tagline),
        AuthErrorText(failure: state.failure),
        SoeTextField(
          controller: _login,
          label: tr.login,
          hint: tr.loginHint,
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
        _forgot(context),
        const SizedBox(height: 8),
        AuthSubmit(
          button: SoeButton(
            label: tr.submit,
            size: SoeButtonSize.xl,
            onPressed: _ready ? _submit : null,
            loading: state.busy,
            fullWidth: true,
          ),
          hint: _ready ? null : tr.missing,
        ),
        const SizedBox(height: 20),
        _Divider(label: tr.newHere),
        const SizedBox(height: 16),
        SoeButton(
          label: tr.signUp,
          variant: SoeButtonVariant.secondary,
          fullWidth: true,
          onPressed: () => context.go(RouteNames.roleChoice),
        ),
        const SizedBox(height: 28),
        Text(tr.phoneLanguage,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppPalette.ink600)),
      ],
    );
  }

  Widget _forgot(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => context.push(RouteNames.passwordForgot),
          style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
          child: Text(Translations.of(context).auth.signIn.forgot,
              style: AppTypography.label.copyWith(color: AppPalette.teal500)),
        ),
      );

  Widget _expiredView(BuildContext context, User user, FlowState state) {
    final tr = Translations.of(context).auth.signIn;
    final name = [user.firstName, user.lastName]
        .where((part) => part.isNotEmpty)
        .join(' ');
    return AuthScaffold(
      children: [
        AuthHeading(title: tr.expired.heading, lead: tr.expired.lead),
        AuthErrorText(failure: state.failure),
        Text(tr.expired.account,
            style: AppTypography.labelSm.copyWith(color: AppPalette.ink900)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: AppPalette.teal50,
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.person_outline, size: 20, color: AppPalette.text2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  [name, maskEmail(user.email)]
                      .where((part) => part.isNotEmpty)
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(color: AppPalette.text)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        SoePasswordField(
          controller: _password,
          label: tr.password,
          hint: tr.passwordHint,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
        ),
        _forgot(context),
        const SizedBox(height: 8),
        SoeButton(
          label: tr.expired.submit,
          size: SoeButtonSize.xl,
          onPressed: _ready ? _submit : null,
          loading: state.busy,
          fullWidth: true,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tr.expired.notYou,
                style: AppTypography.bodySm.copyWith(color: AppPalette.ink700)),
            TextButton(
              onPressed: _changeAccount,
              child: Text(tr.expired.changeAccount,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.teal500)),
            ),
          ],
        ),
      ],
    );
  }
}

/// « m•••••@gmail.com »: the first letter of the address, its domain.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1) return email;
  return '${email[0]}•••••${email.substring(at)}';
}

/// « ——— Nouveau sur SOE ? ——— »
class _Divider extends StatelessWidget {
  const _Divider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider(color: AppPalette.teal100)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: AppTypography.caption.copyWith(color: AppPalette.ink600)),
        ),
        const Expanded(child: Divider(color: AppPalette.teal100)),
      ]);
}
