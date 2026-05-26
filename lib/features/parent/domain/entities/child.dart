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
  final String? classe;
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
    this.classe,
    this.section,
    this.education,
    this.subjects = const [],
    this.address,
  });

  final String firstName;
  final String lastName;
  final int age;
  final ChildGender gender;
  final String? classe;
  final String? section;
  final ChildEducation? education;
  final List<String> subjects;
  final String? address;
}
