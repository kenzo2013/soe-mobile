import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';

/// The tutor entries of « Plus » (REP-01, variant « Menu Plus »): offers, applications, the
/// file, the contracts (with what is left to sign), the payout methods and the quality view. The account, the
/// switch of space and the sign-out stay with the shared « Plus » page.
class TutorMoreLinks extends ConsumerWidget {
  const TutorMoreLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.nav;
    final toSign = ref.watch(tutorContractsProvider).valueOrNull?.fold<int>(
            0,
            (sum, contract) =>
                sum + (contract.canSign ? 1 : 0) + contract.amendmentsToSign) ??
        0;
    return Column(children: [
      _Link(
          icon: Icons.work_outline,
          label: tr.offers,
          route: TutorSpaceRoutes.offers),
      _Link(
          icon: Icons.insert_drive_file_outlined,
          label: tr.applications,
          route: TutorSpaceRoutes.applications),
      _Link(
          icon: Icons.badge_outlined,
          label: tr.file,
          route: TutorSpaceRoutes.file),
      _Link(
          icon: Icons.draw_outlined,
          label: tr.contracts,
          subtitle: toSign > 0 ? tr.contractsToSign(n: toSign) : null,
          route: TutorSpaceRoutes.contracts),
      _Link(
          icon: Icons.account_balance_wallet_outlined,
          label: tr.payoutMethods,
          route: TutorSpaceRoutes.payoutMethods),
      _Link(
          icon: Icons.insights_outlined,
          label: tr.quality,
          route: TutorSpaceRoutes.quality),
    ]);
  }
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
