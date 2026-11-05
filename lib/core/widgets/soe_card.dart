import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// SOE card: white on the light teal page ground, radius 20, soft shadow, no border.
/// [raised] is the first card of a home, overlapping the header band (radius 24, deeper
/// shadow); [color] gives a coloured card (white text is then up to the caller).
class SoeCard extends StatelessWidget {
  const SoeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius,
    this.raised = false,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool raised;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? (raised ? AppRadius.rCardLg : AppRadius.rCard);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: color != null
            ? null
            : (raised ? AppShadows.raised : AppShadows.card),
      ),
      child: Material(
        color: color ?? AppPalette.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
