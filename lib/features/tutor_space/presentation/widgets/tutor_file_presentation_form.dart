import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_api.dart';
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';

/// REP-09 — the photo and the presentation the families read (at most `bio_max` characters, the
/// « texte trop long » state beyond), with writing help. The last section: when the 6 others are
/// complete, saving also sends the file to SOE.
class TutorFilePresentationForm extends ConsumerStatefulWidget {
  const TutorFilePresentationForm({super.key, required this.data});

  final TutorFileSection data;

  @override
  ConsumerState<TutorFilePresentationForm> createState() =>
      _TutorFilePresentationFormState();
}

class _TutorFilePresentationFormState
    extends ConsumerState<TutorFilePresentationForm> with TutorFileSaving {
  late final TutorPresentationContent _onFile = widget.data.presentation;
  late final _bio = TextEditingController(text: _onFile.bio ?? '');
  TutorUpload? _photo;

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  int get _length => _bio.text.trim().length;
  bool get _tooLong => _length > _onFile.bioMax;
  bool get _changed =>
      _photo != null || _bio.text.trim() != (_onFile.bio ?? '').trim();
  bool get _complete => (_onFile.hasPhoto || _photo != null) && _length > 0;

  Future<void> _pickPhoto() async {
    final photo = await pickTutorPhoto(context, ref);
    if (photo == null || !mounted) return;
    setState(() => _photo = photo);
  }

  Future<void> _save({required bool send}) async {
    final tr = Translations.of(context).tutorSpace.file;
    final section = widget.data.section;
    final ok = await runSave(
      section,
      (api) async {
        if (_changed) {
          await api.updateSection(section, {'content': _bio.text.trim()},
              files: [if (_photo != null) _photo!], filesField: 'photo');
        }
        if (send) await api.submit();
      },
      success: send ? tr.submitted : tr.saved,
    );
    if (ok && mounted) continueTutorFile(context, section);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trP = tr.presentation;
    final file = ref.watch(tutorFileProvider).valueOrNull;
    final send = file != null &&
        file.filling &&
        file.completeExcept(TutorFileSections.presentation) &&
        _complete;
    final over = _length - _onFile.bioMax;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context, insets: false),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(trP.photo, style: AppTypography.label)),
                      Text(trP.photoTip,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    ]),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => unawaited(_pickPhoto()),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppPalette.surfaceSoft,
                          backgroundImage: _photo == null
                              ? null
                              : MemoryImage(Uint8List.fromList(_photo!.bytes)),
                          child: _photo == null
                              ? Icon(
                                  _onFile.hasPhoto
                                      ? Icons.check
                                      : Icons.photo_camera_outlined,
                                  color: _onFile.hasPhoto
                                      ? AppPalette.success
                                      : AppPalette.text2)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _onFile.hasPhoto || _photo != null
                                        ? trP.changePhoto
                                        : trP.addPhoto,
                                    style: AppTypography.label
                                        .copyWith(color: AppPalette.teal600)),
                                Text(
                                    _photo != null
                                        ? trP.photoNew
                                        : _onFile.hasPhoto
                                            ? trP.photoOnFile
                                            : trP.photoNeeded,
                                    style: AppTypography.caption
                                        .copyWith(color: AppPalette.text2)),
                              ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Text(trP.bio,
                        style: AppTypography.label.copyWith(
                            color: _tooLong
                                ? AppPalette.dangerText
                                : AppPalette.text)),
                    const SizedBox(height: 6),
                    SoeTextField(
                      controller: _bio,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      errorText: _tooLong
                          ? trP.tooLong(max: _onFile.bioMax, n: over)
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(trP.counter(n: _length, max: _onFile.bioMax),
                          style: AppTypography.caption.copyWith(
                              color: _tooLong
                                  ? AppPalette.dangerText
                                  : AppPalette.text2)),
                    ),
                  ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trP.tipsTitle,
                        style: AppTypography.h3
                            .copyWith(color: AppPalette.teal800)),
                    const SizedBox(height: 8),
                    for (final tip in [trP.tip1, trP.tip2, trP.tip3, trP.tip4])
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.edit_outlined,
                                  size: 16, color: AppPalette.teal600),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      Text(tip, style: AppTypography.bodySm)),
                            ]),
                      ),
                  ]),
            ),
          ],
        ),
      ),
      TutorBottomBar(
        hint: _tooLong
            ? trP.hintTooLong
            : send
                ? tr.submitHint
                : _photo != null
                    ? tr.backToReview
                    : null,
        child: SoeButton(
          label: send ? trP.saveAndSend : trP.save,
          fullWidth: true,
          loading: busy,
          onPressed:
              busy || _tooLong ? null : () => unawaited(_save(send: send)),
        ),
      ),
    ]);
  }
}
