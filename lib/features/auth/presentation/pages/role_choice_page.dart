import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-02 — parent or tutor.
class RoleChoicePage extends ConsumerWidget {
  const RoleChoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).auth.profile;
    final state = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);
    final role = state.answers.role;

    Future<void> next() async {
      if (await controller.validate(SignUpStep.profile) && context.mounted)
        unawaited(context.push(RouteNames.registerStep1));
    }

    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
          label: Translations.of(context).auth.kContinue,
          onPressed: role == null ? null : next,
          loading: state.busy,
          variant: SoeButtonVariant.secondary,
          fullWidth: true,
        ),
        hint: role == null ? tr.missing : null,
      ),
      children: [
        AuthHeading(title: tr.heading, lead: tr.lead),
        AuthErrorText(failure: state.failure),
        for (final (value, icon, title, text) in [
          ('parent', Icons.person_outline, tr.parentTitle, tr.parentText),
          ('tutor', Icons.school_outlined, tr.tutorTitle, tr.tutorText),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProfileCard(
              icon: icon,
              title: title,
              text: text,
              selected: role == value,
              onTap: () =>
                  controller.update((answers) => answers.copyWith(role: value)),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppPalette.n50, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 18, color: AppPalette.teal500),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(tr.later,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.ink700))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tr.signedUp,
                style: AppTypography.bodySm.copyWith(color: AppPalette.ink700)),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(tr.signIn,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.teal500)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppPalette.teal50 : AppPalette.n50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: selected ? AppPalette.teal500 : Colors.transparent,
              width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppPalette.teal500),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTypography.label
                              .copyWith(color: AppPalette.ink900)),
                      Text(text,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.ink700)),
                    ],
                  ),
                ),
                Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppPalette.teal500 : AppPalette.ink400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
