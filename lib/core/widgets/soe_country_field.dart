import 'package:flutter/material.dart';

import '../data/countries.dart';
import 'soe_country_picker_sheet.dart';
import 'soe_picker.dart';

/// Sélecteur pays — un [SoePickerField] qui ouvre [showSoeCountryPicker].
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
    return SoePickerField(
      placeholder: country.name,
      valueText: '${country.name} · ${country.code}',
      leading: CountryFlag(country: country),
      onTap: () async {
        final picked = await showSoeCountryPicker(
          context,
          selected: country,
          mode: SoeCountryPickerMode.address,
          title: pickerTitle,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
