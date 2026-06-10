/// Contrat / convention de tutorat (`GET /tutors/contracts`).
class TutorContract {
  const TutorContract({
    required this.id,
    required this.reference,
    required this.parent,
    required this.student,
    required this.signed,
    required this.dateLine,
    required this.monthlyAmount,
    required this.amendment,
  });

  final String id;
  final String reference;
  final String parent;
  final String student;
  final bool signed;
  final String dateLine;
  final int monthlyAmount;

  /// `true` si c'est un avenant à une convention existante.
  final bool amendment;
}
