import 'package:dio/dio.dart';

import '../../../core/error/exception_mapper.dart';
import 'tutor_file_models.dart';

/// A photo sent with a section: identity `images[]`, diploma `documents[]`, presentation `photo`.
class TutorUpload {
  const TutorUpload({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;

  /// The type the server checks from the content; the name only helps its first guess.
  DioMediaType get mediaType {
    final name = filename.toLowerCase();
    if (name.endsWith('.png')) return DioMediaType('image', 'png');
    if (name.endsWith('.webp')) return DioMediaType('image', 'webp');
    return DioMediaType('image', 'jpeg');
  }
}

/// Calls of the recruitment journey of the API v2 (`/tutor/file`, `/tutor/interview`,
/// `/tutor/charter`). Returns models built from the envelope's `data`.
class TutorFileApi {
  const TutorFileApi(this._dio);
  final Dio _dio;

  static const String _file = '/tutor/file';
  static String _section(String section) => '/tutor/file/$section';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      (r.data?['data'] as Map<String, dynamic>?) ?? const {};

  /// Runs a call; a Dio error becomes a Failure the screens display (ErrorView, toasts).
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }

  static String day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<TutorFile> file() => _guard(() async =>
      TutorFile.fromJson(_data(await _dio.get<Map<String, dynamic>>(_file))));

  /// Sends the complete file to SOE (409 while a section is missing).
  Future<TutorFile> submit() => _guard(() async => TutorFile.fromJson(
      _data(await _dio.post<Map<String, dynamic>>('$_file/submit'))));

  Future<TutorFileSection> section(String section) =>
      _guard(() async => TutorFileSection.fromJson(
          _data(await _dio.get<Map<String, dynamic>>(_section(section)))));

  /// Saves a section (adds an item for subjects, diplomas and experiences). JSON without files;
  /// multipart with them, a list becoming repeated `key[]` fields and the files sent under
  /// [filesField] (`images[]`, `documents[]` or `photo`).
  Future<TutorFileSection> updateSection(
    String section,
    Map<String, Object?> fields, {
    List<TutorUpload> files = const [],
    String? filesField,
  }) =>
      _guard(() async {
        final Object body;
        if (files.isEmpty || filesField == null) {
          body = fields;
        } else {
          final form = FormData();
          fields.forEach((key, value) {
            if (value == null) return;
            if (value is List) {
              form.fields.addAll(value.map((v) => MapEntry('$key[]', '$v')));
            } else {
              form.fields.add(MapEntry(key, '$value'));
            }
          });
          form.files.addAll(files.map((f) => MapEntry(
              filesField,
              MultipartFile.fromBytes(f.bytes,
                  filename: f.filename, contentType: f.mediaType))));
          body = form;
        }
        return TutorFileSection.fromJson(_data(await _dio
            .patch<Map<String, dynamic>>(_section(section), data: body)));
      });

  /// Removes a course, a diploma or an experience.
  Future<TutorFileSection> deleteItem(String section, int itemId) =>
      _guard(() async => TutorFileSection.fromJson(_data(
          await _dio.delete<Map<String, dynamic>>(
              '${_section(section)}/items/$itemId'))));

  Future<TutorInterview> interview() =>
      _guard(() async => TutorInterview.fromJson(
          _data(await _dio.get<Map<String, dynamic>>('/tutor/interview'))));

  Future<TutorCharter> charter() => _guard(() async => TutorCharter.fromJson(
      _data(await _dio.get<Map<String, dynamic>>('/tutor/charter'))));

  /// The drawn signature as a PNG, sent once the charter was read to the end.
  Future<TutorCharter> signCharter(List<int> png) =>
      _guard(() async => TutorCharter.fromJson(
          _data(await _dio.post<Map<String, dynamic>>('/tutor/charter/sign',
              data: FormData.fromMap({
                'read_confirmed': '1',
                'signature': MultipartFile.fromBytes(png,
                    filename: 'signature.png',
                    contentType: DioMediaType('image', 'png')),
              })))));
}
