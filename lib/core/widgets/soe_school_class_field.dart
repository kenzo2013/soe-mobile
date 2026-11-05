import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../data/school_catalog.dart';
import 'soe_picker.dart';

/// Class of a child or of a tutor's course: a [SoePickerField] opening a sheet with search, the
/// classes grouped by cycle and sub-system (« Lycée · francophone »). Offers the active classes
/// of [subsystem] (all when null) plus the [value] already chosen, even if no longer offered.
class SoeSchoolClassField extends StatelessWidget {
  const SoeSchoolClassField({
    super.key,
    required this.catalog,
    required this.value,
    required this.onChanged,
    this.subsystem,
    this.errorText,
    this.semanticLabel,
  });

  final SchoolCatalog catalog;
  final int? value;
  final String? subsystem;
  final ValueChanged<int> onChanged;
  final String? errorText;
  final String? semanticLabel;

  /// Items of the sheet, in catalogue order, each under « group · sub-system ».
  static List<SoePickerItem<int>> items(
      BuildContext context, SchoolCatalog catalog,
      {String? subsystem, int? currentId}) {
    final tr = Translations.of(context).schoolCatalog;
    final language = Localizations.localeOf(context).languageCode;
    String section(SchoolClassRef item) {
      final group = switch (item.group) {
        'primary' => tr.groups.primary,
        'lower_secondary' => tr.groups.lowerSecondary,
        'upper_secondary' => tr.groups.upperSecondary,
        'technical' => tr.groups.technical,
        _ => tr.groups.other,
      };
      final system = switch (item.subsystem) {
        'francophone' => tr.subsystems.francophone,
        'anglophone' => tr.subsystems.anglophone,
        _ => null,
      };
      return system == null ? group : '$group · $system';
    }

    return [
      for (final item
          in catalog.offeredClasses(subsystem: subsystem, currentId: currentId))
        SoePickerItem<int>(
          value: item.id,
          label: item.label(language),
          trailing: item.abbr,
          section: section(item),
          searchKey: soeSearchKey(
              '${item.label(language)} ${item.name} ${item.abbr ?? ''}'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).schoolCatalog;
    final language = Localizations.localeOf(context).languageCode;
    return SoePickerField(
      placeholder: tr.choose,
      valueText: catalog.classById(value)?.label(language),
      errorText: errorText,
      semanticLabel: semanticLabel,
      onTap: () async {
        final picked = await showSoePickerSheet<int>(
          context,
          title: tr.pickerTitle,
          items:
              items(context, catalog, subsystem: subsystem, currentId: value),
          selected: value,
          searchHint: tr.search,
          emptyText: tr.empty,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
