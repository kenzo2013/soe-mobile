import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/cameroon_city.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';

/// City of the sign-up and the address: looks like a field, opens a sheet listing every city of
/// Cameroon (main ones first) with a search. A [value] no longer offered (an older spelling) is
/// still shown. While the list loads the field waits; if it fails, a tap retries.
class CityField extends ConsumerWidget {
  const CityField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.errorText,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).cityPicker;
    final cities = ref.watch(cameroonCitiesProvider);
    final chosen = (value ?? '').isNotEmpty;
    final failed = cities.hasError && !cities.hasValue;

    Future<void> open() async {
      if (failed) {
        ref.invalidate(cameroonCitiesProvider);
        return;
      }
      final list = cities.valueOrNull;
      if (list == null) return;
      final picked = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: AppPalette.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (_) => _CitySheet(cities: list, selected: value),
      );
      if (picked != null) onChanged(picked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTypography.label.copyWith(color: AppPalette.ink900)),
          const SizedBox(height: 8),
        ],
        Semantics(
          button: true,
          label: label,
          value: chosen ? value : tr.placeholder,
          child: InkWell(
            borderRadius: AppRadius.rSm,
            onTap: open,
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: AppRadius.rSm,
                border: Border.all(
                    color:
                        errorText != null ? AppPalette.danger : AppPalette.n300,
                    width: errorText != null ? 2 : 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city_outlined,
                      size: 20, color: AppPalette.ink700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      failed ? tr.retry : (chosen ? value! : tr.placeholder),
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: chosen && !failed
                            ? AppPalette.ink900
                            : AppPalette.ink600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (cities.isLoading && !cities.hasValue)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Icon(failed ? Icons.refresh : Icons.keyboard_arrow_down,
                        size: 20, color: AppPalette.ink700),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!,
              style:
                  AppTypography.caption.copyWith(color: AppPalette.dangerText)),
        ],
      ],
    );
  }
}

class _CitySheet extends StatefulWidget {
  const _CitySheet({required this.cities, required this.selected});

  final List<CameroonCity> cities;
  final String? selected;

  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).cityPicker;
    final found =
        widget.cities.where((city) => city.matches(_query.text)).toList();
    final major = found.where((city) => city.major).toList();
    final others = found.where((city) => !city.major).toList();

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppPalette.n300,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 14),
            Text(tr.title, style: AppTypography.h4),
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: tr.search,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppPalette.n50,
                border: const OutlineInputBorder(
                    borderRadius: AppRadius.rSm, borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: found.isEmpty
                  ? Center(
                      child: Text(tr.empty,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.ink700)))
                  : ListView(
                      children: [
                        if (major.isNotEmpty) _header(tr.major),
                        for (final city in major) _row(city),
                        if (others.isNotEmpty) _header(tr.others),
                        for (final city in others) _row(city),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
        child: Text(text.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.ink600)),
      );

  Widget _row(CameroonCity city) {
    final selected = city.name == widget.selected;
    return InkWell(
      borderRadius: AppRadius.rSm,
      onTap: () => Navigator.of(context).pop(city.name),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(city.name,
                  style: AppTypography.body.copyWith(
                    color: selected ? AppPalette.teal800 : AppPalette.ink900,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
            if (city.region != null)
              Text(city.region!,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.ink600)),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 18, color: AppPalette.teal500),
            ],
          ],
        ),
      ),
    );
  }
}
