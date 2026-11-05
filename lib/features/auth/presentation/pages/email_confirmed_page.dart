import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../../parent_space/presentation/parent_space_routes.dart';
import '../../../tutor_space/presentation/tutor_space_routes.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-08 — account activated: the parent adds a first child, the tutor completes the file.
class EmailConfirmedPage extends ConsumerWidget {
  const EmailConfirmedPage({super.key});

  /// Opens the first step over the space's home, so that back leads home: the new child
  /// form (PAR-05) for a parent, the recruitment file (REP-02) for a tutor.
  static void _start(BuildContext context, {required bool tutor}) {
    final router = GoRouter.of(context)
      ..go(tutor ? RouteNames.tutorHome : RouteNames.parentHome);
    unawaited(router
        .push(tutor ? TutorSpaceRoutes.file : ParentSpaceRoutes.newChild));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).auth.welcome;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    final steps = tutor
        ? [for (final section in tr.tutorSectionList) (section, null)]
        : [
            (tr.parentStep1, tr.parentStep1Text),
            (tr.parentStep2, tr.parentStep2Text),
            (tr.parentStep3, null)
          ];

    return AuthScaffold(
      bottom: SoeButton(
        label: tutor ? tr.tutorCta : tr.parentCta,
        onPressed: () => _start(context, tutor: tutor),
        fullWidth: true,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppPalette.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: AppPalette.success, size: 32),
          ),
        ),
        const SizedBox(height: 20),
        AuthHeading(
            title: tr.heading, lead: tutor ? tr.tutorLead : tr.parentLead),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppPalette.successBg,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tutor ? tr.tutorSections : tr.next,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.ink900)),
              const SizedBox(height: 12),
              for (final (index, (title, text)) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppPalette.white,
                        child: Text('${index + 1}',
                            style: AppTypography.labelSm
                                .copyWith(color: AppPalette.ink700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: AppTypography.labelSm
                                    .copyWith(color: AppPalette.ink900)),
                            if (text != null)
                              Text(text,
                                  style: AppTypography.caption
                                      .copyWith(color: AppPalette.ink700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (tutor)
                Text(tr.tutorDelay,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.ink700)),
            ],
          ),
        ),
      ],
    );
  }
}
