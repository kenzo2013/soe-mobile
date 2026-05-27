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
        // Cases OTP : LayoutBuilder calcule la largeur d'une case en
        // fonction de la largeur disponible, puis on impose
        // `width == height` via un SizedBox carré. Plus fiable que
        // AspectRatio + TextField qui se laisse écraser par la hauteur
        // intrinsèque de l'InputDecoration.
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final cellSize = ((constraints.maxWidth -
                        spacing * (widget.length - 1)) /
                    widget.length)
                .clamp(40.0, 72.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (i) {
                return _OtpCell(
                  size: cellSize,
                  hasError: hasError,
                  focusNode: _focusNodes[i],
                  controller: _controllers[i],
                  enabled: widget.enabled,
                  autofocus: widget.autofocus && i == 0,
                  maxLen: widget.length,
                  onChanged: (v) => _onChanged(i, v),
                );
              }),
            );
          },
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

/// Une case OTP carrée. Décoration sur Container externe, TextField
/// transparent à l'intérieur — la taille est garantie par le SizedBox
/// peu importe les contraintes intrinsèques du TextField/Material.
class _OtpCell extends StatefulWidget {
  const _OtpCell({
    required this.size,
    required this.hasError,
    required this.focusNode,
    required this.controller,
    required this.enabled,
    required this.autofocus,
    required this.maxLen,
    required this.onChanged,
  });
  final double size;
  final bool hasError;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final int maxLen;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  late bool _focused;

  @override
  void initState() {
    super.initState();
    _focused = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? AppPalette.danger
        : (_focused ? AppPalette.teal : Colors.transparent);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.hasError ? AppPalette.dangerBg : AppPalette.n100,
          borderRadius: AppRadius.rMd,
          border: Border.all(
            color: borderColor,
            width: _focused || widget.hasError ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.maxLen),
            ],
            cursorColor: AppPalette.teal,
            cursorHeight: 24,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
              height: 1,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
