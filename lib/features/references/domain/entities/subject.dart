/// Une matière de référence côté back (Mathématiques, Français, …).
/// Les cours du tuteur et les réservations réfèrent une matière par
/// `subject_id` (UUID).
class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.abbr,
  });

  final String id;
  final String name;

  /// Abréviation officielle (ex: "MATHS"). Affichée à côté du nom si fournie.
  final String? abbr;
}
