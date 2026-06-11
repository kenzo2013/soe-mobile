import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

enum SoeButtonVariant {
  primary, // jaune (CTA), texte ink, ombre cta
  secondary, // outline teal, texte teal
  tertiary, // ghost teal
  link, // lien souligné
  onBrand, // sur surface marque : blanc, texte teal
  onBrandGhost, // sur surface marque : transparent, bordure blanc 55%
  danger, // rouge plein
}

enum SoeButtonSize { sm, md, lg }

/// Bouton SOE — design system officiel.
///
/// Hauteurs tactiles : sm 36 / md 48 / lg 56. Forme arrondie (radius 10),
/// ou pill pour `variant: link` (souligné). Le jaune est réservé au CTA.
class SoeButton extends StatelessWidget {
  const SoeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SoeButtonVariant.primary,
    this.size = SoeButtonSize.md,
    this.icon,
    this.iconRight = false,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SoeButtonVariant variant;
  final SoeButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool loading;
  final bool fullWidth;

  bool get _disabled => onPressed == null || loading;

  @override
  Widget build(BuildContext context) {
    final s = _sizeSpec(size);
    final c = _variantSpec(variant);
    final iconColor = c.fg;

    final labelWidget = Text(
      label,
      style: TextStyle(
        color: c.fg,
        fontSize: s.fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        decoration:
            variant == SoeButtonVariant.link ? TextDecoration.underline : null,
      ),
    );

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: c.fg),
          ),
          const SizedBox(width: 10),
          labelWidget,
        ] else ...[
          if (icon != null && !iconRight) ...[
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
          ],
          labelWidget,
          if (icon != null && iconRight) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: iconColor),
          ],
        ],
      ],
    );

    final radius =
        variant == SoeButtonVariant.link ? AppRadius.rXs : AppRadius.rSm;

    return Opacity(
      opacity: _disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _disabled ? null : onPressed,
          borderRadius: radius,
          child: Container(
            height: s.height,
            padding: EdgeInsets.symmetric(horizontal: s.paddingX),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: radius,
              border: Border.all(color: c.border, width: 1.5),
              boxShadow: variant == SoeButtonVariant.primary && !_disabled
                  ? AppShadows.cta
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  static _ButtonSizeSpec _sizeSpec(SoeButtonSize size) => switch (size) {
        SoeButtonSize.sm =>
          const _ButtonSizeSpec(height: 36, paddingX: 16, fontSize: 13),
        SoeButtonSize.md =>
          const _ButtonSizeSpec(height: 48, paddingX: 20, fontSize: 14),
        SoeButtonSize.lg =>
          const _ButtonSizeSpec(height: 56, paddingX: 24, fontSize: 15),
      };

  static _ButtonVariantSpec _variantSpec(SoeButtonVariant v) => switch (v) {
        SoeButtonVariant.primary => const _ButtonVariantSpec(
            background: AppPalette.yellow,
            fg: AppPalette.ink,
            border: Colors.transparent,
          ),
        SoeButtonVariant.secondary => const _ButtonVariantSpec(
            background: AppPalette.white,
            fg: AppPalette.teal,
            border: AppPalette.teal,
          ),
        SoeButtonVariant.tertiary => const _ButtonVariantSpec(
            background: Colors.transparent,
            fg: AppPalette.teal,
            border: Colors.transparent,
          ),
        SoeButtonVariant.link => const _ButtonVariantSpec(
            background: Colors.transparent,
            fg: AppPalette.teal,
            border: Colors.transparent,
          ),
        SoeButtonVariant.onBrand => const _ButtonVariantSpec(
            background: AppPalette.white,
            fg: AppPalette.teal,
            border: Colors.transparent,
          ),
        SoeButtonVariant.onBrandGhost => const _ButtonVariantSpec(
            background: Colors.transparent,
            fg: AppPalette.white,
            border: Color(0x8CFFFFFF),
          ),
        SoeButtonVariant.danger => const _ButtonVariantSpec(
            background: AppPalette.danger,
            fg: AppPalette.white,
            border: Colors.transparent,
          ),
      };
}

class _ButtonSizeSpec {
  const _ButtonSizeSpec({
    required this.height,
    required this.paddingX,
    required this.fontSize,
  });
  final double height;
  final double paddingX;
  final double fontSize;
}

class _ButtonVariantSpec {
  const _ButtonVariantSpec({
    required this.background,
    required this.fg,
    required this.border,
  });
  final Color background;
  final Color fg;
  final Color border;
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
