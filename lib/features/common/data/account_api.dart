import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/api_endpoints_v2.dart';
import '../../../core/network/paginated.dart';
import '../../../core/data/cameroon_city.dart';
import 'account_models.dart';

/// Calls of the API v2 account and common endpoints (COM-01 to COM-10). Returns models built
/// from the envelope's `data`; a Dio error becomes a Failure.
class AccountApi {
  const AccountApi(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      (r.data?['data'] as Map<String, dynamic>?) ?? const {};

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }

  // ── Profile (COM-02) ──────────────────────────────────────

  /// `PATCH /me`: only the fields given change; multipart when a [photo] is sent. Returns the
  /// account (CurrentUser schema).
  Future<Map<String, dynamic>> updateProfile({
    String? civility,
    String? firstName,
    String? lastName,
    String? lang,
    File? photo,
  }) =>
      _guard(() async {
        final fields = <String, dynamic>{
          if (civility != null) 'civility': civility,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (lang != null) 'lang': lang,
        };
        final body = photo == null
            ? fields
            : FormData.fromMap({...fields, 'photo': await _image(photo)});
        return _data(await _dio.patch<Map<String, dynamic>>(ApiEndpointsV2.me,
            data: body));
      });

  /// A link to the profile photo, valid 15 minutes (never stored).
  Future<String?> photoUrl() => _guard(() async =>
      _data(await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.mePhoto))['url']
          as String?);

  /// Asks for a new phone number or e-mail address: a 6-digit code is sent.
  Future<ContactChange> requestContactChange(
          {required String field,
          required String value,
          required String currentPassword}) =>
      _guard(() async => ContactChange.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(ApiEndpointsV2.contactChange, data: {
            'field': field,
            'contact_value': value,
            'current_password': currentPassword,
          }))));

  /// Confirms the change with its code; returns the updated account.
  Future<Map<String, dynamic>> confirmContactChange(String code) =>
      _guard(() async => _data(await _dio.post<Map<String, dynamic>>(
          ApiEndpointsV2.contactChangeConfirm,
          data: {'code': code})));

  Future<ContactChange> resendContactChange() =>
      _guard(() async => ContactChange.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.contactChangeResend))));

  Future<void> cancelContactChange() =>
      _guard(() => _dio.delete<void>(ApiEndpointsV2.contactChange));

  // ── Security (COM-03) ─────────────────────────────────────

  /// Changes the password. Every earlier token is revoked: returns the new session
  /// (`{token, token_expires_at, user}`) to store.
  Future<Map<String, dynamic>> changePassword(
          {required String currentPassword,
          required String password,
          required String confirmation}) =>
      _guard(() async => _data(await _dio
              .put<Map<String, dynamic>>(ApiEndpointsV2.accountPassword, data: {
            'current_password': currentPassword,
            'password': password,
            'password_confirmation': confirmation,
          })));

  Future<DeletionCheck> deletionCheck() =>
      _guard(() async => DeletionCheck.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.accountDeletion))));

  /// Deletes the account for good; the token stops working at once.
  Future<void> deleteAccount(String password) =>
      _guard(() => _dio.post<void>(ApiEndpointsV2.accountDeletion,
          data: {'password': password, 'confirmed': true}));

  // ── Address (COM-04) ──────────────────────────────────────

  Future<AccountAddress> address() =>
      _guard(() async => AccountAddress.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.accountAddress))));

  Future<AccountAddress> updateAddress(AccountAddress address) =>
      _guard(() async => AccountAddress.fromJson(_data(
          await _dio.patch<Map<String, dynamic>>(ApiEndpointsV2.accountAddress,
              data: address.toJson()))));

  /// Every city of Cameroon (`/auth/cities`, public), the main ones first: the sign-up and the
  /// address choose from it.
  Future<List<CameroonCity>> cities() => _guard(() async =>
      (((await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.cities))
                  .data?['data'] as List<dynamic>?) ??
              const [])
          .whereType<Map<String, dynamic>>()
          .map(CameroonCity.fromJson)
          .where((city) => city.name.isNotEmpty)
          .toList());

  // ── Roles (COM-05) ────────────────────────────────────────

  Future<AccountRoles> roles() =>
      _guard(() async => AccountRoles.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.accountRoles))));

  /// Adds the other role and switches to it.
  Future<AccountRoles> addRole(String role) =>
      _guard(() async => AccountRoles.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.accountRoles,
              data: {'role': role}))));

  Future<AccountRoles> switchRole(String role) =>
      _guard(() async => AccountRoles.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.accountRolesSwitch,
              data: {'role': role}))));

  /// The space opened after sign-in; null for the last one used.
  Future<AccountRoles> setDefaultRole(String? role) =>
      _guard(() async => AccountRoles.fromJson(_data(await _dio
          .patch<Map<String, dynamic>>(ApiEndpointsV2.accountRolesDefault,
              data: {'preferred_role': role}))));

  // ── Notification preferences (COM-06) ─────────────────────

  Future<NotificationPreferences> notificationPreferences() =>
      _guard(() async => NotificationPreferences.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.notificationPreferences))));

  /// Changes one box of the grid (only the boxes sent change).
  Future<NotificationPreferences> updateNotificationPreference(
          {required String category,
          required String channel,
          required bool value}) =>
      _guard(() async => NotificationPreferences.fromJson(_data(await _dio
              .patch<Map<String, dynamic>>(
                  ApiEndpointsV2.notificationPreferences,
                  data: {
                'preferences': {
                  category: {channel: value}
                }
              }))));

  // ── Notifications (COM-07) ────────────────────────────────

  /// [filter]: `all`, `unread` or `todo`.
  Future<NotificationPage> notifications(
          {String filter = 'all', int page = 1, int perPage = 50}) =>
      _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.notifications,
            queryParameters: {
              'filter': filter,
              'page': page,
              'per_page': perPage
            });
        final body = r.data ?? const {};
        final list = Paginated.fromEnvelope(body, AppNotification.fromJson);
        final meta = body['meta'] as Map<String, dynamic>? ?? const {};
        return NotificationPage(
          items: list.items,
          unreadCount: (meta['unread_count'] as num?)?.toInt() ?? 0,
          hasMore: list.hasMore,
        );
      });

  Future<int> unreadCount() => _guard(() async =>
      (_data(await _dio.get<Map<String, dynamic>>(
              ApiEndpointsV2.notificationsUnreadCount))['unread_count'] as num?)
          ?.toInt() ??
      0);

  Future<int> readAll() => _guard(() async =>
      (_data(await _dio.post<Map<String, dynamic>>(
              ApiEndpointsV2.notificationsReadAll))['unread_count'] as num?)
          ?.toInt() ??
      0);

  /// Opens a notification: marks it read and returns it with its target screen.
  Future<AppNotification> read(int id) =>
      _guard(() async => AppNotification.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.notificationRead(id)))));

  Future<AppNotification> unread(int id) =>
      _guard(() async => AppNotification.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.notificationUnread(id)))));

  Future<void> deleteNotification(int id) =>
      _guard(() => _dio.delete<void>(ApiEndpointsV2.notification(id)));

  // ── Reports (COM-09) ──────────────────────────────────────

  Future<ReportReasons> reportReasons() =>
      _guard(() async => ReportReasons.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.reportReasons))));

  Future<List<ReportSession>> reportSessions() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.reportSessions,
            queryParameters: {'per_page': 50});
        return Paginated.fromEnvelope(
                r.data ?? const {}, ReportSession.fromJson)
            .items;
      });

  Future<List<ProblemReport>> reports() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.reports,
            queryParameters: {'per_page': 50});
        return Paginated.fromEnvelope(
                r.data ?? const {}, ProblemReport.fromJson)
            .items;
      });

  Future<ProblemReport> report(int id) =>
      _guard(() async => ProblemReport.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.report(id)))));

  /// Sends a report to SOE (never to the other party); multipart with the photos.
  Future<ProblemReport> createReport({
    required int sessionId,
    required String description,
    String? reportType,
    bool serious = false,
    List<File> photos = const [],
  }) =>
      _guard(() async {
        final form = FormData.fromMap({
          'session_id': sessionId,
          'description': description,
          if (!serious && reportType != null) 'report_type': reportType,
          'serious': serious,
        });
        for (final photo in photos) {
          form.files.add(MapEntry('photos[]', await _image(photo)));
        }
        return ProblemReport.fromJson(_data(await _dio
            .post<Map<String, dynamic>>(ApiEndpointsV2.reports, data: form)));
      });

  // ── Help (COM-10) ─────────────────────────────────────────

  Future<HelpContent> help() => _guard(() async => HelpContent.fromJson(
      _data(await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.help))));

  // ── Push devices ──────────────────────────────────────────

  /// Registers this device for push notifications, by its OneSignal player id.
  Future<void> registerDevice({
    required String playerId,
    required String deviceType,
    String? deviceName,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    bool pushEnabled = true,
  }) =>
      _guard(() => _dio.post<void>(ApiEndpointsV2.devices, data: {
            'onesignal_player_id': playerId,
            'device_type': deviceType,
            if (deviceName != null) 'device_name': deviceName,
            if (deviceModel != null) 'device_model': deviceModel,
            if (osVersion != null) 'os_version': osVersion,
            if (appVersion != null) 'app_version': appVersion,
            'push_enabled': pushEnabled,
          }));

  /// Unregisters this device (before sign-out).
  Future<void> unregisterDevice(String playerId) =>
      _guard(() => _dio.delete<void>(ApiEndpointsV2.device(playerId)));

  static Future<MultipartFile> _image(File file) {
    final name = file.path.split(Platform.pathSeparator).last;
    final png = name.toLowerCase().endsWith('.png');
    return MultipartFile.fromFile(file.path,
        filename: name, contentType: MediaType('image', png ? 'png' : 'jpeg'));
  }
}
