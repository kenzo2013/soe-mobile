/// Models of the tutor space v2 (lot 4), read from the API v2 (`soe/docs/api/v2/openapi.yml`).
/// Plain classes: the screens only read them.
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

int? _intOrNull(Object? value) => (value as num?)?.toInt();

List<Map<String, dynamic>> _list(Object? value) =>
    (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

/// A session of the tutor (planning, today).
class TutorSession {
  const TutorSession({
    required this.id,
    required this.date,
    required this.startsAt,
    required this.endsAt,
    required this.subject,
    required this.pupil,
    required this.schoolClass,
    required this.status,
    required this.state,
    required this.stateLabel,
    required this.hasReport,
  });

  factory TutorSession.fromJson(Map<String, dynamic> json) {
    final startsAt = _date(json['starts_at']) ?? DateTime.now();
    return TutorSession(
      id: _int(json['id']),
      date: _day(json['date']) ?? startsAt,
      startsAt: startsAt,
      endsAt: _date(json['ends_at']),
      subject: json['subject'] as String?,
      pupil: json['pupil'] as String? ?? '',
      schoolClass: json['school_class'] as String?,
      status: json['status'] as String? ?? 'pending',
      state: json['state'] as String? ?? 'planned',
      stateLabel: json['state_label'] as String? ?? '',
      hasReport: json['has_report'] == true,
    );
  }

  final int id;
  final DateTime date;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? subject;
  final String pupil;
  final String? schoolClass;

  /// pending, in_progress, completed, approved, rejected, suspended, cancelled.
  final String status;

  /// planned, to_report, report_sent, approved, disputed, suspended, cancelled.
  final String state;
  final String stateLabel;
  final bool hasReport;

  String get title => [subject, pupil]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' · ');

  /// Cancelled and suspended sessions can no longer be checked in.
  bool get closed => state == 'cancelled' || state == 'suspended';
}

/// A session with its place (hidden until the contract is signed), its pay and its check-in.
class TutorSessionDetail {
  const TutorSessionDetail({
    required this.session,
    required this.neighborhood,
    required this.address,
    required this.landmark,
    required this.parentName,
    required this.parentPhone,
    required this.rate,
    required this.checkInOpensAt,
    required this.checkedInAt,
    required this.checkInMethod,
    required this.checkedOutAt,
    required this.reportAvailableAt,
    required this.reportDueAt,
    this.canMove = false,
  });

  factory TutorSessionDetail.fromJson(Map<String, dynamic> json) {
    final checkIn = json['check_in'] as Map<String, dynamic>? ?? const {};
    final session = TutorSession.fromJson(json);
    return TutorSessionDetail(
      session: session,
      neighborhood: json['neighborhood'] as String?,
      address: json['address'] as String?,
      landmark: json['landmark'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      rate: _intOrNull(json['rate']),
      checkInOpensAt: _date(checkIn['opens_at']) ?? session.startsAt,
      checkedInAt: _date(checkIn['checked_in_at']),
      checkInMethod: checkIn['method'] as String?,
      checkedOutAt: _date(checkIn['checked_out_at']),
      reportAvailableAt: _date(json['report_available_at']) ?? session.startsAt,
      reportDueAt: _date(json['report_due_at']),
      canMove: json['can_move'] == true,
    );
  }

  final TutorSession session;
  final String? neighborhood;
  final String? address;
  final String? landmark;
  final String? parentName;
  final String? parentPhone;

  /// The tutor's pay for the session once approved (FCFA).
  final int? rate;
  final DateTime checkInOpensAt;
  final DateTime? checkedInAt;

  /// gps or code.
  final String? checkInMethod;
  final DateTime? checkedOutAt;
  final DateTime reportAvailableAt;
  final DateTime? reportDueAt;

  /// POST /tutor/sessions/{id}/move is open (planned, not checked in, notice respected).
  final bool canMove;

  /// The length of the session in minutes (kept when it is moved).
  int? get minutes => session.endsAt?.difference(session.startsAt).inMinutes;

  /// The family's contact is shared once the contract is signed.
  bool get hasContact =>
      address != null ||
      landmark != null ||
      parentName != null ||
      parentPhone != null;
}

/// The report sent for a session.
class TutorReport {
  const TutorReport({
    required this.sessionId,
    required this.date,
    required this.startAt,
    required this.endAt,
    required this.topics,
    required this.homework,
    required this.observations,
    required this.hasSignature,
    required this.submittedAt,
    required this.late,
    required this.validated,
    required this.disputeReason,
    required this.autoValidatesAt,
  });

  factory TutorReport.fromJson(Map<String, dynamic> json) => TutorReport(
        sessionId: _int(json['session_id']),
        date: _day(json['date']),
        startAt: json['start_at'] as String?,
        endAt: json['end_at'] as String?,
        topics: _strings(json['topics']),
        homework: json['homework'] as String?,
        observations: json['observations'] as String?,
        hasSignature: json['has_signature'] == true,
        submittedAt: _date(json['submitted_at']),
        late: json['late'] == true,
        validated: json['validated'] as bool?,
        disputeReason: json['dispute_reason'] as String?,
        autoValidatesAt: _date(json['auto_validates_at']),
      );

  final int sessionId;
  final DateTime? date;

  /// HH:MM.
  final String? startAt;
  final String? endAt;
  final List<String> topics;
  final String? homework;
  final String? observations;
  final bool hasSignature;
  final DateTime? submittedAt;
  final bool late;

  /// Null while the parent has not answered.
  final bool? validated;
  final String? disputeReason;
  final DateTime? autoValidatesAt;

  /// waiting, approved or disputed.
  String get state => validated == true
      ? 'approved'
      : (validated == false || disputeReason != null ? 'disputed' : 'waiting');
}

/// A family proposed to the tutor (assignment).
class TutorProposal {
  const TutorProposal({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.canAnswer,
    required this.respondBy,
    required this.sessionRate,
    required this.subject,
    required this.pupil,
    required this.schoolClass,
    required this.neighborhood,
    required this.sessionsPerWeek,
    required this.sessionMinutes,
    required this.moments,
    required this.startDate,
  });

  factory TutorProposal.fromJson(Map<String, dynamic> json) => TutorProposal(
        id: _int(json['id']),
        status: json['status'] as String? ?? 'proposed',
        statusLabel: json['status_label'] as String? ?? '',
        canAnswer: json['can_answer'] == true,
        respondBy: _date(json['respond_by']),
        sessionRate: _int(json['session_rate']),
        subject: json['subject'] as String?,
        pupil: json['pupil'] as String? ?? '',
        schoolClass: json['school_class'] as String?,
        neighborhood: json['neighborhood'] as String?,
        sessionsPerWeek: _intOrNull(json['sessions_per_week']),
        sessionMinutes: _intOrNull(json['session_minutes']),
        moments: _strings(json['moments']),
        startDate: _day(json['start_date']),
      );

  final int id;

  /// proposed, accepted, declined, expired, withdrawn, replaced.
  final String status;
  final String statusLabel;
  final bool canAnswer;
  final DateTime? respondBy;
  final int sessionRate;
  final String? subject;
  final String pupil;
  final String? schoolClass;
  final String? neighborhood;
  final int? sessionsPerWeek;
  final int? sessionMinutes;
  final List<String> moments;
  final DateTime? startDate;
}

/// A weekly time of a slot.
class TutorPlanningTime {
  const TutorPlanningTime({
    required this.day,
    required this.from,
    required this.to,
    required this.status,
    required this.statusLabel,
  });

  factory TutorPlanningTime.fromJson(Map<String, dynamic> json) =>
      TutorPlanningTime(
        day: json['day'] as String?,
        from: json['from'] as String?,
        to: json['to'] as String?,
        status: json['status'] as String? ?? 'proposed',
        statusLabel: json['status_label'] as String? ?? '',
      );

  /// monday … sunday.
  final String? day;
  final String? from;
  final String? to;

  /// proposed, approved, change_requested.
  final String status;
  final String statusLabel;
}

/// The weekly times of a signed slot and the start times that can be proposed.
class TutorPlanning {
  const TutorPlanning({
    required this.slotId,
    required this.subject,
    required this.pupil,
    required this.sessionsPerWeek,
    required this.sessionMinutes,
    required this.canPropose,
    required this.fromAvailabilities,
    required this.options,
    required this.times,
  });

  factory TutorPlanning.fromJson(Map<String, dynamic> json) => TutorPlanning(
        slotId: _int(json['slot_id']),
        subject: json['subject'] as String?,
        pupil: json['pupil'] as String? ?? '',
        sessionsPerWeek: _intOrNull(json['sessions_per_week']),
        sessionMinutes: _intOrNull(json['session_minutes']),
        canPropose: json['can_propose'] == true,
        fromAvailabilities: json['from_availabilities'] == true,
        options: _strings(json['options']),
        times: _list(json['times']).map(TutorPlanningTime.fromJson).toList(),
      );

  final int slotId;
  final String? subject;
  final String pupil;
  final int? sessionsPerWeek;
  final int? sessionMinutes;
  final bool canPropose;
  final bool fromAvailabilities;

  /// « monday 16:00 », Monday first.
  final List<String> options;
  final List<TutorPlanningTime> times;

  String get title => [subject, pupil]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' · ');
}

/// Something the tutor must do, by deadline.
class TutorHomeAction {
  const TutorHomeAction({
    required this.kind,
    required this.label,
    required this.title,
    required this.deadline,
    required this.overdue,
    required this.targetId,
  });

  factory TutorHomeAction.fromJson(Map<String, dynamic> json) =>
      TutorHomeAction(
        kind: json['kind'] as String? ?? '',
        label: json['label'] as String? ?? '',
        title: json['title'] as String?,
        deadline: _date(json['deadline']),
        overdue: json['overdue'] == true,
        targetId: _int(json['target_id']),
      );

  /// assignment, report, planning, contract, disputed.
  final String kind;
  final String label;
  final String? title;
  final DateTime? deadline;
  final bool overdue;

  /// Proposal (assignment), session (report, disputed), slot (planning) or contract id.
  final int targetId;
}

/// The pay of the month on the home.
class TutorMonth {
  const TutorMonth({
    required this.amount,
    required this.approved,
    required this.pendingCount,
    required this.pendingAmount,
    required this.disputedCount,
    required this.disputedAmount,
    required this.payoutOn,
  });

  factory TutorMonth.fromJson(Map<String, dynamic> json) => TutorMonth(
        amount: _int(json['amount']),
        approved: _int(json['approved']),
        pendingCount: _int(json['pending_count']),
        pendingAmount: _int(json['pending_amount']),
        disputedCount: _int(json['disputed_count']),
        disputedAmount: _int(json['disputed_amount']),
        payoutOn: _day(json['payout_on']),
      );

  final int amount;
  final int approved;
  final int pendingCount;
  final int pendingAmount;
  final int disputedCount;
  final int disputedAmount;

  /// Null until SOE sets the day.
  final DateTime? payoutOn;
}

/// A recruitment document still missing, under review or to redo.
class TutorMissingDocument {
  const TutorMissingDocument({
    required this.document,
    required this.label,
    required this.state,
    required this.stateLabel,
  });

  factory TutorMissingDocument.fromJson(Map<String, dynamic> json) =>
      TutorMissingDocument(
        document: json['document'] as String? ?? '',
        label: json['label'] as String? ?? '',
        state: json['state'] as String? ?? 'missing',
        stateLabel: json['state_label'] as String? ?? '',
      );

  final String document;
  final String label;

  /// missing, in_review, redo.
  final String state;
  final String stateLabel;
}

/// Where a candidate's recruitment stands.
class TutorRecruitment {
  const TutorRecruitment({
    required this.stage,
    required this.stageLabel,
    required this.refused,
    required this.step,
    required this.totalSteps,
    required this.missingDocuments,
  });

  factory TutorRecruitment.fromJson(Map<String, dynamic> json) =>
      TutorRecruitment(
        stage: json['stage'] as String? ?? 'file',
        stageLabel: json['stage_label'] as String? ?? '',
        refused: json['refused'] == true,
        step: _int(json['step']),
        totalSteps: _int(json['total_steps']),
        missingDocuments: _list(json['missing_documents'])
            .map(TutorMissingDocument.fromJson)
            .toList(),
      );

  final String stage;
  final String stageLabel;
  final bool refused;
  final int step;
  final int totalSteps;
  final List<TutorMissingDocument> missingDocuments;
}

/// The tutor's home: to do, today, the month; the recruitment of a candidate.
class TutorHome {
  const TutorHome({
    required this.active,
    required this.mayTeach,
    required this.actions,
    required this.todaySessions,
    required this.month,
    required this.recruitment,
  });

  factory TutorHome.fromJson(Map<String, dynamic> json) {
    final recruitment = json['recruitment'] as Map<String, dynamic>?;
    return TutorHome(
      active: json['active'] == true,
      mayTeach: json['may_teach'] == true,
      actions: _list(json['actions']).map(TutorHomeAction.fromJson).toList(),
      todaySessions:
          _list(json['today_sessions']).map(TutorSession.fromJson).toList(),
      month: TutorMonth.fromJson(
          json['month'] as Map<String, dynamic>? ?? const {}),
      recruitment:
          recruitment == null ? null : TutorRecruitment.fromJson(recruitment),
    );
  }

  /// False: still in recruitment.
  final bool active;

  /// False: on hold or deactivated.
  final bool mayTeach;
  final List<TutorHomeAction> actions;
  final List<TutorSession> todaySessions;
  final TutorMonth month;
  final TutorRecruitment? recruitment;

  /// The action that gets the gold button: the most urgent one SOE does not review.
  int get urgentIndex => actions.indexWhere((a) => a.kind != 'disputed');
}

/// An offer as the home lists it (« Offres pour moi »): the need, the neighbourhood, the pay.
class TutorOfferPreview {
  const TutorOfferPreview({
    required this.id,
    required this.subjects,
    required this.schoolClasses,
    required this.neighborhood,
    required this.sessionRate,
  });

  factory TutorOfferPreview.fromJson(Map<String, dynamic> json) =>
      TutorOfferPreview(
        id: _int(json['id']),
        subjects: _strings(json['subjects']),
        schoolClasses: _strings(json['school_classes']),
        neighborhood: json['neighborhood'] as String?,
        sessionRate: _intOrNull(json['session_rate']),
      );

  final int id;
  final List<String> subjects;
  final List<String> schoolClasses;
  final String? neighborhood;

  /// The tutor's indicative pay per session (FCFA).
  final int? sessionRate;

  /// « Mathématiques · 3e ».
  String get title => [
        subjects.take(2).join(', '),
        if (schoolClasses.isNotEmpty) schoolClasses.first,
      ].where((s) => s.isNotEmpty).join(' · ');
}

/// The pay of the month for one pupil.
class TutorEarningsPupil {
  const TutorEarningsPupil({
    required this.name,
    required this.approved,
    required this.rate,
    required this.amount,
    required this.pending,
    required this.disputed,
  });

  factory TutorEarningsPupil.fromJson(Map<String, dynamic> json) =>
      TutorEarningsPupil(
        name: json['name'] as String?,
        approved: _int(json['approved']),
        rate: _intOrNull(json['rate']),
        amount: _int(json['amount']),
        pending: _int(json['pending']),
        disputed: _int(json['disputed']),
      );

  final String? name;
  final int approved;

  /// Null when the rates differ.
  final int? rate;
  final int amount;
  final int pending;
  final int disputed;
}

/// A payout already made.
class TutorPayout {
  const TutorPayout({
    required this.id,
    required this.period,
    required this.paidAt,
    required this.amount,
    required this.sessions,
  });

  factory TutorPayout.fromJson(Map<String, dynamic> json) => TutorPayout(
        id: _int(json['id']),
        period: _day(json['period']),
        paidAt: _date(json['paid_at']),
        amount: _int(json['amount']),
        sessions: _int(json['sessions']),
      );

  final int id;
  final DateTime? period;
  final DateTime? paidAt;
  final int amount;
  final int sessions;
}

/// The pay of the month by pupil, the payout, the history.
class TutorEarnings {
  const TutorEarnings({
    required this.amount,
    required this.approved,
    required this.pendingAmount,
    required this.disputedAmount,
    required this.pupils,
    required this.payoutOn,
    required this.defaultMethodLabel,
    required this.history,
  });

  factory TutorEarnings.fromJson(Map<String, dynamic> json) => TutorEarnings(
        amount: _int(json['amount']),
        approved: _int(json['approved']),
        pendingAmount: _int(json['pending_amount']),
        disputedAmount: _int(json['disputed_amount']),
        pupils: _list(json['pupils']).map(TutorEarningsPupil.fromJson).toList(),
        payoutOn: _day(json['payout_on']),
        defaultMethodLabel: json['default_method_label'] as String?,
        history: _list(json['history']).map(TutorPayout.fromJson).toList(),
      );

  final int amount;
  final int approved;
  final int pendingAmount;
  final int disputedAmount;
  final List<TutorEarningsPupil> pupils;
  final DateTime? payoutOn;
  final String? defaultMethodLabel;
  final List<TutorPayout> history;
}

/// A mission letter; [text] is empty in the list (only the detail carries it).
class TutorContract {
  const TutorContract({
    required this.id,
    required this.reference,
    required this.pupil,
    required this.subject,
    required this.status,
    required this.statusLabel,
    required this.receivedAt,
    required this.signedAt,
    required this.canSign,
    required this.text,
    this.legacy = false,
    this.amendmentsCount = 0,
    this.amendmentsToSign = 0,
    this.textFormat = 'text',
  });

  factory TutorContract.fromJson(Map<String, dynamic> json) => TutorContract(
        id: _int(json['id']),
        reference: json['reference'] as String?,
        pupil: json['pupil'] as String? ?? '',
        subject: json['subject'] as String?,
        status: json['status'] as String? ?? 'sent',
        statusLabel: json['status_label'] as String? ?? '',
        receivedAt: _date(json['received_at']),
        signedAt: _date(json['signed_at']),
        canSign: json['can_sign'] == true,
        text: json['text'] as String? ?? '',
        legacy: json['legacy'] == true,
        amendmentsCount: _int(json['amendments_count']),
        amendmentsToSign: _int(json['amendments_to_sign']),
        textFormat: json['text_format'] as String? ?? 'text',
      );

  final int id;
  final String? reference;
  final String pupil;
  final String? subject;

  /// sent or signed.
  final String status;
  final String statusLabel;
  final DateTime? receivedAt;
  final DateTime? signedAt;
  final bool canSign;
  final String text;

  /// A v1 contract (« Anciens contrats »).
  final bool legacy;
  final int amendmentsCount;
  final int amendmentsToSign;

  /// text for a mission letter, sanitized HTML for a v1 contract.
  final String textFormat;

  String get title => [subject, pupil]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' · ');
}
