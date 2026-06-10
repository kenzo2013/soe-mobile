import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_profile_dto.dart';
import 'tutor_remote_base.dart';

/// Profil tuteur : identité (`/current_user`), bio (`/tutors/descriptions`),
/// formations, expériences, pièces, matières (`/tutors/tutor_courses`),
/// disponibilités. CRUD complet.
class TutorProfileRemoteDatasource {
  const TutorProfileRemoteDatasource(this._dio);
  final Dio _dio;

  // ── Identité (current_user) ──────────────────────────────────
  Future<Map<String, dynamic>> currentUser() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.currentUser);
    return TutorApi.dataObject(r.data);
  }

  // ── Bio / description ────────────────────────────────────────
  Future<TutorDescriptionDto?> description() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsDescriptions);
    final body = r.data;
    // L'API peut renvoyer une liste ou un objet unique.
    if (body?['data'] is List) {
      final list = TutorApi.dataList(body);
      return list.isEmpty ? null : TutorDescriptionDto.fromJson(list.first);
    }
    final data = TutorApi.dataObject(body);
    return data.isEmpty ? null : TutorDescriptionDto.fromJson(data);
  }

  Future<void> saveDescription({required String content, String? id}) async {
    final payload = {
      'description': {'content': content},
    };
    if (id == null) {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.tutorsDescriptions,
        data: payload,
      );
    } else {
      await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.tutorsDescriptions}/$id',
        data: payload,
      );
    }
  }

  // ── Formations ───────────────────────────────────────────────
  Future<List<TutorTrainingDto>> trainings() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsTrainings);
    return TutorApi.dataList(r.data).map(TutorTrainingDto.fromJson).toList();
  }

  Future<void> saveTraining(Map<String, dynamic> payload, {String? id}) =>
      _save(ApiEndpoints.tutorsTrainings, 'training', payload, id: id);

  Future<void> deleteTraining(String id) =>
      _delete(ApiEndpoints.tutorsTrainings, id);

  // ── Expériences ──────────────────────────────────────────────
  Future<List<TutorWorkDto>> works() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsWorks);
    return TutorApi.dataList(r.data).map(TutorWorkDto.fromJson).toList();
  }

  Future<void> saveWork(Map<String, dynamic> payload, {String? id}) =>
      _save(ApiEndpoints.tutorsWorks, 'work', payload, id: id);

  Future<void> deleteWork(String id) => _delete(ApiEndpoints.tutorsWorks, id);

  // ── Pièces d'identité (multipart) ────────────────────────────
  Future<List<TutorIdentityDto>> identities() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsIdentities);
    return TutorApi.dataList(r.data).map(TutorIdentityDto.fromJson).toList();
  }

  Future<void> createIdentity(
    Map<String, dynamic> payload,
    List<File> images,
  ) async {
    final data = await TutorApi.multipart(
      'identity',
      payload,
      files: {'identity[images][]': images},
    );
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.tutorsIdentities,
      data: data,
    );
  }

  /// Édition : PATCH multipart. Les photos sont optionnelles — si la liste est
  /// vide, on n'envoie pas le champ `images[]` (on conserve celles existantes).
  Future<void> updateIdentity(
    String id,
    Map<String, dynamic> payload,
    List<File> images,
  ) async {
    final data = await TutorApi.multipart(
      'identity',
      payload,
      files: images.isEmpty ? const {} : {'identity[images][]': images},
    );
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsIdentities}/$id',
      data: data,
    );
  }

  Future<void> deleteIdentity(String id) =>
      _delete(ApiEndpoints.tutorsIdentities, id);

  // ── Matières enseignées (tutor_courses) ──────────────────────
  Future<List<TutorTeachingCourseDto>> teachingCourses() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsTutorCourses);
    return TutorApi.dataList(r.data)
        .map(TutorTeachingCourseDto.fromJson)
        .toList();
  }

  Future<void> saveTeachingCourse(Map<String, dynamic> payload, {String? id}) =>
      _save(ApiEndpoints.tutorsTutorCourses, 'tutor_course', payload, id: id);

  Future<void> deleteTeachingCourse(String id) =>
      _delete(ApiEndpoints.tutorsTutorCourses, id);

  // ── Disponibilités ───────────────────────────────────────────
  Future<List<TutorAvailabilitySlotDto>> availabilities() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsAvailabilities);
    return TutorApi.dataList(r.data)
        .map(TutorAvailabilitySlotDto.fromJson)
        .toList();
  }

  Future<void> createAvailability(Map<String, dynamic> payload) =>
      _save(ApiEndpoints.tutorsAvailabilities, 'availability', payload);

  Future<void> deleteAvailability(String id) =>
      _delete(ApiEndpoints.tutorsAvailabilities, id);

  // ── Helpers POST/PATCH/DELETE wrappés Rails ──────────────────
  Future<void> _save(
    String path,
    String wrapper,
    Map<String, dynamic> payload, {
    String? id,
  }) async {
    final data = {wrapper: payload};
    if (id == null) {
      await _dio.post<Map<String, dynamic>>(path, data: data);
    } else {
      await _dio.patch<Map<String, dynamic>>('$path/$id', data: data);
    }
  }

  Future<void> _delete(String path, String id) async {
    await _dio.delete<void>('$path/$id');
  }
}
