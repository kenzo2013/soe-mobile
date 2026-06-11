import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/countries.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_field_label.dart';
import '../../../../core/widgets/soe_phone_field.dart';
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
  late final TextEditingController _phoneLocal;
  late Country _phoneCountry;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _email = TextEditingController(text: s.email)..addListener(_syncFlow);
    _phoneCountry = Countries.byCode(s.phoneCountryCode);
    _phoneLocal = TextEditingController(text: _stripPrefix(s.phone))
      ..addListener(_syncFlow);
  }

  String _stripPrefix(String fullPhone) {
    if (fullPhone.isEmpty) return '';
    // On essaie de retirer l'indicatif du pays courant ; à défaut, on tente
    // tous les indicatifs connus pour récupérer la partie locale.
    if (fullPhone.startsWith(_phoneCountry.callingCode)) {
      return fullPhone.substring(_phoneCountry.callingCode.length).trim();
    }
    for (final c in Countries.all) {
      if (fullPhone.startsWith(c.callingCode)) {
        _phoneCountry = c;
        return fullPhone.substring(c.callingCode.length).trim();
      }
    }
    return fullPhone;
  }

  String _composeE164() {
    final digits = _phoneLocal.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return '';
    return '${_phoneCountry.callingCode}$digits';
  }

  void _syncFlow() {
    ref.read(registerFlowViewModelProvider.notifier).setContact(
          email: _email.text,
          phone: _composeE164(),
          phoneCountryCode: _phoneCountry.code,
        );
  }

  @override
  void dispose() {
    _email
      ..removeListener(_syncFlow)
      ..dispose();
    _phoneLocal
      ..removeListener(_syncFlow)
      ..dispose();
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
                SoeFieldLabel(tr.signup.step2.email),
                SoeTextField(
                  controller: _email,
                  hint: tr.signup.step2.emailHint,
                  leadingIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null ||
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v))
                      ? tr.errors.emailInvalid
                      : null,
                ),
                const SizedBox(height: 14),
                SoeFieldLabel(tr.signup.step2.phone),
                SoePhoneField(
                  controller: _phoneLocal,
                  country: _phoneCountry,
                  hint: tr.signup.step2.phoneHint,
                  textInputAction: TextInputAction.done,
                  pickerTitle: tr.countryPicker.phoneTitle,
                  onCountryChanged: (c) {
                    setState(() => _phoneCountry = c);
                    _syncFlow();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 14),
                  child: Text(
                    tr.signup.step2.phoneHelp,
                    style:
                        AppTypography.caption.copyWith(color: AppPalette.n700),
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
                    _syncFlow();
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
