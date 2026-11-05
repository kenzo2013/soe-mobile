import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// SOE back button — 40×40, n100 ground, radius 12, left chevron. The leading of a screen
/// without an app bar.
class SoeBackButton extends StatelessWidget {
  const SoeBackButton({super.key, this.onPressed, this.tooltip});

  /// Null: `Navigator.maybePop(context)`.
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left,
              size: 22,
              color: AppPalette.ink,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
