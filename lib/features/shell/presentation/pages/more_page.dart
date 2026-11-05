import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../common/presentation/pages/account_hub_page.dart';
import '../../../parent_space/presentation/widgets/parent_more_links.dart';
import '../../../tutor_space/presentation/widgets/tutor_more_links.dart';

/// « Plus » of both spaces: the account hub (COM-01), with the links of the active space in
/// their own card (PAR-01 and REP-01, variant « Menu Plus »).
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    return AccountHubView(
      spaceLinks: [tutor ? const TutorMoreLinks() : const ParentMoreLinks()],
    );
  }
}
