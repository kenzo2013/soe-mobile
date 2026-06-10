import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/image_url.dart';
import '../../domain/entities/tutor_profile.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_profile_dto.freezed.dart';
part 'tutor_profile_dto.g.dart';

/// Profil agrégé : `GET /current_user` (identité) + `GET /tutors/descriptions`
/// (bio). Pas d'endpoint unique côté API (CDC) — l'agrégation se fait dans le
/// repository.
@freezed
abstract class TutorDescriptionDto with _$TutorDescriptionDto {
  const factory TutorDescriptionDto({
    String? id,
    @Default('') String content,
    String? category,
  }) = _TutorDescriptionDto;
  factory TutorDescriptionDto.fromJson(Map<String, dynamic> json) =>
      _$TutorDescriptionDtoFromJson(json);
}

@freezed
abstract class TutorTrainingDto with _$TutorTrainingDto {
  const factory TutorTrainingDto({
    @Default('') String id,
    @Default('') String category,
    @JsonKey(readValue: _levelRead) @Default('') String level,
    @JsonKey(readValue: _domainRead) @Default('') String domain,
    @JsonKey(readValue: _speciality) @Default('') String specialty,
    @JsonKey(readValue: _trainingDate) @Default('') String date,
  }) = _TutorTrainingDto;
  factory TutorTrainingDto.fromJson(Map<String, dynamic> json) =>
      _$TutorTrainingDtoFromJson(json);
}

@freezed
abstract class TutorWorkDto with _$TutorWorkDto {
  const factory TutorWorkDto({
    @Default('') String id,
    @JsonKey(readValue: _workTitle) @Default('') String title,
    @JsonKey(readValue: _workCompany) @Default('') String company,
    @JsonKey(name: 'current_position') @Default(false) bool current,
    @Default('') String since,
    String? until,
  }) = _TutorWorkDto;
  factory TutorWorkDto.fromJson(Map<String, dynamic> json) =>
      _$TutorWorkDtoFromJson(json);
}

@freezed
abstract class TutorIdentityDto with _$TutorIdentityDto {
  const factory TutorIdentityDto({
    @Default('') String id,
    @JsonKey(readValue: _docType) @Default('') String type,
    @JsonKey(readValue: _expiresRead) String? expirationDate,
    @JsonKey(readValue: _birthRead) String? birthday,
    // `image_urls` (nouveau format backend, mai 2026) : chemins ActiveStorage
    // relatifs. readValue interdit sur les List → on lit via `name` + fallbacks
    // gérés dans toEntity.
    @JsonKey(name: 'image_urls') @Default(<dynamic>[]) List<dynamic> imageUrls,
    @Default('pending') String status,
  }) = _TutorIdentityDto;
  factory TutorIdentityDto.fromJson(Map<String, dynamic> json) =>
      _$TutorIdentityDtoFromJson(json);
}

@freezed
abstract class TutorTeachingCourseDto with _$TutorTeachingCourseDto {
  const factory TutorTeachingCourseDto({
    @Default('') String id,
    @JsonKey(readValue: _className) @Default('') String classe,
    @JsonKey(name: 'subjects') @Default(<dynamic>[]) List<dynamic> subjects,
  }) = _TutorTeachingCourseDto;
  factory TutorTeachingCourseDto.fromJson(Map<String, dynamic> json) =>
      _$TutorTeachingCourseDtoFromJson(json);
}

/// Disponibilité d'un jour : `{ id, day: "lundi", time_availabilities: [{ from,
/// to }] }`. Un enregistrement par jour, créneaux imbriqués.
@freezed
abstract class TutorAvailabilitySlotDto with _$TutorAvailabilitySlotDto {
  const factory TutorAvailabilitySlotDto({
    String? id,
    @Default('') String day,
    @JsonKey(readValue: _timeSlots)
    @Default(<dynamic>[])
    List<dynamic> timeAvailabilities,
  }) = _TutorAvailabilitySlotDto;
  factory TutorAvailabilitySlotDto.fromJson(Map<String, dynamic> json) =>
      _$TutorAvailabilitySlotDtoFromJson(json);
}

TutorIdentityStatus _parseIdentityStatus(String? raw) => switch (raw) {
      'approved' || 'validated' => TutorIdentityStatus.approved,
      'pending' => TutorIdentityStatus.pending,
      'rejected' => TutorIdentityStatus.rejected,
      _ => TutorIdentityStatus.unknown,
    };

extension TutorDescriptionDtoX on TutorDescriptionDto {
  String get text => content;
}

extension TutorTrainingDtoX on TutorTrainingDto {
  TutorTraining toEntity() => TutorTraining(
        id: id,
        category: category,
        level: level,
        domain: domain,
        specialty: specialty.isEmpty ? '—' : specialty,
        date: date,
      );
}

extension TutorWorkDtoX on TutorWorkDto {
  TutorWork toEntity() => TutorWork(
        id: id,
        title: title,
        company: company,
        current: current,
        since: since,
        until: until,
      );
}

extension TutorIdentityDtoX on TutorIdentityDto {
  TutorIdentity toEntity() => TutorIdentity(
        id: id,
        type: type.toUpperCase(),
        expires: expirationDate ?? '',
        dob: birthday ?? '',
        photoUrls: imageUrls
            .map((e) => ImageUrl.resolve(e?.toString()))
            .whereType<String>()
            .toList(),
        status: _parseIdentityStatus(status),
      );
}

extension TutorTeachingCourseDtoX on TutorTeachingCourseDto {
  TutorTeachingCourse toEntity() => TutorTeachingCourse(
        id: id,
        classe: classe,
        subjects: TutorApi.names(subjects),
      );
}

/// Regroupe les enregistrements (un par jour, nom FR + créneaux imbriqués) en
/// 7 jours (Lun→Dim).
List<TutorDayAvailability> groupAvailabilities(
  List<TutorAvailabilitySlotDto> records,
) {
  const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const names = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  // Extrait `HH:MM` d'une heure renvoyée soit en `HH:MM:SS`, soit en datetime
  // ISO ancré (`2000-01-01T14:00:00.000+01:00`). On lit la portion après le
  // `T` sans conversion de fuseau, pour conserver l'heure murale saisie.
  String hm(String? t) {
    if (t == null || t.isEmpty) return '';
    final tIndex = t.indexOf('T');
    final timePart = tIndex >= 0 ? t.substring(tIndex + 1) : t;
    return timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
  }

  return List.generate(7, (i) {
    final dayRecords =
        records.where((r) => r.day.toLowerCase().trim() == names[i]).toList();
    final slots = <TutorTimeSlot>[];
    for (final r in dayRecords) {
      for (final s in r.timeAvailabilities) {
        if (s is Map) {
          slots.add(TutorTimeSlot(
            from: hm(s['from']?.toString()),
            to: hm(s['to']?.toString()),
          ));
        }
      }
    }
    return TutorDayAvailability(
      dayKey: keys[i],
      label: labels[i],
      slots: slots,
      recordId: dayRecords.isEmpty ? null : dayRecords.first.id,
    );
  });
}

// ── readValue tolérants (acceptent plusieurs noms de champ API) ──────────
Object? _levelRead(Map<dynamic, dynamic> j, String _) =>
    j['level_of_study'] ?? j['level'] ?? j['degree'];
Object? _domainRead(Map<dynamic, dynamic> j, String _) =>
    j['field_of_training'] ?? j['domain'] ?? j['field'];
Object? _speciality(Map<dynamic, dynamic> j, String _) =>
    j['specialty'] ?? j['speciality'];
Object? _trainingDate(Map<dynamic, dynamic> j, String _) =>
    j['obtained_at'] ?? j['date'] ?? j['year'] ?? j['graduation_year'];
Object? _expiresRead(Map<dynamic, dynamic> j, String _) =>
    j['expires_on'] ?? j['expiration_date'];
Object? _birthRead(Map<dynamic, dynamic> j, String _) =>
    j['birthdate'] ?? j['birthday'];
Object? _timeSlots(Map<dynamic, dynamic> j, String _) =>
    j['time_availabilities'] ?? j['time_availabilities_attributes'];
Object? _workTitle(Map<dynamic, dynamic> j, String _) =>
    j['title'] ?? j['position'];
Object? _workCompany(Map<dynamic, dynamic> j, String _) =>
    j['company'] ?? j['organization'] ?? j['enterprise'];
Object? _docType(Map<dynamic, dynamic> j, String _) =>
    j['type'] ?? j['document_type'];

Object? _className(Map<dynamic, dynamic> j, String _) {
  final sc = j['school_class'] ?? j['classe'] ?? j['class'];
  if (sc is Map) return sc['name'] ?? sc['abbr'];
  return sc;
}
