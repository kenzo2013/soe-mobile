import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_ui.dart';

/// PAR-02 — the children, always as cards; PAR-03 (mobile) — a child's courses.
class ParentChildrenPage extends ConsumerWidget {
  const ParentChildrenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: ParentAsyncBody<List<ParentChild>>(
          value: ref.watch(parentChildrenProvider),
          onRetry: () => ref.invalidate(parentChildrenProvider),
          builder: (children) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(tr.children.title,
                  style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 12),
              if (children.isEmpty)
                SoeEmptyState(
                    title: tr.children.empty,
                    message: tr.children.emptyText,
                    icon: Icons.family_restroom_outlined),
              ...children.map((child) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoeCard(
                      onTap: () =>
                          context.push(ParentSpaceRoutes.child(child.id)),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppPalette.gold100,
                          child: Text(
                              child.firstName.isEmpty
                                  ? '?'
                                  : child.firstName[0],
                              style: AppTypography.title
                                  .copyWith(color: AppPalette.ink900)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.firstName,
                                    style: AppTypography.label),
                                Text(
                                    [child.schoolClass, child.schoolName]
                                        .whereType<String>()
                                        .join(' · '),
                                    style: AppTypography.caption
                                        .copyWith(color: AppPalette.text2)),
                              ]),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppPalette.text2),
                      ]),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ParentChildPage extends ConsumerWidget {
  const ParentChildPage({super.key, required this.childId});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final value = ref.watch(parentChildProvider(childId));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(
          title: Text(value.valueOrNull?.firstName ?? tr.children.title)),
      body: ParentAsyncBody<ParentChild>(
        value: value,
        onRetry: () => ref.invalidate(parentChildProvider(childId)),
        builder: (child) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
                [child.schoolClass, child.schoolName]
                    .whereType<String>()
                    .join(' · '),
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 12),
            if (child.courses.isEmpty)
              SoeCard(
                  child: Text(tr.children.noCourse,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2))),
            ...child.courses.map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoeCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              tr.children.course(
                                  subject: course.subject,
                                  tutor: course.tutorName),
                              style: AppTypography.label),
                          const SizedBox(height: 4),
                          Text(
                              tr.children
                                  .validated(count: course.validatedSessions),
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
                          if (course.nextSessionAt != null)
                            Text(
                                tr.children.next(
                                    date: ParentFormat.dateTime(
                                        context, course.nextSessionAt!)),
                                style: AppTypography.caption
                                    .copyWith(color: AppPalette.text2)),
                        ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
