import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../../../common/presentation/widgets/more_entry.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';

/// The tutor entries of « Plus » (REP-01, variant « Menu Plus »): offers, applications, the
/// file, the contracts (with what is left to sign), the payout methods and the quality view.
/// A candidate's « Plus » (recruitment mode, as the web): the interview and test, the charter,
/// help; the file, offers and applications are tabs.
List<MoreEntry> tutorMoreEntries(BuildContext context, WidgetRef ref) {
  final tr = Translations.of(context).tutorSpace.nav;
  if (ref.watch(tutorCandidateProvider)) {
    return [
      (
        icon: Icons.calendar_today_outlined,
        label: tr.interview,
        hint: null,
        route: TutorSpaceRoutes.interview
      ),
      (
        icon: Icons.draw_outlined,
        label: tr.charter,
        hint: null,
        route: TutorSpaceRoutes.charter
      ),
      (
        icon: Icons.chat_bubble_outline,
        label: tr.help,
        hint: null,
        route: RouteNames.help
      ),
    ];
  }
  final toSign = ref.watch(tutorContractsProvider).valueOrNull?.fold<int>(
          0,
          (sum, contract) =>
              sum + (contract.canSign ? 1 : 0) + contract.amendmentsToSign) ??
      0;
  return [
    (
      icon: Icons.work_outline,
      label: tr.offers,
      hint: null,
      route: TutorSpaceRoutes.offers
    ),
    (
      icon: Icons.insert_drive_file_outlined,
      label: tr.applications,
      hint: null,
      route: TutorSpaceRoutes.applications
    ),
    (
      icon: Icons.badge_outlined,
      label: tr.file,
      hint: null,
      route: TutorSpaceRoutes.file
    ),
    (
      icon: Icons.draw_outlined,
      label: tr.contracts,
      hint: toSign > 0 ? tr.contractsToSign(n: toSign) : null,
      route: TutorSpaceRoutes.contracts
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      label: tr.payoutMethods,
      hint: null,
      route: TutorSpaceRoutes.payoutMethods
    ),
    (
      icon: Icons.star_border,
      label: tr.quality,
      hint: null,
      route: TutorSpaceRoutes.quality
    ),
  ];
}

/// The tutor entries as rows, in the « Plus » page of a tablet.
class TutorMoreLinks extends ConsumerWidget {
  const TutorMoreLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(children: [
        for (final entry in tutorMoreEntries(context, ref))
          _Link(
              icon: entry.icon,
              label: entry.label,
              subtitle: entry.hint,
              route: entry.route),
      ]);
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppPalette.teal),
        title: Text(label, style: AppTypography.label),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        trailing: const Icon(Icons.chevron_right, color: AppPalette.n500),
        onTap: () => unawaited(context.push(route)),
      );
}
