/// Models of the parent space v2 (lot 3), read from the API v2 (`soe/docs/api/v2/openapi.yml`).
/// Plain classes: the screens only read them.
library;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

int? _intOrNull(Object? value) => (value as num?)?.toInt();

List<String> _strings(Object? value) =>
    (value as List<dynamic>? ?? const []).whereType<String>().toList();

/// Names sent as strings or as objects ({name} or {first_name}).
List<String> _names(Object? value) => [
      for (final item in value is List<dynamic> ? value : const <dynamic>[])
        if (item is String && item.isNotEmpty)
          item
        else if (item is Map<String, dynamic> &&
            (item['name'] ?? item['first_name']) is String)
          (item['name'] ?? item['first_name']) as String,
    ];

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
    this.reportDisputed = false,
    this.reportValidated,
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
      reportDisputed: report?['disputed'] == true,
      reportValidated: report?['validated'] as bool?,
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

  /// The report was disputed (the API's `report.disputed`): no automatic validation is coming.
  final bool reportDisputed;

  /// The parent's answer: true approved, false refused, null not yet.
  final bool? reportValidated;

  /// The automatic validation still ahead, if any (none once disputed or answered).
  DateTime? get pendingAutoValidation =>
      reportDisputed || reportValidated != null || session.status == 'disputed'
          ? null
          : reportAutoValidatesAt;
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

/// A request on its way for a child (the child's file): its reference, its step as the
/// server words it, its subjects.
class ParentChildRequest {
  const ParentChildRequest({
    required this.id,
    required this.reference,
    required this.stepLabel,
    required this.subjects,
  });

  factory ParentChildRequest.fromJson(Map<String, dynamic> json) =>
      ParentChildRequest(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        stepLabel: json['step_label'] as String? ?? '',
        subjects: _names(json['subjects']),
      );

  final int id;
  final String reference;
  final String stepLabel;
  final List<String> subjects;
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
    this.pendingStep,
    this.statusLabel,
    this.statusTone,
    this.requests = const [],
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
      pendingStep: json['pending_step'] as String?,
      statusLabel: json['status_label'] as String?,
      statusTone: json['status_tone'] as String?,
      requests: (json['requests'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ParentChildRequest.fromJson)
          .toList(growable: false),
    );
  }

  /// The file only: the requests on their way for the child (no course yet), when the API
  /// sends them.
  final List<ParentChildRequest> requests;

  /// Home only: the step of the request on its way (no course yet).
  final String? pendingStep;

  /// Home only: the line of the web card, « 1 cours · Anglais » or « Contrat à signer ».
  final String? statusLabel;

  /// Home only: neutral, warning (the parent must act) or info (SOE acts).
  final String? statusTone;

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
    this.monthLabel,
    this.summary,
    this.canPay,
    this.paymentMethodLabel,
    this.receiptPaymentId,
  });

  factory ParentInvoice.fromJson(Map<String, dynamic> json) => ParentInvoice(
        monthLabel: json['month_label'] as String?,
        summary: json['summary'] as String?,
        canPay: json['can_pay'] as bool?,
        paymentMethodLabel: json['payment_method_label'] as String?,
        receiptPaymentId: _intOrNull(json['receipt_payment_id']),
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

  /// Home only: « Novembre », the card's text, whether the card offers to pay (not when « À
  /// faire » already does), the means and the payment of the receipt once paid.
  final String? monthLabel;
  final String? summary;
  final bool? canPay;
  final String? paymentMethodLabel;
  final int? receiptPaymentId;

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
    this.children = const [],
    this.subjects = const [],
    this.firstMonth = false,
    this.title,
    this.meansLabel,
  });

  factory ParentPayment.fromJson(Map<String, dynamic> json) => ParentPayment(
        children: _strings(json['children']),
        subjects: _strings(json['subjects']),
        firstMonth: json['first_month'] == true,
        title: json['title'] as String?,
        meansLabel: json['means_label'] as String?,
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

  /// The children and subjects the payment is for (empty when unknown).
  final List<String> children;
  final List<String> subjects;
  final bool firstMonth;

  /// The web line: « Novembre · Yann (premier mois) », « MTN MoMo · •• 21 09 ».
  final String? title;
  final String? meansLabel;

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
      required this.targetId,
      this.kindLabel,
      this.heading,
      this.explanation,
      this.buttonLabel,
      this.subjects = const [],
      this.children = const [],
      this.tutorName,
      this.hoursLeft,
      this.totalHours,
      this.daysLeft,
      this.badgeLabel,
      this.countdownLabel,
      this.deadlineLabel});

  factory ParentHomeAction.fromJson(Map<String, dynamic> json) =>
      ParentHomeAction(
        kind: json['kind'] as String? ?? '',
        label: json['label'] as String? ?? '',
        title: json['title'] as String?,
        deadline: _date(json['deadline']),
        overdue: json['overdue'] == true,
        targetId: _int(json['target_id']),
        kindLabel: json['kind_label'] as String?,
        heading: json['heading'] as String?,
        explanation: json['explanation'] as String?,
        buttonLabel: json['button_label'] as String?,
        subjects: _strings(json['subjects']),
        children: _strings(json['children']),
        tutorName: json['tutor_name'] as String?,
        hoursLeft: _intOrNull(json['hours_left']),
        totalHours: _intOrNull(json['total_hours']),
        daysLeft: _intOrNull(json['days_left']),
        badgeLabel: json['badge_label'] as String?,
        countdownLabel: json['countdown_label'] as String?,
        deadlineLabel: json['deadline_label'] as String?,
      );

  final String kind;
  final String label;

  /// Child first name, request reference or invoice number.
  final String? title;
  final DateTime? deadline;
  final bool overdue;
  final int targetId;

  /// The texts of the web card: the overline (« Paiement en retard »), the heading
  /// (« Anglais · Léa »), why, the button.
  final String? kindLabel;
  final String? heading;
  final String? explanation;
  final String? buttonLabel;
  final List<String> subjects;
  final List<String> children;

  /// Report or review: « Aline N. ».
  final String? tutorName;

  /// Report: hours before the automatic validation, out of [totalHours].
  final int? hoursLeft;
  final int? totalHours;

  /// Payment: days before the due date (negative when overdue), and its badge.
  final int? daysLeft;
  final String? badgeLabel;

  /// What the card shows big (« 46 h », « 3 j », « ven. 6 ») and the caption below it.
  final String? countdownLabel;
  final String? deadlineLabel;
}

class ParentHomeRequest {
  const ParentHomeRequest(
      {this.id = 0,
      required this.reference,
      required this.step,
      required this.stepLabel,
      required this.children,
      this.title,
      this.subjects = const [],
      this.childLabels = const [],
      this.explanation,
      this.quoteValidUntil});

  factory ParentHomeRequest.fromJson(Map<String, dynamic> json) =>
      ParentHomeRequest(
        id: _int(json['id']),
        reference: json['reference'] as String? ?? '',
        step: json['step'] as String? ?? 'request',
        stepLabel: json['step_label'] as String? ?? '',
        children:
            (json['children'] as List<dynamic>? ?? const []).cast<String>(),
        title: json['title'] as String?,
        subjects: _strings(json['subjects']),
        childLabels: _strings(json['child_labels']),
        explanation: json['explanation'] as String?,
        quoteValidUntil: json['quote_valid_until'] is String
            ? DateTime.tryParse(json['quote_valid_until'] as String)
            : null,
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

  /// The web card: « Maths et physique pour Yann », the subjects, « Yann, 4e », what happens
  /// next, the end of the quote's validity (quote step).
  final String? title;
  final List<String> subjects;
  final List<String> childLabels;
  final String? explanation;
  final DateTime? quoteValidUntil;
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
    this.todo,
    this.advisor,
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
      todo: json['todo'] is List
          ? list('todo').map(ParentHomeAction.fromJson).toList()
          : null,
      advisor: advisor == null ? null : ParentHomeAdvisor.fromJson(advisor),
    );
  }

  /// The web « À faire » (the reviews to give included); null from an older API.
  final List<ParentHomeAction>? todo;
  final ParentHomeAdvisor? advisor;

  /// What « À faire » lists: [todo], else [actions].
  List<ParentHomeAction> get todoActions => todo ?? actions;

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
    this.explanation,
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
        explanation: json['explanation'] as String?,
      );

  final int id;
  final String reference;
  final List<String> children;
  final String step;
  final String stepLabel;

  /// The server's sentence for where the request stands (« En attente de la signature du
  /// répétiteur »), shown as sent instead of the app's own text for the step.
  final String? explanation;

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
    this.children = const [],
    this.subjects = const [],
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
        children: _names(json['children']),
        subjects: _names(json['subjects']),
      );

  final int id;
  final String reference;
  final String statusLabel;

  /// The children and subjects the contract covers (first names, subject names), when the
  /// API sends them: they title the card, the status being a badge.
  final List<String> children;
  final List<String> subjects;

  /// « Léa · Anglais, Maths »; null when the API sent neither.
  String? get title {
    final parts = [children.join(', '), subjects.join(', ')]
        .where((part) => part.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

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

/// « Mon conseiller SOE » as the web card shows it.
class ParentHomeAdvisor {
  const ParentHomeAdvisor({
    required this.name,
    required this.initials,
    this.phone,
    this.roleLabel,
    this.hoursLabel,
    this.phoneLabel,
    this.whatsappUrl,
  });

  factory ParentHomeAdvisor.fromJson(Map<String, dynamic> json) {
    final fallback = [json['first_name'], json['last_name']]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' ');
    return ParentHomeAdvisor(
      name: json['name'] as String? ?? fallback,
      initials: json['initials'] as String? ??
          fallback
              .split(' ')
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join(),
      phone: json['phone'] as String?,
      roleLabel: json['role_label'] as String?,
      hoursLabel: json['hours_label'] as String?,
      phoneLabel: json['phone_label'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
    );
  }

  final String name;
  final String initials;
  final String? phone;
  final String? roleLabel;
  final String? hoursLabel;
  final String? phoneLabel;
  final String? whatsappUrl;
}
