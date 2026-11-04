import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_checkbox.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-06 — address and consents, then the account is created and a code is sent.
class SignupStep4Page extends ConsumerStatefulWidget {
  const SignupStep4Page({super.key});

  @override
  ConsumerState<SignupStep4Page> createState() => _SignupStep4PageState();
}

class _SignupStep4PageState extends ConsumerState<SignupStep4Page> {
  late final _answers = ref.read(signUpControllerProvider).answers;
  late final _neighborhood = TextEditingController(text: _answers.neighborhood);
  late final _landmark = TextEditingController(text: _answers.landmark);

  @override
  void dispose() {
    _neighborhood.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _update(SignUpAnswers Function(SignUpAnswers) change) =>
      ref.read(signUpControllerProvider.notifier).update(change);

  Future<void> _create() async {
    final pending = await ref.read(signUpControllerProvider.notifier).create();
    if (pending != null && mounted) context.go(RouteNames.emailSent);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.address;
    final auth = Translations.of(context).auth;
    final state = ref.watch(signUpControllerProvider);
    final answers = state.answers;
    final consentsGiven = answers.acceptTermsOfUse &&
        answers.acceptPrivacy &&
        (!answers.isParent || answers.acceptTermsOfSale);
    final missing = [
      if (answers.neighborhood.trim().isEmpty) tr.neighborhood.toLowerCase(),
      if (answers.city == null) tr.city.toLowerCase(),
      if (!consentsGiven) tr.consents,
    ];

    // `change` gets the latest answers: two quick taps never undo each other.
    Widget consent(String label, bool value, String field,
            SignUpAnswers Function(SignUpAnswers, bool) change) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoeCheckbox(
                value: value,
                onChanged: (checked) =>
                    _update((latest) => change(latest, checked)),
                label: Text(label,
                    style: AppTypography.bodySm
                        .copyWith(color: AppPalette.ink900)),
              ),
              if (state.fieldError(field) != null)
                Text(state.fieldError(field)!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.dangerText)),
            ],
          ),
        );

    return AuthScaffold(
      step: 4,
      bottom: AuthSubmit(
        button: SoeButton(
          label: tr.submit,
          onPressed: missing.isEmpty ? _create : null,
          loading: state.busy,
          fullWidth: true,
        ),
        hint: missing.isEmpty ? null : auth.missing(fields: missing.join(', ')),
      ),
      children: [
        AuthErrorText(failure: state.failure, shownFields: const {
          'neighborhood',
          'city',
          'landmark',
          'accept_terms_of_use',
          'accept_terms_of_sale',
          'accept_privacy',
        }),
        AuthHeading(
            title: tr.heading,
            lead: answers.isParent ? tr.leadParent : tr.leadTutor),
        SoeTextField(
          controller: _neighborhood,
          label: tr.neighborhood,
          hint: tr.neighborhoodHint,
          leadingIcon: Icons.search,
          errorText: state.fieldError('neighborhood'),
          onChanged: (value) => _update((a) => a.copyWith(neighborhood: value)),
        ),
        const SizedBox(height: 20),
        ChoiceSegmented(
          label: tr.city,
          options: const {'Douala': 'Douala', 'Yaoundé': 'Yaoundé'},
          value: answers.city,
          errorText: state.fieldError('city'),
          onChanged: (value) => _update((a) => a.copyWith(city: value)),
        ),
        SoeTextField(
          controller: _landmark,
          label: tr.landmark,
          hint: tr.landmarkHint,
          onChanged: (value) => _update((a) => a.copyWith(landmark: value)),
        ),
        const SizedBox(height: 16),
        consent(tr.termsOfUse, answers.acceptTermsOfUse, 'accept_terms_of_use',
            (latest, v) => latest.copyWith(acceptTermsOfUse: v)),
        if (answers.isParent)
          consent(
              tr.termsOfSale,
              answers.acceptTermsOfSale,
              'accept_terms_of_sale',
              (latest, v) => latest.copyWith(acceptTermsOfSale: v)),
        consent(tr.privacy, answers.acceptPrivacy, 'accept_privacy',
            (latest, v) => latest.copyWith(acceptPrivacy: v)),
      ],
    );
  }
}
