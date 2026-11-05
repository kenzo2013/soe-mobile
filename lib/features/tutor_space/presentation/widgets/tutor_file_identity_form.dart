import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_api.dart';
import '../../data/tutor_file_models.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';

/// REP-03 — the identity document: its type, the dates, the photos of the front and the back
/// with a guided frame, the photo to redo with SOE's reason. A new document replaces the previous
/// one and goes back to SOE's review; it is always sent with its photos.
class TutorFileIdentityForm extends ConsumerStatefulWidget {
  const TutorFileIdentityForm({super.key, required this.data});

  final TutorFileSection data;

  @override
  ConsumerState<TutorFileIdentityForm> createState() =>
      _TutorFileIdentityFormState();
}

class _TutorFileIdentityFormState extends ConsumerState<TutorFileIdentityForm>
    with TutorFileSaving {
  static const _types = ['cni', 'passport', 'residence_permit'];

  late final TutorIdentityContent _onFile = widget.data.identity;
  late String? _type =
      _types.contains(_onFile.documentType) ? _onFile.documentType : null;
  late DateTime? _birthdate = _onFile.birthdate;
  late DateTime? _expiresOn = _onFile.expiresOn;
  TutorUpload? _front;
  TutorUpload? _back;

  bool get _editable => widget.data.editable;
  bool get _backNeeded => _type != 'passport';

  bool get _changed =>
      _front != null ||
      _back != null ||
      _type != _onFile.documentType ||
      _birthdate != _onFile.birthdate ||
      _expiresOn != _onFile.expiresOn;

  /// Why the document cannot be saved yet (null: it can).
  String? _missing(TranslationsTutorSpaceFileIdentityFr tr) {
    if (_type == null || _birthdate == null || _expiresOn == null) {
      return tr.hintType;
    }
    if (_front == null) {
      return widget.data.toRedo
          ? tr.hintRedo
          : _onFile.imagesCount > 0
              ? tr.hintPhotos
              : tr.hintFront;
    }
    if (_backNeeded && _back == null) return tr.hintBack;
    return null;
  }

  Future<void> _pick(bool front) async {
    final photo = await pickTutorPhoto(context, ref);
    if (photo == null || !mounted) return;
    setState(() => front ? _front = photo : _back = photo);
  }

  Future<void> _save() async {
    final tr = Translations.of(context).tutorSpace.file;
    if (!_editable || !_changed) {
      continueTutorFile(context, widget.data.section);
      return;
    }
    final ok = await runSave(
      widget.data.section,
      (api) => api.updateSection(
        widget.data.section,
        {
          'document_type': _type,
          'birthdate': TutorFileApi.day(_birthdate!),
          'expires_on': TutorFileApi.day(_expiresOn!),
        },
        files: [_front!, if (_back != null) _back!],
        filesField: 'images[]',
      ),
      success: tr.saved,
    );
    if (ok && mounted) continueTutorFile(context, widget.data.section);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trId = tr.identity;
    // A document to redo is never left as is: its photo is taken again.
    final missing =
        _editable && (_changed || widget.data.toRedo) ? _missing(trId) : null;
    final today = DateTime.now();
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trId.documentType, style: AppTypography.label),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final type in _types)
                        SoeChip(
                          label: switch (type) {
                            'cni' => trId.types.cni,
                            'passport' => trId.types.passport,
                            _ => trId.types.residencePermit,
                          },
                          selected: _type == type,
                          onTap: _editable
                              ? () => setState(() => _type = type)
                              : null,
                        ),
                    ]),
                    const SizedBox(height: 16),
                    TutorDateField(
                      label: trId.birthdate,
                      value: _birthdate,
                      last: today,
                      enabled: _editable,
                      onChanged: (d) => setState(() => _birthdate = d),
                    ),
                    const SizedBox(height: 16),
                    TutorDateField(
                      label: trId.expiresOn,
                      value: _expiresOn,
                      first: DateTime(today.year - 10),
                      enabled: _editable,
                      onChanged: (d) => setState(() => _expiresOn = d),
                    ),
                  ]),
            ),
            const SizedBox(height: 12),
            _PhotoSlot(
              title: trId.front,
              data: widget.data,
              onFile: _onFile.imagesCount >= 1,
              photo: _front,
              editable: _editable,
              onPick: () => unawaited(_pick(true)),
            ),
            const SizedBox(height: 12),
            _PhotoSlot(
              title: _backNeeded ? trId.back : trId.backOptional,
              data: widget.data,
              onFile: _onFile.imagesCount >= 2,
              photo: _back,
              editable: _editable,
              onPick: () => unawaited(_pick(false)),
            ),
          ],
        ),
      ),
      TutorBottomBar(
        hint: missing ?? (_editable && _changed ? tr.backToReview : null),
        child: SoeButton(
          label: _editable ? tr.saveContinue : tr.continueLabel,
          fullWidth: true,
          loading: busy,
          onPressed: busy || missing != null ? null : () => unawaited(_save()),
        ),
      ),
    ]);
  }
}

/// A side of the document: on file, newly taken, to take (guided frame) or refused (to redo).
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.title,
    required this.data,
    required this.onFile,
    required this.photo,
    required this.editable,
    required this.onPick,
  });

  final String title;
  final TutorFileSection data;
  final bool onFile;
  final TutorUpload? photo;
  final bool editable;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file.identity;
    final refused = data.toRedo && photo == null;
    final Widget frame;
    final String button;
    var primary = false;
    if (photo != null) {
      frame = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(Uint8List.fromList(photo!.bytes),
            height: 170, width: double.infinity, fit: BoxFit.cover),
      );
      button = tr.retake;
    } else if (refused) {
      frame = _Frame(
        color: AppPalette.dangerBg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppPalette.dangerText, size: 28),
          const SizedBox(height: 6),
          Text(tr.refused,
              style:
                  AppTypography.labelSm.copyWith(color: AppPalette.dangerText)),
        ]),
      );
      button = tr.retakeRefused;
      primary = true;
    } else if (onFile) {
      frame = _Frame(
        color: AppPalette.teal50,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.badge_outlined, color: AppPalette.teal700),
          const SizedBox(height: 6),
          Text(tr.onFile,
              style: AppTypography.caption.copyWith(color: AppPalette.teal700)),
        ]),
      );
      button = tr.retake;
    } else {
      frame = _Frame(
        color: AppPalette.teal800,
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.white, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(tr.frameTitle,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(color: AppPalette.white)),
            const SizedBox(height: 10),
            const Icon(Icons.photo_camera_outlined, color: AppPalette.white),
            const SizedBox(height: 10),
            Text(tr.frameHint,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppPalette.white)),
          ]),
        ),
      );
      button = tr.take;
      primary = true;
    }
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: AppTypography.label)),
          if (photo == null && (onFile || refused))
            TutorFileStateBadge(state: data.state, label: data.stateLabel),
        ]),
        const SizedBox(height: 10),
        frame,
        if (refused && data.redoReason != null) ...[
          const SizedBox(height: 8),
          Text(data.redoReason!,
              style:
                  AppTypography.caption.copyWith(color: AppPalette.dangerText)),
        ],
        if (editable) ...[
          const SizedBox(height: 10),
          SoeButton(
            label: button,
            icon: Icons.photo_camera_outlined,
            fullWidth: true,
            size: SoeButtonSize.md,
            variant:
                primary ? SoeButtonVariant.secondary : SoeButtonVariant.outline,
            onPressed: onPick,
          ),
        ],
      ]),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        height: 170,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}
