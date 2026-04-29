import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../viewmodels/register_flow_state.dart';
import '../viewmodels/register_flow_viewmodel.dart';
import '../widgets/signup_header.dart';

class SignupStep3Page extends ConsumerStatefulWidget {
  const SignupStep3Page({super.key});

  @override
  ConsumerState<SignupStep3Page> createState() => _SignupStep3PageState();
}

class _SignupStep3PageState extends ConsumerState<SignupStep3Page> {
  late final TextEditingController _password;
  late final TextEditingController _confirm;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _password = TextEditingController(text: s.password);
    _confirm = TextEditingController(text: s.passwordConfirmation);
    _password.addListener(_syncFlow);
  }

  void _syncFlow() {
    ref.read(registerFlowViewModelProvider.notifier).setPassword(
          password: _password.text,
          passwordConfirmation: _confirm.text,
        );
  }

  @override
  void dispose() {
    _password.removeListener(_syncFlow);
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final flow = ref.watch(registerFlowViewModelProvider);

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SignupHeader(step: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr.signup.step3.heading, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  tr.signup.step3.subtitle,
                  style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 22),
                SoePasswordField(
                  controller: _password,
                  label: tr.signup.step3.password,
                  hint: tr.signup.step3.passwordHint,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 6) ? tr.errors.passwordTooShort : null,
                ),
                const SizedBox(height: 12),
                SoePasswordField(
                  controller: _confirm,
                  label: tr.signup.step3.confirm,
                  hint: tr.signup.step3.confirmHint,
                  validator: (v) => v != _password.text
                      ? tr.errors.passwordMismatch
                      : null,
                ),
                const SizedBox(height: 16),
                _StrengthMeter(
                  state: flow,
                  label: tr.signup.step3.strengthLabel,
                  rules: [
                    _Rule(label: tr.signup.step3.rule6Chars, ok: flow.password.length >= 6),
                    _Rule(
                      label: tr.signup.step3.ruleMixCase,
                      ok: RegExp('[A-Z]').hasMatch(flow.password) &&
                          RegExp('[a-z]').hasMatch(flow.password),
                    ),
                    _Rule(
                      label: tr.signup.step3.ruleDigitOrSymbol,
                      ok: RegExp(r'[\d!@#$%^&*(),.?":{}|<>]')
                          .hasMatch(flow.password),
                    ),
                    _Rule(
                      label: tr.signup.step3.rule12Strong,
                      ok: flow.password.length >= 12,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SoeButton(
                  label: tr.common.kContinue,
                  icon: Icons.chevron_right,
                  iconRight: true,
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    _syncFlow();
                    context.push(RouteNames.registerStep4);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rule {
  const _Rule({required this.label, required this.ok});
  final String label;
  final bool ok;
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({
    required this.state,
    required this.label,
    required this.rules,
  });

  final RegisterFlowState state;
  final String label;
  final List<_Rule> rules;

  @override
  Widget build(BuildContext context) {
    final strength = state.passwordStrength;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppPalette.n100,
        borderRadius: AppRadius.rMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: AppPalette.ink,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < strength
                          ? AppPalette.success
                          : AppPalette.n300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 10),
          for (final r in rules) _RuleRow(rule: r),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule});
  final _Rule rule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rule.ok ? AppPalette.success : Colors.transparent,
              border: Border.all(
                color: rule.ok ? AppPalette.success : AppPalette.n500,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: rule.ok
                ? const Icon(Icons.check, size: 10, color: AppPalette.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            rule.label,
            style: AppTypography.caption.copyWith(
              color: rule.ok ? AppPalette.success : AppPalette.n700,
            ),
          ),
        ],
      ),
    );
  }
}
