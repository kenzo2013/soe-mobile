import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as g;

import '../../i18n/translations.g.dart';
import '../services/places_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'soe_text_field.dart';

/// Champ de saisie avec autocomplete Google Places.
///
/// - Debounce 300 ms sur la frappe
/// - Liste de suggestions sous le champ
/// - Sélection : récupère les détails de la place et émet un [SoePlaceResult]
///   utilisable pour pré-remplir city / country / address
class SoePlacesAutocompleteField extends StatefulWidget {
  const SoePlacesAutocompleteField({
    super.key,
    required this.controller,
    required this.client,
    required this.onPlaceSelected,
    this.hint,
    this.countryCodes = const ['cm'],
  });

  final TextEditingController controller;
  final g.FlutterGooglePlacesSdk client;
  final ValueChanged<SoePlaceResult> onPlaceSelected;
  final String? hint;
  final List<String> countryCodes;

  @override
  State<SoePlacesAutocompleteField> createState() =>
      _SoePlacesAutocompleteFieldState();
}

class _SoePlacesAutocompleteFieldState
    extends State<SoePlacesAutocompleteField> {
  Timer? _debounce;
  List<g.AutocompletePrediction> _predictions = const [];
  bool _loading = false;
  bool _serviceUnavailable = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _predictions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;
    setState(() => _loading = true);
    try {
      final r = await widget.client.findAutocompletePredictions(
        query,
        countries: widget.countryCodes,
      );
      if (!mounted) return;
      setState(() {
        _predictions = r.predictions;
        _loading = false;
        _serviceUnavailable = false;
      });
    } catch (_) {
      // Cle non autorisee / reseau down → degrade gracieusement avec
      // message inline. L'utilisateur peut taper son adresse manuellement.
      if (!mounted) return;
      setState(() {
        _predictions = const [];
        _loading = false;
        _serviceUnavailable = true;
      });
    }
  }

  Future<void> _select(g.AutocompletePrediction p) async {
    setState(() {
      widget.controller.text = p.fullText;
      _predictions = const [];
      _loading = true;
    });
    try {
      final details = await widget.client.fetchPlace(
        p.placeId,
        fields: const [
          g.PlaceField.Address,
          g.PlaceField.AddressComponents,
          g.PlaceField.Name,
          g.PlaceField.Location,
        ],
      );
      final place = details.place;
      if (place == null) return;
      final mapped = SoePlaceResult.fromPlace(place);
      if (mapped != null) widget.onPlaceSelected(mapped);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoeTextField(
          controller: widget.controller,
          hint: widget.hint,
          leadingIcon: Icons.search,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          trailing: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        if (_predictions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: AppRadius.rMd,
              border: Border.all(color: AppPalette.n300),
            ),
            child: Column(
              children: [
                for (final p in _predictions.take(5))
                  _PredictionTile(
                    prediction: p,
                    onTap: () => _select(p),
                  ),
              ],
            ),
          ),
        ] else if (_serviceUnavailable) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppPalette.warningBg,
              borderRadius: AppRadius.rMd,
              border: Border.all(color: AppPalette.warning),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 16,
                  color: AppPalette.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.widgets.placesUnavailable,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.warning, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({required this.prediction, required this.onTap});
  final g.AutocompletePrediction prediction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.place_outlined, size: 18, color: AppPalette.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.primaryText,
                    style: AppTypography.bodySm
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prediction.secondaryText.isNotEmpty)
                    Text(
                      prediction.secondaryText,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.n700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
