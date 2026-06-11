import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../data/countries.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum SoeCountryPickerMode {
  /// Affiche le nom du pays + l'indicatif (sélecteur téléphone).
  phone,

  /// Affiche uniquement nom du pays + code ISO (sélecteur adresse).
  address,
}

/// BottomSheet de sélection pays — 8 entrées MVP, scroll vertical.
///
/// Renvoie le [Country] choisi (ou `null` si fermé sans choix).
Future<Country?> showSoeCountryPicker(
  BuildContext context, {
  required Country selected,
  required SoeCountryPickerMode mode,
  String? title,
}) {
  final tr = Translations.of(context);
  final resolvedTitle = title ??
      (mode == SoeCountryPickerMode.phone
          ? tr.countryPicker.phoneTitle
          : tr.countryPicker.addressTitle);
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPalette.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _CountryPicker(
      selected: selected,
      mode: mode,
      title: resolvedTitle,
    ),
  );
}

class _CountryPicker extends StatelessWidget {
  const _CountryPicker({
    required this.selected,
    required this.mode,
    required this.title,
  });

  final Country selected;
  final SoeCountryPickerMode mode;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPalette.n300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTypography.h4),
            const SizedBox(height: 12),
            for (final c in Countries.all) _row(context, c),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Country c) {
    final isSelected = c.code == selected.code;
    final trailing =
        mode == SoeCountryPickerMode.phone ? c.callingCode : c.code;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.rSm,
        onTap: () => Navigator.of(context).pop(c),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              CountryFlag(country: c, width: 24, height: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.name,
                  style: AppTypography.body.copyWith(
                    color: AppPalette.ink,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                trailing,
                style: AppTypography.bodySm.copyWith(
                  color: AppPalette.n700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: isSelected ? AppPalette.teal : AppPalette.n500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
