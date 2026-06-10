enum TutorPaymentKind { mobile, bank, unknown }

/// Méthode de paiement du tuteur (`GET /tutors/payment_informations`).
class TutorPaymentMethod {
  const TutorPaymentMethod({
    required this.id,
    required this.kind,
    required this.isDefault,
    this.operator,
    this.phone,
    this.bank,
    this.holder,
    this.iban,
    this.accountNumber,
    this.bankCode,
    this.branchCode,
    this.bic,
    this.key,
  });

  final String id;
  final TutorPaymentKind kind;
  final bool isDefault;

  /// Mobile money : `MTN MoMo` | `Orange Money`.
  final String? operator;
  final String? phone;

  /// Bancaire.
  final String? bank;
  final String? holder;
  final String? iban;
  final String? accountNumber;
  final String? bankCode;
  final String? branchCode;
  final String? bic;
  final String? key;
}
