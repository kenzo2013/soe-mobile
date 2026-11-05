import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import '../../data/tutor_references.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';
import 'tutor_ui.dart';

/// REP-05 — the subjects taught, class by class: each class with its subjects, removed as a
/// whole; a class and its subjects added from the references (added to what is on file).
class TutorFileSubjectsForm extends ConsumerStatefulWidget {
  const TutorFileSubjectsForm({super.key, required this.data});

  final TutorFileSection data;

  @override
  ConsumerState<TutorFileSubjectsForm> createState() =>
      _TutorFileSubjectsFormState();
}

class _TutorFileSubjectsFormState extends ConsumerState<TutorFileSubjectsForm>
    with TutorFileSaving {
  Future<void> _add() async {
    final tr = Translations.of(context).tutorSpace.file;
    final choice = await showModalBottomSheet<({int classId, List<int> ids})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppPalette.white,
      builder: (context) => const _AddCourseSheet(),
    );
    if (choice == null || !mounted) return;
    await runSave(
      widget.data.section,
      (api) => api.updateSection(widget.data.section, {
        'school_class_id': choice.classId,
        'subject_ids': choice.ids,
      }),
      success: tr.saved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trS = tr.subjects;
    final courses = widget.data.courses;
    final subjectCount = courses.expand((c) => c.subjects).toSet().length;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            if (courses.isEmpty)
              SoeEmptyState(
                title: trS.empty,
                message: trS.emptyText,
                icon: Icons.menu_book_outlined,
              )
            else
              SoeCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  for (var i = 0; i < courses.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppPalette.n100),
                    TutorFileItemTile(
                      icon: Icons.menu_book_outlined,
                      title: courses[i].schoolClass ?? '',
                      subtitle: courses[i].subjects.join(', '),
                      onRemove: busy
                          ? null
                          : () => unawaited(removeItem(
                              widget.data.section, courses[i].id,
                              title: trS.removeTitle, message: trS.removeText)),
                    ),
                  ],
                ]),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: SoeButton(
                label: '+ ${trS.add}',
                variant: SoeButtonVariant.outline,
                size: SoeButtonSize.md,
                onPressed: busy ? null : () => unawaited(_add()),
              ),
            ),
          ],
        ),
      ),
      TutorBottomBar(
        hint: courses.isEmpty
            ? trS.hint
            : '${trS.subjectsCount(n: subjectCount)} · ${trS.classesCount(n: courses.length)}',
        child: SoeButton(
          label: tr.continueLabel,
          fullWidth: true,
          onPressed: busy
              ? null
              : () => continueTutorFile(context, widget.data.section),
        ),
      ),
    ]);
  }
}

/// Picks a school class and its subjects from the references.
class _AddCourseSheet extends ConsumerStatefulWidget {
  const _AddCourseSheet();

  @override
  ConsumerState<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends ConsumerState<_AddCourseSheet> {
  int? _classId;
  final Set<int> _subjectIds = {};

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trS = tr.subjects;
    final references = ref.watch(tutorReferencesProvider);
    return TutorSheet(children: [
      Text(trS.addTitle,
          style: AppTypography.title.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 12),
      references.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Text(
            tutorFailureMessage(context, asFailure(error)),
            style: AppTypography.body.copyWith(color: AppPalette.dangerText)),
        data: (refs) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(trS.schoolClass, style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in refs.schoolClasses)
              SoeChip(
                label: c.abbr ?? c.name,
                selected: _classId == c.id,
                onTap: () => setState(() => _classId = c.id),
              ),
          ]),
          const SizedBox(height: 16),
          Text(trS.subjects, style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in refs.subjects)
              SoeChip(
                label: s.name,
                selected: _subjectIds.contains(s.id),
                onTap: () => setState(() => _subjectIds.contains(s.id)
                    ? _subjectIds.remove(s.id)
                    : _subjectIds.add(s.id)),
              ),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      SoeButton(
        label: tr.add,
        fullWidth: true,
        onPressed: _classId == null || _subjectIds.isEmpty
            ? null
            : () => Navigator.of(context)
                .pop((classId: _classId!, ids: _subjectIds.toList())),
      ),
    ]);
  }
}
