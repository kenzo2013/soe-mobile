/// Catégorie métier d'une notification — pilote l'icône, la couleur et la
/// navigation (CDC §6.2). Alignée sur les types renvoyés par l'API.
enum NotificationKind { reservation, session, payment, review, contract, system }

extension NotificationKindX on NotificationKind {
  /// Mappe un `type`/`category` API arbitraire vers une catégorie connue.
  static NotificationKind fromApi(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('reserv') || v.contains('quote') || v.contains('devis')) {
      return NotificationKind.reservation;
    }
    if (v.contains('session') || v.contains('seance') || v.contains('séance')) {
      return NotificationKind.session;
    }
    if (v.contains('pay') || v.contains('paiement') || v.contains('remun')) {
      return NotificationKind.payment;
    }
    if (v.contains('review') || v.contains('avis') || v.contains('rating')) {
      return NotificationKind.review;
    }
    if (v.contains('contract') || v.contains('contrat')) {
      return NotificationKind.contract;
    }
    return NotificationKind.system;
  }
}

/// Une notification du centre de notifications.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.read,
    this.timeLabel = '',
    this.createdAt,
    this.resourceType,
    this.resourceId,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final bool read;

  /// Heure courte affichée (`10:42`, `Lun`…) — calculée côté data.
  final String timeLabel;
  final DateTime? createdAt;

  /// Ressource cible pour la navigation au tap (ex. `reservation` + id).
  final String? resourceType;
  final String? resourceId;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        read: read ?? this.read,
        timeLabel: timeLabel,
        createdAt: createdAt,
        resourceType: resourceType,
        resourceId: resourceId,
      );
}
