import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/sign_up_step_page.dart';

/// AUT-05 — password: the 4 rules ticked as the user types, and the confirmation.
class SignupStep3Page extends ConsumerStatefulWidget {
  const SignupStep3Page({super.key});

  @override
  ConsumerState<SignupStep3Page> createState() => _SignupStep3PageState();
}

class _SignupStep3PageState extends ConsumerState<SignupStep3Page> {
  late final _answers = ref.read(signUpControllerProvider).answers;
  late final _password = TextEditingController(text: _answers.password);
  late final _confirmation =
      TextEditingController(text: _answers.passwordConfirmation);

  @override
  void initState() {
    super.initState();
    _password.addListener(_sync);
    _confirmation.addListener(_sync);
  }

  void _sync() => ref.read(signUpControllerProvider.notifier).update(
        (a) => a.copyWith(
            password: _password.text, passwordConfirmation: _confirmation.text),
      );

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.password;
    final state = ref.watch(signUpControllerProvider);
    final answers = state.answers;
    final missing = [
      if (!PasswordRules.allMet(answers.password)) tr.password.toLowerCase(),
      if (answers.passwordConfirmation.isEmpty) tr.confirmation.toLowerCase(),
    ];

    return SignUpStepPage(
      step: SignUpStep.password,
      number: 3,
      next: RouteNames.registerStep4,
      missing: missing,
      children: [
        AuthHeading(title: tr.heading, lead: tr.lead),
        SoePasswordField(
          controller: _password,
          label: tr.password,
          errorText: state.fieldError('password'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        PasswordRules(password: answers.password),
        SoePasswordField(
          controller: _confirmation,
          label: tr.confirmation,
          errorText: state.fieldError('password_confirmation'),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
