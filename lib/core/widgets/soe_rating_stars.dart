import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Étoiles SOE — affichage compact (16px) ou interactives (24px).
///
/// `onChanged` non null → mode sélection.
class SoeRatingStars extends StatelessWidget {
  const SoeRatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size,
    this.max = 5,
  });

  final int rating; // 0..max
  final ValueChanged<int>? onChanged;
  final double? size;
  final int max;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final s = size ?? (_interactive ? 24 : 16);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= max; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: GestureDetector(
              onTap: _interactive ? () => onChanged!(i) : null,
              child: Icon(
                i <= rating ? Icons.star : Icons.star_border,
                size: s,
                color:
                    i <= rating ? AppPalette.yellow : const Color(0xFFD1D5DB),
              ),
            ),
          ),
      ],
    );
  }
}
