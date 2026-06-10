import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_remuneration.dart';
import '../datasources/tutor_remote_base.dart';

part 'tutor_remuneration_dto.freezed.dart';
part 'tutor_remuneration_dto.g.dart';

@freezed
abstract class TutorRemunerationDto with _$TutorRemunerationDto {
  const factory TutorRemunerationDto({
    @Default('') String id,
    @JsonKey(readValue: _period) @Default('') String period,
    @JsonKey(readValue: _amount) @Default(0) int amount,
    @Default('pending') String status,
    @JsonKey(readValue: _sessions) @Default(0) int sessions,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'payment_method') String? method,
  }) = _TutorRemunerationDto;
  factory TutorRemunerationDto.fromJson(Map<String, dynamic> json) =>
      _$TutorRemunerationDtoFromJson(json);

  const TutorRemunerationDto._();

  bool get isPaid => status == 'paid' || status == 'completed';
}

RemunerationStatus _parseStatus(String? raw) => switch (raw) {
      'paid' || 'completed' => RemunerationStatus.paid,
      'pending' || 'pending_payment' => RemunerationStatus.pending,
      _ => RemunerationStatus.unknown,
    };

extension TutorRemunerationDtoX on TutorRemunerationDto {
  TutorRemuneration toEntity() => TutorRemuneration(
        id: id,
        period: period,
        amount: amount,
        status: _parseStatus(status),
        sessions: sessions,
        paidOn: paidAt == null ? null : TutorApi.shortDate(paidAt),
        method: method,
      );
}

/// Construit l'agrégat (résumé calculé client-side à partir des items).
TutorRemunerations buildRemunerations(List<TutorRemunerationDto> dtos) {
  final items = dtos.map((e) => e.toEntity()).toList();
  final paid = dtos.where((e) => e.isPaid).toList();
  final totalEarned = paid.fold<int>(0, (s, e) => s + e.amount);
  final totalSessions = dtos.fold<int>(0, (s, e) => s + e.sessions);
  final avg = totalSessions == 0 ? 0 : (totalEarned / totalSessions).round();
  return TutorRemunerations(
    summary: TutorEarningsSummary(
      year: DateTime.now().year,
      totalEarned: totalEarned,
      totalSessions: totalSessions,
      totalStudents: 0,
      averageRate: avg,
    ),
    items: items,
  );
}

Object? _period(Map<dynamic, dynamic> j, String _) =>
    j['period'] ?? j['label'] ?? j['month'] ?? '';
Object? _amount(Map<dynamic, dynamic> j, String _) {
  return TutorApi.amount(j['amount'] ?? j['total'] ?? j['net_amount']);
}

Object? _sessions(Map<dynamic, dynamic> j, String _) {
  final s = j['sessions_count'] ?? j['session_count'] ?? j['sessions'];
  if (s is num) return s.toInt();
  if (s is List) return s.length;
  return 0;
}
