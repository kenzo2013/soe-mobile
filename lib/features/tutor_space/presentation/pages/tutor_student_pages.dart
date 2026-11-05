import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_student_models.dart';
import '../tutor_offer_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_offer_ui.dart';
import '../widgets/tutor_ui.dart';

/// REP-14 — the pupils, a tab of the tutor shell: one card each with the class, the subjects,
/// the neighbourhood, the state and the approved weekly times (or the start).
class TutorStudentsPage extends ConsumerWidget {
  const TutorStudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.students;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(tr.title,
                style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          ),
          Expanded(
            child: TutorAsyncBody<List<TutorPupil>>(
              value: ref.watch(tutorStudentsProvider),
              onRetry: () => ref.invalidate(tutorStudentsProvider),
              builder: (pupils) => RefreshIndicator(
                onRefresh: () => ref.refresh(tutorStudentsProvider.future),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  if (pupils.isEmpty)
                    SoeEmptyState(
                        title: tr.empty,
                        message: tr.emptyText,
                        icon: Icons.people_outline)
                  else
                    TutorListCard(children: [
                      for (final pupil in pupils)
                        TutorListTile(
                          leading: TutorTileLeading(
                              text: TutorOfferFormat.initials(pupil.pupil)),
                          title: TutorOfferFormat.pupilName(
                              pupil.pupil, pupil.schoolClass),
                          subtitle: _summary(context, pupil),
                          badge: TutorToneBadge(
                              state: pupil.state, label: pupil.stateLabel),
                          onTap: () => unawaited(
                              context.push(TutorSpaceRoutes.student(pupil.id))),
                        ),
                    ]),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// « Maths et physique · Bonapriso · mer. 16:00, sam. 9:00 », or « début lun. 7 déc. ».
  static String _summary(BuildContext context, TutorPupil pupil) {
    final tr = Translations.of(context).tutorSpace.students;
    final when = pupil.times.isNotEmpty
        ? pupil.times
            .map((time) => TutorOfferFormat.shortTime(context, time))
            .join(', ')
        : pupil.startDate == null
            ? null
            : tr.starts(date: TutorFormat.day(context, pupil.startDate!));
    return [pupil.subjects.join(', '), pupil.neighborhood, when]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' · ');
  }
}

/// REP-14 — a pupil's file: the weekly times (or the slots to plan), the address, the landmark
/// and the parents once the contract is signed (hidden with an explanation before), the reports.
class TutorStudentPage extends ConsumerWidget {
  const TutorStudentPage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.students.detail;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: TutorAsyncBody<TutorPupilFile>(
        value: ref.watch(tutorStudentProvider(studentId)),
        onRetry: () => ref.invalidate(tutorStudentProvider(studentId)),
        builder: (file) {
          // The state is on the pupil cards (already read when coming from the tab).
          final card = ref
              .watch(tutorStudentsProvider)
              .valueOrNull
              ?.where((pupil) => pupil.id == studentId)
              .firstOrNull;
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(tutorStudentProvider(studentId).future),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(
                  [file.subjects.join(', '), file.neighborhood]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(' · ')
                      .toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal500)),
              const SizedBox(height: 4),
              Text(TutorOfferFormat.pupilName(file.pupil, file.schoolClass),
                  style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
              if (card != null) ...[
                const SizedBox(height: 6),
                Align(
                    alignment: Alignment.centerLeft,
                    child: TutorToneBadge(
                        state: card.state, label: card.stateLabel)),
              ],
              const SizedBox(height: 16),
              _TimesCard(file: file),
              const SizedBox(height: 12),
              if (file.contactShared)
                _ContactCard(file: file)
              else
                _MutedCard(title: tr.contactHidden, text: tr.contactHiddenText),
              const SizedBox(height: 12),
              _ReportsCard(file: file),
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }
}

/// A soft card with a title and an explanation (what is hidden before the contract).
class _MutedCard extends StatelessWidget {
  const _MutedCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppPalette.surfaceSoft,
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 6),
          Text(text,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        ]),
      );
}

/// The approved weekly times; the slots whose times are to propose open REP-15.
class _TimesCard extends StatelessWidget {
  const _TimesCard({required this.file});

  final TutorPupilFile file;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.students.detail;
    if (file.times.isEmpty && file.slotsToPlan.isEmpty) {
      return _MutedCard(
          title: tr.times,
          text: file.contactShared ? tr.noTimes : tr.timesAfterContract);
    }
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(tr.times,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        for (var i = 0; i < file.times.length; i++)
          TutorInfoRow(
            label: TutorFormat.weekday(context, file.times[i].day),
            value: file.times[i].hours,
            last: i == file.times.length - 1,
          ),
        if (file.times.isEmpty)
          Text(tr.noTimes,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        for (final slot in file.slotsToPlan) ...[
          const SizedBox(height: 8),
          SoeButton(
            label: slot.subject == null
                ? tr.proposeNoSubject
                : tr.propose(subject: slot.subject!),
            variant: SoeButtonVariant.secondary,
            size: SoeButtonSize.md,
            fullWidth: true,
            onPressed: () =>
                unawaited(context.push(TutorSpaceRoutes.times(slot.slotId))),
          ),
        ],
      ]),
    );
  }
}

/// The address, the landmark and the parents (once the contract is signed): directions, call.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.file});

  final TutorPupilFile file;

  Future<void> _open(BuildContext context, Uri uri) async {
    final message =
        Translations.of(context).tutorSpace.students.detail.cannotOpen;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened && context.mounted) {
      SoeToast.show(context, message: message, tone: SoeToastTone.danger);
    }
  }

  Future<void> _call(BuildContext context) async {
    final parents = file.callableParents;
    final parent = parents.length == 1
        ? parents.first
        : await showModalBottomSheet<TutorPupilParent>(
            context: context,
            builder: (sheet) => SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      Translations.of(context)
                          .tutorSpace
                          .students
                          .detail
                          .callWho,
                      style: AppTypography.title),
                ),
                for (final p in parents)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(p.name),
                    subtitle: Text(p.phone!),
                    onTap: () => Navigator.of(sheet).pop(p),
                  ),
              ]),
            ),
          );
    if (parent == null || !context.mounted) return;
    await _open(context, Uri(scheme: 'tel', path: parent.phone));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.students.detail;
    final place = [file.address, file.neighborhood]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');
    final rows = <(String, String)>[
      if (file.address != null) (tr.address, file.address!),
      if (file.address == null && file.neighborhood != null)
        (tr.neighborhood, file.neighborhood!),
      if (file.landmark != null) (tr.landmark, file.landmark!),
      for (final parent in file.parents)
        (
          tr.parent,
          [parent.name, parent.phone]
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .join(' · ')
        ),
    ];
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(tr.contact,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        for (var i = 0; i < rows.length; i++)
          TutorInfoRow(
              label: rows[i].$1, value: rows[i].$2, last: i == rows.length - 1),
        const SizedBox(height: 12),
        Row(children: [
          if (place.isNotEmpty)
            SoeButton(
              label: tr.route,
              variant: SoeButtonVariant.outline,
              size: SoeButtonSize.md,
              onPressed: () => unawaited(_open(
                  context,
                  Uri.https('www.google.com', '/maps/search/',
                      {'api': '1', 'query': place}))),
            ),
          if (file.callableParents.isNotEmpty) ...[
            const SizedBox(width: 8),
            SoeButton(
              label: tr.call,
              icon: Icons.phone_outlined,
              variant: SoeButtonVariant.tertiary,
              size: SoeButtonSize.md,
              onPressed: () => unawaited(_call(context)),
            ),
          ],
        ]),
      ]),
    );
  }
}

/// The reports written for the pupil, the latest first; a tap opens the session.
class _ReportsCard extends StatelessWidget {
  const _ReportsCard({required this.file});

  final TutorPupilFile file;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.students.detail;
    if (file.reports.isEmpty) {
      return _MutedCard(title: tr.reports, text: tr.noReport);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TutorSectionTitle(tr.reports),
      TutorListCard(children: [
        for (final report in file.reports)
          TutorListTile(
            leading: const TutorTileLeading(icon: Icons.description_outlined),
            title: report.date == null
                ? ''
                : TutorFormat.day(context, report.date!),
            subtitle: report.topics.join(' · '),
            badge:
                TutorStateBadge(state: report.state, label: report.stateLabel),
            onTap: () => unawaited(
                context.push(TutorSpaceRoutes.session(report.sessionId))),
          ),
      ]),
    ]);
  }
}
