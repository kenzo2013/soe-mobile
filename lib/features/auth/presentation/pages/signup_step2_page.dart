import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/sign_up_step_page.dart';

/// AUT-04 — contact: +237 phone and e-mail (the code goes there).
class SignupStep2Page extends ConsumerStatefulWidget {
  const SignupStep2Page({super.key});

  @override
  ConsumerState<SignupStep2Page> createState() => _SignupStep2PageState();
}

class _SignupStep2PageState extends ConsumerState<SignupStep2Page> {
  late final _answers = ref.read(signUpControllerProvider).answers;
  late final _phone = TextEditingController(text: _answers.phone);
  late final _email = TextEditingController(text: _answers.email);

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _update(SignUpAnswers Function(SignUpAnswers) change) =>
      ref.read(signUpControllerProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.contact;
    final state = ref.watch(signUpControllerProvider);
    final answers = state.answers;
    final missing = [
      if (answers.phone.trim().isEmpty) tr.phone.toLowerCase(),
      if (answers.email.trim().isEmpty) tr.email.toLowerCase(),
    ];

    return SignUpStepPage(
      step: SignUpStep.contact,
      number: 2,
      next: RouteNames.registerStep3,
      missing: missing,
      children: [
        AuthHeading(title: tr.heading),
        SoeTextField(
          controller: _phone,
          label: tr.phone,
          hint: tr.phoneHint,
          leadingIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          errorText: state.fieldError('phone'),
          textInputAction: TextInputAction.next,
          onChanged: (value) => _update((a) => a.copyWith(phone: value)),
        ),
        const SizedBox(height: 16),
        SoeTextField(
          controller: _email,
          label: tr.email,
          hint: tr.emailHint,
          leadingIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: state.fieldError('email'),
          textInputAction: TextInputAction.done,
          onChanged: (value) => _update((a) => a.copyWith(email: value.trim())),
        ),
        if (state.fieldError('email') == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(tr.emailHelp,
                style:
                    AppTypography.caption.copyWith(color: AppPalette.ink700)),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppPalette.n50, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.phone_outlined,
                  size: 18, color: AppPalette.teal500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answers.isParent ? tr.phoneUseParent : tr.phoneUseTutor,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.ink700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
