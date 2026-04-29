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
import '../viewmodels/register_flow_viewmodel.dart';
import '../widgets/signup_header.dart';

class SignupStep2Page extends ConsumerStatefulWidget {
  const SignupStep2Page({super.key});

  @override
  ConsumerState<SignupStep2Page> createState() => _SignupStep2PageState();
}

class _SignupStep2PageState extends ConsumerState<SignupStep2Page> {
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _email = TextEditingController(text: s.email);
    _phone = TextEditingController(text: s.phone);
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SignupHeader(step: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr.signup.step2.heading, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  tr.signup.step2.subtitle,
                  style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 22),
                SoeTextField(
                  controller: _email,
                  label: tr.signup.step2.email,
                  hint: tr.signup.step2.emailHint,
                  leadingIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? tr.errors.emailInvalid
                      : null,
                ),
                const SizedBox(height: 14),
                SoeTextField(
                  controller: _phone,
                  label: tr.signup.step2.phone,
                  hint: tr.signup.step2.phoneHint,
                  leadingIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 14),
                  child: Text(
                    tr.signup.step2.phoneHelp,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.n700),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPalette.infoBg,
                    borderRadius: AppRadius.rMd,
                    border: Border.all(
                        color: AppPalette.teal.withValues(alpha: .2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.phone_android,
                          size: 16, color: AppPalette.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr.signup.step2.momoInfo,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.n700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SoeButton(
                  label: tr.common.kContinue,
                  icon: Icons.chevron_right,
                  iconRight: true,
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    ref
                        .read(registerFlowViewModelProvider.notifier)
                        .setContact(
                            email: _email.text.trim(),
                            phone: _phone.text.trim());
                    context.push(RouteNames.registerStep3);
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
