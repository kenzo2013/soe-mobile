/// Une classe scolaire de référence côté back (CP, CM2, 4ème, 1re S, …).
/// Les students réfèrent une classe par `school_class_id` (UUID).
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.name,
    this.abbr,
  });

  final String id;
  final String name;

  /// Abréviation officielle (ex: "CM2"). Affichée à côté du nom si fournie.
  final String? abbr;
}

/// Bundle retourné par `GET /common/school_classes` :
/// la liste des classes + les valeurs de référence pour les pickers
/// (niveaux d'éducation et sections).
class SchoolClassReferences {
  const SchoolClassReferences({
    required this.educations,
    required this.sections,
    required this.classes,
  });

  final List<String> educations;
  final List<String> sections;
  final List<SchoolClass> classes;

  bool get isEmpty => classes.isEmpty && educations.isEmpty;

  SchoolClassReferences copyWith({
    List<SchoolClass>? classes,
  }) =>
      SchoolClassReferences(
        educations: educations,
        sections: sections,
        classes: classes ?? this.classes,
      );

  static const empty = SchoolClassReferences(
    educations: [],
    sections: [],
    classes: [],
  );
}
