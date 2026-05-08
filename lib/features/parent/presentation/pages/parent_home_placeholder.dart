import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/soe_dashboard_placeholder.dart';
import '../../../../i18n/translations.g.dart';

class ParentHomePlaceholderPage extends ConsumerWidget {
  const ParentHomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    return SoeDashboardPlaceholder(
      title: tr.dashboardPlaceholder.parentTitle,
      subtitle: tr.dashboardPlaceholder.body,
      roleLabel: tr.dashboardPlaceholder.parentRole,
      icon: Icons.groups_outlined,
    );
  }
}
