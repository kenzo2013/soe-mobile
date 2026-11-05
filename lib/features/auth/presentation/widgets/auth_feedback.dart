import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';

/// Home of a role once signed in.
String homeForRole(String role) =>
    role == 'tutor' ? RouteNames.tutorHome : RouteNames.parentHome;

/// A refused action, in plain words (announced to screen readers).
class AuthErrorText extends StatelessWidget {
  const AuthErrorText(
      {super.key, required this.failure, this.shownFields, this.onRestart});
  final Failure? failure;

  /// Fields the screen shows next to their input. When given, the validation errors of
  /// the other fields (e.g. an e-mail taken meanwhile, on the last step) are listed here.
  final Set<String>? shownFields;

  /// For an expired flow: a « Recommencer » button.
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;
    if (failure == null) return const SizedBox.shrink();
    final tr = Translations.of(context);
    final String message;
    if (failure is ValidationFailure) {
      final shown = shownFields;
      if (shown == null) return const SizedBox.shrink();
      final others = [
        for (final entry in failure.errors.entries)
          if (!shown.contains(entry.key)) ...entry.value,
      ];
      if (others.isEmpty) return const SizedBox.shrink();
      message = others.join('\n');
    } else {
      message = failureMessage(failure, tr);
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppPalette.dangerBg,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline,
                color: AppPalette.dangerText, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppTypography.bodySm
                        .copyWith(color: AppPalette.dangerText),
                  ),
                  if (onRestart != null)
                    TextButton(
                      onPressed: onRestart,
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(44, 44),
                          foregroundColor: AppPalette.dangerText),
                      child: Text(tr.auth.code.restart,
                          style: AppTypography.labelSm
                              .copyWith(color: AppPalette.dangerText)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// « Renvoyer le code » / « … dans 42 s » (AUT-07, AUT-10): enabled once the wait is over.
class ResendCodeButton extends StatefulWidget {
  const ResendCodeButton(
      {super.key, required this.seconds, required this.onResend});

  final int seconds;
  final Future<void> Function() onResend;

  @override
  State<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<ResendCodeButton> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(ResendCodeButton old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) {
      _remaining = widget.seconds;
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    if (_remaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _remaining -= 1);
      if (_remaining <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.code;
    final waiting = _remaining > 0;
    return TextButton(
      onPressed: waiting ? null : widget.onResend,
      style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          foregroundColor: AppPalette.teal500),
      child: Text(
        waiting ? tr.resendIn(seconds: _remaining) : tr.resend,
        style: AppTypography.labelSm
            .copyWith(color: waiting ? AppPalette.ink700 : AppPalette.teal500),
      ),
    );
  }
}
