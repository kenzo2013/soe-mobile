import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Champ de saisie d'un code OTP à N chiffres (par défaut 6).
///
/// - Auto-focus du suivant à chaque saisie
/// - Backspace recule au précédent
/// - Émet `onCompleted` quand toutes les cases sont remplies
/// - Émet `onChanged` à chaque modif (pour activer/désactiver le bouton)
class SoeOtpField extends StatefulWidget {
  const SoeOtpField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.errorText,
    this.autofocus = true,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? errorText;
  final bool autofocus;
  final bool enabled;

  @override
  State<SoeOtpField> createState() => _SoeOtpFieldState();
}

class _SoeOtpFieldState extends State<SoeOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String v) {
    if (v.length > 1) {
      // Collage : on dispatche les chiffres collés sur les cases suivantes.
      final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < widget.length - index; i++) {
        if (i < digits.length) {
          _controllers[index + i].text = digits[i];
        }
      }
      final last = (index + digits.length).clamp(0, widget.length - 1);
      FocusScope.of(context).requestFocus(_focusNodes[last]);
    } else if (v.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (v.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    final value = _value;
    widget.onChanged?.call(value);
    if (value.length == widget.length &&
        !value.contains(RegExp(r'[^0-9]'))) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = (widget.errorText ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            return SizedBox(
              width: 48,
              height: 60,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                autofocus: widget.autofocus && i == 0,
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  // Pas de filtre `digitsOnly` pour autoriser le collage —
                  // on filtre dans `_onChanged`.
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                  height: 1,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: hasError ? AppPalette.dangerBg : AppPalette.n100,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.rMd,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rMd,
                    borderSide: BorderSide(
                      color: hasError ? AppPalette.danger : Colors.transparent,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.rMd,
                    borderSide: BorderSide(color: AppPalette.teal, width: 1.5),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style:
                AppTypography.caption.copyWith(color: AppPalette.danger),
          ),
        ],
      ],
    );
  }
}
