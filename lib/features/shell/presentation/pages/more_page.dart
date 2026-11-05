import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../i18n/translations.g.dart';
import '../../../common/presentation/pages/account_hub_page.dart';
import '../../../common/presentation/widgets/account_ui.dart';
import '../../../parent_space/presentation/parent_space_routes.dart';

/// « Plus » of both spaces: the account hub (COM-01), with the links of the active space in
/// their own card.
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    return AccountHubView(
      spaceLinks: tutor ? _tutorLinks(context) : _parentLinks(context),
    );
  }

  /// The parent space's links (requests and quotes…).
  List<Widget> _parentLinks(BuildContext context) => [
        AccountRow(
          icon: Icons.assignment_outlined,
          title: Translations.of(context).parentSpace.requests.title,
          divider: false,
          onTap: () => unawaited(context.push(ParentSpaceRoutes.requests)),
        ),
      ];

  /// The tutor space's links (none beyond its tabs yet).
  List<Widget> _tutorLinks(BuildContext context) => const [];
}
