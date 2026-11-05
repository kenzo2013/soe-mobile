import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../data/countries.dart';
import 'soe_picker.dart';

enum SoeCountryPickerMode {
  /// Affiche le nom du pays + l'indicatif (sélecteur téléphone).
  phone,

  /// Affiche uniquement nom du pays + code ISO (sélecteur adresse).
  address,
}

/// BottomSheet de sélection pays ([showSoePickerSheet]) — 8 entrées MVP.
///
/// Renvoie le [Country] choisi (ou `null` si fermé sans choix).
Future<Country?> showSoeCountryPicker(
  BuildContext context, {
  required Country selected,
  required SoeCountryPickerMode mode,
  String? title,
}) async {
  final tr = Translations.of(context);
  final resolvedTitle = title ??
      (mode == SoeCountryPickerMode.phone
          ? tr.countryPicker.phoneTitle
          : tr.countryPicker.addressTitle);
  final code = await showSoePickerSheet<String>(
    context,
    title: resolvedTitle,
    selected: selected.code,
    items: [
      for (final country in Countries.all)
        SoePickerItem(
          value: country.code,
          label: country.name,
          leading: CountryFlag(country: country, width: 24, height: 16),
          trailing: mode == SoeCountryPickerMode.phone
              ? country.callingCode
              : country.code,
        ),
    ],
  );
  if (code == null) return null;
  return Countries.all.firstWhere((country) => country.code == code);
}
