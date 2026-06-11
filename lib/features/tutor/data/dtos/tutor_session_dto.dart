import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/tutor_session.dart';
import '../datasources/tutor_remote_base.dart';
import 'tutor_dashboard_dto.dart' show parseSessionStatus;

part 'tutor_session_dto.freezed.dart';
part 'tutor_session_dto.g.dart';

@freezed
abstract class TutorSessionDto with _$TutorSessionDto {
  const factory TutorSessionDto({
    @Default('') String id,
    @JsonKey(readValue: _startAt) String? startAt,
    @JsonKey(readValue: _endAt) String? endAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(readValue: _student) @Default('') String student,
    @JsonKey(readValue: _subject) @Default('') String subject,
    @Default('') String status,
    @JsonKey(name: 'editable') @Default(false) bool editable,
    @JsonKey(name: 'report_available') @Default(false) bool reportAvailable,
    @JsonKey(name: 'report_submitted') @Default(false) bool reportSubmitted,
  }) = _TutorSessionDto;
  factory TutorSessionDto.fromJson(Map<String, dynamic> json) =>
      _$TutorSessionDtoFromJson(json);

  const TutorSessionDto._();

  DateTime? get startDate => DateTime.tryParse(startAt ?? '');
}

@freezed
abstract class TutorSessionDetailDto with _$TutorSessionDetailDto {
  const factory TutorSessionDetailDto({
    @Default('') String id,
    @JsonKey(readValue: _subject) @Default('') String subject,
    @JsonKey(readValue: _startAt) String? startAt,
    @JsonKey(readValue: _endAt) String? endAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(readValue: _student) @Default('') String student,
    @JsonKey(readValue: _classe) @Default('') String classe,
    @JsonKey(readValue: _reservationRef) @Default('') String reservationRef,
    @Default('') String status,
    @JsonKey(name: 'editable') @Default(false) bool editable,
    @JsonKey(name: 'report_available') @Default(false) bool reportAvailable,
  }) = _TutorSessionDetailDto;
  factory TutorSessionDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TutorSessionDetailDtoFromJson(json);
}

extension TutorSessionDtoX on TutorSessionDto {
  TutorSession toEntity() => TutorSession(
        id: id,
        timeRange: TutorApi.timeRange(startAt,
            endIso: endAt, minutes: durationMinutes),
        student: student,
        subject: subject,
        status: parseSessionStatus(status),
        editable: editable,
        reportAvailable: reportAvailable,
        reportSubmitted: reportSubmitted,
      );
}

extension TutorSessionDetailDtoX on TutorSessionDetailDto {
  TutorSessionDetail toEntity() => TutorSessionDetail(
        id: id,
        subject: subject,
        dateLine:
            TutorApi.dateLine(startAt, endIso: endAt, minutes: durationMinutes),
        timeRange: TutorApi.timeRange(startAt,
            endIso: endAt, minutes: durationMinutes),
        student: student,
        classe: classe,
        reservationRef: reservationRef,
        status: parseSessionStatus(status),
        editable: editable,
        editableReason: editable
            ? 'Oui · plus de 24h avant le début'
            : 'Non · début dans moins de 24h',
        reportAvailable: reportAvailable,
        reportReason: reportAvailable
            ? 'Oui · à soumettre'
            : 'Disponible après la séance',
      );
}

/// Regroupe une liste plate de séances par jour (libellé relatif FR).
List<TutorSessionGroup> groupSessionsByDay(List<TutorSessionDto> sessions) {
  final fmt = DateFormat('EEEE d MMMM', 'fr');
  final byDay = <String, List<TutorSessionDto>>{};
  final order = <String>[];
  for (final s in sessions) {
    final d = s.startDate;
    final label = d == null ? 'Planifiées' : _relativeDay(d.toLocal(), fmt);
    if (!byDay.containsKey(label)) {
      byDay[label] = [];
      order.add(label);
    }
    byDay[label]!.add(s);
  }
  return [
    for (final label in order)
      TutorSessionGroup(
        day: label,
        items: byDay[label]!.map((e) => e.toEntity()).toList(),
      ),
  ];
}

String _relativeDay(DateTime d, DateFormat fmt) {
  final today = DateTime.now();
  final day0 = DateTime(today.year, today.month, today.day);
  final target = DateTime(d.year, d.month, d.day);
  final diff = target.difference(day0).inDays;
  final cap = _cap(fmt.format(d));
  return switch (diff) {
    0 => "Aujourd'hui · $cap",
    1 => 'Demain · $cap',
    -1 => 'Hier · $cap',
    _ => cap,
  };
}

String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// L'API sépare `date` (jour) et `start_at`/`end_at` (heures, année 2000).
// On recombine pour obtenir l'horodatage réel de la séance.
Object? _startAt(Map<dynamic, dynamic> j, String _) =>
    _combineDateTime(j['date'], j['start_at']);

Object? _endAt(Map<dynamic, dynamic> j, String _) =>
    _combineDateTime(j['date'], j['end_at']);

String? _combineDateTime(Object? date, Object? time) {
  final d = date?.toString();
  final t = DateTime.tryParse(time?.toString() ?? '');
  if (d == null || d.isEmpty) return time?.toString();
  if (t == null) return d;
  final l = t.toLocal();
  final hh = l.hour.toString().padLeft(2, '0');
  final mm = l.minute.toString().padLeft(2, '0');
  return '${d}T$hh:$mm:00';
}

Object? _student(Map<dynamic, dynamic> j, String _) {
  final s = j['student'] ?? j['child'];
  if (s is Map) {
    final full = '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();
    return full.isNotEmpty ? full : (s['name'] ?? s['full_name'] ?? '');
  }
  return j['student_name'] ?? s ?? '';
}

Object? _subject(Map<dynamic, dynamic> j, String _) {
  final sub = j['subject'] ?? j['subjects'];
  if (sub is Map) return sub['name'];
  if (sub is List && sub.isNotEmpty) {
    final first = sub.first;
    return first is Map ? first['name'] : first.toString();
  }
  return sub ?? '';
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

Object? _reservationRef(Map<dynamic, dynamic> j, String _) {
  final r = j['reservation'];
  if (r is Map) return r['reference'] ?? r['ref'];
  return j['reservation_ref'] ?? j['reservation_reference'] ?? '';
}
