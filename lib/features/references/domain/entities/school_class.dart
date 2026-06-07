/// Une classe scolaire de référence côté back (CP, CM2, 4ème, 1re S, …).
///
/// L'API renvoie la liste via `GET /references/school_classes` (CDC §7.7).
/// Les students réfèrent une classe par `school_class_id` (UUID).
class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.name,
    this.education,
    this.section,
    this.position,
  });

  final String id;
  final String name;

  /// `general` / `technic` / `primary` — pour filtrer le dropdown selon le
  /// niveau choisi sur le form enfant.
  final String? education;

  /// `francophone` / `anglophone` — idem.
  final String? section;

  /// Ordre d'affichage si fourni par l'API.
  final int? position;
}
