import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

/// Variants of the Studio matrix (same names as the web `Soe::ButtonComponent`).
enum SoeButtonVariant {
  /// Gold, ink text. One per screen.
  primary,

  /// Teal 500 filled, white text.
  secondary,

  /// Teal outline 1.5 px.
  outline,

  /// Text only, teal.
  tertiary,

  /// Destructive confirmation: danger text colour filled, white text.
  danger,

  /// Risky action: danger outline.
  dangerOutline,

  /// On deep teal surfaces: white text, outline in onDark2.
  onBrand,
}

/// Studio heights: sm 40 (compact) · md 48 (standard) · lg 52 (mobile).
enum SoeButtonSize { sm, md, lg }

/// SoeButton — always a pill; the label is a verb. One `primary` (gold) button per screen.
/// Mirror of the web `Soe::ButtonComponent` (soe/app/components/soe/button_component.rb).
class SoeButton extends StatelessWidget {
  const SoeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SoeButtonVariant.primary,
    this.size = SoeButtonSize.lg,
    this.icon,
    this.iconRight = false,
    this.loading = false,
    this.loadingLabel,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SoeButtonVariant variant;
  final SoeButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool loading;

  /// Text shown while [loading] (e.g. "Envoi…"); defaults to [label].
  final String? loadingLabel;
  final bool fullWidth;

  bool get _disabled => onPressed == null || loading;

  @override
  Widget build(BuildContext context) {
    final spec =
        _disabled && !loading ? _disabledSpec(variant) : _variantSpec(variant);
    final height = switch (size) {
      SoeButtonSize.sm => 40.0,
      SoeButtonSize.md => 48.0,
      SoeButtonSize.lg => 52.0,
    };
    final textStyle = switch (size) {
      SoeButtonSize.sm => AppTypography.buttonSm,
      _ when variant == SoeButtonVariant.primary => AppTypography.buttonLg,
      _ => AppTypography.button,
    };

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: loading ? (loadingLabel ?? label) : label,
      excludeSemantics: true,
      child: Material(
        color: spec.background,
        shape: StadiumBorder(side: spec.border),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _disabled ? null : onPressed,
          overlayColor: WidgetStatePropertyAll(spec.overlay),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height, minWidth: height),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size == SoeButtonSize.sm ? AppSpacing.lg : AppSpacing.xl),
              child: _content(
                  textStyle.copyWith(color: spec.foreground), spec.foreground),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(TextStyle style, Color color) {
    final text = Flexible(
      child: Text(
        loading ? (loadingLabel ?? label) : label,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final leading = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color))
        : (icon != null && !iconRight
            ? Icon(icon, size: 20, color: color)
            : null);
    final trailing = !loading && icon != null && iconRight
        ? Icon(icon, size: 20, color: color)
        : null;
    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 8)],
        text,
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  static _ButtonSpec _variantSpec(SoeButtonVariant v) => switch (v) {
        SoeButtonVariant.primary =>
          const _ButtonSpec(AppPalette.gold400, AppPalette.ink900),
        SoeButtonVariant.secondary =>
          const _ButtonSpec(AppPalette.teal500, AppPalette.white),
        SoeButtonVariant.outline => const _ButtonSpec(
            Colors.transparent,
            AppPalette.teal500,
            border: BorderSide(color: AppPalette.teal500, width: 1.5),
            overlay: AppPalette.teal50,
          ),
        SoeButtonVariant.tertiary => const _ButtonSpec(
            Colors.transparent, AppPalette.teal500,
            overlay: AppPalette.teal50),
        SoeButtonVariant.danger =>
          const _ButtonSpec(AppPalette.dangerText, AppPalette.white),
        SoeButtonVariant.dangerOutline => const _ButtonSpec(
            Colors.transparent,
            AppPalette.dangerText,
            border: BorderSide(color: AppPalette.dangerText, width: 1.5),
            overlay: AppPalette.dangerBg,
          ),
        SoeButtonVariant.onBrand => const _ButtonSpec(
            Colors.transparent,
            AppPalette.white,
            border: BorderSide(color: AppPalette.onDark2, width: 1.5),
            overlay: AppPalette.overlayDarkHover,
          ),
      };

  static _ButtonSpec _disabledSpec(SoeButtonVariant v) => switch (v) {
        SoeButtonVariant.outline ||
        SoeButtonVariant.dangerOutline =>
          const _ButtonSpec(
            Colors.transparent,
            AppPalette.ink600,
            border: BorderSide(color: AppPalette.n300, width: 1.5),
          ),
        SoeButtonVariant.tertiary =>
          const _ButtonSpec(Colors.transparent, AppPalette.ink600),
        SoeButtonVariant.onBrand =>
          const _ButtonSpec(AppPalette.lineDark, AppPalette.onDark2),
        _ => const _ButtonSpec(AppPalette.n300, AppPalette.ink600),
      };
}

class _ButtonSpec {
  const _ButtonSpec(
    this.background,
    this.foreground, {
    this.border = BorderSide.none,
    this.overlay = AppPalette.overlayHover,
  });

  final Color background;
  final Color foreground;
  final BorderSide border;
  final Color overlay;
}

/// Bouton icône seul (44×44, radius 14). Variants `filled` (teal) ou `outline`.
class SoeIconButton extends StatelessWidget {
  const SoeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.outline = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool outline;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bg = outline ? AppPalette.white : AppPalette.teal;
    final fg = outline ? AppPalette.ink : AppPalette.white;
    final border = outline ? AppPalette.n300 : AppPalette.teal;
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.rMd,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.rMd,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// FAB jaune 56 avec ombre cta.
class SoeFab extends StatelessWidget {
  const SoeFab({super.key, required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.rPill,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppPalette.yellow,
            shape: BoxShape.circle,
            boxShadow: AppShadows.cta,
          ),
          child: Icon(icon, size: 22, color: AppPalette.ink),
        ),
      ),
    );
  }
}
