import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_field_label.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../viewmodels/register_flow_viewmodel.dart';
import '../widgets/signup_header.dart';

class SignupStep1Page extends ConsumerStatefulWidget {
  const SignupStep1Page({super.key});

  @override
  ConsumerState<SignupStep1Page> createState() => _SignupStep1PageState();
}

class _SignupStep1PageState extends ConsumerState<SignupStep1Page> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  String _civility = 'Mr';
  String _lang = 'fr';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _firstName = TextEditingController(text: s.firstName)
      ..addListener(_syncFlow);
    _lastName = TextEditingController(text: s.lastName)
      ..addListener(_syncFlow);
    _civility = s.civility;
    _lang = s.lang;
  }

  /// Sync au fil de l'eau : chaque frappe met à jour le state, donc même
  /// si l'utilisateur quitte la page sans cliquer "Continuer", les données
  /// sont préservées.
  void _syncFlow() {
    ref.read(registerFlowViewModelProvider.notifier).setIdentity(
          civility: _civility,
          firstName: _firstName.text,
          lastName: _lastName.text,
          lang: _lang,
        );
  }

  @override
  void dispose() {
    _firstName
      ..removeListener(_syncFlow)
      ..dispose();
    _lastName
      ..removeListener(_syncFlow)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SignupHeader(step: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr.signup.step1.heading, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  tr.signup.step1.subtitle,
                  style: AppTypography.bodySm
                      .copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 24),
                SoeFieldLabel(tr.signup.step1.civility),
                Row(
                  children: [
                    Expanded(
                      child: _PillOption(
                        label: tr.signup.step1.civilityMr,
                        selected: _civility == 'Mr',
                        onTap: () {
                          setState(() => _civility = 'Mr');
                          _syncFlow();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PillOption(
                        label: tr.signup.step1.civilityMme,
                        selected: _civility == 'Mme',
                        onTap: () {
                          setState(() => _civility = 'Mme');
                          _syncFlow();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SoeFieldLabel(tr.signup.step1.firstName),
                SoeTextField(
                  controller: _firstName,
                  hint: tr.signup.step1.firstNameHint,
                  leadingIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr.errors.required : null,
                ),
                const SizedBox(height: 12),
                SoeFieldLabel(tr.signup.step1.lastName),
                SoeTextField(
                  controller: _lastName,
                  hint: tr.signup.step1.lastNameHint,
                  leadingIcon: Icons.person_outline,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr.errors.required : null,
                ),
                const SizedBox(height: 14),
                SoeFieldLabel(tr.signup.step1.lang),
                Row(
                  children: [
                    Expanded(
                      child: _PillOption(
                        label: tr.languages.fr,
                        selected: _lang == 'fr',
                        onTap: () {
                          setState(() => _lang = 'fr');
                          _syncFlow();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PillOption(
                        label: tr.languages.en,
                        selected: _lang == 'en',
                        onTap: () {
                          setState(() => _lang = 'en');
                          _syncFlow();
                        },
                      ),
                    ),
                  ],
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
                        .setIdentity(
                          civility: _civility,
                          firstName: _firstName.text.trim(),
                          lastName: _lastName.text.trim(),
                          lang: _lang,
                        );
                    context.push(RouteNames.registerStep2);
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

class _PillOption extends StatelessWidget {
  const _PillOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppPalette.n300 : AppPalette.white,
            border: Border.all(
              color: selected ? AppPalette.teal : AppPalette.n300,
              width: 1.5,
            ),
            borderRadius: AppRadius.rMd,
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.h4)),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppPalette.teal : AppPalette.n500,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalette.teal,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
