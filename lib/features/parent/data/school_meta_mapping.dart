/// Helpers de mapping entre les libellés affichés (`data.educations` et
/// `data.sections` de l'API `/common/school_classes`) et les enums
/// stockés en base (champs `student.education` et `student.section`).
///
/// L'API renvoie 2 vocabulaires différents :
/// - `data.educations` : ["Primaire", "Secondaire", "Général", "Technique"]
/// - `student.attributes.education` : "primary" / "secondary" / "general" / "technic"
/// On centralise ici la conversion pour ne pas dupliquer la table.
abstract final class SchoolMetaMapping {
  // ── Education ──────────────────────────────────────────────
  static const Map<String, String> _educationLabelToApi = {
    'Primaire': 'primary',
    'Secondaire': 'secondary',
    'Général': 'general',
    'Generale': 'general',
    'Technique': 'technic',
  };

  static const Map<String, String> _educationApiToLabel = {
    'primary': 'Primaire',
    'secondary': 'Secondaire',
    'general': 'Général',
    'technic': 'Technique',
  };

  /// Libellé affiché → enum API. Fallback : lowercase brut.
  static String? educationLabelToApi(String? label) {
    if (label == null || label.isEmpty) return null;
    return _educationLabelToApi[label] ?? label.toLowerCase();
  }

  /// Enum API → libellé affiché. Fallback : la chaîne d'entrée.
  static String? educationApiToLabel(String? api) {
    if (api == null || api.isEmpty) return null;
    return _educationApiToLabel[api.toLowerCase()] ?? api;
  }

  // ── Section ────────────────────────────────────────────────
  /// "Francophone" → "francophone" — simple lowercase suffit ici
  /// (pas d'accent à gérer).
  static String? sectionLabelToApi(String? label) =>
      (label == null || label.isEmpty) ? null : label.toLowerCase();

  /// "francophone" → "Francophone" — capitalise la 1re lettre.
  static String? sectionApiToLabel(String? api) {
    if (api == null || api.isEmpty) return null;
    return api[0].toUpperCase() + api.substring(1);
  }
}
