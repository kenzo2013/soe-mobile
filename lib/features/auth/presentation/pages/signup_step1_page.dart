import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/sign_up_step_page.dart';

/// AUT-03 — identity: civility, names, link with the child (parent). The account takes the
/// phone's language.
class SignupStep1Page extends ConsumerStatefulWidget {
  const SignupStep1Page({super.key});

  @override
  ConsumerState<SignupStep1Page> createState() => _SignupStep1PageState();
}

class _SignupStep1PageState extends ConsumerState<SignupStep1Page> {
  late final _answers = ref.read(signUpControllerProvider).answers;
  late final _firstName = TextEditingController(text: _answers.firstName);
  late final _lastName = TextEditingController(text: _answers.lastName);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _update(SignUpAnswers Function(SignUpAnswers) change) =>
      ref.read(signUpControllerProvider.notifier).update(change);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.identity;
    final state = ref.watch(signUpControllerProvider);
    final answers = state.answers;
    final missing = [
      if (answers.civility == null) tr.civility.toLowerCase(),
      if (answers.firstName.trim().isEmpty) tr.firstName.toLowerCase(),
      if (answers.lastName.trim().isEmpty) tr.lastName.toLowerCase(),
      if (answers.isParent && answers.linkWithChildren == null)
        tr.linkWithChildren.toLowerCase(),
    ];

    return SignUpStepPage(
      step: SignUpStep.identity,
      number: 1,
      next: RouteNames.registerStep2,
      missing: missing,
      children: [
        AuthHeading(
            title: tr.heading,
            lead: answers.isParent ? tr.leadParent : tr.leadTutor),
        ChoiceSegmented(
          label: tr.civility,
          options: {'mr': tr.mr, 'mrs': tr.mrs},
          value: answers.civility,
          errorText: state.fieldError('civility'),
          onChanged: (value) => _update((a) => a.copyWith(civility: value)),
        ),
        SoeTextField(
          controller: _firstName,
          label: tr.firstName,
          hint: tr.firstNameHint,
          errorText: state.fieldError('first_name'),
          textInputAction: TextInputAction.next,
          onChanged: (value) => _update((a) => a.copyWith(firstName: value)),
        ),
        const SizedBox(height: 16),
        SoeTextField(
          controller: _lastName,
          label: tr.lastName,
          hint: tr.lastNameHint,
          errorText: state.fieldError('last_name'),
          textInputAction: TextInputAction.done,
          onChanged: (value) => _update((a) => a.copyWith(lastName: value)),
        ),
        const SizedBox(height: 20),
        if (answers.isParent)
          ChoiceSegmented(
            label: tr.linkWithChildren,
            options: {
              'father': tr.father,
              'mother': tr.mother,
              'legal_guardian': tr.legalGuardian
            },
            value: answers.linkWithChildren,
            errorText: state.fieldError('link_with_children'),
            onChanged: (value) =>
                _update((a) => a.copyWith(linkWithChildren: value)),
          ),
      ],
    );
  }
}
