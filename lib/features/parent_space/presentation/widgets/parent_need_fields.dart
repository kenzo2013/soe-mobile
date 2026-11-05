import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import 'parent_ui.dart';
import 'parent_widgets.dart';

/// The fields of a child's need (PAR-05 step 2, PAR-07 « Modifier le besoin »): subjects,
/// goal, start, sessions per week, length, moments, tutor preference. The labelled options
/// come from the request draft.
class ParentNeedFields extends StatelessWidget {
  const ParentNeedFields({
    super.key,
    required this.need,
    required this.draft,
    required this.subjects,
    required this.onChanged,
    this.missing = const {},
    this.subjectsLoading = false,
    this.onRetrySubjects,
  });

  final ParentNeed need;
  final ParentRequestDraft draft;
  final List<ParentSubject> subjects;
  final ValueChanged<ParentNeed> onChanged;

  /// Fields the server found missing.
  final Set<String> missing;

  /// The child's class is still loading: the subjects wait (no unfiltered list to tick).
  final bool subjectsLoading;

  /// The child's class could not be loaded: the subjects are replaced by a retry.
  final VoidCallback? onRetrySubjects;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.wizard;
    final catalogTr = Translations.of(context).schoolCatalog;
    String? error(String field) => missing.contains(field)
        ? Translations.of(context).parentSpace.common.required
        : null;
    void update(ParentNeed next) => onChanged(next);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ParentFieldLabel(tr.subjects),
      if (subjectsLoading)
        Semantics(
          label: catalogTr.subjectsLoading,
          child: const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SoeSkeleton(
                    width: 96, height: 36, borderRadius: AppRadius.rPill),
                SoeSkeleton(
                    width: 120, height: 36, borderRadius: AppRadius.rPill),
                SoeSkeleton(
                    width: 80, height: 36, borderRadius: AppRadius.rPill),
              ]),
        )
      else if (onRetrySubjects != null) ...[
        ParentErrorText(catalogTr.subjectsUnavailable),
        SoeButton(
          label: catalogTr.retry,
          variant: SoeButtonVariant.outline,
          size: SoeButtonSize.sm,
          icon: Icons.refresh,
          onPressed: onRetrySubjects,
        ),
      ] else
        ParentChoiceChips<int>(
          options: [for (final subject in subjects) (subject.id, subject.name)],
          selected: need.subjectIds.toSet(),
          onToggle: (id) => update(need.copyWith(
              subjectIds: need.subjectIds.contains(id)
                  ? (need.subjectIds.toList()..remove(id))
                  : [...need.subjectIds, id])),
        ),
      if (missing.contains('subjects_not_taught'))
        ParentErrorText(catalogTr.notTaught),
      if (error('subject_ids') != null || error('subjects') != null)
        ParentErrorText(Translations.of(context).parentSpace.common.required),
      ParentFieldLabel(tr.objective),
      ParentSegmented<String>(
        options: [
          for (final option in draft.objectives) (option.value, option.label)
        ],
        value: need.objective,
        onChanged: (value) => update(need.copyWith(objective: value)),
      ),
      if (error('objective') != null) ParentErrorText(error('objective')!),
      ParentFieldLabel(tr.startOn),
      ParentPickerField(
        icon: Icons.calendar_today_outlined,
        label: need.startOn == null
            ? tr.chooseDate
            : ParentFormat.dayLong(context, need.startOn!),
        placeholder: need.startOn == null,
        errorText: error('start_on'),
        onTap: () async {
          final today = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: need.startOn != null && need.startOn!.isAfter(today)
                ? need.startOn!
                : today.add(const Duration(days: 7)),
            firstDate: today,
            lastDate: today.add(const Duration(days: 365)),
          );
          if (picked != null) update(need.copyWith(startOn: picked));
        },
      ),
      ParentFieldLabel(tr.sessionsPerWeek),
      ParentSegmented<int>(
        options: [for (final count in draft.sessionsPerWeek) (count, '$count')],
        value: need.sessionsPerWeek,
        onChanged: (value) => update(need.copyWith(sessionsPerWeek: value)),
      ),
      if (error('sessions_per_week') != null)
        ParentErrorText(error('sessions_per_week')!),
      ParentFieldLabel(tr.duration),
      ParentSegmented<int>(
        options: [
          for (final option in draft.sessionMinutes)
            (int.tryParse(option.value) ?? 0, option.label)
        ],
        value: need.sessionMinutes,
        onChanged: (value) => update(need.copyWith(sessionMinutes: value)),
      ),
      if (error('session_minutes') != null)
        ParentErrorText(error('session_minutes')!),
      ParentFieldLabel(tr.moments, optional: true),
      ParentChoiceChips<String>(
        options: [
          for (final option in draft.moments) (option.value, option.label)
        ],
        selected: need.moments.toSet(),
        onToggle: (value) => update(need.copyWith(
            moments: need.moments.contains(value)
                ? (need.moments.toList()..remove(value))
                : [...need.moments, value])),
      ),
      ParentFieldLabel(tr.gender),
      ParentSegmented<String>(
        options: [
          for (final option in draft.genders) (option.value, option.label)
        ],
        value: need.gender,
        onChanged: (value) => update(need.copyWith(gender: value)),
      ),
      if (error('gender') != null) ParentErrorText(error('gender')!),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(tr.genderHint,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ),
    ]);
  }
}
