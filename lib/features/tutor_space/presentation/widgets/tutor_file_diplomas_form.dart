import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_api.dart';
import '../../data/tutor_file_models.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';
import 'tutor_ui.dart';

/// The diploma typed in the add sheet, with its photos.
typedef TutorDiplomaDraft = ({
  Map<String, Object?> fields,
  List<TutorUpload> documents,
});

/// REP-07 — the diplomas and their supporting photos: SOE checks them; one to redo shows SOE's
/// reason and is replaced by removing it and adding the new one.
class TutorFileDiplomasForm extends ConsumerStatefulWidget {
  const TutorFileDiplomasForm({super.key, required this.data});

  final TutorFileSection data;

  /// Photos per diploma at most (TutorSpace::UploadCheck).
  static const documentsMax = 3;

  @override
  ConsumerState<TutorFileDiplomasForm> createState() =>
      _TutorFileDiplomasFormState();
}

class _TutorFileDiplomasFormState extends ConsumerState<TutorFileDiplomasForm>
    with TutorFileSaving {
  Future<void> _add() async {
    final tr = Translations.of(context).tutorSpace.file;
    final draft = await showModalBottomSheet<TutorDiplomaDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppPalette.white,
      builder: (context) => const _AddDiplomaSheet(),
    );
    if (draft == null || !mounted) return;
    await runSave(
      widget.data.section,
      (api) => api.updateSection(widget.data.section, draft.fields,
          files: draft.documents, filesField: 'documents[]'),
      success: tr.saved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trD = tr.diplomas;
    final items = widget.data.diplomas;
    final max = widget.data.diplomasMax;
    final editable = widget.data.editable;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            if (items.isEmpty)
              SoeEmptyState(
                  title: trD.empty,
                  message: trD.emptyText,
                  icon: Icons.school_outlined)
            else
              SoeCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppPalette.n100),
                    TutorFileItemTile(
                      icon: Icons.school_outlined,
                      title: items[i].title.isEmpty
                          ? (items[i].levelOfStudy ?? '')
                          : items[i].title,
                      subtitle: [
                        items[i].levelOfStudy,
                        if (items[i].obtainedAt != null)
                          '${items[i].obtainedAt!.year}',
                        trD.documentsCount(n: items[i].documentsCount),
                      ].whereType<String>().join(' · '),
                      onRemove: !editable || busy
                          ? null
                          : () => unawaited(removeItem(
                              widget.data.section, items[i].id,
                              title: trD.removeTitle, message: trD.removeText)),
                    ),
                  ],
                ]),
              ),
            if (editable) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: SoeButton(
                  label: '+ ${trD.add}',
                  variant: SoeButtonVariant.outline,
                  size: SoeButtonSize.md,
                  onPressed: busy || items.length >= max
                      ? null
                      : () => unawaited(_add()),
                ),
              ),
              const SizedBox(height: 6),
              Text(trD.max(max: max),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ],
          ],
        ),
      ),
      TutorBottomBar(
        hint: widget.data.toRedo ? trD.hintRedo : null,
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

/// The fields of a diploma and up to 3 photos.
class _AddDiplomaSheet extends ConsumerStatefulWidget {
  const _AddDiplomaSheet();

  @override
  ConsumerState<_AddDiplomaSheet> createState() => _AddDiplomaSheetState();
}

class _AddDiplomaSheetState extends ConsumerState<_AddDiplomaSheet> {
  final _category = TextEditingController();
  final _level = TextEditingController();
  final _field = TextEditingController();
  final _speciality = TextEditingController();
  DateTime? _obtainedAt;
  final List<TutorUpload> _documents = [];

  @override
  void dispose() {
    _category.dispose();
    _level.dispose();
    _field.dispose();
    _speciality.dispose();
    super.dispose();
  }

  bool get _complete =>
      _category.text.trim().isNotEmpty && _level.text.trim().isNotEmpty;

  Future<void> _addPhoto() async {
    final photo = await pickTutorPhoto(context, ref);
    if (photo == null || !mounted) return;
    setState(() => _documents.add(photo));
  }

  void _done() => Navigator.of(context).pop<TutorDiplomaDraft>((
        fields: {
          'category': _category.text.trim(),
          'level_of_study': _level.text.trim(),
          'field_of_training': _field.text.trim(),
          'speciality': _speciality.text.trim(),
          if (_obtainedAt != null)
            'obtained_at': TutorFileApi.day(_obtainedAt!),
        },
        documents: [..._documents],
      ));

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trD = tr.diplomas;
    return TutorSheet(children: [
      Text(trD.add,
          style: AppTypography.title.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 12),
      SoeTextField(
          controller: _category,
          label: trD.category,
          hint: trD.categoryHint,
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 12),
      SoeTextField(
          controller: _level,
          label: trD.level,
          hint: trD.levelHint,
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 12),
      SoeTextField(controller: _field, label: trD.field),
      const SizedBox(height: 12),
      SoeTextField(controller: _speciality, label: trD.speciality),
      const SizedBox(height: 12),
      TutorDateField(
        label: trD.obtainedAt,
        value: _obtainedAt,
        last: DateTime.now(),
        onChanged: (d) => setState(() => _obtainedAt = d),
      ),
      const SizedBox(height: 16),
      Text(trD.documents, style: AppTypography.label),
      Text(
          '${trD.documentsHelp(max: TutorFileDiplomasForm.documentsMax)} ${tr.photo.imagesOnly}',
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < _documents.length; i++)
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(Uint8List.fromList(_documents[i].bytes),
                  width: 72, height: 72, fit: BoxFit.cover),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => setState(() => _documents.removeAt(i)),
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppPalette.white, shape: BoxShape.circle),
                  child: Icon(Icons.close,
                      size: 18,
                      color: AppPalette.dangerText,
                      semanticLabel: tr.remove),
                ),
              ),
            ),
          ]),
        if (_documents.length < TutorFileDiplomasForm.documentsMax)
          SoeButton(
            label: trD.addPhoto,
            icon: Icons.photo_camera_outlined,
            variant: SoeButtonVariant.outline,
            size: SoeButtonSize.sm,
            onPressed: () => unawaited(_addPhoto()),
          ),
      ]),
      const SizedBox(height: 20),
      if (!_complete)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(trD.hint,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ),
      SoeButton(
        label: tr.add,
        fullWidth: true,
        onPressed: _complete ? _done : null,
      ),
    ]);
  }
}
