/// Avenant à un contrat (`amendments[]`).
class ContractAmendment {
  const ContractAmendment({
    required this.id,
    required this.reference,
    required this.signed,
    required this.contentFr,
    required this.contentEn,
    this.createdAt,
  });

  final String id;
  final String reference;
  final bool signed;
  final String contentFr;
  final String contentEn;
  final DateTime? createdAt;

  /// Contenu selon la langue (`fr` par défaut).
  String content(String lang) =>
      lang.toLowerCase().startsWith('en') && contentEn.isNotEmpty
          ? contentEn
          : contentFr;
}

/// Contrat de service de tutorat — `GET/PATCH /common/contracts` (CDC §6).
class ServiceContract {
  const ServiceContract({
    required this.id,
    required this.reference,
    required this.signed,
    required this.contentFr,
    required this.contentEn,
    required this.amendments,
    this.createdAt,
  });

  final String id;
  final String reference;
  final bool signed;
  final String contentFr;
  final String contentEn;
  final DateTime? createdAt;
  final List<ContractAmendment> amendments;

  String content(String lang) =>
      lang.toLowerCase().startsWith('en') && contentEn.isNotEmpty
          ? contentEn
          : contentFr;

  int get unsignedAmendments => amendments.where((a) => !a.signed).length;
}
