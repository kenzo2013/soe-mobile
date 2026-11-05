/// Models of the candidate tutor's recruitment journey (REP-02 to REP-09, REP-23, REP-24), read
/// from the API v2 (`soe/docs/api/v2/openapi.yml`: TutorFile, TutorFileSection, the interview and
/// the charter). Plain classes: the screens only read them.
library;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

/// A calendar day (`2026-11-05`), kept as a local date without a time zone shift.
DateTime? _day(Object? value) {
  if (value is! String) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

List<Map<String, dynamic>> _list(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

String? _text(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

/// The 7 sections of the file, in the order of the journey.
abstract final class TutorFileSections {
  static const identity = 'identity';
  static const address = 'address';
  static const subjects = 'subjects';
  static const availability = 'availability';
  static const diplomas = 'diplomas';
  static const experiences = 'experiences';
  static const presentation = 'presentation';

  static const all = [
    identity,
    address,
    subjects,
    availability,
    diplomas,
    experiences,
    presentation,
  ];

  /// The section where a document to redo (identity, photo, diploma) is changed.
  static String ofDocument(String document) => switch (document) {
        'photo' => presentation,
        'diploma' => diplomas,
        _ => identity,
      };
}

/// The steps of the journey, after the file is filled (`application`).
abstract final class TutorJourney {
  static const steps = [
    'file',
    'documents_check',
    'interview',
    'test',
    'charter',
    'active',
  ];

  /// The position of a stage in the journey (`application` counts as the first step).
  static int indexOf(String stage) {
    final index = steps.indexOf(stage);
    return index < 0 ? 0 : index;
  }

  /// Whether [stage] is at or after [step].
  static bool reached(String stage, String step) =>
      stage != 'refused' && indexOf(stage) >= steps.indexOf(step);
}

/// A section of the file in the overview (REP-02).
class TutorFileSectionSummary {
  const TutorFileSectionSummary({
    required this.section,
    required this.label,
    required this.state,
    required this.stateLabel,
    required this.summary,
    required this.editable,
  });

  factory TutorFileSectionSummary.fromJson(Map<String, dynamic> json) =>
      TutorFileSectionSummary(
        section: json['section'] as String? ?? '',
        label: json['label'] as String? ?? '',
        state: json['state'] as String? ?? 'missing',
        stateLabel: json['state_label'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        editable: json['editable'] != false,
      );

  final String section;
  final String label;

  /// missing, in_review, complete, accepted, redo.
  final String state;
  final String stateLabel;
  final String summary;

  /// False: a checked document, changed only when SOE asks to redo it.
  final bool editable;

  bool get isComplete => state != 'missing';
}

/// A point of the « Vérifié SOE » badge as parents will see it.
class TutorBadgeItem {
  const TutorBadgeItem({
    required this.item,
    required this.label,
    required this.state,
    required this.stateLabel,
  });

  factory TutorBadgeItem.fromJson(Map<String, dynamic> json) => TutorBadgeItem(
        item: json['item'] as String? ?? '',
        label: json['label'] as String? ?? '',
        state: json['state'] as String? ?? 'upcoming',
        stateLabel: json['state_label'] as String? ?? '',
      );

  /// identity, diplomas, interview, test.
  final String item;
  final String label;

  /// missing, in_review, complete, accepted, redo, upcoming.
  final String state;
  final String stateLabel;
}

/// A document SOE asked to redo, with its reason.
class TutorRedoItem {
  const TutorRedoItem(
      {required this.document, required this.label, this.reason});

  factory TutorRedoItem.fromJson(Map<String, dynamic> json) => TutorRedoItem(
        document: json['document'] as String? ?? 'identity',
        label: json['label'] as String? ?? '',
        reason: _text(json['reason']),
      );

  /// identity, photo, diploma.
  final String document;
  final String label;
  final String? reason;

  String get section => TutorFileSections.ofDocument(document);
}

/// The candidate's file (REP-02): the journey, the 7 sections, the badge, what to redo.
class TutorFile {
  const TutorFile({
    required this.stage,
    required this.step,
    required this.totalSteps,
    required this.stepLabel,
    required this.active,
    required this.refused,
    required this.completeCount,
    required this.totalSections,
    required this.canSubmit,
    required this.sections,
    required this.badge,
    required this.toRedo,
  });

  factory TutorFile.fromJson(Map<String, dynamic> json) => TutorFile(
        stage: json['stage'] as String? ?? 'application',
        step: _int(json['step']).clamp(1, 99),
        totalSteps: _int(json['total_steps']),
        stepLabel: json['step_label'] as String? ?? '',
        active: json['active'] == true,
        refused: json['refused'] == true,
        completeCount: _int(json['complete_count']),
        totalSections: _int(json['total_sections']),
        canSubmit: json['can_submit'] == true,
        sections: _list(json['sections'])
            .map(TutorFileSectionSummary.fromJson)
            .toList(),
        badge: _list(json['badge']).map(TutorBadgeItem.fromJson).toList(),
        toRedo: _list(json['to_redo']).map(TutorRedoItem.fromJson).toList(),
      );

  /// application, file, documents_check, interview, test, charter, active, refused.
  final String stage;
  final int step;
  final int totalSteps;
  final String stepLabel;
  final bool active;
  final bool refused;
  final int completeCount;
  final int totalSections;
  final bool canSubmit;
  final List<TutorFileSectionSummary> sections;
  final List<TutorBadgeItem> badge;
  final List<TutorRedoItem> toRedo;

  /// The file is still being filled (not yet sent to SOE).
  bool get filling => stage == 'application';

  TutorFileSectionSummary? section(String name) {
    for (final s in sections) {
      if (s.section == name) return s;
    }
    return null;
  }

  /// Whether every section but [except] is complete (the last one then sends the file).
  bool completeExcept(String except) =>
      sections.where((s) => s.section != except).every((s) => s.isComplete);
}

/// The identity on file (REP-03).
class TutorIdentityContent {
  const TutorIdentityContent({
    this.documentType,
    this.birthdate,
    this.expiresOn,
    required this.imagesCount,
  });

  factory TutorIdentityContent.fromJson(Map<String, dynamic> json) =>
      TutorIdentityContent(
        documentType: _text(json['document_type']),
        birthdate: _day(json['birthdate']),
        expiresOn: _day(json['expires_on']),
        imagesCount: _int(json['images_count']),
      );

  /// cni, passport or residence_permit (v1 files may hold others).
  final String? documentType;
  final DateTime? birthdate;
  final DateTime? expiresOn;
  final int imagesCount;
}

/// The address and the travel zones (REP-04).
class TutorAddressContent {
  const TutorAddressContent({
    this.address,
    this.neighborhood,
    this.city,
    this.landmark,
    required this.travelZones,
  });

  factory TutorAddressContent.fromJson(Map<String, dynamic> json) =>
      TutorAddressContent(
        address: _text(json['address']),
        neighborhood: _text(json['neighborhood']),
        city: _text(json['city']),
        landmark: _text(json['landmark']),
        travelZones: _strings(json['travel_zones']),
      );

  final String? address;
  final String? neighborhood;
  final String? city;
  final String? landmark;
  final List<String> travelZones;
}

/// A course of the file: a school class and the subjects taught in it (REP-05).
class TutorCourse {
  const TutorCourse({
    required this.id,
    this.schoolClassId,
    this.schoolClass,
    required this.subjectIds,
    required this.subjects,
  });

  factory TutorCourse.fromJson(Map<String, dynamic> json) => TutorCourse(
        id: _int(json['id']),
        schoolClassId: (json['school_class_id'] as num?)?.toInt(),
        schoolClass: _text(json['school_class']),
        subjectIds: (json['subject_ids'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .map((n) => n.toInt())
            .toList(),
        subjects: _strings(json['subjects']),
      );

  final int id;
  final int? schoolClassId;
  final String? schoolClass;
  final List<int> subjectIds;
  final List<String> subjects;
}

/// A time range of a day, « HH:MM ».
class TutorTimeRange {
  const TutorTimeRange({required this.from, required this.to});

  factory TutorTimeRange.fromJson(Map<String, dynamic> json) => TutorTimeRange(
        from: json['from'] as String? ?? '',
        to: json['to'] as String? ?? '',
      );

  final String from;
  final String to;

  Map<String, String> toJson() => {'from': from, 'to': to};

  @override
  bool operator ==(Object other) =>
      other is TutorTimeRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// The weekly availabilities (REP-06): the 7 days from Monday, two ranges a day at most, between
/// [opensAt] and [closesAt].
class TutorAvailabilityContent {
  const TutorAvailabilityContent({
    required this.days,
    required this.opensAt,
    required this.closesAt,
  });

  factory TutorAvailabilityContent.fromJson(Map<String, dynamic> json) {
    final days = <String, List<TutorTimeRange>>{};
    for (final day in _list(json['days'])) {
      final name = day['day'] as String?;
      if (name == null) continue;
      days[name.toLowerCase()] = _list(day['ranges'])
          .map(TutorTimeRange.fromJson)
          .where((r) => r.from.isNotEmpty && r.to.isNotEmpty)
          .toList();
    }
    return TutorAvailabilityContent(
      days: days,
      opensAt: json['opens_at'] as String? ?? '07:00',
      closesAt: json['closes_at'] as String? ?? '21:30',
    );
  }

  /// Ranges by day name (`monday`...).
  final Map<String, List<TutorTimeRange>> days;
  final String opensAt;
  final String closesAt;
}

/// A diploma of the file (REP-07).
class TutorDiploma {
  const TutorDiploma({
    required this.id,
    this.category,
    this.levelOfStudy,
    this.fieldOfTraining,
    this.speciality,
    this.obtainedAt,
    required this.documentsCount,
  });

  factory TutorDiploma.fromJson(Map<String, dynamic> json) => TutorDiploma(
        id: _int(json['id']),
        category: _text(json['category']),
        levelOfStudy: _text(json['level_of_study']),
        fieldOfTraining: _text(json['field_of_training']),
        speciality: _text(json['speciality']),
        obtainedAt: _day(json['obtained_at']),
        documentsCount: _int(json['documents_count']),
      );

  final int id;
  final String? category;
  final String? levelOfStudy;
  final String? fieldOfTraining;
  final String? speciality;
  final DateTime? obtainedAt;
  final int documentsCount;

  /// « Licence · Mathématiques ».
  String get title =>
      [category, speciality ?? fieldOfTraining].whereType<String>().join(' · ');
}

/// An experience of the file (REP-08).
class TutorExperience {
  const TutorExperience({
    required this.id,
    this.position,
    this.company,
    required this.currentPosition,
  });

  factory TutorExperience.fromJson(Map<String, dynamic> json) =>
      TutorExperience(
        id: _int(json['id']),
        position: _text(json['position']),
        company: _text(json['company']),
        currentPosition: json['current_position'] == true,
      );

  final int id;
  final String? position;
  final String? company;
  final bool currentPosition;
}

/// The presentation (REP-09): the bio and whether a photo is on file.
class TutorPresentationContent {
  const TutorPresentationContent(
      {this.bio, required this.bioMax, required this.hasPhoto});

  factory TutorPresentationContent.fromJson(Map<String, dynamic> json) =>
      TutorPresentationContent(
        bio: json['bio'] as String?,
        bioMax: _int(json['bio_max']) > 0 ? _int(json['bio_max']) : 500,
        hasPhoto: json['has_photo'] == true,
      );

  final String? bio;
  final int bioMax;
  final bool hasPhoto;
}

/// One section of the file (REP-03 to REP-09): its state, whether it can change now, and what is
/// on file ([content], read through the getter of the section).
class TutorFileSection {
  const TutorFileSection({
    required this.section,
    required this.label,
    required this.state,
    required this.stateLabel,
    required this.editable,
    this.redoReason,
    required this.content,
  });

  factory TutorFileSection.fromJson(Map<String, dynamic> json) =>
      TutorFileSection(
        section: json['section'] as String? ?? '',
        label: json['label'] as String? ?? '',
        state: json['state'] as String? ?? 'missing',
        stateLabel: json['state_label'] as String? ?? '',
        editable: json['editable'] != false,
        redoReason: _text(json['redo_reason']),
        content: (json['content'] as Map<String, dynamic>?) ?? const {},
      );

  final String section;
  final String label;
  final String state;
  final String stateLabel;
  final bool editable;
  final String? redoReason;
  final Map<String, dynamic> content;

  bool get toRedo => state == 'redo';

  TutorIdentityContent get identity => TutorIdentityContent.fromJson(content);
  TutorAddressContent get address => TutorAddressContent.fromJson(content);
  List<TutorCourse> get courses =>
      _list(content['items']).map(TutorCourse.fromJson).toList();
  TutorAvailabilityContent get availability =>
      TutorAvailabilityContent.fromJson(content);
  List<TutorDiploma> get diplomas =>
      _list(content['items']).map(TutorDiploma.fromJson).toList();
  int get diplomasMax => _int(content['max']) > 0 ? _int(content['max']) : 10;
  List<TutorExperience> get experiences =>
      _list(content['items']).map(TutorExperience.fromJson).toList();
  TutorPresentationContent get presentation =>
      TutorPresentationContent.fromJson(content);
}

/// The interview with SOE and the level test (REP-23).
class TutorInterview {
  const TutorInterview({
    required this.stage,
    this.interviewAt,
    required this.interviewPassed,
    required this.bring,
    this.testScore,
    required this.testPassed,
  });

  factory TutorInterview.fromJson(Map<String, dynamic> json) => TutorInterview(
        stage: json['stage'] as String? ?? 'application',
        interviewAt: _date(json['interview_at']),
        interviewPassed: json['interview_passed'] == true,
        bring: _strings(json['bring']),
        testScore: (json['test_score'] as num?)?.toInt(),
        testPassed: json['test_passed'] == true,
      );

  final String stage;

  /// Set by SOE; null while no date is set.
  final DateTime? interviewAt;
  final bool interviewPassed;
  final List<String> bring;

  /// Out of 100, null while the test is not graded.
  final int? testScore;
  final bool testPassed;
}

/// An article of the charter.
class TutorCharterArticle {
  const TutorCharterArticle({required this.title, required this.body});

  factory TutorCharterArticle.fromJson(Map<String, dynamic> json) =>
      TutorCharterArticle(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String title;
  final String body;
}

/// The charter and code of conduct (REP-24).
class TutorCharter {
  const TutorCharter({
    required this.stage,
    this.signedAt,
    required this.canSign,
    required this.articles,
  });

  factory TutorCharter.fromJson(Map<String, dynamic> json) => TutorCharter(
        stage: json['stage'] as String? ?? 'application',
        signedAt: _date(json['signed_at']),
        canSign: json['can_sign'] == true,
        articles:
            _list(json['articles']).map(TutorCharterArticle.fromJson).toList(),
      );

  final String stage;
  final DateTime? signedAt;
  final bool canSign;
  final List<TutorCharterArticle> articles;
}
