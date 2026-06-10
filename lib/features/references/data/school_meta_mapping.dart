/// Conversion entre les libellés affichés (pickers Niveau/Section) et les
/// enums attendus/renvoyés par l'API (`general`, `francophone`, …).
///
/// Historiquement `GET /common/school_classes` renvoyait `data.educations`
/// en libellés ; il renvoie désormais les enums (`general`, `primary`, …).
/// On centralise ici la conversion pour que toute l'app manipule des libellés
/// et n'envoie/affiche les enums qu'au niveau réseau.
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
  /// "Francophone" → "francophone" — simple lowercase suffit ici.
  static String? sectionLabelToApi(String? label) =>
      (label == null || label.isEmpty) ? null : label.toLowerCase();

  /// "francophone" → "Francophone" — capitalise la 1re lettre.
  static String? sectionApiToLabel(String? api) {
    if (api == null || api.isEmpty) return null;
    return api[0].toUpperCase() + api.substring(1);
  }
}
