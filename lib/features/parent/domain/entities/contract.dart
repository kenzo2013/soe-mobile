enum ContractStatus { unsigned, signed, expired, terminated, unknown }

class Contract {
  const Contract({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.tutorName,
    this.childName,
    this.amount,
    this.pdfUrl,
    this.signedAt,
  });
  final String id;
  final String title;
  final ContractStatus status;
  final DateTime createdAt;
  final String? tutorName;
  final String? childName;
  final int? amount;
  final String? pdfUrl;
  final DateTime? signedAt;
}
