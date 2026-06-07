enum ChildGender { male, feminine, unknown }

/// Valeurs API officielles (CDC §11.5) : `general`, `technic`, `primary`.
enum ChildEducation { primary, general, technic, unknown }

class Child {
  const Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    this.classe,
    this.schoolClassId,
    this.section,
    this.education = ChildEducation.unknown,
    this.subjects = const [],
    this.avatarUrl,
    this.address,
  });

  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final ChildGender gender;

  /// Nom de la classe (ex: "CM2", "4ème") — pour affichage liste.
  final String? classe;

  /// UUID de la SchoolClass — pour pre-remplir le picker en mode edit.
  final String? schoolClassId;
  final String? section;
  final ChildEducation education;
  final List<String> subjects;
  final String? avatarUrl;
  final String? address;

  String get fullName => '$firstName $lastName';

  String get genderLabel => switch (gender) {
        ChildGender.male => 'Garçon',
        ChildGender.feminine => 'Fille',
        ChildGender.unknown => '—',
      };
}

class ChildFormParams {
  const ChildFormParams({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.city,
    this.schoolClassId,
    this.section,
    this.education,
    this.subjects = const [],
    this.neighborhood,
    this.country = 'Cameroun',
    this.countryCode = 'CM',
  });

  final String firstName;
  final String lastName;
  final int age;
  final ChildGender gender;

  /// UUID d'une `SchoolClass` recuperee via /references/school_classes.
  /// Obligatoire cote back ("Classe doit exister").
  final String? schoolClassId;
  final String? section;
  final ChildEducation? education;
  final List<String> subjects;

  /// Adresse — `city` est obligatoire côté API (CDC + 422).
  final String city;
  final String? neighborhood;
  final String country;
  final String countryCode;
}
