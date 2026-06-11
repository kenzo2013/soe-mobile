import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/dtos/user_dto.dart';
import '../../domain/entities/account_address.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/service_contract.dart';
import '../../domain/repositories/common_repository.dart';
import '../mappers/notification_mapper.dart';

/// Accès réseau des écrans communs (CDC §6). Aplatit l'enveloppe JSON:API
/// (`{id, type, attributes}`) comme les autres datasources SOE.
class CommonRemoteDatasource {
  const CommonRemoteDatasource(this._dio);
  final Dio _dio;

  // ── Mon compte ────────────────────────────────────────────
  Future<UserDto> updateProfile(UpdateProfileParams p) async {
    final user = <String, dynamic>{
      if (p.civility != null) 'civility': p.civility,
      if (p.firstName != null) 'first_name': p.firstName,
      if (p.lastName != null) 'last_name': p.lastName,
      if (p.phone != null) 'phone': p.phone,
      if (p.lang != null) 'lang': p.lang,
    };

    Response<Map<String, dynamic>> r;
    if (p.photo != null) {
      final form = <String, dynamic>{
        for (final e in user.entries) 'user[${e.key}]': e.value,
        // L'attribut image du User est `photo` (CDC §médias), pas `avatar`.
        'user[photo]': await _multipart(p.photo!),
      };
      r = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.currentUser,
        data: FormData.fromMap(form),
      );
    } else {
      r = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.currentUser,
        data: {'user': user},
      );
    }
    final data = (r.data?['data'] as Map<String, dynamic>?) ?? r.data ?? {};
    return UserDto.fromJson(data);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.updatePassword,
      data: {
        'user': {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmation,
        },
      },
    );
  }

  // ── Adresse ───────────────────────────────────────────────
  Future<AccountAddress> getAddress() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.address);
    return _addressFromJson(_attrs(r.data?['data'] ?? r.data));
  }

  Future<AccountAddress> updateAddress(AccountAddress a) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.address,
      data: {
        // Noms de champs alignés sur la réponse réelle de l'API :
        // `address2` (complément), `state` (région).
        'address': {
          'address': a.address,
          'address2': a.complement,
          'neighborhood': a.neighborhood,
          'city': a.city,
          'state': a.region,
          'country': a.country,
          if (a.countryCode != null) 'country_code': a.countryCode,
          'landmark': a.landmark,
          if (a.latitude != null) 'latitude': a.latitude,
          if (a.longitude != null) 'longitude': a.longitude,
        }..removeWhere((_, v) => v == null),
      },
    );
    return _addressFromJson(_attrs(r.data?['data'] ?? r.data));
  }

  // ── Rôle ──────────────────────────────────────────────────
  Future<void> switchRole(String role) async {
    await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.roleSwitch,
      data: {'role': role},
    );
  }

  Future<void> addRole(String role) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.roleAddition,
      data: {'role': role},
    );
  }

  // ── Préférences de notification ───────────────────────────
  Future<NotificationPreferences> getNotificationPreferences() async {
    final r = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.notificationPreferences);
    return NotificationMapper.preferencesFromJson(r.data?['data'] ?? r.data);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences prefs,
  ) async {
    // L'API attend `preferences` au niveau racine (et non sous
    // `notification_preference`) — sinon 400 « Paramètre requis manquant ».
    final r = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.notificationPreferences,
      data: {'preferences': prefs.toPayload()},
    );
    return NotificationMapper.preferencesFromJson(r.data?['data'] ?? r.data);
  }

  // ── Centre de notifications ───────────────────────────────
  Future<List<AppNotification>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: unreadOnly ? {'filter': 'unread'} : null,
    );
    final list = (r.data?['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(NotificationMapper.fromJson)
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.notifications}/$id/mark_as_read',
    );
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.notifications}/mark_all_as_read',
    );
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete<void>('${ApiEndpoints.notifications}/$id');
  }

  // ── Contrats ──────────────────────────────────────────────
  Future<List<ServiceContract>> getContracts() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contracts);
    final list = (r.data?['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_contractFromJson)
        .toList();
  }

  /// Signature du contrat : multipart `contract[signature]` + `contract[signed]`.
  Future<ServiceContract> signContract(String id, File signature) async {
    final form = FormData.fromMap({
      'contract[signature]': await _multipart(signature),
      'contract[signed]': 'true',
    });
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$id',
      data: form,
    );
    return _contractFromJson(
      (r.data?['data'] as Map<String, dynamic>?) ?? r.data ?? {},
    );
  }

  /// Signature d'un avenant : `amendment[signature]` + `amendment[signed]`.
  Future<void> signAmendment(
    String contractId,
    String amendmentId,
    File signature,
  ) async {
    final form = FormData.fromMap({
      'amendment[signature]': await _multipart(signature),
      'amendment[signed]': 'true',
    });
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$contractId/amendments/$amendmentId',
      data: form,
    );
  }

  static ServiceContract _contractFromJson(Map<String, dynamic> node) {
    final a = _attrs(node);
    final rawAmend = (a['amendments'] as List?) ?? const [];
    return ServiceContract(
      id: (node['id'] ?? a['id'] ?? '').toString(),
      reference: (a['reference'] ?? '').toString(),
      signed: a['signed'] == true,
      contentFr: (a['content_fr'] ?? a['content'] ?? '').toString(),
      contentEn: (a['content_en'] ?? '').toString(),
      createdAt: DateTime.tryParse((a['created_at'] ?? '').toString()),
      amendments: rawAmend.whereType<Map<String, dynamic>>().map((m) {
        final ma = _attrs(m);
        return ContractAmendment(
          id: (m['id'] ?? ma['id'] ?? '').toString(),
          reference: (ma['reference'] ?? '').toString(),
          signed: ma['signed'] == true,
          contentFr: (ma['content_fr'] ?? '').toString(),
          contentEn: (ma['content_en'] ?? '').toString(),
          createdAt: DateTime.tryParse((ma['created_at'] ?? '').toString()),
        );
      }).toList(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
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

  static AccountAddress _addressFromJson(Map<String, dynamic> j) {
    double? toD(Object? v) => v == null ? null : double.tryParse(v.toString());
    return AccountAddress(
      id: j['id']?.toString(),
      address:
          (j['address'] ?? j['formatted_address'] ?? j['line1'])?.toString(),
      complement: (j['address2'] ?? j['address_complement'] ?? j['complement'])
          ?.toString(),
      neighborhood:
          (j['neighborhood'] ?? j['quarter'] ?? j['district'])?.toString(),
      city: j['city']?.toString(),
      region: (j['region'] ?? j['state'])?.toString(),
      country: j['country']?.toString(),
      countryCode: (j['country_code'] ?? j['countryCode'])?.toString(),
      landmark: (j['landmark'] ?? j['point_of_reference'] ?? j['reference'])
          ?.toString(),
      latitude: toD(j['latitude'] ?? j['lat']),
      longitude: toD(j['longitude'] ?? j['lng'] ?? j['lon']),
    );
  }

  static Future<MultipartFile> _multipart(File f) {
    final ext = f.path.split('.').last.toLowerCase();
    final subtype = ext == 'png' ? 'png' : 'jpeg';
    return MultipartFile.fromFile(
      f.path,
      filename: f.path.split(Platform.pathSeparator).last,
      contentType: MediaType('image', subtype),
    );
  }
}
