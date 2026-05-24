class ProgramModule {
  const ProgramModule({
    required this.id,
    required this.title,
    required this.progress, // 0.0 - 1.0
  });
  final String id;
  final String title;
  final double progress;
}

class ParentProgram {
  const ParentProgram({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.progress,
    this.description,
    this.modules = const [],
  });
  final String id;
  final String title;
  final String subject;
  final String level;
  final double progress;
  final String? description;
  final List<ProgramModule> modules;
}
