/// Models of the account and common screens (COM-01 to COM-10), read from the API v2
/// envelope's `data` (soe/docs/api/v2/openapi.yml).
library;

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

List<Map<String, dynamic>> _maps(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

/// A phone or e-mail change waiting for its 6-digit code (COM-02).
class ContactChange {
  const ContactChange({
    required this.id,
    required this.field,
    required this.value,
    required this.codeSentTo,
    required this.expiresAt,
    required this.resendIn,
  });

  factory ContactChange.fromJson(Map<String, dynamic> json) => ContactChange(
        id: _int(json['id']),
        field: json['field'] as String? ?? 'email',
        value: json['value'] as String? ?? '',
        codeSentTo: json['code_sent_to'] as String? ?? '',
        expiresAt: _date(json['expires_at']),
        resendIn: _int(json['resend_in']),
      );

  final int id;

  /// `phone` or `email`.
  final String field;
  final String value;
  final String codeSentTo;
  final DateTime? expiresAt;

  /// Seconds before a new code may be asked.
  final int resendIn;

  bool get isPhone => field == 'phone';
}

/// Something that keeps the account from being deleted, and how to clear it (COM-03).
class DeletionBlocker {
  const DeletionBlocker(
      {required this.code,
      required this.label,
      required this.step,
      this.count,
      this.amount});

  factory DeletionBlocker.fromJson(Map<String, dynamic> json) =>
      DeletionBlocker(
        code: json['code'] as String? ?? '',
        label: json['label'] as String? ?? '',
        step: json['step'] as String? ?? '',
        count: (json['count'] as num?)?.toInt(),
        amount: (json['amount'] as num?)?.toInt(),
      );

  /// `running_contract`, `unpaid_invoice`, `running_mission` or `disputed_report`.
  final String code;
  final String label;
  final String step;
  final int? count;
  final int? amount;
}

/// Whether the account can be deleted now (COM-03).
class DeletionCheck {
  const DeletionCheck({required this.allowed, required this.blockers});

  factory DeletionCheck.fromJson(Map<String, dynamic> json) => DeletionCheck(
        allowed: json['allowed'] == true,
        blockers:
            _maps(json['blockers']).map(DeletionBlocker.fromJson).toList(),
      );

  final bool allowed;
  final List<DeletionBlocker> blockers;
}

/// The account's address (COM-04): parent, where the lessons take place and the tutor's
/// check-in point; tutor, where they live.
class AccountAddress {
  const AccountAddress({
    this.neighborhood,
    this.city,
    this.landmark,
    this.latitude,
    this.longitude,
    this.checkInRadiusMeters = 150,
  });

  factory AccountAddress.fromJson(Map<String, dynamic> json) => AccountAddress(
        neighborhood: json['neighborhood'] as String?,
        city: json['city'] as String?,
        landmark: json['landmark'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        checkInRadiusMeters:
            (json['check_in_radius_meters'] as num?)?.toInt() ?? 150,
      );

  final String? neighborhood;
  final String? city;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final int checkInRadiusMeters;

  bool get hasPin => latitude != null && longitude != null;

  /// « Bonapriso, Douala », or empty.
  String get place => [neighborhood, city]
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(', ');

  Map<String, dynamic> toJson() => {
        'neighborhood': neighborhood ?? '',
        'city': city ?? '',
        'landmark': landmark ?? '',
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// The roles of the account (COM-05).
class AccountRoles {
  const AccountRoles({
    required this.currentRole,
    required this.roles,
    this.addableRole,
    this.preferredRole,
  });

  factory AccountRoles.fromJson(Map<String, dynamic> json) => AccountRoles(
        currentRole: json['current_role'] as String? ?? 'parent',
        roles: _maps(json['roles'])
            .map((role) => (
                  role: role['role'] as String? ?? '',
                  label: role['label'] as String? ?? ''
                ))
            .toList(),
        addableRole: json['addable_role'] as String?,
        preferredRole: json['preferred_role'] as String?,
      );

  final String currentRole;
  final List<({String role, String label})> roles;

  /// The role the account may still add (`parent` or `tutor`), or null.
  final String? addableRole;

  /// The space opened after sign-in; null: the last one used.
  final String? preferredRole;

  bool get multiRole => roles.length > 1;
}

/// One row of the categories × channels grid (COM-06).
class PreferenceCategory {
  const PreferenceCategory(
      {required this.key,
      required this.label,
      required this.app,
      required this.email});

  factory PreferenceCategory.fromJson(Map<String, dynamic> json) {
    final channels = json['channels'] as Map<String, dynamic>? ?? const {};
    return PreferenceCategory(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      app: channels['app'] == true,
      email: channels['email'] == true,
    );
  }

  final String key;
  final String label;
  final bool app;
  final bool email;

  bool channel(String key) => switch (key) {
        'app' => app,
        'email' => email,
        _ => false,
      };

  PreferenceCategory withChannel(String key, bool value) => PreferenceCategory(
        key: this.key,
        label: label,
        app: key == 'app' ? value : app,
        email: key == 'email' ? value : email,
      );
}

/// The notification preferences of the active role (COM-06).
class NotificationPreferences {
  const NotificationPreferences(
      {required this.categories,
      required this.channels,
      required this.mandatory});

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        categories:
            _maps(json['categories']).map(PreferenceCategory.fromJson).toList(),
        channels: _maps(json['channels'])
            .map((channel) => (
                  key: channel['key'] as String? ?? '',
                  label: channel['label'] as String? ?? '',
                  available: channel['available'] == true,
                ))
            .toList(),
        mandatory: _maps(json['mandatory'])
            .map((message) => (
                  key: message['key'] as String? ?? '',
                  title: message['title'] as String? ?? '',
                  text: message['text'] as String? ?? '',
                ))
            .toList(),
      );

  final List<PreferenceCategory> categories;
  final List<({String key, String label, bool available})> channels;
  final List<({String key, String title, String text})> mandatory;

  NotificationPreferences withCategory(PreferenceCategory category) =>
      NotificationPreferences(
        categories: [
          for (final c in categories) c.key == category.key ? category : c
        ],
        channels: channels,
        mandatory: mandatory,
      );
}

/// The screen a notification opens (null: the space home). For `session_report`, [id] is the
/// session's.
class NotificationTarget {
  const NotificationTarget({required this.kind, required this.id});

  static NotificationTarget? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final kind = json['kind'];
    if (kind is! String) return null;
    return NotificationTarget(kind: kind, id: _int(json['id']));
  }

  /// session, session_report, contract, payment, invoice, request, child, earnings, job,
  /// proposal.
  final String kind;
  final int id;
}

/// A notification of the centre (COM-07).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.read,
    required this.todo,
    required this.day,
    this.type,
    this.body,
    this.createdAt,
    this.target,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: _int(json['id']),
        type: json['type'] as String?,
        title: json['title'] as String? ?? '',
        body: json['body'] as String?,
        read: json['read'] == true,
        todo: json['todo'] == true,
        day: json['day'] as String? ?? 'earlier',
        createdAt: _date(json['created_at']),
        target: NotificationTarget.fromJson(json['target']),
      );

  final int id;

  /// reservation, sessions, session_report, payment, contract…: icon and colour.
  final String? type;
  final String title;
  final String? body;
  final bool read;

  /// Waits for an action.
  final bool todo;

  /// `today`, `yesterday` or `earlier`.
  final String day;
  final DateTime? createdAt;
  final NotificationTarget? target;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read ?? this.read,
        todo: todo,
        day: day,
        createdAt: createdAt,
        target: target,
      );
}

/// A page of notifications and the badge count.
class NotificationPage {
  const NotificationPage(
      {required this.items, required this.unreadCount, required this.hasMore});

  final List<AppNotification> items;
  final int unreadCount;
  final bool hasMore;
}

/// What the report form offers to the active role (COM-09).
class ReportReasons {
  const ReportReasons({
    required this.reasons,
    required this.seriousReason,
    required this.descriptionMax,
    required this.photosMax,
    required this.recentDays,
    required this.emergencyPhone,
  });

  factory ReportReasons.fromJson(Map<String, dynamic> json) {
    ({String key, String label}) reason(Object? value) {
      final map = value as Map<String, dynamic>? ?? const {};
      return (
        key: map['key'] as String? ?? '',
        label: map['label'] as String? ?? ''
      );
    }

    return ReportReasons(
      reasons:
          (json['reasons'] as List<dynamic>? ?? const []).map(reason).toList(),
      seriousReason: reason(json['serious_reason']),
      descriptionMax: (json['description_max'] as num?)?.toInt() ?? 2000,
      photosMax: (json['photos_max'] as num?)?.toInt() ?? 3,
      recentDays: (json['recent_days'] as num?)?.toInt() ?? 30,
      emergencyPhone: json['emergency_phone'] as String? ?? '',
    );
  }

  final List<({String key, String label})> reasons;
  final ({String key, String label}) seriousReason;
  final int descriptionMax;
  final int photosMax;
  final int recentDays;
  final String emergencyPhone;
}

/// A recent session the account can report (COM-09).
class ReportSession {
  const ReportSession(
      {required this.id,
      required this.label,
      this.date,
      this.studentFirstName});

  factory ReportSession.fromJson(Map<String, dynamic> json) => ReportSession(
        id: _int(json['id']),
        label: json['label'] as String? ?? '',
        date: json['date'] is String
            ? DateTime.tryParse(json['date'] as String)
            : null,
        studentFirstName: json['student_first_name'] as String?,
      );

  final int id;
  final String label;
  final DateTime? date;
  final String? studentFirstName;
}

/// A step of a report's follow-up: received, in progress, resolved or dismissed.
class ReportStep {
  const ReportStep(
      {required this.key, required this.label, required this.reached, this.at});

  factory ReportStep.fromJson(Map<String, dynamic> json) => ReportStep(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        reached: json['reached'] == true,
        at: _date(json['at']),
      );

  final String key;
  final String label;
  final bool reached;
  final DateTime? at;
}

/// A report sent to SOE, with its follow-up when read one by one (COM-09).
class ProblemReport {
  const ProblemReport({
    required this.id,
    required this.reference,
    required this.typeLabel,
    required this.serious,
    required this.status,
    required this.statusLabel,
    this.sessionDate,
    this.studentFirstName,
    this.createdAt,
    this.description,
    this.photosCount = 0,
    this.answer,
    this.steps = const [],
  });

  factory ProblemReport.fromJson(Map<String, dynamic> json) {
    final session = json['session'] as Map<String, dynamic>?;
    return ProblemReport(
      id: _int(json['id']),
      reference: json['reference'] as String? ?? '',
      typeLabel: json['report_type_label'] as String? ?? '',
      serious: json['serious'] == true,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String? ?? '',
      sessionDate: session?['date'] is String
          ? DateTime.tryParse(session!['date'] as String)
          : null,
      studentFirstName: session?['student_first_name'] as String?,
      createdAt: _date(json['created_at']),
      description: json['description'] as String?,
      photosCount: _int(json['photos_count']),
      answer: json['answer'] as String?,
      steps: _maps(json['steps']).map(ReportStep.fromJson).toList(),
    );
  }

  final int id;
  final String reference;
  final String typeLabel;
  final bool serious;

  /// pending, under_review, resolved or dismissed.
  final String status;
  final String statusLabel;
  final DateTime? sessionDate;
  final String? studentFirstName;
  final DateTime? createdAt;
  final String? description;
  final int photosCount;
  final String? answer;
  final List<ReportStep> steps;
}

/// FAQ by topic, official contacts and emergency (COM-10).
class HelpContent {
  const HelpContent({
    required this.defaultTopic,
    required this.topics,
    required this.email,
    required this.phones,
    required this.emergencyText,
    required this.emergencyPhone,
  });

  factory HelpContent.fromJson(Map<String, dynamic> json) {
    final contacts = json['contacts'] as Map<String, dynamic>? ?? const {};
    final emergency = json['emergency'] as Map<String, dynamic>? ?? const {};
    return HelpContent(
      defaultTopic: json['default_topic'] as String? ?? '',
      topics: _maps(json['topics'])
          .map((topic) => HelpTopic(
                key: topic['key'] as String? ?? '',
                label: topic['label'] as String? ?? '',
                questions: _maps(topic['questions'])
                    .map((q) => (
                          question: q['question'] as String? ?? '',
                          answer: q['answer'] as String? ?? '',
                        ))
                    .toList(),
              ))
          .toList(),
      email: contacts['email'] as String? ?? '',
      phones: _maps(contacts['phones'])
          .map((phone) => (
                key: phone['key'] as String? ?? '',
                label: phone['label'] as String? ?? '',
                number: phone['number'] as String? ?? '',
                display: phone['display'] as String? ?? '',
                whatsappUrl: phone['whatsapp_url'] as String? ?? '',
              ))
          .toList(),
      emergencyText: emergency['text'] as String? ?? '',
      emergencyPhone: emergency['phone'] as String? ?? '',
    );
  }

  final String defaultTopic;
  final List<HelpTopic> topics;
  final String email;
  final List<
      ({
        String key,
        String label,
        String number,
        String display,
        String whatsappUrl
      })> phones;
  final String emergencyText;
  final String emergencyPhone;
}

class HelpTopic {
  const HelpTopic(
      {required this.key, required this.label, required this.questions});

  final String key;
  final String label;
  final List<({String question, String answer})> questions;
}
