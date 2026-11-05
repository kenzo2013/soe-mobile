import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:soe/core/storage/secure_storage.dart';

/// A request the fake API received.
class RecordedRequest {
  RecordedRequest(this.method, this.path, this.data, this.query);

  final String method;
  final String path;
  final Object? data;
  final Map<String, dynamic> query;

  String get key => '$method $path';

  /// The JSON body sent (null for multipart or no body).
  Map<String, dynamic>? get json =>
      data is Map<String, dynamic> ? data! as Map<String, dynamic> : null;
}

/// An answer of the fake API: an HTTP status and a JSON body (null: no body).
typedef FakeAnswer = (int, Object?);

/// The API v2 as the tests want it: answers by « METHOD /path » (path relative to /api/v2),
/// every request recorded. Unknown paths answer 404 in the v2 envelope.
class FakeApi implements HttpClientAdapter {
  FakeApi([Map<String, FakeAnswer Function(RecordedRequest)>? routes]) {
    if (routes != null) this.routes.addAll(routes);
  }

  /// The bell of every header asks for the unread count.
  final Map<String, FakeAnswer Function(RecordedRequest)> routes = {
    'GET /notifications/unread_count': (_) => (
          200,
          {
            'data': {'unread_count': 0},
            'meta': <String, dynamic>{}
          }
        ),
  };
  final List<RecordedRequest> requests = [];

  void on(String key, FakeAnswer answer) => routes[key] = (_) => answer;

  /// The requests sent to a « METHOD /path ».
  List<RecordedRequest> sent(String key) =>
      requests.where((request) => request.key == key).toList();

  Dio get dio => Dio(BaseOptions(baseUrl: 'http://api.test/api/v2'))
    ..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final path = options.uri.path.replaceFirst('/api/v2', '');
    final request = RecordedRequest(
        options.method, path, options.data, options.uri.queryParameters);
    requests.add(request);
    final handler = routes[request.key];
    final (status, body) = handler == null
        ? (
            404,
            {
              'errors': [
                {'code': 'not_found', 'message': 'Not found', 'field': null}
              ]
            }
          )
        : handler(request);
    return ResponseBody.fromString(body == null ? '' : jsonEncode(body), status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

/// `{ data, meta }` of a v2 answer.
Map<String, dynamic> envelope(Object data, [Map<String, dynamic>? meta]) =>
    {'data': data, 'meta': meta ?? <String, dynamic>{}};

/// A 422 of the v2 envelope on [field].
FakeAnswer invalid(String field, String message) => (
      422,
      {
        'errors': [
          {'code': 'invalid', 'message': message, 'field': field}
        ]
      }
    );

/// The secure storage in memory.
class MemoryStorage extends SecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}
