import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_course.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_course_dto.freezed.dart';
part 'tutor_course_dto.g.dart';

/// Cours actif = réservation assignée (`GET /tutors/tutoring_courses`).
/// Forme tolérante : on récupère le 1er élève/demande de tutorat de la
/// réservation pour la carte.
@freezed
abstract class TutorActiveCourseDto with _$TutorActiveCourseDto {
  const factory TutorActiveCourseDto({
    @Default('') String id,
    @JsonKey(readValue: _reference) @Default('') String reference,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(readValue: _student) @Default('') String student,
    @JsonKey(readValue: _classe) @Default('') String classe,
    @JsonKey(name: 'subjects') @Default(<dynamic>[]) List<dynamic> subjects,
    @JsonKey(readValue: _schedule) @Default('') String schedule,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _TutorActiveCourseDto;
  factory TutorActiveCourseDto.fromJson(Map<String, dynamic> json) =>
      _$TutorActiveCourseDtoFromJson(json);
}

@freezed
abstract class TutorCourseSlotDto with _$TutorCourseSlotDto {
  const factory TutorCourseSlotDto({
    @Default('') String day,
    @JsonKey(name: 'time_range') String? timeRange,
    @Default('') String subject,
  }) = _TutorCourseSlotDto;
  factory TutorCourseSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TutorCourseSlotDtoFromJson(json);
}

@freezed
abstract class TutorCourseDetailDto with _$TutorCourseDetailDto {
  const factory TutorCourseDetailDto({
    @Default('') String id,
    @JsonKey(readValue: _student) @Default('') String student,
    @Default(0) int age,
    @Default('') String gender,
    @JsonKey(readValue: _classe) @Default('') String classe,
    @JsonKey(name: 'subjects') @Default(<dynamic>[]) List<dynamic> subjects,
    @Default(<TutorCourseSlotDto>[]) List<TutorCourseSlotDto> slots,
  }) = _TutorCourseDetailDto;
  factory TutorCourseDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TutorCourseDetailDtoFromJson(json);
}

extension TutorActiveCourseDtoX on TutorActiveCourseDto {
  TutorActiveCourse toEntity() => TutorActiveCourse(
        id: studentId ?? id,
        reference: reference,
        student: student,
        classe: classe,
        subjects: TutorApi.names(subjects),
        schedule: schedule,
        start: TutorApi.shortDate(createdAt),
      );
}

extension TutorCourseSlotDtoX on TutorCourseSlotDto {
  TutorCourseSlot toEntity() =>
      TutorCourseSlot(day: day, timeRange: timeRange ?? '', subject: subject);
}

extension TutorCourseDetailDtoX on TutorCourseDetailDto {
  TutorCourseDetail toEntity() => TutorCourseDetail(
        id: id,
        student: student,
        age: age,
        gender: _gender(gender),
        classe: classe,
        subjects: TutorApi.names(subjects),
        slots: slots.map((e) => e.toEntity()).toList(),
      );
}

String _gender(String g) => switch (g) {
      'male' => 'Garçon',
      'feminine' || 'female' => 'Fille',
      _ => g,
    };

Object? _reference(Map<dynamic, dynamic> j, String _) =>
    j['reference'] ?? j['ref'] ?? (j['id']?.toString());

Object? _student(Map<dynamic, dynamic> j, String _) {
  final s = j['student'] ?? j['child'];
  if (s is Map) {
    final fn = s['first_name'] ?? '';
    final ln = s['last_name'] ?? '';
    final full = '$fn $ln'.trim();
    return full.isNotEmpty ? full : (s['name'] ?? s['full_name']);
  }
  return j['student_name'] ?? j['full_name'] ?? s ?? '';
}

Object? _classe(Map<dynamic, dynamic> j, String _) {
  final sc = j['school_class'] ?? j['classe'];
  if (sc is Map) return sc['name'] ?? sc['abbr'];
  final student = j['student'];
  if (student is Map) {
    final ssc = student['school_class'];
    if (ssc is Map) return ssc['name'] ?? ssc['abbr'];
  }
  return sc ?? '';
}

Object? _schedule(Map<dynamic, dynamic> j, String _) =>
    j['schedule'] ?? j['schedule_summary'] ?? '';
