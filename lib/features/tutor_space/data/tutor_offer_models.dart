/// Models of the offers and applications of the tutor space v2 (REP-10 to REP-12), read from
/// the API v2 (`TutorOffer`, `TutorApplication` of `soe/docs/api/v2/openapi.yml`).
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

/// The start date is before today (the API's `start_passed` when it does not say it).
bool tutorOfferStartPassed(DateTime? start, {DateTime? today}) {
  if (start == null) return false;
  final now = today ?? DateTime.now();
  return start.isBefore(DateTime(now.year, now.month, now.day));
}

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

/// « Mathématiques et physique · 3e »: the subjects, then the classes.
String _title(List<String> subjects, List<String> classes, String and) {
  final names = subjects.length < 2
      ? subjects.join()
      : '${subjects.sublist(0, subjects.length - 1).join(', ')} $and ${subjects.last}';
  return [names, classes.join(', ')].where((s) => s.isNotEmpty).join(' · ');
}

/// An offer published by SOE: never the address, only the neighbourhood.
class TutorOffer {
  const TutorOffer({
    required this.id,
    required this.reference,
    required this.subjects,
    required this.schoolClasses,
    required this.neighborhood,
    required this.description,
    required this.startDate,
    required this.sessionRate,
    required this.publishedAt,
    required this.applied,
    required this.applicationStatus,
    required this.appliedAt,
    required this.canApply,
    this.startLabel,
    this.startPassed = false,
  });

  factory TutorOffer.fromJson(Map<String, dynamic> json) {
    final startDate = _day(json['start_date']);
    return TutorOffer(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reference: json['reference'] as String? ?? '',
      subjects: _strings(json['subjects']),
      schoolClasses: _strings(json['school_classes']),
      neighborhood: json['neighborhood'] as String?,
      description: json['description'] as String? ?? '',
      startDate: startDate,
      startLabel: json['start_label'] as String?,
      startPassed: json['start_passed'] is bool
          ? json['start_passed'] as bool
          : tutorOfferStartPassed(startDate),
      sessionRate: (json['session_rate'] as num?)?.toInt(),
      publishedAt: _date(json['published_at']),
      applied: json['applied'] == true,
      applicationStatus: json['application_status'] as String?,
      appliedAt: _date(json['applied_at']),
      canApply: json['can_apply'] == true,
    );
  }

  final int id;
  final String reference;
  final List<String> subjects;
  final List<String> schoolClasses;
  final String? neighborhood;
  final String description;
  final DateTime? startDate;

  /// The server's words for the start (« Jeudi 12 novembre », the year when it is another
  /// year, « Dès que possible » once passed); null from an older API.
  final String? startLabel;

  /// The start date is in the past: the offer starts as soon as possible.
  final bool startPassed;

  /// The tutor's indicative pay per approved session (FCFA), never the family's price.
  final int? sessionRate;
  final DateTime? publishedAt;
  final bool applied;

  /// sent, selected, not_selected.
  final String? applicationStatus;
  final DateTime? appliedAt;
  final bool canApply;

  /// « Mathématiques et physique · 3e », [and] being the translated conjunction.
  String title(String and) => _title(subjects, schoolClasses, and);

  TutorOffer copyWith({bool? applied, bool? canApply, DateTime? appliedAt}) =>
      TutorOffer(
        id: id,
        reference: reference,
        subjects: subjects,
        schoolClasses: schoolClasses,
        neighborhood: neighborhood,
        description: description,
        startDate: startDate,
        startLabel: startLabel,
        startPassed: startPassed,
        sessionRate: sessionRate,
        publishedAt: publishedAt,
        applied: applied ?? this.applied,
        applicationStatus: applicationStatus,
        appliedAt: appliedAt ?? this.appliedAt,
        canApply: canApply ?? this.canApply,
      );
}

/// One of the tutor's applications and SOE's answer.
class TutorApplication {
  const TutorApplication({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.sentAt,
    required this.message,
    required this.offerId,
    required this.reference,
    required this.subjects,
    required this.schoolClass,
    required this.neighborhood,
  });

  factory TutorApplication.fromJson(Map<String, dynamic> json) =>
      TutorApplication(
        id: (json['id'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'sent',
        statusLabel: json['status_label'] as String? ?? '',
        sentAt: _date(json['sent_at']),
        message: json['message'] as String?,
        offerId: (json['offer_id'] as num?)?.toInt() ?? 0,
        reference: json['reference'] as String? ?? '',
        subjects: _strings(json['subjects']),
        schoolClass: json['school_class'] as String?,
        neighborhood: json['neighborhood'] as String?,
      );

  final int id;

  /// sent, selected, not_selected.
  final String status;
  final String statusLabel;
  final DateTime? sentAt;
  final String? message;
  final int offerId;
  final String reference;
  final List<String> subjects;
  final String? schoolClass;
  final String? neighborhood;

  String title(String and) => _title(subjects,
      [if (schoolClass != null && schoolClass!.isNotEmpty) schoolClass!], and);
}

/// The filters of the offers: the tutor's subjects ([mine]), their city ([zone]), a class.
class TutorOfferFilters {
  const TutorOfferFilters(
      {this.mine = true, this.zone = true, this.schoolClassId});

  final bool mine;
  final bool zone;
  final int? schoolClassId;

  TutorOfferFilters copyWith(
          {bool? mine, bool? zone, int? Function()? schoolClassId}) =>
      TutorOfferFilters(
        mine: mine ?? this.mine,
        zone: zone ?? this.zone,
        schoolClassId:
            schoolClassId == null ? this.schoolClassId : schoolClassId(),
      );

  Map<String, Object> get query => {
        'mine': mine ? '1' : '0',
        'zone': zone ? '1' : '0',
        if (schoolClassId != null) 'school_class_id': schoolClassId!,
      };

  @override
  bool operator ==(Object other) =>
      other is TutorOfferFilters &&
      other.mine == mine &&
      other.zone == zone &&
      other.schoolClassId == schoolClassId;

  @override
  int get hashCode => Object.hash(mine, zone, schoolClassId);
}

/// A page of the offers for some filters (the key of the paginated provider).
class TutorOfferPageKey {
  const TutorOfferPageKey(this.filters, this.page);

  final TutorOfferFilters filters;
  final int page;

  @override
  bool operator ==(Object other) =>
      other is TutorOfferPageKey &&
      other.filters == filters &&
      other.page == page;

  @override
  int get hashCode => Object.hash(filters, page);
}
