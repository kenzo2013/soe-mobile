import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// « Semaine | Mois » (Studio): a soft pill with the chosen option on white.
class SoePillSwitch<T> extends StatelessWidget {
  const SoePillSwitch({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<({T value, String label})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: AppPalette.surfaceSoft,
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final option in options)
            Semantics(
              selected: option.value == selected,
              button: true,
              child: GestureDetector(
                onTap: () => onChanged(option.value),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: option.value == selected
                        ? AppPalette.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: option.value == selected
                        ? const [
                            BoxShadow(
                                color: Color(0x14041527),
                                blurRadius: 4,
                                offset: Offset(0, 1))
                          ]
                        : null,
                  ),
                  child: Text(option.label,
                      style: AppTypography.labelSm.copyWith(
                          color: option.value == selected
                              ? AppPalette.text
                              : AppPalette.text2)),
                ),
              ),
            ),
        ]),
      );
}
