/// The classes × subjects referential (`GET /references`: `classes` and `subjects`). A class
/// lists the subjects taught in it; an empty list means any active subject. Older servers send
/// only `school_classes`: every class is then offered, with any subject.
class SchoolCatalog {
  const SchoolCatalog({required this.subjects, required this.classes});

  factory SchoolCatalog.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> maps(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    final classes = json['classes'] is List
        ? maps('classes').map(SchoolClassRef.fromJson).toList()
        : maps('school_classes').map(SchoolClassRef.fromLegacyJson).toList();
    return SchoolCatalog(
      subjects: maps('subjects').map(SchoolSubjectRef.fromJson).toList(),
      classes: classes,
    );
  }

  static const empty = SchoolCatalog(subjects: [], classes: []);

  final List<SchoolSubjectRef> subjects;
  final List<SchoolClassRef> classes;

  SchoolClassRef? classById(int? id) =>
      id == null ? null : classes.where((item) => item.id == id).firstOrNull;

  SchoolSubjectRef? subjectById(int id) =>
      subjects.where((item) => item.id == id).firstOrNull;

  /// The classes a form offers: the active ones of [subsystem] (all when null or unknown), plus
  /// [currentId] (the class a child already has), in catalogue order.
  List<SchoolClassRef> offeredClasses({String? subsystem, int? currentId}) =>
      classes
          .where((item) =>
              item.id == currentId ||
              (item.active &&
                  (subsystem == null ||
                      item.subsystem == null ||
                      item.subsystem == subsystem)))
          .toList();

  /// The active subjects taught in [classId], in the order of `subjects`: those listed for the
  /// class, else every active subject (like the server's forms). [keep] (subjects already chosen)
  /// stay offered even when no longer taught or deactivated.
  List<SchoolSubjectRef> subjectsFor(int? classId,
      {Iterable<int> keep = const []}) {
    final taught = classById(classId)?.subjectIds;
    final kept = keep.toSet();
    return subjects
        .where((subject) =>
            kept.contains(subject.id) ||
            (subject.active &&
                (taught == null ||
                    taught.isEmpty ||
                    taught.contains(subject.id))))
        .toList();
  }

  /// The name of subject [id] in the app's language, or [fallback] when it is not in the catalog.
  String subjectLabel(int id, String languageCode,
          {required String fallback}) =>
      subjectById(id)?.label(languageCode) ?? fallback;

  /// Whether [subjectId] may be chosen for [classId] (any subject for a class with none listed).
  bool teaches(int? classId, int subjectId) {
    final taught = classById(classId)?.subjectIds;
    return taught == null || taught.isEmpty || taught.contains(subjectId);
  }
}

/// A subject: French [name], English [nameEn] (may be null), [category], [active].
class SchoolSubjectRef {
  const SchoolSubjectRef({
    required this.id,
    required this.name,
    this.nameEn,
    this.abbr,
    this.category,
    this.active = true,
  });

  factory SchoolSubjectRef.fromJson(Map<String, dynamic> json) =>
      SchoolSubjectRef(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        nameEn: json['name_en'] as String?,
        abbr: json['abbr'] as String?,
        category: json['category'] as String?,
        active: json['active'] as bool? ?? true,
      );

  final int id;
  final String name;
  final String? nameEn;
  final String? abbr;
  final String? category;
  final bool active;

  /// The name in the app's language ([languageCode] `en`: the English name when known).
  String label(String languageCode) =>
      languageCode == 'en' && (nameEn ?? '').isNotEmpty ? nameEn! : name;
}

/// A class of the referential: its [subsystem] (francophone / anglophone), [track] (primary,
/// general, technic), [cycle] and the ids of the subjects taught in it.
class SchoolClassRef {
  const SchoolClassRef({
    required this.id,
    required this.name,
    this.key,
    this.nameEn,
    this.abbr,
    this.subsystem,
    this.track,
    this.cycle,
    this.active = true,
    this.subjectIds = const [],
  });

  factory SchoolClassRef.fromJson(Map<String, dynamic> json) => SchoolClassRef(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        key: json['key'] as String?,
        nameEn: json['name_en'] as String?,
        abbr: json['abbr'] as String?,
        subsystem: json['subsystem'] as String?,
        track: json['track'] as String?,
        cycle: json['cycle'] as String?,
        active: json['active'] as bool? ?? true,
        subjectIds: (json['subjects'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((item) => (item['id'] as num?)?.toInt())
            .whereType<int>()
            .toList(),
      );

  /// An entry of the older `school_classes` list: no subjects listed (any subject).
  factory SchoolClassRef.fromLegacyJson(Map<String, dynamic> json) =>
      SchoolClassRef(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        abbr: json['abbr'] as String?,
        subsystem: json['section'] as String?,
        track: json['education'] as String?,
      );

  final int id;
  final String name;
  final String? key;
  final String? nameEn;
  final String? abbr;
  final String? subsystem;
  final String? track;
  final String? cycle;
  final bool active;
  final List<int> subjectIds;

  String label(String languageCode) =>
      languageCode == 'en' && (nameEn ?? '').isNotEmpty ? nameEn! : name;

  /// The group of the class picker: technical classes together, else by cycle.
  String get group =>
      track == 'technic' ? 'technical' : (cycle ?? track ?? 'other');
}
