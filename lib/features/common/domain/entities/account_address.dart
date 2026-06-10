/// Adresse du compte — `GET/PATCH /common/address` (CDC §6.1).
class AccountAddress {
  const AccountAddress({
    this.id,
    this.address,
    this.complement,
    this.neighborhood,
    this.city,
    this.region,
    this.country,
    this.countryCode,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  final String? id;

  /// Ligne principale (autocomplete Google Places).
  final String? address;

  /// Complément d'adresse (immeuble, étage…).
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? region;
  final String? country;
  final String? countryCode;

  /// Point de repère.
  final String? landmark;
  final double? latitude;
  final double? longitude;

  AccountAddress copyWith({
    String? address,
    String? complement,
    String? neighborhood,
    String? city,
    String? region,
    String? country,
    String? countryCode,
    String? landmark,
    double? latitude,
    double? longitude,
  }) =>
      AccountAddress(
        id: id,
        address: address ?? this.address,
        complement: complement ?? this.complement,
        neighborhood: neighborhood ?? this.neighborhood,
        city: city ?? this.city,
        region: region ?? this.region,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        landmark: landmark ?? this.landmark,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  /// Résumé court pour le hub « Mon compte » (`Bastos, Yaoundé`).
  String get shortLabel {
    final parts = [neighborhood, city].where((s) => s != null && s.isNotEmpty);
    return parts.isEmpty ? 'Non renseignée' : parts.join(', ');
  }
}
