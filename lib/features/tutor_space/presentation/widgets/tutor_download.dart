import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../data/tutor_money_models.dart';
import 'tutor_ui.dart';

/// Opens a URL outside the app; true when it was opened.
typedef TutorUrlLauncher = Future<bool> Function(Uri url);

/// The phone's browser or PDF viewer; tests override it with a fake.
final tutorUrlLauncherProvider = Provider<TutorUrlLauncher>(
    (ref) => (url) => launchUrl(url, mode: LaunchMode.externalApplication));

/// Asks for a short-lived link (5 minutes) at tap time and opens it at once outside the app:
/// a failure of the link or of the opening becomes a toast. True when the file was opened.
Future<bool> openTutorDownload(
  BuildContext context,
  WidgetRef ref,
  Future<TutorDownloadLink> Function() fetch,
) async {
  final launch = ref.read(tutorUrlLauncherProvider);
  try {
    final link = await fetch();
    if (await launch(link.url)) return true;
    if (context.mounted) _toast(context, const UnknownFailure());
  } on Failure catch (failure) {
    if (context.mounted) _toast(context, failure);
  }
  return false;
}

void _toast(BuildContext context, Failure failure) => SoeToast.show(context,
    message: tutorFailureMessage(context, failure), tone: SoeToastTone.danger);

/// A small « PDF » / « Reçu » button that fetches the link when tapped, with a spinner meanwhile.
class TutorDownloadButton extends ConsumerStatefulWidget {
  const TutorDownloadButton({
    super.key,
    required this.label,
    required this.fetch,
    this.icon = Icons.download_outlined,
  });

  final String label;
  final IconData icon;
  final Future<TutorDownloadLink> Function() fetch;

  @override
  ConsumerState<TutorDownloadButton> createState() =>
      _TutorDownloadButtonState();
}

class _TutorDownloadButtonState extends ConsumerState<TutorDownloadButton> {
  bool _busy = false;

  Future<void> _open() async {
    setState(() => _busy = true);
    await openTutorDownload(context, ref, widget.fetch);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: _busy ? null : () => unawaited(_open()),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.teal800,
          side: const BorderSide(color: AppPalette.teal500, width: 1.5),
          shape: const StadiumBorder(),
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        icon: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(widget.icon, size: 18),
        label: Text(widget.label),
      );
}
