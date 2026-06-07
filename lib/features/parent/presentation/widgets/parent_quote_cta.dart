import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class ParentQuoteCta extends StatelessWidget {
  const ParentQuoteCta({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Ombre CTA du design : 0 8px 20px rgba(255,180,0,.35)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppPalette.yellow.withValues(alpha: 0.35),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
      color: AppPalette.yellow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppPalette.ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppPalette.yellow,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demander un devis',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Trouvez un tuteur en 3 étapes',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xB3010814),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppPalette.ink,
                size: 18,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
