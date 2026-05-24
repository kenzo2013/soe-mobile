class StudentSummary {
  const StudentSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.classe,
    this.avatarUrl,
    this.section,
    this.subjects = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final String classe;
  final String? avatarUrl;
  final String? section;
  final List<String> subjects;

  String get fullName => '$firstName $lastName';
}
