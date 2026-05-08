import 'package:flutter/material.dart';

/// Pays supporté par le picker du flow d'inscription.
@immutable
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.callingCode,
  });

  /// ISO 3166-1 alpha-2 (CM, FR, ...).
  final String code;

  /// Nom affiché localisé en français (les 8 entrées MVP sont francophones).
  final String name;

  /// Indicatif téléphonique (« +237 », « +33 », ...).
  final String callingCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && other.code == code);

  @override
  int get hashCode => code.hashCode;
}

/// 8 pays MVP — francophones d'Afrique de l'Ouest et France métropolitaine.
abstract final class Countries {
  static const Country cameroon = Country(
    code: 'CM',
    name: 'Cameroun',
    callingCode: '+237',
  );
  static const Country france = Country(
    code: 'FR',
    name: 'France',
    callingCode: '+33',
  );
  static const Country ivoryCoast = Country(
    code: 'CI',
    name: 'Côte d’Ivoire',
    callingCode: '+225',
  );
  static const Country senegal = Country(
    code: 'SN',
    name: 'Sénégal',
    callingCode: '+221',
  );
  static const Country benin = Country(
    code: 'BJ',
    name: 'Bénin',
    callingCode: '+229',
  );
  static const Country gabon = Country(
    code: 'GA',
    name: 'Gabon',
    callingCode: '+241',
  );
  static const Country togo = Country(
    code: 'TG',
    name: 'Togo',
    callingCode: '+228',
  );
  static const Country mali = Country(
    code: 'ML',
    name: 'Mali',
    callingCode: '+223',
  );

  static const List<Country> all = [
    cameroon,
    france,
    ivoryCoast,
    senegal,
    benin,
    gabon,
    togo,
    mali,
  ];

  static Country byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => cameroon);
}

/// Drapeau du pays — rendu vectoriel via [Container] colorés (pas d'asset).
///
/// Format compact, légèrement arrondi (1px) pour s'inscrire dans les pills
/// et inputs du design (taille canonique 20×14 dans `auth.jsx`).
class CountryFlag extends StatelessWidget {
  const CountryFlag({
    super.key,
    required this.country,
    this.width = 20,
    this.height = 14,
  });

  final Country country;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1.5),
      child: SizedBox(
        width: width,
        height: height,
        child: _flagFor(country.code),
      ),
    );
  }

  Widget _flagFor(String code) {
    switch (code) {
      case 'CM':
        return _vertical3([_green, _red, _yellow]);
      case 'FR':
        return _vertical3([
          const Color(0xFF0055A4),
          const Color(0xFFFFFFFF),
          const Color(0xFFEF4135),
        ]);
      case 'CI':
        return _vertical3([
          const Color(0xFFFF8200),
          const Color(0xFFFFFFFF),
          const Color(0xFF009E60),
        ]);
      case 'SN':
        return _vertical3([
          const Color(0xFF00853F),
          const Color(0xFFFDEF42),
          const Color(0xFFE31B23),
        ]);
      case 'BJ':
        return Row(
          children: [
            Expanded(child: Container(color: const Color(0xFF008751))),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: Container(color: const Color(0xFFFCD116))),
                  Expanded(child: Container(color: const Color(0xFFE8112D))),
                ],
              ),
            ),
          ],
        );
      case 'GA':
        return _horizontal3([
          const Color(0xFF009E60),
          const Color(0xFFFCD116),
          const Color(0xFF3A75C4),
        ]);
      case 'TG':
        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: Container(color: const Color(0xFF006A4E))),
                Expanded(child: Container(color: const Color(0xFFFFCE00))),
                Expanded(child: Container(color: const Color(0xFF006A4E))),
                Expanded(child: Container(color: const Color(0xFFFFCE00))),
                Expanded(child: Container(color: const Color(0xFF006A4E))),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              width: width * 0.4,
              height: height * 0.6,
              child: Container(color: const Color(0xFFD21034)),
            ),
          ],
        );
      case 'ML':
        return _vertical3([
          const Color(0xFF14B53A),
          const Color(0xFFFCD116),
          const Color(0xFFCE1126),
        ]);
    }
    return const ColoredBox(color: Color(0xFFEEEEEE));
  }

  // Couleurs Cameroun (réutilisées par défaut).
  static const Color _green = Color(0xFF007A3D);
  static const Color _red = Color(0xFFCE1126);
  static const Color _yellow = Color(0xFFFCD116);

  Widget _vertical3(List<Color> colors) => Row(
        children: [
          for (final c in colors) Expanded(child: Container(color: c)),
        ],
      );

  Widget _horizontal3(List<Color> colors) => Column(
        children: [
          for (final c in colors) Expanded(child: Container(color: c)),
        ],
      );
}
