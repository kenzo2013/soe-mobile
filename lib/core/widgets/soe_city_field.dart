import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../data/cameroon_city.dart';
import '../providers/cameroon_cities_provider.dart';
import '../theme/app_palette.dart';
import 'soe_picker.dart';

/// City of the sign-up and the address: a [SoePickerField] opening a searchable sheet of every
/// city of Cameroon, the main ones first with their region. A [value] no longer offered (an
/// older spelling) is still shown. While the list loads the field waits; if loading failed, a
/// tap retries (and the field waits again).
class SoeCityField extends ConsumerWidget {
  const SoeCityField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.errorText,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? label;

  /// Name read by screen readers when the page draws the label itself.
  final String? semanticLabel;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).cityPicker;
    final cities = ref.watch(cameroonCitiesProvider);
    final loading = cities.isLoading && !cities.hasValue;
    final failed = cities.hasError && !cities.isLoading && !cities.hasValue;

    Future<void> open() async {
      if (failed) {
        ref.invalidate(cameroonCitiesProvider);
        return;
      }
      final list = cities.valueOrNull;
      if (list == null) return;
      final picked = await showSoePickerSheet<String>(
        context,
        title: tr.title,
        selected: value,
        searchHint: tr.search,
        emptyText: tr.empty,
        items: [
          for (final city in list) _item(city, tr),
        ],
      );
      if (picked != null) onChanged(picked);
    }

    return SoePickerField(
      label: label,
      semanticLabel: semanticLabel,
      placeholder: failed ? tr.retry : tr.placeholder,
      valueText: failed ? null : value,
      leading: const Icon(Icons.location_city_outlined,
          size: 20, color: AppPalette.ink600),
      trailingIcon: failed ? Icons.refresh : Icons.keyboard_arrow_down,
      loading: loading,
      errorText: errorText,
      onTap: open,
    );
  }

  SoePickerItem<String> _item(CameroonCity city, TranslationsCityPickerFr tr) =>
      SoePickerItem(
        value: city.name,
        label: city.name,
        trailing: city.region,
        section: city.major ? tr.major : tr.others,
        searchKey: city.searchKey,
      );
}
