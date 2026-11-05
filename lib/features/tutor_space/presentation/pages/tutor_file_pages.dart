import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_file_address_form.dart';
import '../widgets/tutor_file_availability_form.dart';
import '../widgets/tutor_file_diplomas_form.dart';
import '../widgets/tutor_file_experiences_form.dart';
import '../widgets/tutor_file_identity_form.dart';
import '../widgets/tutor_file_presentation_form.dart';
import '../widgets/tutor_file_subjects_form.dart';
import '../widgets/tutor_file_ui.dart';
import '../widgets/tutor_ui.dart';

/// REP-02 — the recruitment file: where the candidate stands, the 7 sections with their state,
/// what SOE asks to redo, the « Vérifié SOE » badge as parents will see it, the journey; the file
/// is sent once complete.
class TutorFilePage extends ConsumerStatefulWidget {
  const TutorFilePage({super.key});

  @override
  ConsumerState<TutorFilePage> createState() => _TutorFilePageState();
}

class _TutorFilePageState extends ConsumerState<TutorFilePage> {
  bool _busy = false;

  Future<void> _submit() async {
    final tr = Translations.of(context).tutorSpace.file;
    setState(() => _busy = true);
    try {
      await ref.read(tutorFileApiProvider).submit();
      if (!mounted) return;
      refreshTutorFile(ref);
      SoeToast.show(context, message: tr.submitted, tone: SoeToastTone.success);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final value = ref.watch(tutorFileProvider);
    final file = value.valueOrNull;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      bottomNavigationBar: file != null && file.canSubmit
          ? TutorBottomBar(
              hint: tr.submitHint,
              child: SoeButton(
                label: tr.submit,
                fullWidth: true,
                loading: _busy,
                onPressed: _busy ? null : () => unawaited(_submit()),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorFileProvider.future),
        child: TutorAsyncBody<TutorFile>(
          value: value,
          onRetry: () => ref.invalidate(tutorFileProvider),
          builder: (file) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Header(file: file),
              if (_nextRoute(file) != null) ...[
                const SizedBox(height: 16),
                _NextStep(file: file),
              ],
              if (file.toRedo.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ToRedo(items: file.toRedo),
              ],
              const SizedBox(height: 16),
              SoeCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  for (var i = 0; i < file.sections.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppPalette.n100),
                    _SectionRow(section: file.sections[i]),
                  ],
                ]),
              ),
              if (file.badge.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Badge(items: file.badge),
              ],
              const SizedBox(height: 16),
              _Journey(file: file),
            ],
          ),
        ),
      ),
    );
  }
}

/// The screen the next step opens: the interview and test, then the charter.
String? _nextRoute(TutorFile file) => switch (file.stage) {
      'interview' || 'test' => TutorSpaceRoutes.interview,
      'charter' => TutorSpaceRoutes.charter,
      _ => null,
    };

class _Header extends StatelessWidget {
  const _Header({required this.file});

  final TutorFile file;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final (label, tone) = file.refused
        ? (tr.status.refused, SoeBadgeTone.danger)
        : file.active
            ? (tr.status.active, SoeBadgeTone.success)
            : file.filling
                ? (tr.status.filling, SoeBadgeTone.warning)
                : (tr.status.review, SoeBadgeTone.info);
    final text = file.refused
        ? tr.refused
        : file.active
            ? '${tr.active} ${tr.activeDetail}'
            : file.filling
                ? tr.progress(
                    count: file.completeCount, total: file.totalSections)
                : switch (file.stage) {
                    'interview' => tr.waiting.interview,
                    'test' => tr.waiting.test,
                    'charter' => tr.waiting.charter,
                    _ => tr.sent,
                  };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tr.title,
          style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 8),
      Align(
          alignment: Alignment.centerLeft,
          child: SoeBadge(label: label, tone: tone)),
      const SizedBox(height: 8),
      Text(text, style: AppTypography.body.copyWith(color: AppPalette.text2)),
    ]);
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({required this.file});

  final TutorFile file;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final route = _nextRoute(file)!;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.next.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal600)),
        const SizedBox(height: 4),
        Text(file.stepLabel, style: AppTypography.title),
        const SizedBox(height: 12),
        SoeButton(
          label: route == TutorSpaceRoutes.charter
              ? tr.openCharter
              : tr.openInterview,
          variant: SoeButtonVariant.outline,
          size: SoeButtonSize.md,
          onPressed: () => context.push(route),
        ),
      ]),
    );
  }
}

class _ToRedo extends StatelessWidget {
  const _ToRedo({required this.items});

  final List<TutorRedoItem> items;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.dangerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded,
              size: 20, color: AppPalette.dangerText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tr.toRedo(n: items.length),
                style:
                    AppTypography.label.copyWith(color: AppPalette.dangerText)),
          ),
        ]),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Expanded(
                child: Text(
                    item.reason == null
                        ? item.label
                        : tr.redoItem(label: item.label, reason: item.reason!),
                    style: AppTypography.bodySm),
              ),
              TextButton(
                onPressed: () =>
                    context.push(TutorSpaceRoutes.fileSection(item.section)),
                child: Text(tr.redo),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});

  final TutorFileSectionSummary section;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () =>
            context.push(TutorSpaceRoutes.fileSection(section.section)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            TutorFileIcon(tutorFileSectionIcon(section.section)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.label, style: AppTypography.label),
                    if (section.summary.isNotEmpty)
                      Text(section.summary,
                          style: AppTypography.caption.copyWith(
                              color: section.state == 'redo'
                                  ? AppPalette.dangerText
                                  : AppPalette.text2)),
                  ]),
            ),
            const SizedBox(width: 8),
            TutorFileStateBadge(
                state: section.state, label: section.stateLabel),
            const Icon(Icons.chevron_right, color: AppPalette.text3),
          ]),
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.items});

  final List<TutorBadgeItem> items;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.badgeOverline.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal600)),
        const SizedBox(height: 4),
        Text(tr.parentView,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        Text(tr.badgeHint,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppPalette.n300),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                  child: Text(items[i].label,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2))),
              Text(items[i].stateLabel,
                  style: AppTypography.labelSm
                      .copyWith(color: tutorFileColor(items[i].state))),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _Journey extends StatelessWidget {
  const _Journey({required this.file});

  final TutorFile file;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final labels = [
      tr.steps.file,
      tr.steps.documentsCheck,
      tr.steps.interview,
      tr.steps.test,
      tr.steps.charter,
      tr.steps.active,
    ];
    final current = file.active ? labels.length : file.step - 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(tr.journey,
                style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          ),
          Text(
              tr.stepOf(
                  step: file.step,
                  total: file.totalSteps > 0 ? file.totalSteps : labels.length),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              _StepDot(
                  done: i < current, current: i == current && !file.refused),
              const SizedBox(width: 10),
              Expanded(
                child: Text(labels[i],
                    style: AppTypography.bodySm.copyWith(
                        color:
                            i <= current ? AppPalette.text : AppPalette.text2)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.done, required this.current});

  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done
              ? AppPalette.success
              : current
                  ? AppPalette.gold400
                  : AppPalette.white,
          border: done || current
              ? null
              : Border.all(color: AppPalette.n300, width: 1.5),
        ),
        child: done
            ? const Icon(Icons.check, size: 14, color: AppPalette.white)
            : null,
      );
}

/// REP-03 to REP-09 — one section of the file: identity, address, subjects, availability,
/// diplomas, experiences, presentation.
class TutorFileSectionPage extends ConsumerWidget {
  const TutorFileSectionPage({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.file;
    if (!TutorFileSections.all.contains(section)) {
      return Scaffold(
        appBar: AppBar(),
        body: SoeEmptyState(
            title: tr.unknownSection,
            message: '',
            icon: Icons.help_outline,
            actionLabel: tr.backToFile,
            onAction: () => context.go(TutorSpaceRoutes.file)),
      );
    }
    final title = switch (section) {
      TutorFileSections.identity => tr.short.identity,
      TutorFileSections.address => tr.short.address,
      TutorFileSections.subjects => tr.short.subjects,
      TutorFileSections.availability => tr.short.availability,
      TutorFileSections.diplomas => tr.short.diplomas,
      TutorFileSections.experiences => tr.short.experiences,
      _ => tr.short.presentation,
    };
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(title)),
      body: TutorAsyncBody<TutorFileSection>(
        value: ref.watch(tutorFileSectionProvider(section)),
        onRetry: () => ref.invalidate(tutorFileSectionProvider(section)),
        builder: (data) => switch (section) {
          TutorFileSections.identity => TutorFileIdentityForm(data: data),
          TutorFileSections.address => TutorFileAddressForm(data: data),
          TutorFileSections.subjects => TutorFileSubjectsForm(data: data),
          TutorFileSections.availability =>
            TutorFileAvailabilityForm(data: data),
          TutorFileSections.diplomas => TutorFileDiplomasForm(data: data),
          TutorFileSections.experiences => TutorFileExperiencesForm(data: data),
          _ => TutorFilePresentationForm(data: data),
        },
      ),
    );
  }
}
