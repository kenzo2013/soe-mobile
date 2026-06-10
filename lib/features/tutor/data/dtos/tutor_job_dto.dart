import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_job.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_job_dto.freezed.dart';
part 'tutor_job_dto.g.dart';

@freezed
abstract class TutorJobDto with _$TutorJobDto {
  const factory TutorJobDto({
    @Default('') String id,
    @JsonKey(readValue: _title) @Default('') String title,
    @JsonKey(readValue: _price) @Default(0) int pricePerHour,
    @JsonKey(readValue: _frequency) @Default('') String frequency,
    @JsonKey(readValue: _start) @Default('') String start,
    @JsonKey(name: 'subjects') @Default(<dynamic>[]) List<dynamic> subjects,
    @JsonKey(name: 'school_classes')
    @Default(<dynamic>[])
    List<dynamic> classes,
    @JsonKey(readValue: _location) @Default('') String location,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(readValue: _applied) @Default(false) bool applied,
    @JsonKey(readValue: _summary) @Default('') String summary,
  }) = _TutorJobDto;
  factory TutorJobDto.fromJson(Map<String, dynamic> json) =>
      _$TutorJobDtoFromJson(json);
}

extension TutorJobDtoX on TutorJobDto {
  TutorJob toEntity() => TutorJob(
        id: id,
        title: title,
        pricePerHour: pricePerHour,
        frequency: frequency,
        start: start,
        subjects: TutorApi.names(subjects),
        classes: TutorApi.names(classes),
        location: location,
        posted: TutorApi.relative(createdAt),
        applied: applied,
        summary: summary.isEmpty ? title : summary,
      );
}

Object? _title(Map<dynamic, dynamic> j, String _) =>
    j['title'] ?? j['name'] ?? j['description'];
Object? _price(Map<dynamic, dynamic> j, String _) {
  return TutorApi.amount(
    j['price'] ?? j['price_per_hour'] ?? j['proposed_price'] ?? j['amount'],
  );
}

Object? _frequency(Map<dynamic, dynamic> j, String _) {
  final f = j['frequency'];
  if (f is num) return '${f.toInt()}×/sem';
  return f ?? '';
}

Object? _start(Map<dynamic, dynamic> j, String _) {
  final s = j['estimated_start_date'] ?? j['start_date'] ?? j['start'];
  return s == null ? '' : TutorApi.shortDate(s.toString());
}

Object? _location(Map<dynamic, dynamic> j, String _) {
  final loc = j['location'] ?? j['city'];
  if (loc != null) {
    final neighborhood = j['neighborhood'];
    return neighborhood != null ? '$neighborhood, $loc' : loc.toString();
  }
  final addr = j['address'];
  if (addr is Map) return addr['city']?.toString() ?? '';
  return '';
}

Object? _applied(Map<dynamic, dynamic> j, String _) =>
    j['applied'] ?? j['already_applied'] ?? j['has_applied'] ?? false;
Object? _summary(Map<dynamic, dynamic> j, String _) =>
    j['summary'] ?? j['description'] ?? j['details'] ?? '';
