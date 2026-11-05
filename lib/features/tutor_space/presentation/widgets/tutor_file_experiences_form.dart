import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_checkbox.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';
import 'tutor_ui.dart';

/// REP-08 — the teaching experiences, even informal: listed, added, removed. One at least is
/// needed to send the file.
class TutorFileExperiencesForm extends ConsumerStatefulWidget {
  const TutorFileExperiencesForm({super.key, required this.data});

  final TutorFileSection data;

  @override
  ConsumerState<TutorFileExperiencesForm> createState() =>
      _TutorFileExperiencesFormState();
}

class _TutorFileExperiencesFormState
    extends ConsumerState<TutorFileExperiencesForm> with TutorFileSaving {
  Future<void> _add() async {
    final tr = Translations.of(context).tutorSpace.file;
    final fields = await showModalBottomSheet<Map<String, Object?>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppPalette.white,
      builder: (context) => const _AddExperienceSheet(),
    );
    if (fields == null || !mounted) return;
    await runSave(widget.data.section,
        (api) => api.updateSection(widget.data.section, fields),
        success: tr.saved);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trE = tr.experiences;
    final items = widget.data.experiences;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            if (items.isEmpty)
              SoeEmptyState(
                title: trE.empty,
                message: trE.emptyText,
                icon: Icons.work_outline,
                actionLabel: trE.add,
                onAction: busy ? null : () => unawaited(_add()),
              )
            else ...[
              SoeCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppPalette.n100),
                    TutorFileItemTile(
                      icon: Icons.work_outline,
                      title: items[i].position ?? '',
                      subtitle: [
                        items[i].company,
                        if (items[i].currentPosition) trE.current,
                      ].whereType<String>().join(' · '),
                      onRemove: busy
                          ? null
                          : () => unawaited(removeItem(
                              widget.data.section, items[i].id,
                              title: trE.removeTitle, message: trE.removeText)),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: SoeButton(
                  label: '+ ${trE.add}',
                  variant: SoeButtonVariant.outline,
                  size: SoeButtonSize.md,
                  onPressed: busy ? null : () => unawaited(_add()),
                ),
              ),
            ],
          ],
        ),
      ),
      TutorBottomBar(
        hint: items.isEmpty ? trE.required : null,
        child: SoeButton(
          label: items.isEmpty ? trE.continueWithout : tr.continueLabel,
          fullWidth: true,
          onPressed: busy
              ? null
              : () => continueTutorFile(context, widget.data.section),
        ),
      ),
    ]);
  }
}

class _AddExperienceSheet extends StatefulWidget {
  const _AddExperienceSheet();

  @override
  State<_AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<_AddExperienceSheet> {
  final _position = TextEditingController();
  final _company = TextEditingController();
  bool _current = false;

  @override
  void dispose() {
    _position.dispose();
    _company.dispose();
    super.dispose();
  }

  bool get _complete =>
      _position.text.trim().isNotEmpty && _company.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trE = tr.experiences;
    return TutorSheet(children: [
      Text(trE.add,
          style: AppTypography.title.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 12),
      SoeTextField(
          controller: _position,
          label: trE.position,
          hint: trE.positionHint,
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 12),
      SoeTextField(
          controller: _company,
          label: trE.company,
          hint: trE.companyHint,
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 12),
      SoeCheckbox(
        value: _current,
        label: Text(trE.current, style: AppTypography.body),
        onChanged: (value) => setState(() => _current = value),
      ),
      const SizedBox(height: 20),
      if (!_complete)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(trE.hint,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ),
      SoeButton(
        label: tr.add,
        fullWidth: true,
        onPressed: _complete
            ? () => Navigator.of(context).pop<Map<String, Object?>>({
                  'position': _position.text.trim(),
                  'company': _company.text.trim(),
                  'current_position': _current ? '1' : '0',
                })
            : null,
      ),
    ]);
  }
}
