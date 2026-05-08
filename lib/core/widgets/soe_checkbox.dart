import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Case à cocher SOE — 20×20, radius 6, fond teal actif.
///
/// Usage : [SoeCheckbox] + slot label libre (typiquement [RichText]).
class SoeCheckbox extends StatelessWidget {
  const SoeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.only(top: 1),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppPalette.teal : AppPalette.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppPalette.teal : AppPalette.n500,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: value
                  ? const Icon(Icons.check, size: 12, color: AppPalette.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: label),
          ],
        ),
      ),
    );
  }
}
