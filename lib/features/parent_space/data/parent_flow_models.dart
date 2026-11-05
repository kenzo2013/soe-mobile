/// Models of the parent flows added after lot 3: request detail and wizard, proposed tutors,
/// amendments, reviews, co-parents, references. Read from the API v2
/// (`soe/docs/api/v2/openapi.yml`); plain classes the screens only read.
library;

import 'parent_models.dart';

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

DateTime? _day(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

List<Map<String, dynamic>> _maps(Object? value) =>
    (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).map((item) => '$item').toList();

List<int> _ints(Object? value) =>
    (value as List<dynamic>? ?? const []).map(_int).toList();

/// A value and its translated label (options of the request wizard).
typedef ParentOption = ({String value, String label});

/// A child's need as the wizard and the request detail show it.
class ParentNeed {
  const ParentNeed({
    this.id,
    required this.childId,
    this.childName,
    required this.subjectIds,
    required this.subjects,
    this.objective,
    this.startOn,
    this.sessionsPerWeek,
    this.sessionMinutes,
    this.moments = const [],
    this.gender,
    this.missing = const [],
  });

  factory ParentNeed.fromJson(Map<String, dynamic> json) => ParentNeed(
        id: (json['id'] as num?)?.toInt(),
        childId: _int(json['child_id']),
        childName: json['child'] as String?,
        subjectIds: _ints(json['subject_ids']),
        subjects: _strings(json['subjects']),
        objective: json['objective'] as String?,
        startOn: _day(json['start_on']),
        sessionsPerWeek: (json['sessions_per_week'] as num?)?.toInt(),
        sessionMinutes: (json['session_minutes'] as num?)?.toInt(),
        moments: _strings(json['moments']),
        gender: json['gender'] as String?,
        missing: _strings(json['missing']),
      );

  /// The tutoring request (request detail only).
  final int? id;
  final int childId;
  final String? childName;
  final List<int> subjectIds;
  final List<String> subjects;

  /// catch_up, regular or exam.
  final String? objective;
  final DateTime? startOn;
  final int? sessionsPerWeek;
  final int? sessionMinutes;

  /// wednesday_afternoon, saturday_morning, weekday_evening, sunday.
  final List<String> moments;

  /// Preferred tutor gender: no_preference, male or female.
  final String? gender;

  /// Fields still to fill (wizard).
  final List<String> missing;

  bool get complete => missing.isEmpty;

  /// The body sent to the API (`need` of ParentNeedInput).
  Map<String, dynamic> toInput() => {
        'subject_ids': subjectIds,
        'objective': objective,
        'start_on': startOn == null
            ? null
            : '${startOn!.year.toString().padLeft(4, '0')}-${startOn!.month.toString().padLeft(2, '0')}-${startOn!.day.toString().padLeft(2, '0')}',
        'sessions_per_week': sessionsPerWeek,
        'session_minutes': sessionMinutes,
        'moments': moments,
        'gender': gender,
      };

  ParentNeed copyWith({
    List<int>? subjectIds,
    String? objective,
    DateTime? startOn,
    int? sessionsPerWeek,
    int? sessionMinutes,
    List<String>? moments,
    String? gender,
  }) =>
      ParentNeed(
        id: id,
        childId: childId,
        childName: childName,
        subjectIds: subjectIds ?? this.subjectIds,
        subjects: subjects,
        objective: objective ?? this.objective,
        startOn: startOn ?? this.startOn,
        sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
        sessionMinutes: sessionMinutes ?? this.sessionMinutes,
        moments: moments ?? this.moments,
        gender: gender ?? this.gender,
        missing: missing,
      );
}

/// One event of a request's history (including SOE's actions).
class ParentHistoryEvent {
  const ParentHistoryEvent(
      {required this.action,
      required this.label,
      required this.actor,
      required this.at});

  factory ParentHistoryEvent.fromJson(Map<String, dynamic> json) =>
      ParentHistoryEvent(
        action: json['action'] as String? ?? '',
        label: json['label'] as String? ?? '',
        actor: json['actor'] as String? ?? 'soe',
        at: _date(json['at']),
      );

  final String action;
  final String label;

  /// you, soe or family.
  final String actor;
  final DateTime? at;
}

/// PAR-07 — a request with its rights, needs and history.
class ParentRequestDetail {
  const ParentRequestDetail({
    required this.request,
    required this.canCancel,
    required this.needEditable,
    required this.tutorsPresented,
    required this.needs,
    required this.history,
  });

  factory ParentRequestDetail.fromJson(Map<String, dynamic> json) =>
      ParentRequestDetail(
        request: ParentRequest.fromJson(json),
        canCancel: json['can_cancel'] == true,
        needEditable: json['need_editable'] == true,
        tutorsPresented: json['tutors_presented'] == true,
        needs: _maps(json['needs']).map(ParentNeed.fromJson).toList(),
        history:
            _maps(json['history']).map(ParentHistoryEvent.fromJson).toList(),
      );

  final ParentRequest request;
  final bool canCancel;
  final bool needEditable;
  final bool tutorsPresented;
  final List<ParentNeed> needs;
  final List<ParentHistoryEvent> history;

  /// The replacement events of the history (PAR-20 follow-up).
  List<ParentHistoryEvent> get replacementEvents =>
      history.where((event) => event.action.contains('replacement')).toList();
}

/// A child the wizard may include.
class ParentDraftChild {
  const ParentDraftChild(
      {required this.id,
      required this.firstName,
      this.schoolClass,
      required this.selected});

  factory ParentDraftChild.fromJson(Map<String, dynamic> json) =>
      ParentDraftChild(
        id: _int(json['id']),
        firstName: json['first_name'] as String? ?? '',
        schoolClass: json['school_class'] as String?,
        selected: json['selected'] == true,
      );

  final int id;
  final String firstName;
  final String? schoolClass;
  final bool selected;
}

/// PAR-05 — the request being written, saved by the server at each step.
class ParentRequestDraft {
  const ParentRequestDraft({
    required this.childIds,
    required this.complete,
    required this.children,
    required this.needs,
    required this.objectives,
    required this.moments,
    required this.genders,
    required this.sessionsPerWeek,
    required this.sessionMinutes,
  });

  factory ParentRequestDraft.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as Map<String, dynamic>? ?? const {};
    List<ParentOption> labelled(Object? value) => _maps(value)
        .map((item) => (
              value: '${item['value']}',
              label: item['label'] as String? ?? '${item['value']}'
            ))
        .toList();
    return ParentRequestDraft(
      childIds: _ints(json['child_ids']),
      complete: json['complete'] == true,
      children: _maps(json['children']).map(ParentDraftChild.fromJson).toList(),
      needs: _maps(json['needs']).map(ParentNeed.fromJson).toList(),
      objectives: labelled(options['objectives']),
      moments: labelled(options['moments']),
      genders: labelled(options['genders']),
      sessionsPerWeek: _ints(options['sessions_per_week']),
      sessionMinutes: labelled(options['session_minutes']),
    );
  }

  final List<int> childIds;
  final bool complete;
  final List<ParentDraftChild> children;
  final List<ParentNeed> needs;
  final List<ParentOption> objectives;
  final List<ParentOption> moments;
  final List<ParentOption> genders;
  final List<int> sessionsPerWeek;
  final List<ParentOption> sessionMinutes;

  /// A draft already started: children chosen or a need filled.
  bool get started => childIds.isNotEmpty;

  ParentNeed needOf(int childId) => needs.firstWhere(
        (need) => need.childId == childId,
        orElse: () => ParentNeed(
            childId: childId, subjectIds: const [], subjects: const []),
      );

  String labelOf(List<ParentOption> options, Object? value) => options
      .firstWhere((option) => option.value == '$value',
          orElse: () => (value: '$value', label: '${value ?? ''}'))
      .label;
}

/// PAR-09 — a tutor SOE presents for one or more slots of the request.
class ParentTutorProfile {
  const ParentTutorProfile({
    required this.id,
    required this.name,
    required this.contractSigned,
    required this.slots,
    required this.checks,
    this.rating,
    required this.reviewsCount,
    required this.trainings,
    required this.experiences,
    required this.subjects,
    this.presentation,
    required this.availabilities,
  });

  factory ParentTutorProfile.fromJson(Map<String, dynamic> json) =>
      ParentTutorProfile(
        id: _int(json['id']),
        name: json['name'] as String? ?? '',
        contractSigned: json['contract_signed'] == true,
        slots: _maps(json['slots'])
            .map((slot) => (
                  id: _int(slot['id']),
                  subject: slot['subject'] as String? ?? '',
                  child: slot['child'] as String? ?? ''
                ))
            .toList(),
        checks: _checks(json['checks']),
        rating: (json['rating'] as num?)?.toDouble(),
        reviewsCount: _int(json['reviews_count']),
        trainings: _strings(json['trainings']),
        experiences: _strings(json['experiences']),
        subjects: _strings(json['subjects']),
        presentation: json['presentation'] as String?,
        availabilities: _maps(json['availabilities'])
            .map((day) => (
                  day: day['day'] as String? ?? '',
                  ranges: _strings(day['ranges'])
                ))
            .toList(),
      );

  /// « Vérifié SOE »: the checks done (identity, diplomas, interview, level test...).
  static List<String> _checks(Object? value) {
    if (value is List) return _strings(value);
    if (value is Map) {
      return value.entries
          .where((entry) => entry.value == true)
          .map((entry) => '${entry.key}')
          .toList();
    }
    return const [];
  }

  final int id;
  final String name;
  final bool contractSigned;
  final List<({int id, String subject, String child})> slots;
  final List<String> checks;
  final double? rating;
  final int reviewsCount;
  final List<String> trainings;
  final List<String> experiences;
  final List<String> subjects;
  final String? presentation;
  final List<({String day, List<String> ranges})> availabilities;

  String get initials => name
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// A review of another family, shown on a proposed tutor's profile.
class ParentTutorReview {
  const ParentTutorReview(
      {required this.id,
      required this.rating,
      this.comment,
      required this.subjects,
      this.createdAt});

  factory ParentTutorReview.fromJson(Map<String, dynamic> json) =>
      ParentTutorReview(
        id: _int(json['id']),
        rating: _int(json['rating']),
        comment: json['comment'] as String?,
        subjects: _strings(json['subjects']),
        createdAt: _date(json['created_at']),
      );

  final int id;
  final int rating;
  final String? comment;
  final List<String> subjects;
  final DateTime? createdAt;
}

/// An amendment of a contract (COM-08), signed like the contract.
class ParentAmendment {
  const ParentAmendment({
    required this.id,
    required this.reference,
    required this.contractId,
    required this.signed,
    required this.canSign,
    this.createdAt,
    this.signedAt,
    this.text = '',
  });

  factory ParentAmendment.fromJson(Map<String, dynamic> json) =>
      ParentAmendment(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        contractId: _int(json['contract_id']),
        signed: json['signed'] == true,
        canSign: json['can_sign'] == true,
        createdAt: _date(json['created_at']),
        signedAt: _date(json['signed_at']),
        text: json['text'] as String? ?? '',
      );

  final int id;
  final String reference;
  final int contractId;
  final bool signed;
  final bool canSign;
  final DateTime? createdAt;
  final DateTime? signedAt;
  final String text;
}

/// A subject as the API returns it ({id, name}).
typedef ParentSubject = ({int id, String name});

List<ParentSubject> _subjects(Object? value) => _maps(value)
    .map((item) => (id: _int(item['id']), name: item['name'] as String? ?? ''))
    .toList();

/// PAR-18 — a review the parent gave.
class ParentReview {
  const ParentReview({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.rating,
    this.comment,
    required this.subjects,
    required this.status,
    this.statusLabel,
    this.createdAt,
    required this.editable,
  });

  factory ParentReview.fromJson(Map<String, dynamic> json) => ParentReview(
        id: _int(json['id']),
        tutorId: _int(json['tutor_id']),
        tutorName: json['tutor_name'] as String? ?? '',
        rating: _int(json['rating']),
        comment: json['comment'] as String?,
        subjects: _subjects(json['subjects']),
        status: json['status'] as String? ?? 'active',
        statusLabel: json['status_label'] as String?,
        createdAt: _date(json['created_at']),
        editable: json['editable'] == true,
      );

  final int id;
  final int tutorId;
  final String tutorName;
  final int rating;
  final String? comment;
  final List<ParentSubject> subjects;
  final String status;
  final String? statusLabel;
  final DateTime? createdAt;
  final bool editable;
}

/// PAR-18 — a tutor of the family: review to give, soon, or already given.
class ParentReviewTutor {
  const ParentReviewTutor({
    required this.id,
    required this.name,
    this.activeReviewId,
    required this.subjects,
    required this.approvedSessions,
    required this.sessionsRequired,
    required this.eligible,
    this.since,
    this.courses,
  });

  factory ParentReviewTutor.fromJson(Map<String, dynamic> json) =>
      ParentReviewTutor(
        id: _int(json['id']),
        name: json['name'] as String? ?? '',
        activeReviewId: (json['active_review_id'] as num?)?.toInt(),
        subjects: _subjects(json['subjects']),
        approvedSessions: _int(json['approved_sessions']),
        sessionsRequired: _int(json['sessions_required']),
        eligible: json['eligible'] == true,
        since: _day(json['since']),
        courses: json['courses'] as String?,
      );

  final int id;
  final String name;
  final int? activeReviewId;
  final List<ParentSubject> subjects;
  final int approvedSessions;
  final int sessionsRequired;
  final bool eligible;
  final DateTime? since;

  /// « Anglais · Léa »: what the tutor teaches to the family.
  final String? courses;
}

/// PAR-19 — a co-parent who accepted the invitation.
class ParentCoParent {
  const ParentCoParent({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.children,
    required this.canAnswerReports,
  });

  factory ParentCoParent.fromJson(Map<String, dynamic> json) => ParentCoParent(
        id: _int(json['id']),
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        email: json['email'] as String?,
        children: _strings(json['children']),
        canAnswerReports: json['can_answer_reports'] == true,
      );

  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final List<String> children;
  final bool canAnswerReports;

  String get name => '$firstName $lastName'.trim();
}

/// PAR-19 — an invitation still pending (sent or expired).
class ParentInvitation {
  const ParentInvitation({
    required this.id,
    this.civility,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.canAnswerReports,
    required this.state,
    this.sentAt,
    this.expiresAt,
  });

  factory ParentInvitation.fromJson(Map<String, dynamic> json) =>
      ParentInvitation(
        id: _int(json['id']),
        civility: json['civility'] as String?,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        canAnswerReports: json['can_answer_reports'] == true,
        state: json['state'] as String? ?? 'sent',
        sentAt: _date(json['sent_at']),
        expiresAt: _date(json['expires_at']),
      );

  final int id;
  final String? civility;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final bool canAnswerReports;
  final String state;
  final DateTime? sentAt;
  final DateTime? expiresAt;

  String get name => '$firstName $lastName'.trim();

  bool get expired =>
      state == 'expired' ||
      (expiresAt != null && expiresAt!.isBefore(DateTime.now()));
}

/// The lists of the forms (`GET /references`).
class ParentReferences {
  const ParentReferences({
    required this.subjects,
    required this.schoolClasses,
    required this.sections,
    required this.cities,
  });

  factory ParentReferences.fromJson(Map<String, dynamic> json) =>
      ParentReferences(
        subjects: _subjects(json['subjects']),
        schoolClasses: _maps(json['school_classes'])
            .map((item) => (
                  id: _int(item['id']),
                  name: item['name'] as String? ?? '',
                  education: item['education'] as String?,
                  section: item['section'] as String?,
                ))
            .toList(),
        sections: _maps(json['sections'])
            .map((item) => (
                  value: '${item['key']}',
                  label: item['label'] as String? ?? '${item['key']}'
                ))
            .toList(),
        cities: _maps(json['cities'])
            .map((item) => (
                  name: item['name'] as String? ?? '',
                  neighborhoods: _strings(item['neighborhoods'])
                ))
            .toList(),
      );

  final List<ParentSubject> subjects;
  final List<({int id, String name, String? education, String? section})>
      schoolClasses;
  final List<ParentOption> sections;
  final List<({String name, List<String> neighborhoods})> cities;

  /// The classes of a section (all of them when the section is unknown).
  List<({int id, String name, String? education, String? section})> classesOf(
          String? section) =>
      schoolClasses
          .where((item) =>
              section == null ||
              item.section == null ||
              item.section!.toLowerCase() == section.toLowerCase())
          .toList();
}

/// What an action of the home is about: the subjects and children of its request, or the
/// session of the report to examine (PAR-01, « À faire »).
class ParentActionSubject {
  const ParentActionSubject(
      {required this.subjects, required this.children, this.session});

  final List<String> subjects;
  final List<String> children;

  /// The session of a report action (its day, its tutor).
  final ParentSession? session;
}
