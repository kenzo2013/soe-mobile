/// Préférences de notification — `GET/PATCH /common/notification_preferences`
/// (CDC §6.1). Le contrat réel est data-driven : l'API renvoie la liste des
/// `categories`, la liste des `channels` (email / web / push) et un objet
/// `preferences` (catégorie → canal → bool). On modélise donc une catégorie
/// par une map canal→activé plutôt que des champs email/push figés.
class NotificationCategory {
  const NotificationCategory({
    required this.key,
    required this.label,
    required this.sub,
    required this.channels,
  });

  /// Clé API (ex. `reservation`, `payment`, `sessions`…).
  final String key;
  final String label;
  final String sub;

  /// canal → activé (ex. `{email: true, web: false, push: true}`).
  final Map<String, bool> channels;

  bool isOn(String channel) => channels[channel] ?? false;

  NotificationCategory toggle(String channel) => NotificationCategory(
        key: key,
        label: label,
        sub: sub,
        channels: {...channels, channel: !isOn(channel)},
      );
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.channels,
    required this.categories,
  });

  /// Canaux disponibles, dans l'ordre renvoyé par l'API.
  final List<String> channels;
  final List<NotificationCategory> categories;

  /// Nombre de canaux actifs, tous catégories confondues (sous-titre du hub).
  int get activeChannels => categories.fold(
        0,
        (n, c) => n + c.channels.values.where((v) => v).length,
      );

  NotificationPreferences withUpdated(NotificationCategory updated) =>
      NotificationPreferences(
        channels: channels,
        categories: [
          for (final c in categories) c.key == updated.key ? updated : c,
        ],
      );

  /// Sérialise l'objet `preferences` attendu par l'API : catégorie → canaux.
  Map<String, dynamic> toPayload() => {
        for (final c in categories) c.key: c.channels,
      };
}
