import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';

/// Provider exposant un client `FlutterGooglePlacesSdk` initialisé une seule
/// fois par session.
///
/// La clé doit être injectée au build via
/// `--dart-define=GOOGLE_PLACES_API_KEY=...`. Si la clé est absente, on lève
/// une erreur explicite plutôt que d'envoyer des requêtes anonymes.
final googlePlacesClientProvider = Provider<FlutterGooglePlacesSdk>((ref) {
  final key = Env.googlePlacesApiKey;
  if (key.isEmpty) {
    throw StateError(
      'GOOGLE_PLACES_API_KEY missing — pass it via --dart-define at build time.',
    );
  }
  return FlutterGooglePlacesSdk(key);
});

/// Détails utiles d'une place sélectionnée par l'utilisateur, mappés sur
/// les champs adresse SOE.
class SoePlaceResult {
  const SoePlaceResult({
    required this.formattedAddress,
    required this.city,
    required this.country,
    required this.countryCode,
    this.neighborhood,
  });

  final String formattedAddress;
  final String city;
  final String country;
  final String countryCode;
  final String? neighborhood;

  /// Construit un [SoePlaceResult] à partir des composants d'adresse Google.
  static SoePlaceResult? fromPlace(Place place) {
    final addr = place.address ?? place.name ?? '';
    if (addr.isEmpty) return null;
    String? city;
    String? country;
    String? countryCode;
    String? neighborhood;
    for (final c in place.addressComponents ?? const <AddressComponent>[]) {
      final types = c.types;
      if (types.contains('locality')) {
        city = c.name;
      } else if (city == null && types.contains('administrative_area_level_2')) {
        city = c.name;
      }
      if (types.contains('country')) {
        country = c.name;
        countryCode = c.shortName;
      }
      if (types.contains('sublocality') ||
          types.contains('sublocality_level_1') ||
          types.contains('neighborhood')) {
        neighborhood = c.name;
      }
    }
    return SoePlaceResult(
      formattedAddress: addr,
      city: city ?? '',
      country: country ?? '',
      countryCode: countryCode ?? '',
      neighborhood: neighborhood,
    );
  }
}
