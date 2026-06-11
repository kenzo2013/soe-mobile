import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/service_contract.dart';

/// Carte d'un contrat dans la liste (parent + tuteur). Tap → détail.
class ContractCard extends StatelessWidget {
  const ContractCard({
    super.key,
    required this.contract,
    required this.lang,
    required this.onTap,
  });

  final ServiceContract contract;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final c = contract;
    final color = c.signed ? AppPalette.success : AppPalette.warning;
    final bg = c.signed ? AppPalette.successBg : AppPalette.warningBg;
    final preview = c.content(lang).split('\n').firstWhere(
          (l) => l.trim().isNotEmpty,
          orElse: () => '',
        );
    return SoeCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description_outlined, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.reference,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  c.signed
                      ? tr.contracts.badgeSigned
                      : tr.contracts.badgeToSign,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.n700,
                height: 1.4,
              ),
            ),
          ],
          if (c.amendments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.layers_outlined,
                    size: 14, color: AppPalette.teal),
                const SizedBox(width: 6),
                Text(
                  c.amendments.length <= 1
                      ? tr.contracts
                          .amendmentCountOne(count: c.amendments.length)
                      : tr.contracts
                          .amendmentCountOther(count: c.amendments.length),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.teal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
