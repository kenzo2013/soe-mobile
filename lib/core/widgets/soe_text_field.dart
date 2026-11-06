import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../i18n/translations.g.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// SOE text field: label above, filled light teal, radius 16, no border at rest; a 2 px
/// teal ring on focus, a red ring and the message below on error.
class SoeTextField extends StatelessWidget {
  const SoeTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.leadingIcon,
    this.prefixText,
    this.trailing,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;

  /// Label intégré rendu au-dessus du champ. Si `null` ou vide, on ne rend
  /// rien — laisser au parent le soin d'utiliser [SoeFieldLabel].
  final String? label;
  final String? hint;
  final IconData? leadingIcon;

  /// Fixed text before the value (« +237 »), not editable.
  final String? prefixText;
  final Widget? trailing;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final fill = SoeFieldFill.of(context);
    final showLabel = label != null && label!.isNotEmpty;
    OutlineInputBorder ring(Color color) => OutlineInputBorder(
          borderRadius: AppRadius.rField,
          borderSide: BorderSide(color: color, width: 2),
        );
    const rest = OutlineInputBorder(
      borderRadius: AppRadius.rField,
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: AppTypography.label.copyWith(color: AppPalette.teal800),
            ),
          ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          autofocus: autofocus,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          style: AppTypography.body.copyWith(
            color: enabled ? AppPalette.ink : AppPalette.ink600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppPalette.ink600),
            filled: true,
            fillColor: enabled ? fill : AppPalette.n100,
            counterText: '',
            prefixIcon: leadingIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 10),
                    child:
                        Icon(leadingIcon, size: 18, color: AppPalette.ink600),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            prefixText: prefixText == null ? null : '$prefixText  ',
            prefixStyle: AppTypography.body.copyWith(
                color: AppPalette.teal800, fontWeight: FontWeight.w600),
            suffixIcon: trailing,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: rest,
            enabledBorder: hasError ? ring(AppPalette.dangerText) : rest,
            disabledBorder: rest,
            focusedBorder:
                ring(hasError ? AppPalette.dangerText : AppPalette.teal500),
            errorBorder: ring(AppPalette.dangerText),
            focusedErrorBorder: ring(AppPalette.dangerText),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: AppPalette.dangerText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText!,
                    style: AppTypography.caption.copyWith(
                      color: AppPalette.dangerText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The fill of the fields below it: light teal (#EEF5F8) by default, on a white card or
/// sheet; a form laid straight on the light teal page ground gives white.
class SoeFieldFill extends InheritedWidget {
  const SoeFieldFill({super.key, required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SoeFieldFill>()?.color ??
      AppPalette.teal50;

  @override
  bool updateShouldNotify(SoeFieldFill oldWidget) => color != oldWidget.color;
}

/// Champ mot de passe avec œil pour afficher/masquer.
class SoePasswordField extends StatefulWidget {
  const SoePasswordField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;

  /// Label du champ. Si `null`, `widgets.password` est utilisé.
  final String? label;

  /// Placeholder. Si `null`, `widgets.passwordHint` est utilisé.
  final String? hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<SoePasswordField> createState() => _SoePasswordFieldState();
}

class _SoePasswordFieldState extends State<SoePasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeTextField(
      controller: widget.controller,
      label: widget.label ?? tr.widgets.password,
      hint: widget.hint ?? tr.widgets.passwordHint,
      leadingIcon: Icons.lock_outline,
      obscureText: _obscure,
      errorText: widget.errorText,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      trailing: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppPalette.ink600,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

/// Compact search field (height 48, pill, filled like the fields).
class SoeSearchField extends StatelessWidget {
  const SoeSearchField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
  });

  final TextEditingController controller;

  /// Placeholder. Si `null`, `widgets.searchHint` est utilisé.
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: SoeFieldFill.of(context),
        borderRadius: AppRadius.rPill,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppPalette.n700),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.body.copyWith(color: AppPalette.ink),
              decoration: InputDecoration(
                hintText: hint ?? tr.widgets.searchHint,
                hintStyle: AppTypography.body.copyWith(color: AppPalette.n700),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
