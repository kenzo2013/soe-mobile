import 'package:intl/intl.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';

/// Mappe les notifications et les préférences renvoyées par l'API. Les deux
/// contrats étant peu spécifiés côté backend, on lit défensivement plusieurs
/// noms de champs et on retombe sur les catégories du design au besoin.
abstract final class NotificationMapper {
  static final DateFormat _hm = DateFormat('HH:mm');
  static final DateFormat _day = DateFormat('EEE', 'fr');

  // ── Notifications ─────────────────────────────────────────
  static AppNotification fromJson(Map<String, dynamic> json) {
    final j = _attrs(json);
    final created = DateTime.tryParse(
      (j['created_at'] ?? j['createdAt'] ?? '').toString(),
    );
    final readRaw = j['read'] ?? j['is_read'] ?? j['read_at'];
    final read = readRaw is bool ? readRaw : readRaw != null;

    return AppNotification(
      id: (json['id'] ?? j['id'] ?? '').toString(),
      kind: NotificationKindX.fromApi(
        (j['category'] ?? j['notification_type'] ?? j['type'] ?? j['kind'])
            ?.toString(),
      ),
      title: (j['title'] ?? j['subject'] ?? '').toString(),
      body: (j['body'] ?? j['message'] ?? j['content'] ?? '').toString(),
      read: read,
      timeLabel: _timeLabel(created),
      createdAt: created,
      resourceType:
          (j['resource_type'] ?? j['notifiable_type'])?.toString(),
      resourceId:
          (j['resource_id'] ?? j['notifiable_id'])?.toString(),
    );
  }

  static String _timeLabel(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final local = d.toLocal();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (sameDay) return _hm.format(local);
    if (days <= 7) return _cap(_day.format(local));
    return DateFormat('d/MM').format(local);
  }

  /// Libellé du groupe (`Aujourd'hui`, `Hier`, `Cette semaine`, `Plus ancien`).
  static String dayGroup(DateTime? d) {
    if (d == null) return 'Plus ancien';
    final now = DateTime.now();
    final local = d.toLocal();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (days <= 0) return "Aujourd'hui";
    if (days == 1) return 'Hier';
    if (days <= 7) return 'Cette semaine';
    return 'Plus ancien';
  }

  // ── Préférences ───────────────────────────────────────────
  /// Libellés FR + sous-titre par clé de catégorie connue de l'API.
  static const _labels = <String, (String, String)>{
    'reservation': ('Réservations', 'Devis reçus, négociations'),
    'payment': ('Paiements', 'Confirmations, échecs'),
    'remuneration': ('Rémunérations', 'Versements, relevés'),
    'sessions': ('Séances', 'Rappels, modifications'),
    'session': ('Séances', 'Rappels, modifications'),
    'review': ('Avis et notations', 'Demandes de feedback'),
    'contract': ('Contrats', 'À signer, signés'),
    'admin': ('Administration', 'Validations, documents'),
    'account': ('Compte', 'Sécurité, connexion'),
    'system': ('Système et marketing', 'Mises à jour, offres'),
  };

  static const _channelFallback = ['email', 'push'];
  static const _categoryFallback = [
    'reservation',
    'payment',
    'sessions',
    'account',
  ];

  /// Construit les préférences à partir du contrat réel :
  /// `{ preferences: {cat: {channel: bool}}, categories: [...], channels: [...] }`.
  static NotificationPreferences preferencesFromJson(Object? raw) {
    final flat = _attrs(raw);

    final channels = ((flat['channels'] as List?) ?? _channelFallback)
        .map((e) => e.toString())
        .toList();
    final categoryKeys = ((flat['categories'] as List?) ?? _categoryFallback)
        .map((e) => e.toString())
        .toList();
    final prefs = (flat['preferences'] is Map)
        ? (flat['preferences'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    bool flag(Object? v) =>
        v is bool ? v : (v != null && v.toString() == 'true');

    return NotificationPreferences(
      channels: channels,
      categories: [
        for (final key in categoryKeys)
          () {
            final label = _labels[key];
            final catPrefs = prefs[key] is Map
                ? (prefs[key] as Map)
                : const <String, dynamic>{};
            return NotificationCategory(
              key: key,
              label: label?.$1 ?? _humanize(key),
              sub: label?.$2 ?? '',
              channels: {
                for (final ch in channels) ch: flag(catPrefs[ch]),
              },
            );
          }(),
      ],
    );
  }

  static String _humanize(String key) =>
      key.isEmpty ? key : _cap(key.replaceAll('_', ' '));

  static Map<String, dynamic> _attrs(Object? node) {
    if (node is! Map) return const {};
    final a = node['attributes'];
    return a is Map
        ? {
            ...a.cast<String, dynamic>(),
            if (node['id'] != null) 'id': node['id'],
          }
        : node.cast<String, dynamic>();
  }

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
