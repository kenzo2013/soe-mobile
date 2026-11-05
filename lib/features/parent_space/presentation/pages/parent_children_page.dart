import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_child_avatar.dart';
import '../widgets/parent_session_tile.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';

/// Labels of a child's schooling: « CM2 · section francophone · École de Bonapriso ».
String parentSchooling(BuildContext context, ParentChild child) {
  final tr = Translations.of(context).parentSpace.childForm;
  final section = switch (child.section) {
    'francophone' => tr.francophone,
    'anglophone' => tr.anglophone,
    _ => null,
  };
  return [child.schoolClass, section, child.schoolName]
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(' · ');
}

/// PAR-02 — the children, always as cards: class, section, school, course in place.
class ParentChildrenPage extends ConsumerWidget {
  const ParentChildrenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(parentChildrenProvider.future),
          child: ParentAsyncBody<List<ParentChild>>(
            value: ref.watch(parentChildrenProvider),
            onRetry: () => ref.invalidate(parentChildrenProvider),
            builder: (children) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ParentHeading(
                    title: tr.children.title, subtitle: tr.childFile.subtitle),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SoeButton(
                    label: tr.childFile.add,
                    size: SoeButtonSize.md,
                    onPressed: () =>
                        unawaited(context.push(ParentSpaceRoutes.newChild)),
                  ),
                ),
                const SizedBox(height: 20),
                if (children.isEmpty)
                  SoeEmptyState(
                      title: tr.children.empty,
                      message: tr.children.emptyText,
                      icon: Icons.family_restroom_outlined),
                ...children.map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ChildCard(child: child),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.childFile;
    // The list has no courses: the child's file brings them (cached per child).
    final courses =
        ref.watch(parentChildProvider(child.id)).valueOrNull?.courses ??
            const <ParentCourse>[];
    final course = courses.isEmpty ? null : courses.first;
    String? courseLine;
    if (course != null) {
      courseLine = [
        Translations.of(context)
            .parentSpace
            .children
            .course(subject: course.subject, tutor: course.tutorName),
        if (course.nextSessionAt != null)
          tr.nextShort(date: ParentFormat.day(context, course.nextSessionAt!))
        else if (!course.active)
          tr.requestInProgress,
      ].join(' · ');
    }
    return SoeCard(
      onTap: () => unawaited(context.push(ParentSpaceRoutes.child(child.id))),
      child: Row(children: [
        ParentChildAvatar(child: child, radius: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(child.firstName, style: AppTypography.label),
            const SizedBox(height: 2),
            Text(parentSchooling(context, child),
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            if (courseLine != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(courseLine,
                    style: AppTypography.caption.copyWith(
                        color: course!.active
                            ? AppPalette.text2
                            : AppPalette.teal700)),
              ),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppPalette.text2),
      ]),
    );
  }
}

enum _ChildTab { courses, sessions, reports, info }

/// PAR-03 — a child's file: courses, sessions, reports, information, safety.
class ParentChildPage extends ConsumerStatefulWidget {
  const ParentChildPage({super.key, required this.childId});

  final int childId;

  @override
  ConsumerState<ParentChildPage> createState() => _ParentChildPageState();
}

class _ParentChildPageState extends ConsumerState<ParentChildPage> {
  _ChildTab _tab = _ChildTab.courses;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final value = ref.watch(parentChildProvider(widget.childId));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(
          title: Text(value.valueOrNull?.firstName ?? tr.children.title)),
      body: ParentAsyncBody<ParentChild>(
        value: value,
        onRetry: () => ref.invalidate(parentChildProvider(widget.childId)),
        builder: (child) {
          final age = child.birthdate == null
              ? null
              : (DateTime.now().difference(child.birthdate!).inDays ~/ 365);
          final section = switch (child.section) {
            'francophone' => tr.childForm.francophone,
            'anglophone' => tr.childForm.anglophone,
            _ => null,
          };
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                ParentChildAvatar(child: child, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: ParentHeading(
                    overline: [
                      child.schoolClass,
                      section,
                      if (age != null) tr.childFile.age(count: age),
                    ].whereType<String>().join(' · '),
                    title: child.fullName,
                  ),
                ),
              ]),
              if ((child.schoolName ?? child.address?.label) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      [child.schoolName, child.address?.label]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style: AppTypography.body
                          .copyWith(color: AppPalette.text2)),
                ),
              const SizedBox(height: 14),
              ParentChoiceChips<_ChildTab>(
                options: [
                  (_ChildTab.courses, tr.childFile.tabCourses),
                  (_ChildTab.sessions, tr.childFile.tabSessions),
                  (_ChildTab.reports, tr.childFile.tabReports),
                  (_ChildTab.info, tr.childFile.tabInfo),
                ],
                selected: {_tab},
                onToggle: (tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: 16),
              ...switch (_tab) {
                _ChildTab.courses => [
                    ..._courses(context, child),
                    _ReportsPanel(childId: child.id, limit: 3),
                    _InfoPanel(child: child),
                    _SafetyPanel(child: child),
                  ],
                _ChildTab.sessions => [_SessionsPanel(childId: child.id)],
                _ChildTab.reports => [_ReportsPanel(childId: child.id)],
                _ChildTab.info => [
                    _InfoPanel(child: child),
                    _SafetyPanel(child: child),
                  ],
              },
            ],
          );
        },
      ),
    );
  }

  List<Widget> _courses(BuildContext context, ParentChild child) {
    final tr = Translations.of(context).parentSpace;
    if (child.courses.isEmpty) {
      return [
        ParentPanel(title: tr.children.noCourse, children: [
          Text(tr.childFile.noCourseText,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          if (child.editable) ...[
            const SizedBox(height: 12),
            SoeButton(
              label: tr.childFile.requestTutor,
              size: SoeButtonSize.md,
              onPressed: () =>
                  unawaited(context.push(ParentSpaceRoutes.newRequest)),
            ),
          ],
        ]),
      ];
    }
    return [
      for (final course in child.courses)
        ParentPanel(children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        (course.active
                                ? tr.childFile.activeCourse
                                : tr.childFile.requestCourse)
                            .toUpperCase(),
                        style: AppTypography.overline
                            .copyWith(color: AppPalette.teal700)),
                    Text(course.subject,
                        style: AppTypography.h3
                            .copyWith(color: AppPalette.teal800)),
                  ]),
            ),
            if (course.active)
              SoeBadge(
                  label: tr.childFile.active, tone: SoeBadgeTone.success),
          ]),
          const SizedBox(height: 8),
          ParentInfoRow(tr.childFile.tutor, course.tutorName),
          if (course.times.isNotEmpty)
            ParentInfoRow(
                tr.childFile.times,
                course.times
                    .map((time) => '${time.day} ${time.from}')
                    .join(', ')),
          ParentInfoRow(
            tr.childFile.since,
            course.since == null
                ? tr.children.validated(count: course.validatedSessions)
                : tr.childFile.sinceValue(
                    date: DateFormat.yMMMMd(
                            Localizations.localeOf(context).languageCode)
                        .format(course.since!),
                    count: course.validatedSessions),
            last: true,
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 4, children: [
            SoeButton(
              label: tr.childFile.seeSessions,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.outline,
              onPressed: () => setState(() => _tab = _ChildTab.sessions),
            ),
            if (course.reservationId != null)
              SoeButton(
                label: course.active
                    ? tr.childFile.askReplacement
                    : tr.childFile.seeRequest,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.tertiary,
                onPressed: () => unawaited(context.push(course.active
                    ? ParentSpaceRoutes.tutors(course.reservationId!)
                    : ParentSpaceRoutes.request(course.reservationId!))),
              ),
          ]),
        ]),
    ];
  }
}

class _SessionsPanel extends ConsumerWidget {
  const _SessionsPanel({required this.childId});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.childFile;
    final value = ref.watch(parentChildSessionsProvider(childId));
    return value.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => TextButton(
          onPressed: () => ref.invalidate(parentChildSessionsProvider(childId)),
          child: Text(Translations.of(context).parentSpace.retry)),
      data: (sessions) => sessions.isEmpty
          ? ParentPanel(children: [
              Text(tr.noSession,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ])
          : Column(children: [
              for (final session in sessions.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ParentSessionTile(
                      session: session,
                      onTap: () => unawaited(context
                          .push(ParentSpaceRoutes.session(session.id)))),
                ),
            ]),
    );
  }
}

/// The reports of the child's past sessions: to approve, approved, disputed.
class _ReportsPanel extends ConsumerWidget {
  const _ReportsPanel({required this.childId, this.limit});

  final int childId;
  final int? limit;

  static const _withReport = ['report_to_approve', 'approved', 'disputed'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.childFile;
    final sessions =
        ref.watch(parentChildSessionsProvider(childId)).valueOrNull ??
            const <ParentSession>[];
    final reports = sessions.reversed
        .where((session) => _withReport.contains(session.status))
        .take(limit ?? 100)
        .toList();
    return ParentPanel(
      title: tr.lastReports,
      children: [
        if (reports.isEmpty)
          Text(tr.noReport,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        for (final session in reports)
          InkWell(
            onTap: () =>
                unawaited(context.push(ParentSpaceRoutes.report(session.id))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(
                    child: Text(
                        '${ParentFormat.day(context, session.startsAt)} · ${session.subject ?? ''}',
                        style: AppTypography.bodySm)),
                Text(session.statusLabel,
                    style: AppTypography.labelSm.copyWith(
                        color: switch (session.status) {
                      'approved' => AppPalette.successText,
                      'disputed' => AppPalette.dangerText,
                      _ => AppPalette.warningText,
                    })),
              ]),
            ),
          ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final schoolType = switch (child.schoolType) {
      'public' => tr.childForm.public,
      'private_secular' => tr.childForm.privateSecular,
      'religious' => tr.childForm.religious,
      _ => null,
    };
    return ParentPanel(
      title: tr.childFile.info,
      children: [
        if (child.birthdate != null)
          ParentInfoRow(
              tr.childFile.bornOn,
              DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
                  .format(child.birthdate!)),
        if (schoolType != null)
          ParentInfoRow(tr.childFile.schoolType, schoolType),
        if (child.address != null && child.address!.label.isNotEmpty)
          ParentInfoRow(
              tr.childFile.address,
              [child.address!.city, child.address!.label]
                  .whereType<String>()
                  .join(', ')),
        ParentInfoRow(
            tr.childFile.specialNeeds,
            (child.specialNeeds?.isNotEmpty ?? false)
                ? child.specialNeeds!
                : tr.childFile.noneReported,
            last: true),
        if (child.editable) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: tr.common.edit,
            size: SoeButtonSize.md,
            variant: SoeButtonVariant.outline,
            onPressed: () =>
                unawaited(context.push(ParentSpaceRoutes.editChild(child.id))),
          ),
        ],
      ],
    );
  }
}

/// « Sécurité de Léa »: serious behaviour goes straight to SOE, from the last held session.
class _SafetyPanel extends ConsumerWidget {
  const _SafetyPanel({required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.childFile;
    return ParentPanel(
      soft: true,
      title: tr.safetyTitle(name: child.firstName),
      children: [
        Text(tr.safetyText,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 12),
        SoeButton(
          label: tr.safetyAction,
          size: SoeButtonSize.md,
          variant: SoeButtonVariant.dangerOutline,
          onPressed: () async {
            final sessions = await ref
                .read(parentChildSessionsProvider(child.id).future)
                .catchError((Object _) => <ParentSession>[]);
            final now = DateTime.now();
            final held = sessions
                .where((session) =>
                    session.startsAt.isBefore(now) &&
                    session.status != 'cancelled')
                .toList();
            if (!context.mounted) return;
            if (held.isEmpty) {
              SoeToast.show(context,
                  message: tr.safetyNoSession, tone: SoeToastTone.warning);
              return;
            }
            unawaited(context
                .push(ParentSpaceRoutes.sessionSerious(held.last.id)));
          },
        ),
      ],
    );
  }
}
