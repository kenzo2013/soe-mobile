import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../i18n/translations.g.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Champ de saisie SOE — design system officiel.
///
/// Hauteur 56, radius 10, icône optionnelle à gauche, action à droite.
/// État erreur : bordure rouge + halo dangerBg + message sous le champ.
class SoeTextField extends StatelessWidget {
  const SoeTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.leadingIcon,
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
    final borderColor = hasError ? AppPalette.danger : AppPalette.n300;

    final showLabel = label != null && label!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: AppTypography.label.copyWith(
                color: AppPalette.n700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rSm,
            boxShadow: hasError
                ? const [
                    BoxShadow(
                      color: AppPalette.dangerBg,
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
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
              color: enabled ? AppPalette.ink : AppPalette.n500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(color: AppPalette.n500),
              filled: true,
              fillColor: enabled ? AppPalette.white : AppPalette.n100,
              counterText: '',
              prefixIcon: leadingIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 18, right: 12),
                      child:
                          Icon(leadingIcon, size: 18, color: AppPalette.n500),
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: trailing,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.rSm,
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.rSm,
                borderSide: BorderSide(
                  color: hasError ? AppPalette.danger : AppPalette.teal,
                  width: 1.5,
                ),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.rSm,
                borderSide: BorderSide(color: AppPalette.danger, width: 1.5),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.rSm,
                borderSide: BorderSide(color: AppPalette.danger, width: 1.5),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.rSm,
                borderSide: BorderSide(color: AppPalette.n300, width: 1.5),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 18),
            child: Row(
              children: [
                const Icon(Icons.close, size: 12, color: AppPalette.danger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText!,
                    style: AppTypography.caption.copyWith(
                      color: AppPalette.danger,
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
          color: AppPalette.n500,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

/// Champ recherche compact (hauteur 48, fond n300).
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
      decoration: const BoxDecoration(
        color: AppPalette.n300,
        borderRadius: AppRadius.rSm,
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
