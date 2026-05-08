import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/countries.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'soe_country_picker_sheet.dart';

/// Champ téléphone — préfixe pays (drapeau + indicatif) + saisie locale.
///
/// Le préfixe est cliquable et ouvre le [showSoeCountryPicker].
/// Le widget ne stocke pas l'indicatif : c'est au parent de composer
/// `country.callingCode + controller.text` pour l'API.
class SoePhoneField extends StatelessWidget {
  const SoePhoneField({
    super.key,
    required this.country,
    required this.onCountryChanged,
    required this.controller,
    this.hint,
    this.textInputAction,
    this.onFieldSubmitted,
    this.errorText,
    this.pickerTitle = 'Indicatif pays',
  });

  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final TextEditingController controller;
  final String? hint;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? errorText;
  final String pickerTitle;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: AppRadius.rSm,
            border: Border.all(
              color: hasError ? AppPalette.danger : AppPalette.n300,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _PrefixButton(
                country: country,
                onTap: () async {
                  final picked = await showSoeCountryPicker(
                    context,
                    selected: country,
                    mode: SoeCountryPickerMode.phone,
                    title: pickerTitle,
                  );
                  if (picked != null) onCountryChanged(picked);
                },
              ),
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.only(left: 4, right: 12),
                color: AppPalette.n300,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: textInputAction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  ],
                  onSubmitted: onFieldSubmitted,
                  style: AppTypography.body.copyWith(color: AppPalette.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        AppTypography.body.copyWith(color: AppPalette.n500),
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 18),
            child: Row(
              children: [
                const Icon(Icons.close, size: 12, color: AppPalette.danger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.danger),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PrefixButton extends StatelessWidget {
  const _PrefixButton({required this.country, required this.onTap});
  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rXs,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryFlag(country: country),
            const SizedBox(width: 6),
            Text(
              country.callingCode,
              style: AppTypography.bodySm.copyWith(
                color: AppPalette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: AppPalette.n700,
            ),
          ],
        ),
      ),
    );
  }
}
