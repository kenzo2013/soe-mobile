/// Models of the tutor's money and documents (REP-19 history, REP-20 payout methods, COM-08
/// amendments, download links), read from the API v2 (`soe/docs/api/v2/openapi.yml`).
library;

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

DateTime? _day(Object? value) {
  if (value is! String) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

int _int(Object? value) => (value as num?)?.toInt() ?? 0;

/// A pay statement of the history, whatever its state.
class TutorStatement {
  const TutorStatement({
    required this.id,
    required this.period,
    required this.receiptNumber,
    required this.amount,
    required this.sessions,
    required this.status,
    required this.statusLabel,
    required this.paidAt,
    required this.hasReceipt,
  });

  factory TutorStatement.fromJson(Map<String, dynamic> json) => TutorStatement(
        id: _int(json['id']),
        period: _day(json['period']),
        receiptNumber: json['receipt_number'] as String?,
        amount: _int(json['amount']),
        sessions: _int(json['sessions']),
        status: json['status'] as String? ?? 'to_pay',
        statusLabel: json['status_label'] as String? ?? '',
        paidAt: _date(json['paid_at']),
        hasReceipt: json['has_receipt'] == true,
      );

  final int id;

  /// The first day of the month paid.
  final DateTime? period;
  final String? receiptNumber;
  final int amount;
  final int sessions;

  /// paid, processing, failed or to_pay.
  final String status;
  final String statusLabel;
  final DateTime? paidAt;
  final bool hasReceipt;
}

/// One of the tutor's payout methods: Mobile Money (mtn, orange) or bank, masked.
class TutorPayoutMethod {
  const TutorPayoutMethod({
    required this.id,
    required this.kind,
    required this.operator,
    required this.name,
    required this.detail,
    required this.isDefault,
    required this.canBeDefault,
  });

  factory TutorPayoutMethod.fromJson(Map<String, dynamic> json) =>
      TutorPayoutMethod(
        id: _int(json['id']),
        kind: json['kind'] as String? ?? 'mobile',
        operator: json['operator'] as String?,
        name: json['name'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        isDefault: json['default'] == true,
        canBeDefault: json['can_be_default'] == true,
      );

  final int id;

  /// mobile or bank.
  final String kind;

  /// mtn or orange for a Mobile Money account, else null.
  final String? operator;
  final String name;

  /// The end of the number only (« •• 44 12 »).
  final String detail;
  final bool isDefault;
  final bool canBeDefault;

  bool get isMobile => kind == 'mobile';
}

/// The kinds of change of the payout methods (`kind` of POST /tutor/payout_method_changes).
enum TutorPayoutChangeKind {
  addMobile('add_mobile'),
  addBank('add_bank'),
  replaceMobile('replace_mobile'),
  replaceBank('replace_bank'),
  remove('remove'),
  makeDefault('make_default');

  const TutorPayoutChangeKind(this.value);

  final String value;

  bool get needsMobile => this == addMobile || this == replaceMobile;
  bool get needsBank => this == addBank || this == replaceBank;
}

/// A change asked for, waiting for the 6-digit code sent by e-mail.
class TutorPayoutMethodChange {
  const TutorPayoutMethodChange({
    required this.id,
    required this.action,
    required this.summary,
    required this.sentAt,
    required this.expiresAt,
    required this.confirmedAt,
  });

  factory TutorPayoutMethodChange.fromJson(Map<String, dynamic> json) =>
      TutorPayoutMethodChange(
        id: _int(json['id']),
        action: json['action'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        sentAt: _date(json['sent_at']),
        expiresAt: _date(json['expires_at']),
        confirmedAt: _date(json['confirmed_at']),
      );

  final int id;
  final String action;

  /// Masked (« MTN •• 4412 »).
  final String summary;
  final DateTime? sentAt;

  /// The code expires then.
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
}

/// An amendment of a contract; [text] (sanitized HTML) only in the detail.
class TutorAmendment {
  const TutorAmendment({
    required this.id,
    required this.contractId,
    required this.reference,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.signedAt,
    required this.canSign,
    this.text = '',
  });

  factory TutorAmendment.fromJson(Map<String, dynamic> json) => TutorAmendment(
        id: _int(json['id']),
        contractId: _int(json['contract_id']),
        reference: json['reference'] as String?,
        status: json['status'] as String? ?? 'pending',
        statusLabel: json['status_label'] as String? ?? '',
        createdAt: _date(json['created_at']),
        signedAt: _date(json['signed_at']),
        canSign: json['can_sign'] == true,
        text: json['text'] as String? ?? '',
      );

  final int id;
  final int contractId;
  final String? reference;

  /// signed, to_sign, or pending (the contract itself is not signed yet).
  final String status;
  final String statusLabel;
  final DateTime? createdAt;
  final DateTime? signedAt;
  final bool canSign;
  final String text;
}

/// A short-lived link to a file (PDF, receipt), to open at once without the Bearer token.
class TutorDownloadLink {
  const TutorDownloadLink({required this.url, required this.expiresAt});

  factory TutorDownloadLink.fromJson(Map<String, dynamic> json) =>
      TutorDownloadLink(
        url: Uri.parse(json['url'] as String? ?? ''),
        expiresAt: _date(json['expires_at']),
      );

  final Uri url;
  final DateTime? expiresAt;
}

/// A paragraph of a document's text; [heading] for a title (h1–h4, strong alone).
class TutorTextBlock {
  const TutorTextBlock(this.text, {this.heading = false, this.item = false});

  final String text;
  final bool heading;

  /// An item of a list, shown with a bullet.
  final bool item;
}

/// Readable paragraphs from the sanitized HTML of a v1 contract or an amendment (no HTML
/// renderer in the app): block tags split the paragraphs, other tags are dropped, entities decoded.
List<TutorTextBlock> tutorHtmlBlocks(String html) {
  final blocks = <TutorTextBlock>[];
  // Split on block boundaries: every opening or closing block tag ends the current paragraph.
  final parts = html.split(RegExp(
      r'(?=<(?:h[1-6]|p|li|div|tr|blockquote|ul|ol|table)\b)|</(?:h[1-6]|p|li|div|tr|blockquote|ul|ol|table)>|<br\s*/?>',
      caseSensitive: false));
  for (final part in parts) {
    final tag = RegExp(r'^\s*<([a-z0-9]+)', caseSensitive: false)
        .firstMatch(part)
        ?.group(1)
        ?.toLowerCase();
    final text = _decodeEntities(part.replaceAll(RegExp(r'<[^>]*>'), ' '))
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) continue;
    final strongOnly = RegExp(r'^\s*<p\b[^>]*>\s*<(strong|b)>[^<]*</\1>\s*$',
            caseSensitive: false)
        .hasMatch(part);
    blocks.add(TutorTextBlock(text,
        heading:
            (tag != null && RegExp(r'^h[1-6]$').hasMatch(tag)) || strongOnly,
        item: tag == 'li'));
  }
  return blocks;
}

/// Paragraphs of a plain text (mission letter): blank lines separate them, a short line ending
/// without a full stop and starting with a number (« 1. Mission ») is a title.
List<TutorTextBlock> tutorPlainBlocks(String text) => text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .expand((p) {
      final lines = p.split('\n');
      final first = lines.first.trim();
      if (lines.length > 1 && RegExp(r'^\d+[.)]\s').hasMatch(first)) {
        return [
          TutorTextBlock(first, heading: true),
          TutorTextBlock(lines.skip(1).join('\n').trim()),
        ];
      }
      return [
        TutorTextBlock(p,
            heading: lines.length == 1 &&
                first.length < 60 &&
                RegExp(r'^\d+[.)]\s').hasMatch(first))
      ];
    }).toList();

String _decodeEntities(String text) => text
    .replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16);
      return code == null ? m[0]! : String.fromCharCode(code);
    })
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&rsquo;', '’')
    .replaceAll('&laquo;', '«')
    .replaceAll('&raquo;', '»')
    .replaceAll('&eacute;', 'é')
    .replaceAll('&egrave;', 'è')
    .replaceAll('&agrave;', 'à')
    .replaceAll('&amp;', '&');
