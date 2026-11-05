import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../parent_space_routes.dart';
import '../providers.dart';

/// The parent entries of the « Plus » menu (PAR-01 « Menu Plus »): requests and quotes,
/// contracts, reviews, co-parents, the advisor. Rendered by the More page of the shell.
class ParentMoreLinks extends ConsumerWidget {
  const ParentMoreLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.more;
    final quotes = ref
            .watch(parentHomeProvider)
            .valueOrNull
            ?.actions
            .where((action) => action.kind == 'quote')
            .length ??
        0;
    return Column(children: [
      _Link(
          icon: Icons.description_outlined,
          label: tr.requests,
          hint: quotes > 0 ? tr.requestsHint(count: quotes) : null,
          route: ParentSpaceRoutes.requests),
      _Link(
          icon: Icons.draw_outlined,
          label: tr.contracts,
          route: ParentSpaceRoutes.contracts),
      _Link(
          icon: Icons.star_border,
          label: tr.reviews,
          route: ParentSpaceRoutes.reviews),
      _Link(
          icon: Icons.group_outlined,
          label: tr.coParents,
          route: ParentSpaceRoutes.coParents),
      _Link(
          icon: Icons.chat_bubble_outline,
          label: tr.advisor,
          route: ParentSpaceRoutes.advisor),
    ]);
  }
}

class _Link extends StatelessWidget {
  const _Link(
      {required this.icon, required this.label, required this.route, this.hint});

  final IconData icon;
  final String label;
  final String route;
  final String? hint;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppPalette.surfaceSoft,
          child: Icon(icon, size: 18, color: AppPalette.teal800),
        ),
        title: Text(label, style: AppTypography.label),
        subtitle: hint == null
            ? null
            : Text(hint!,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        trailing: const Icon(Icons.chevron_right, color: AppPalette.n500),
        onTap: () => unawaited(context.push(route)),
      );
}
