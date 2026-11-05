import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// SOE filter chip: selected = filled SOE teal, white text; otherwise white on the page ground.
class SoeChip extends StatelessWidget {
  const SoeChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppPalette.teal500 : AppPalette.white;
    final fg = selected ? AppPalette.white : AppPalette.teal800;
    final border = selected ? AppPalette.teal500 : AppPalette.teal100;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
