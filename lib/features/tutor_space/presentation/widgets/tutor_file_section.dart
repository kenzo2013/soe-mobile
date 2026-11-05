import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_dialog.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_api.dart';
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import '../tutor_space_routes.dart';
import 'tutor_file_ui.dart';
import 'tutor_ui.dart';

/// The top of a section (REP-03 to REP-09): progress, title and state, intro, then why it cannot
/// change (a checked document) or what SOE asks to redo.
class TutorFileSectionHeader extends StatelessWidget {
  const TutorFileSectionHeader({super.key, required this.data, this.intro});

  final TutorFileSection data;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TutorFileProgress(section: data.section),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(data.label,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
        ),
        const SizedBox(width: 8),
        TutorFileStateBadge(state: data.state, label: data.stateLabel),
      ]),
      if (intro != null) ...[
        const SizedBox(height: 6),
        Text(intro!,
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
      ],
      if (data.toRedo) ...[
        const SizedBox(height: 12),
        SoeAlert(
            title: tr.redoTitle,
            body: data.redoReason ?? tr.redoDefault,
            tone: SoeAlertTone.danger),
      ] else if (!data.editable) ...[
        const SizedBox(height: 12),
        SoeAlert(
            title: tr.lockedTitle, body: tr.locked, tone: SoeAlertTone.info),
      ],
      const SizedBox(height: 16),
    ]);
  }
}

/// The intro of a section, translated.
String tutorFileIntro(BuildContext context, String section) {
  final tr = Translations.of(context).tutorSpace.file.intro;
  return switch (section) {
    TutorFileSections.identity => tr.identity,
    TutorFileSections.address => tr.address,
    TutorFileSections.subjects => tr.subjects,
    TutorFileSections.availability => tr.availability,
    TutorFileSections.diplomas => tr.diplomas,
    TutorFileSections.experiences => tr.experiences,
    _ => tr.presentation,
  };
}

/// Opens the next section, or goes back to the file after the last one.
void continueTutorFile(BuildContext context, String section) {
  final index = TutorFileSections.all.indexOf(section);
  if (index >= 0 && index < TutorFileSections.all.length - 1) {
    context.pushReplacement(
        TutorSpaceRoutes.fileSection(TutorFileSections.all[index + 1]));
  } else if (context.canPop()) {
    context.pop();
  } else {
    context.go(TutorSpaceRoutes.file);
  }
}

/// Runs the API calls of a section: busy flag, refresh of the file, toast on failure (409 and 422
/// show the server's message).
mixin TutorFileSaving<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;

  /// True when [call] succeeded.
  Future<bool> runSave(
      String section, Future<void> Function(TutorFileApi api) call,
      {String? success}) async {
    if (busy) return false;
    setState(() => busy = true);
    try {
      await call(ref.read(tutorFileApiProvider));
      if (!mounted) return true;
      refreshTutorFile(ref, section);
      if (success != null) {
        SoeToast.show(context, message: success, tone: SoeToastTone.success);
      }
      return true;
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
      return false;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// Asks, then removes an item of [section].
  Future<void> removeItem(String section, int id,
      {required String title, required String message}) async {
    final tr = Translations.of(context).tutorSpace.file;
    final ok = await SoeConfirmDialog.show(context,
        title: title,
        message: message,
        icon: Icons.delete_outline,
        confirmLabel: tr.remove,
        cancelLabel: tr.cancel,
        destructive: true);
    if (ok != true || !mounted) return;
    await runSave(section, (api) => api.deleteItem(section, id),
        success: tr.removed);
  }
}

/// A row of a list of items (course, diploma, experience) with its remove button.
class TutorFileItemTile extends StatelessWidget {
  const TutorFileItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onRemove,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          TutorFileIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTypography.label),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
            ]),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: Translations.of(context).tutorSpace.file.remove,
              icon: const Icon(Icons.delete_outline,
                  color: AppPalette.dangerText),
              onPressed: onRemove,
            ),
        ]),
      );
}
