/// Models of the parent space v2 (lot 3), read from the API v2 (`soe/docs/api/v2/openapi.yml`).
/// Plain classes: the screens only read them.
library;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

class ParentSession {
  const ParentSession({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.childId,
    required this.childName,
    required this.subject,
    required this.tutorName,
    required this.status,
    required this.statusLabel,
  });

  factory ParentSession.fromJson(Map<String, dynamic> json) {
    final child = json['child'] as Map<String, dynamic>? ?? const {};
    return ParentSession(
      id: _int(json['id']),
      startsAt: _date(json['starts_at']) ?? DateTime.now(),
      endsAt: _date(json['ends_at']),
      childId: _int(child['id']),
      childName: child['first_name'] as String? ?? '',
      subject: json['subject'] as String?,
      tutorName: json['tutor_name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String? ?? '',
    );
  }

  final int id;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int childId;
  final String childName;
  final String? subject;
  final String tutorName;
  final String status;
  final String statusLabel;

  String get title => [subject, childName]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' · ');
}

class ParentSessionDetail {
  const ParentSessionDetail({
    required this.session,
    required this.arrivedAt,
    required this.leftAt,
    required this.checkInMethod,
    required this.distanceMeters,
    required this.reportSubmittedAt,
    required this.reportAutoValidatesAt,
    required this.backupCode,
    required this.canCancel,
    required this.lateCancellation,
  });

  factory ParentSessionDetail.fromJson(Map<String, dynamic> json) {
    final checkIn = json['check_in'] as Map<String, dynamic>?;
    final report = json['report'] as Map<String, dynamic>?;
    return ParentSessionDetail(
      session: ParentSession.fromJson(json),
      arrivedAt: _date(checkIn?['arrived_at']),
      leftAt: _date(checkIn?['left_at']),
      checkInMethod: checkIn?['method'] as String?,
      distanceMeters: (checkIn?['distance_meters'] as num?)?.toInt(),
      reportSubmittedAt: _date(report?['submitted_at']),
      reportAutoValidatesAt: _date(report?['auto_validates_at']),
      backupCode: json['backup_code'] as String?,
      canCancel: json['can_cancel'] == true,
      lateCancellation: json['late_cancellation'] == true,
    );
  }

  final ParentSession session;
  final DateTime? arrivedAt;
  final DateTime? leftAt;
  final String? checkInMethod;
  final int? distanceMeters;
  final DateTime? reportSubmittedAt;
  final DateTime? reportAutoValidatesAt;
  final String? backupCode;
  final bool canCancel;
  final bool lateCancellation;
}

class ParentReport {
  const ParentReport({
    required this.sessionId,
    required this.childName,
    required this.startAt,
    required this.endAt,
    required this.topics,
    required this.homework,
    required this.observations,
    required this.comment,
    required this.validated,
    required this.disputeReason,
    required this.autoValidatesAt,
    required this.canAnswer,
  });

  factory ParentReport.fromJson(Map<String, dynamic> json) => ParentReport(
        sessionId: _int(json['session_id']),
        childName: json['child_first_name'] as String? ?? '',
        startAt: json['start_at'] as String?,
        endAt: json['end_at'] as String?,
        topics: [
          ...(json['topics'] as List<dynamic>? ?? const []).cast<String>(),
          if ((json['topics'] as List<dynamic>? ?? const []).isEmpty &&
              (json['proceedings'] as String?)?.isNotEmpty == true)
            json['proceedings'] as String,
        ],
        homework: json['homework'] as String?,
        observations: json['observations'] as String?,
        comment: json['comment'] as String?,
        validated: json['validated'] as bool?,
        disputeReason: json['dispute_reason'] as String?,
        autoValidatesAt: _date(json['auto_validates_at']),
        canAnswer: json['can_answer'] == true,
      );

  final int sessionId;
  final String childName;
  final String? startAt;
  final String? endAt;
  final List<String> topics;
  final String? homework;
  final String? observations;
  final String? comment;
  final bool? validated;
  final String? disputeReason;
  final DateTime? autoValidatesAt;
  final bool canAnswer;
}

class ParentChild {
  const ParentChild({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.schoolClass,
    required this.schoolName,
    required this.courses,
    this.birthdate,
    this.gender,
    this.section,
    this.schoolType,
    this.schoolClassId,
    this.hasPhoto = false,
    this.editable = false,
    this.specialNeeds,
    this.address,
  });

  factory ParentChild.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return ParentChild(
      id: _int(json['id']),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      schoolClass: json['school_class'] as String?,
      schoolName: json['school_name'] as String?,
      courses: (json['courses'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ParentCourse.fromJson)
          .toList(growable: false),
      birthdate: json['birthdate'] is String
          ? DateTime.tryParse(json['birthdate'] as String)
          : null,
      gender: json['gender'] as String?,
      section: json['section'] as String?,
      schoolType: json['school_type'] as String?,
      schoolClassId: (json['school_class_id'] as num?)?.toInt(),
      hasPhoto: json['has_photo'] == true,
      editable: json['editable'] == true,
      specialNeeds: json['special_needs'] as String?,
      address: address == null ? null : ParentAddress.fromJson(address),
    );
  }

  final int id;
  final String firstName;
  final String? lastName;
  final String? schoolClass;
  final String? schoolName;
  final List<ParentCourse> courses;
  final DateTime? birthdate;

  /// male or female.
  final String? gender;

  /// francophone or anglophone.
  final String? section;

  /// public, private_secular or religious.
  final String? schoolType;
  final int? schoolClassId;
  final bool hasPhoto;

  /// Only the holder of the child edits or archives them (a co-parent reads).
  final bool editable;
  final String? specialNeeds;
  final ParentAddress? address;

  String get fullName => [firstName, lastName]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' ');
}

/// Where the courses take place (sent to the tutor only once the contract is signed).
class ParentAddress {
  const ParentAddress(
      {this.address, this.neighborhood, this.city, this.landmark});

  factory ParentAddress.fromJson(Map<String, dynamic> json) => ParentAddress(
        address: json['address'] as String?,
        neighborhood: json['neighborhood'] as String?,
        city: json['city'] as String?,
        landmark: json['landmark'] as String?,
      );

  final String? address;
  final String? neighborhood;
  final String? city;
  final String? landmark;

  String get label => [neighborhood, address, landmark]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(', ');

  Map<String, dynamic> toJson() => {
        'address': address,
        'neighborhood': neighborhood,
        'city': city,
        'landmark': landmark,
      };
}

class ParentCourse {
  const ParentCourse({
    required this.subject,
    required this.tutorName,
    required this.validatedSessions,
    required this.nextSessionAt,
    this.reservationId,
    this.stage,
    this.since,
    this.times = const [],
  });

  factory ParentCourse.fromJson(Map<String, dynamic> json) => ParentCourse(
        subject: json['subject'] as String? ?? '',
        tutorName: json['tutor_name'] as String? ?? '',
        validatedSessions: _int(json['validated_sessions']),
        nextSessionAt: _date(json['next_session_at']),
        reservationId: (json['reservation_id'] as num?)?.toInt(),
        stage: json['stage'] as String?,
        since: json['since'] is String
            ? DateTime.tryParse(json['since'] as String)
            : null,
        times: (json['times'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((time) => (
                  day: time['day'] as String? ?? '',
                  from: time['from'] as String? ?? '',
                  to: time['to'] as String? ?? ''
                ))
            .toList(growable: false),
      );

  final String subject;
  final String tutorName;
  final int validatedSessions;
  final DateTime? nextSessionAt;

  /// The request the course comes from (its tutor page asks for a replacement).
  final int? reservationId;
  final String? stage;
  final DateTime? since;
  final List<({String day, String from, String to})> times;

  /// A course in place: its tutor may be replaced.
  bool get active => const ['first_month_paid', 'scheduled', 'active', 'paused']
      .contains(stage);
}

class ParentInvoice {
  const ParentInvoice({
    required this.id,
    required this.number,
    required this.period,
    required this.amount,
    required this.balanceDue,
    required this.dueOn,
    required this.status,
    required this.statusLabel,
    required this.lines,
    this.paidAt,
    this.issuedOn,
  });

  factory ParentInvoice.fromJson(Map<String, dynamic> json) => ParentInvoice(
        id: _int(json['id']),
        number: json['number'] as String? ?? '',
        period: _date(json['period']) ?? DateTime.now(),
        amount: _int(json['amount']),
        balanceDue: _int(json['balance_due']),
        dueOn: _date(json['due_on']),
        status: json['status'] as String? ?? 'issued',
        statusLabel: json['status_label'] as String? ?? '',
        paidAt: _date(json['paid_at']),
        issuedOn: _date(json['issued_on']),
        lines: (json['lines'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((line) => (
                  label: [line['subject'], line['student']]
                      .whereType<String>()
                      .join(' · '),
                  amount: _int(line['amount'])
                ))
            .toList(growable: false),
      );

  final int id;
  final String number;
  final DateTime period;
  final int amount;
  final int balanceDue;
  final DateTime? dueOn;
  final String status;
  final String statusLabel;
  final List<({String label, int amount})> lines;

  /// When the invoice was paid in full.
  final DateTime? paidAt;

  /// When SOE issued the invoice (the 25th of the month before).
  final DateTime? issuedOn;

  bool get payable => status == 'issued' || status == 'overdue';
}

class ParentPayment {
  const ParentPayment({
    required this.id,
    this.invoiceId,
    required this.amount,
    required this.method,
    required this.phone,
    required this.state,
    required this.receiptNumber,
    required this.paidAt,
    this.status,
    this.statusLabel,
    this.methodLabel,
    this.period,
    this.createdAt,
  });

  factory ParentPayment.fromJson(Map<String, dynamic> json) => ParentPayment(
        id: _int(json['id']),
        invoiceId: (json['invoice_id'] as num?)?.toInt(),
        amount: _int(json['amount']),
        method: json['method'] as String? ?? '',
        phone: json['phone'] as String?,
        state: json['state'] as String? ?? 'waiting',
        receiptNumber: json['receipt_number'] as String?,
        paidAt: _date(json['paid_at']),
        status: json['status'] as String?,
        statusLabel: json['status_label'] as String?,
        methodLabel: json['method_label'] as String?,
        period: json['period'] is String
            ? DateTime.tryParse(json['period'] as String)
            : null,
        createdAt: _date(json['created_at']),
      );

  final int id;
  final int? invoiceId;
  final int amount;
  final String method;
  final String? phone;
  final String state;
  final String? receiptNumber;
  final DateTime? paidAt;

  /// completed, pending, failed... and its label.
  final String? status;
  final String? statusLabel;
  final String? methodLabel;
  final DateTime? period;
  final DateTime? createdAt;

  /// A receipt exists (PDF) once the payment went through.
  bool get hasReceipt => state == 'success' && receiptNumber != null;
}

class ParentHomeAction {
  const ParentHomeAction(
      {required this.kind,
      required this.label,
      this.title,
      required this.deadline,
      required this.overdue,
      required this.targetId});

  factory ParentHomeAction.fromJson(Map<String, dynamic> json) =>
      ParentHomeAction(
        kind: json['kind'] as String? ?? '',
        label: json['label'] as String? ?? '',
        title: json['title'] as String?,
        deadline: _date(json['deadline']),
        overdue: json['overdue'] == true,
        targetId: _int(json['target_id']),
      );

  final String kind;
  final String label;

  /// Child first name, request reference or invoice number.
  final String? title;
  final DateTime? deadline;
  final bool overdue;
  final int targetId;
}

class ParentHomeRequest {
  const ParentHomeRequest(
      {this.id = 0,
      required this.reference,
      required this.step,
      required this.stepLabel,
      required this.children});

  factory ParentHomeRequest.fromJson(Map<String, dynamic> json) =>
      ParentHomeRequest(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        step: json['step'] as String? ?? 'request',
        stepLabel: json['step_label'] as String? ?? '',
        children:
            (json['children'] as List<dynamic>? ?? const []).cast<String>(),
      );

  static const steps = [
    'request',
    'quote',
    'tutor',
    'contract',
    'payment',
    'first_session'
  ];

  final int id;
  final String reference;
  final String step;
  final String stepLabel;
  final List<String> children;
}

class ParentHome {
  const ParentHome({
    required this.actions,
    required this.weekSessions,
    required this.requests,
    required this.children,
    required this.invoice,
    required this.advisorName,
    required this.advisorPhone,
  });

  factory ParentHome.fromJson(Map<String, dynamic> json) {
    final advisor = json['advisor'] as Map<String, dynamic>?;
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return ParentHome(
      actions: list('actions').map(ParentHomeAction.fromJson).toList(),
      weekSessions: list('week_sessions').map(ParentSession.fromJson).toList(),
      requests: list('requests').map(ParentHomeRequest.fromJson).toList(),
      children: list('children').map(ParentChild.fromJson).toList(),
      invoice: json['invoice'] is Map<String, dynamic>
          ? ParentInvoice.fromJson(json['invoice'] as Map<String, dynamic>)
          : null,
      advisorName: advisor == null
          ? null
          : [advisor['first_name'], advisor['last_name']]
              .whereType<String>()
              .join(' '),
      advisorPhone: advisor?['phone'] as String?,
    );
  }

  final List<ParentHomeAction> actions;
  final List<ParentSession> weekSessions;
  final List<ParentHomeRequest> requests;
  final List<ParentChild> children;
  final ParentInvoice? invoice;
  final String? advisorName;
  final String? advisorPhone;
}

class ParentRequest {
  const ParentRequest({
    required this.id,
    required this.reference,
    required this.children,
    required this.step,
    required this.stepLabel,
    required this.action,
    required this.quoteAmount,
    required this.contractId,
    this.contractStatus,
    this.stage = '',
    this.quoteStatus,
    this.createdAt,
  });

  factory ParentRequest.fromJson(Map<String, dynamic> json) => ParentRequest(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        children:
            (json['children'] as List<dynamic>? ?? const []).cast<String>(),
        step: json['step'] as String? ?? 'request',
        stepLabel: json['step_label'] as String? ?? '',
        action: json['action'] as String?,
        quoteAmount: (json['quote_amount'] as num?)?.toInt(),
        contractId: (json['contract_id'] as num?)?.toInt(),
        contractStatus: json['contract_status'] as String?,
        stage: json['stage'] as String? ?? '',
        quoteStatus: json['quote_status'] as String?,
        createdAt: _date(json['created_at']),
      );

  final int id;
  final String reference;
  final List<String> children;
  final String step;
  final String stepLabel;

  /// The holder's action: quote, tutor, payment, planning, or null.
  final String? action;
  final int? quoteAmount;
  final int? contractId;

  /// sent (to sign) or signed.
  final String? contractStatus;

  /// The reservation stage (11-state cycle), e.g. quote_sent, tutor_presented.
  final String stage;
  final String? quoteStatus;
  final DateTime? createdAt;
}

class ParentQuote {
  const ParentQuote({
    required this.version,
    required this.statusLabel,
    required this.validUntil,
    required this.lines,
    required this.totalAmount,
    required this.canAnswer,
    required this.canReactivate,
  });

  factory ParentQuote.fromJson(Map<String, dynamic> json) => ParentQuote(
        version: _int(json['version']),
        statusLabel: json['status_label'] as String? ?? '',
        validUntil: _date(json['valid_until']),
        lines: (json['lines'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((line) => (
                  label: [line['subject'], line['child']]
                      .whereType<String>()
                      .join(' · '),
                  rhythm:
                      '${_int(line['sessions_per_week'])} × ${_int(line['session_minutes'])} min',
                  amount: _int(line['monthly_amount'])
                ))
            .toList(growable: false),
        totalAmount: _int(json['total_amount']),
        canAnswer: json['can_answer'] == true,
        canReactivate: json['can_reactivate'] == true,
      );

  final int version;
  final String statusLabel;
  final DateTime? validUntil;
  final List<({String label, String rhythm, int amount})> lines;
  final int totalAmount;
  final bool canAnswer;
  final bool canReactivate;
}

class ParentContract {
  const ParentContract({
    required this.id,
    required this.reference,
    required this.statusLabel,
    required this.text,
    required this.canSign,
    required this.signedAt,
    this.status = '',
    this.legacy = false,
    this.reservationId,
    this.createdAt,
    this.amendmentsCount = 0,
    this.amendmentsToSign = 0,
  });

  factory ParentContract.fromJson(Map<String, dynamic> json) => ParentContract(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        statusLabel: json['status_label'] as String? ?? '',
        text: json['text'] as String? ?? '',
        canSign: json['can_sign'] == true,
        signedAt: _date(json['signed_at']),
        status: json['status'] as String? ?? '',
        legacy: json['legacy'] == true,
        reservationId: (json['reservation_id'] as num?)?.toInt(),
        createdAt: _date(json['created_at']),
        amendmentsCount: _int(json['amendments_count']),
        amendmentsToSign: _int(json['amendments_to_sign']),
      );

  final int id;
  final String reference;
  final String statusLabel;

  /// Empty in the list (only the detail carries the text).
  final String text;
  final bool canSign;
  final DateTime? signedAt;
  final String status;

  /// A contract of the former platform (v1), kept readable and signable.
  final bool legacy;
  final int? reservationId;
  final DateTime? createdAt;
  final int amendmentsCount;
  final int amendmentsToSign;
}

class ParentPlanningSlot {
  const ParentPlanningSlot({
    required this.id,
    required this.title,
    required this.tutorName,
    required this.canAnswer,
    required this.times,
  });

  factory ParentPlanningSlot.fromJson(Map<String, dynamic> json) =>
      ParentPlanningSlot(
        id: _int(json['id']),
        title: [json['subject'], json['child']].whereType<String>().join(' · '),
        tutorName: json['tutor_name'] as String? ?? '',
        canAnswer: json['can_answer'] == true,
        times: (json['times'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .where((time) =>
                const ['proposed', 'approved'].contains(time['status']))
            .map((time) => (
                  day: time['day'] as String? ?? '',
                  from: time['from'] as String? ?? '',
                  to: time['to'] as String? ?? ''
                ))
            .toList(growable: false),
      );

  final int id;
  final String title;
  final String tutorName;
  final bool canAnswer;
  final List<({String day, String from, String to})> times;
}
