import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'soe_country_picker_sheet.dart';

/// Sélecteur pays — ressemble à un input mais ouvre un BottomSheet.
///
/// Affichage : drapeau + « Cameroun · CM » + chevron ↓.
class SoeCountryField extends StatelessWidget {
  const SoeCountryField({
    super.key,
    required this.country,
    required this.onChanged,
    this.pickerTitle,
  });

  final Country country;
  final ValueChanged<Country> onChanged;

  /// Titre du sélecteur. Si `null`, `countryPicker.addressTitle` est utilisé.
  final String? pickerTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.rSm,
      onTap: () async {
        final picked = await showSoeCountryPicker(
          context,
          selected: country,
          mode: SoeCountryPickerMode.address,
          title: pickerTitle,
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: AppRadius.rSm,
          border: Border.all(color: AppPalette.n300, width: 1.5),
        ),
        child: Row(
          children: [
            CountryFlag(country: country),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${country.name} · ${country.code}',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  color: AppPalette.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppPalette.n500,
            ),
          ],
        ),
      ),
    );
  }
}
