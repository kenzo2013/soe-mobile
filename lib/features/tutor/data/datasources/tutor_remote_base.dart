import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

/// Helpers partagés par les RemoteDatasources tuteur — alignés sur les
/// conventions de la feature `parent` (même backend) :
/// - envelope `{ status, data, pagination }`
/// - format JSON:API `{ id, type, attributes: {...} }` aplati
/// - payloads Rails wrappés + multipart `clé[sous_clé]`
/// - dates ISO parsées puis formatées côté client (les entités portent des
///   chaînes d'affichage).
abstract final class TutorApi {
  /// Déballe `data` (objet) d'une réponse, en repliant le JSON:API si présent.
  static Map<String, dynamic> dataObject(Map<String, dynamic>? body) {
    if (body == null) return const {};
    final data = body['data'];
    final target = data is Map<String, dynamic> ? data : body;
    return deepFlat(target) as Map<String, dynamic>;
  }

  /// Déballe `data` (liste) d'une réponse, en repliant chaque élément.
  static List<Map<String, dynamic>> dataList(Map<String, dynamic>? body) {
    if (body == null) return const [];
    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => deepFlat(e) as Map<String, dynamic>)
          .toList(growable: false);
    }
    return const [];
  }

  /// Aplatit un objet JSON:API : remonte `attributes` à la racine et conserve
  /// l'`id`. Si l'objet est déjà plat, le renvoie tel quel.
  static Map<String, dynamic> flat(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    if (attrs is! Map<String, dynamic>) return json;
    final out = <String, dynamic>{...attrs};
    final id = json['id'];
    if (id != null) out['id'] = id.toString();
    return out;
  }

  /// Aplatit récursivement le JSON:API à tous les niveaux (maps + listes),
  /// y compris les ressources imbriquées (`data` enveloppe locale incluse).
  static dynamic deepFlat(dynamic node) {
    if (node is List) return node.map(deepFlat).toList();
    if (node is Map<String, dynamic>) {
      // Ressource imbriquée encapsulée dans son propre `{data: ...}`.
      final inner = node['data'];
      if (inner is Map<String, dynamic> && node.length == 1) {
        return deepFlat(inner);
      }
      final attrs = node['attributes'];
      final base = <String, dynamic>{};
      if (attrs is Map<String, dynamic>) {
        base.addAll(attrs);
      } else {
        base.addAll(node);
      }
      // `id` toujours stringifié EN DERNIER (après addAll) pour éviter qu'un
      // `id` entier brut ne réécrase la version String — sinon un DTO au champ
      // `String id` lève `int is not String` au parsing.
      if (node['id'] != null) base['id'] = node['id'].toString();
      return base.map((k, v) => MapEntry(k, deepFlat(v)));
    }
    return node;
  }

  /// Construit un `FormData` Rails-style à partir d'un payload + fichiers.
  ///
  /// `files` mappe une clé Rails complète (ex: `identity[images][]`) vers une
  /// liste de fichiers ; `singleFiles` vers un fichier unique
  /// (ex: `session_report[signature]`).
  static Future<FormData> multipart(
    String root,
    Map<String, dynamic> payload, {
    Map<String, List<File>> files = const {},
    Map<String, File> singleFiles = const {},
  }) async {
    final map = <String, dynamic>{};
    _flatten(map, root, payload);
    for (final entry in singleFiles.entries) {
      map[entry.key] = await _multipartFile(entry.value);
    }
    for (final entry in files.entries) {
      map[entry.key] = [
        for (final f in entry.value) await _multipartFile(f),
      ];
    }
    return FormData.fromMap(map);
  }

  static Future<MultipartFile> _multipartFile(File f) {
    final ext = f.path.split('.').last.toLowerCase();
    final subtype = ext == 'png' ? 'png' : 'jpeg';
    return MultipartFile.fromFile(
      f.path,
      filename: f.path.split(Platform.pathSeparator).last,
      contentType: MediaType('image', subtype),
    );
  }

  /// Aplatit récursivement en clés Rails : `{a:{b:1,c:[2,3]}}` →
  /// `a[b]=1`, `a[c][]=2`, `a[c][]=3`.
  static void _flatten(Map<String, dynamic> out, String prefix, dynamic value) {
    if (value is Map<String, dynamic>) {
      value.forEach((k, v) => _flatten(out, '$prefix[$k]', v));
    } else if (value is List) {
      for (final item in value) {
        _flatten(out, '$prefix[]', item);
      }
    } else if (value != null) {
      out[prefix] = value.toString();
    }
  }

  // ── Formatage (les entités portent des chaînes d'affichage) ──────────────
  static final DateFormat _hm = DateFormat('HH:mm');
  static final DateFormat _dMonY = DateFormat('d MMM y', 'fr');
  static final DateFormat _dayLine = DateFormat('EEEE d MMMM', 'fr');

  /// Plage horaire `HH:MM – HH:MM` à partir d'un ISO début + (fin OU durée).
  static String timeRange(String? startIso, {String? endIso, int? minutes}) {
    final start = DateTime.tryParse(startIso ?? '');
    if (start == null) return startIso ?? '';
    final end = DateTime.tryParse(endIso ?? '') ??
        (minutes != null ? start.add(Duration(minutes: minutes)) : null);
    final s = _hm.format(start.toLocal());
    if (end == null) return s;
    return '$s – ${_hm.format(end.toLocal())}';
  }

  /// `Jeudi 14 mai` (+ plage si dispo).
  static String dateLine(String? startIso, {String? endIso, int? minutes}) {
    final start = DateTime.tryParse(startIso ?? '');
    if (start == null) return startIso ?? '';
    final day = _cap(_dayLine.format(start.toLocal()));
    final range = timeRange(startIso, endIso: endIso, minutes: minutes);
    return range.isEmpty ? day : '$day · $range';
  }

  /// `2 mai 2026`.
  static String shortDate(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    return d == null ? (iso ?? '') : _dMonY.format(d.toLocal());
  }

  /// `il y a 2j` / `aujourd'hui`.
  static String relative(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    if (d == null) return iso ?? '';
    final days = DateTime.now().difference(d.toLocal()).inDays;
    if (days <= 0) return "aujourd'hui";
    if (days == 1) return 'hier';
    return 'il y a ${days}j';
  }

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// Parse un montant en `int`, tolérant aux `num` ET aux chaînes décimales
  /// (l'API renvoie souvent `"50000.0"`). `int.tryParse("50000.0")` échoue —
  /// on passe par `num.tryParse`.
  static int amount(dynamic v) {
    if (v is num) return v.toInt();
    return (num.tryParse(v?.toString() ?? '') ?? 0).toInt();
  }

  /// Normalise une liste hétérogène (Strings ou Maps `{name|label}`) en
  /// `List<String>` non vide.
  static List<String> names(List<dynamic> v) => v
      .map((e) =>
          e is Map ? (e['name'] ?? e['label'] ?? '').toString() : e.toString())
      .where((s) => s.isNotEmpty)
      .toList();
}
