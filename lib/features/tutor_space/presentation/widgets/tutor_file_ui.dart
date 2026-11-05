import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_api.dart';
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import 'tutor_ui.dart';

/// Shared bits of the recruitment screens: state badges, section icons, the photo picker, the
/// section progress, the bottom bar.

/// The tone of a state of the file (missing, in_review, complete, accepted, redo, upcoming).
SoeBadgeTone tutorFileTone(String state) => switch (state) {
      'accepted' || 'complete' => SoeBadgeTone.success,
      'in_review' => SoeBadgeTone.info,
      'redo' => SoeBadgeTone.danger,
      _ => SoeBadgeTone.neutral,
    };

/// The text colour of a state (badge rows, summaries).
Color tutorFileColor(String state) => switch (state) {
      'accepted' || 'complete' => AppPalette.successText,
      'in_review' => AppPalette.infoText,
      'redo' => AppPalette.dangerText,
      _ => AppPalette.text2,
    };

class TutorFileStateBadge extends StatelessWidget {
  const TutorFileStateBadge(
      {super.key, required this.state, required this.label});

  final String state;
  final String label;

  @override
  Widget build(BuildContext context) =>
      SoeBadge(label: label, tone: tutorFileTone(state));
}

IconData tutorFileSectionIcon(String section) => switch (section) {
      TutorFileSections.identity => Icons.badge_outlined,
      TutorFileSections.address => Icons.location_on_outlined,
      TutorFileSections.subjects => Icons.menu_book_outlined,
      TutorFileSections.availability => Icons.calendar_today_outlined,
      TutorFileSections.diplomas => Icons.school_outlined,
      TutorFileSections.experiences => Icons.work_outline,
      _ => Icons.person_outline,
    };

/// A round icon of a list row.
class TutorFileIcon extends StatelessWidget {
  const TutorFileIcon(this.icon, {super.key, this.color = AppPalette.teal600});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: AppPalette.teal50, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      );
}

/// Asks camera or gallery, then returns the photo (null when cancelled). A failure of the
/// picker (permission refused) shows a toast.
Future<TutorUpload?> pickTutorPhoto(BuildContext context, WidgetRef ref) async {
  final tr = Translations.of(context).tutorSpace.file.photo;
  final camera = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppPalette.white,
    showDragHandle: true,
    builder: (context) => TutorSheet(children: [
      Text(tr.sourceTitle,
          style: AppTypography.title.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 4),
      Text(tr.imagesOnly,
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.photo_camera_outlined),
        title: Text(tr.camera),
        onTap: () => Navigator.of(context).pop(true),
      ),
      ListTile(
        leading: const Icon(Icons.photo_library_outlined),
        title: Text(tr.gallery),
        onTap: () => Navigator.of(context).pop(false),
      ),
    ]),
  );
  if (camera == null) return null;
  try {
    return await ref.read(tutorImagePickerProvider).pick(camera: camera);
  } on Exception {
    if (context.mounted) {
      SoeToast.show(context,
          message: Translations.of(context).errors.unknown,
          tone: SoeToastTone.danger);
    }
    return null;
  }
}

/// « Section 3 sur 7 » and its 7 segments: done, current, to come.
class TutorFileProgress extends StatelessWidget {
  const TutorFileProgress({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final index = TutorFileSections.all.indexOf(section);
    final total = TutorFileSections.all.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          Translations.of(context)
              .tutorSpace
              .file
              .sectionOf(n: index + 1, total: total),
          style: AppTypography.labelSm.copyWith(color: AppPalette.teal700)),
      const SizedBox(height: 6),
      Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i < index
                      ? AppPalette.teal700
                      : i == index
                          ? AppPalette.teal300
                          : AppPalette.n300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    ]);
  }
}

/// The bottom bar of a screen: an optional hint above the main button.
class TutorBottomBar extends StatelessWidget {
  const TutorBottomBar({super.key, this.hint, required this.child});

  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: AppPalette.surfacePage,
          border: Border(top: BorderSide(color: AppPalette.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (hint != null) ...[
                Text(hint!,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
                const SizedBox(height: 8),
              ],
              child,
            ]),
          ),
        ),
      );
}

/// A date chosen with the date picker, shown like a field.
class TutorDateField extends StatelessWidget {
  const TutorDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.first,
    this.last,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? first;
  final DateTime? last;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = first ?? DateTime(1940);
    final lastDate = last ?? DateTime(now.year + 30);
    var initial = value ?? (last != null && last!.isBefore(now) ? last! : now);
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? Translations.of(context).tutorSpace.file.pickDate
        : TutorFileFormat.date(context, value!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.label),
      const SizedBox(height: 6),
      Material(
        color: AppPalette.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () => _pick(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppPalette.text2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: AppTypography.body.copyWith(
                        color: value == null
                            ? AppPalette.text3
                            : AppPalette.text)),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

/// Date formats of the recruitment screens.
abstract final class TutorFileFormat {
  /// « 12/04/1996 ».
  static String date(BuildContext context, DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
