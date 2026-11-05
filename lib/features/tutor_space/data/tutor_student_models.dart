/// Models of the tutor's pupils (REP-14), read from the API v2 (`TutorPupil`, `TutorPupilFile`
/// of `soe/docs/api/v2/openapi.yml`).
library;

DateTime? _day(Object? value) {
  if (value is! String) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

List<Map<String, dynamic>> _list(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

/// A weekly time approved by the parent: `monday` 16:00 – 18:00.
class TutorWeeklyTime {
  const TutorWeeklyTime({required this.day, this.from, this.to});

  factory TutorWeeklyTime.fromJson(Map<String, dynamic> json) =>
      TutorWeeklyTime(
        day: json['day'] as String? ?? '',
        from: json['from'] as String?,
        to: json['to'] as String?,
      );

  /// monday … sunday.
  final String day;

  /// HH:MM.
  final String? from;
  final String? to;

  /// « 16:00 – 18:00 ».
  String get hours => [from, to].whereType<String>().join(' – ');
}

/// A pupil card: the neighbourhood only, the state and the approved weekly times.
class TutorPupil {
  const TutorPupil({
    required this.id,
    required this.pupil,
    required this.schoolClass,
    required this.subjects,
    required this.neighborhood,
    required this.state,
    required this.stateLabel,
    required this.times,
    required this.startDate,
  });

  factory TutorPupil.fromJson(Map<String, dynamic> json) => TutorPupil(
        id: (json['id'] as num?)?.toInt() ?? 0,
        pupil: json['pupil'] as String? ?? '',
        schoolClass: json['school_class'] as String?,
        subjects: _strings(json['subjects']),
        neighborhood: json['neighborhood'] as String?,
        state: json['state'] as String? ?? 'times',
        stateLabel: json['state_label'] as String? ?? '',
        times: _list(json['times']).map(TutorWeeklyTime.fromJson).toList(),
        startDate: _day(json['start_date']),
      );

  final int id;

  /// « Ornella T. ».
  final String pupil;
  final String? schoolClass;
  final List<String> subjects;
  final String? neighborhood;

  /// contract, active, waiting, times.
  final String state;
  final String stateLabel;
  final List<TutorWeeklyTime> times;
  final DateTime? startDate;
}

/// A parent of the pupil, shared once the contract is signed.
class TutorPupilParent {
  const TutorPupilParent({required this.name, this.phone});

  factory TutorPupilParent.fromJson(Map<String, dynamic> json) =>
      TutorPupilParent(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String?,
      );

  final String name;
  final String? phone;
}

/// A report written for the pupil.
class TutorPupilReport {
  const TutorPupilReport({
    required this.sessionId,
    required this.date,
    required this.topics,
    required this.state,
    required this.stateLabel,
  });

  factory TutorPupilReport.fromJson(Map<String, dynamic> json) =>
      TutorPupilReport(
        sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
        date: _day(json['date']),
        topics: _strings(json['topics']),
        state: json['state'] as String? ?? 'planned',
        stateLabel: json['state_label'] as String? ?? '',
      );

  final int sessionId;
  final DateTime? date;
  final List<String> topics;
  final String state;
  final String stateLabel;
}

/// A slot of the pupil whose weekly times are still to propose.
class TutorSlotToPlan {
  const TutorSlotToPlan({required this.slotId, this.subject});

  factory TutorSlotToPlan.fromJson(Map<String, dynamic> json) =>
      TutorSlotToPlan(
        slotId: (json['slot_id'] as num?)?.toInt() ?? 0,
        subject: json['subject'] as String?,
      );

  final int slotId;
  final String? subject;
}

/// A pupil's file: the address, the landmark and the parents once the contract is signed only.
class TutorPupilFile {
  const TutorPupilFile({
    required this.id,
    required this.pupil,
    required this.schoolClass,
    required this.subjects,
    required this.times,
    required this.neighborhood,
    required this.contactShared,
    required this.address,
    required this.landmark,
    required this.parents,
    required this.reports,
    required this.slotsToPlan,
  });

  factory TutorPupilFile.fromJson(Map<String, dynamic> json) => TutorPupilFile(
        id: (json['id'] as num?)?.toInt() ?? 0,
        pupil: json['pupil'] as String? ?? '',
        schoolClass: json['school_class'] as String?,
        subjects: _strings(json['subjects']),
        times: _list(json['times']).map(TutorWeeklyTime.fromJson).toList(),
        neighborhood: json['neighborhood'] as String?,
        contactShared: json['contact_shared'] == true,
        address: json['address'] as String?,
        landmark: json['landmark'] as String?,
        parents: _list(json['parents']).map(TutorPupilParent.fromJson).toList(),
        reports: _list(json['reports']).map(TutorPupilReport.fromJson).toList(),
        slotsToPlan:
            _list(json['slots_to_plan']).map(TutorSlotToPlan.fromJson).toList(),
      );

  final int id;
  final String pupil;
  final String? schoolClass;
  final List<String> subjects;
  final List<TutorWeeklyTime> times;
  final String? neighborhood;
  final bool contactShared;
  final String? address;
  final String? landmark;
  final List<TutorPupilParent> parents;
  final List<TutorPupilReport> reports;
  final List<TutorSlotToPlan> slotsToPlan;

  /// The parents with a phone number, only once the contact is shared.
  List<TutorPupilParent> get callableParents => contactShared
      ? parents.where((p) => (p.phone ?? '').isNotEmpty).toList()
      : const [];
}
