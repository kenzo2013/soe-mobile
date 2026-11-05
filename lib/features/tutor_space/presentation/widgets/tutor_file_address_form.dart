import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import '../../data/tutor_references.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';

/// REP-04 — the address (never shown to families) and the neighbourhoods the tutor accepts to go
/// to: the city and its neighbourhoods come from the references.
class TutorFileAddressForm extends ConsumerStatefulWidget {
  const TutorFileAddressForm({super.key, required this.data});

  final TutorFileSection data;

  /// Neighbourhoods accepted at most (TutorSpace::FileSectionUpdate::ZONES_MAX).
  static const zonesMax = 15;

  @override
  ConsumerState<TutorFileAddressForm> createState() =>
      _TutorFileAddressFormState();
}

class _TutorFileAddressFormState extends ConsumerState<TutorFileAddressForm>
    with TutorFileSaving {
  late final TutorAddressContent _onFile = widget.data.address;
  late final _neighborhood = TextEditingController(text: _onFile.neighborhood);
  late final _address = TextEditingController(text: _onFile.address);
  late final _landmark = TextEditingController(text: _onFile.landmark);
  final _otherZone = TextEditingController();
  late String? _city = _onFile.city;
  late final List<String> _zones = [..._onFile.travelZones];

  @override
  void dispose() {
    _neighborhood.dispose();
    _address.dispose();
    _landmark.dispose();
    _otherZone.dispose();
    super.dispose();
  }

  bool get _complete =>
      _neighborhood.text.trim().isNotEmpty &&
      (_city ?? '').isNotEmpty &&
      _zones.isNotEmpty;

  void _toggle(String zone) => setState(() {
        if (!_zones.remove(zone) &&
            _zones.length < TutorFileAddressForm.zonesMax) {
          _zones.add(zone);
        }
      });

  void _addOther() {
    final zone = _otherZone.text.trim();
    if (zone.isEmpty) return;
    setState(() {
      if (!_zones.contains(zone) &&
          _zones.length < TutorFileAddressForm.zonesMax) {
        _zones.add(zone);
      }
      _otherZone.clear();
    });
  }

  Future<void> _save() async {
    final tr = Translations.of(context).tutorSpace.file;
    final ok = await runSave(
      widget.data.section,
      (api) => api.updateSection(widget.data.section, {
        'address': _address.text.trim(),
        'neighborhood': _neighborhood.text.trim(),
        'city': _city,
        'landmark': _landmark.text.trim(),
        'travel_zones': _zones.join(', '),
      }),
      success: tr.saved,
    );
    if (ok && mounted) continueTutorFile(context, widget.data.section);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trA = tr.address;
    final cities =
        ref.watch(tutorReferencesProvider).valueOrNull?.cities ?? const [];
    final cityNames = {
      ...cities.map((c) => c.name),
      if (_city != null && _city!.isNotEmpty) _city!,
    }.toList();
    final suggestions =
        cities.where((c) => c.name == _city).firstOrNull?.neighborhoods ??
            const <String>[];
    final zoneChoices = {...suggestions, ..._zones}.toList();
    final full = _zones.length >= TutorFileAddressForm.zonesMax;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context, insets: false),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trA.city, style: AppTypography.label),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final city in cityNames)
                        SoeChip(
                          label: city,
                          selected: _city == city,
                          onTap: () => setState(() => _city = city),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    _NeighborhoodField(
                      controller: _neighborhood,
                      label: trA.neighborhood,
                      hint: trA.neighborhoodHint,
                      suggestions: suggestions,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SoeTextField(
                        controller: _address,
                        label: trA.address,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    SoeTextField(
                        controller: _landmark,
                        label: trA.landmark,
                        hint: trA.landmarkHint,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    Text(trA.zones, style: AppTypography.label),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final zone in zoneChoices)
                        SoeChip(
                          label: zone,
                          selected: _zones.contains(zone),
                          onTap: full && !_zones.contains(zone)
                              ? null
                              : () => _toggle(zone),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: SoeTextField(
                          controller: _otherZone,
                          label: trA.otherZone,
                          enabled: !full,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _addOther(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SoeButton(
                        label: tr.add,
                        size: SoeButtonSize.md,
                        variant: SoeButtonVariant.outline,
                        onPressed: full ? null : _addOther,
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                        trA.zonesCount(
                            n: _zones.length,
                            max: TutorFileAddressForm.zonesMax),
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]),
            ),
          ],
        ),
      ),
      TutorBottomBar(
        hint: _complete ? null : trA.hint,
        child: SoeButton(
          label: tr.saveContinue,
          fullWidth: true,
          loading: busy,
          onPressed: busy || !_complete ? null : () => unawaited(_save()),
        ),
      ),
    ]);
  }
}

/// The neighbourhood, with the neighbourhoods of the chosen city as suggestions.
class _NeighborhoodField extends StatelessWidget {
  const _NeighborhoodField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> suggestions;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoeTextField(
            controller: controller,
            label: label,
            hint: hint,
            leadingIcon: Icons.search,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
          ),
          Builder(builder: (context) {
            final query = controller.text.trim().toLowerCase();
            final matches = query.isEmpty
                ? const <String>[]
                : suggestions
                    .where((n) =>
                        n.toLowerCase().contains(query) &&
                        n.toLowerCase() != query)
                    .take(5)
                    .toList();
            if (matches.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final match in matches)
                  SoeChip(
                    label: match,
                    onTap: () {
                      controller.text = match;
                      onChanged();
                    },
                  ),
              ]),
            );
          }),
        ],
      );
}
