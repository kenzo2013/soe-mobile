enum ReservationStatus {
  draft,
  pending,
  proposedPrice,
  negotiation,
  accepted,
  active,
  completed,
  rejected,
  cancelled,
  unknown,
}

class ReservationSummary {
  const ReservationSummary({
    required this.id,
    required this.reference,
    required this.status,
    required this.childName,
    required this.subjects,
    this.amount,
  });

  final String id;
  final String reference;
  final ReservationStatus status;
  final String childName;
  final List<String> subjects;
  final int? amount;
}
