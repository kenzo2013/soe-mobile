import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/reservation_detail.dart';
import '../../domain/entities/reservation_summary.dart';

part 'reservation_dto.freezed.dart';
part 'reservation_dto.g.dart';

@freezed
abstract class TutorMiniDto with _$TutorMiniDto {
  const factory TutorMiniDto({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    String? category,
    double? rating,
    @JsonKey(name: 'review_count') int? reviewCount,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _TutorMiniDto;
  factory TutorMiniDto.fromJson(Map<String, dynamic> json) =>
      _$TutorMiniDtoFromJson(json);
}

@freezed
abstract class ReservationDetailDto with _$ReservationDetailDto {
  const factory ReservationDetailDto({
    required String id,
    String? reference,
    String? status,
    @JsonKey(name: 'child_id') String? childId,
    @JsonKey(name: 'child_name') String? childName,
    @Default(<String>[]) List<String> subjects,
    @Default(1) int frequency,
    @JsonKey(name: 'estimated_start_date') String? estimatedStartDate,
    @JsonKey(name: 'preferred_tutor_gender') String? preferredTutorGender,
    String? location,
    int? amount,
    @JsonKey(name: 'amount_per_session') int? amountPerSession,
    @JsonKey(name: 'session_count') int? sessionCount,
    @JsonKey(name: 'program_text') String? programText,
    TutorMiniDto? tutor,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ReservationDetailDto;
  factory ReservationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationDetailDtoFromJson(json);
}

extension ReservationDetailDtoX on ReservationDetailDto {
  ReservationDetail toEntity() => ReservationDetail(
        id: id,
        reference: reference ?? '#$id',
        status: _parseReservationStatus(status),
        childId: childId ?? '',
        childName: childName ?? '—',
        subjects: subjects,
        frequency: frequency,
        estimatedStartDate:
            DateTime.tryParse(estimatedStartDate ?? '') ?? DateTime.now(),
        preferredTutorGender: preferredTutorGender ?? 'no_preference',
        location: location ?? '—',
        amount: amount,
        amountPerSession: amountPerSession,
        sessionCount: sessionCount,
        programText: programText,
        tutor: tutor == null
            ? null
            : TutorMini(
                id: tutor!.id,
                firstName: tutor!.firstName,
                lastName: tutor!.lastName,
                category: tutor!.category,
                rating: tutor!.rating,
                reviewCount: tutor!.reviewCount,
                avatarUrl: tutor!.avatarUrl,
              ),
        createdAt: DateTime.tryParse(createdAt ?? ''),
      );
}

/// Payload conforme CDC §4.4 :
/// `{reservation: {tutoring_requests_attributes: [{...}]}}`
Map<String, dynamic> newReservationParamsToJson(NewReservationParams p) {
  final dateIso =
      '${p.estimatedStartDate.year.toString().padLeft(4, '0')}-${p.estimatedStartDate.month.toString().padLeft(2, '0')}-${p.estimatedStartDate.day.toString().padLeft(2, '0')}';
  return {
    'tutoring_requests_attributes': [
      {
        'student_id': p.childId,
        'estimated_start_date': dateIso,
        'frequency': p.frequency,
        'preferred_tutor_gender': switch (p.preferredTutorGender) {
          TutorGenderPref.male => 'male',
          TutorGenderPref.female => 'female',
          TutorGenderPref.noPreference => 'no_preference',
        },
        'subject_ids': p.subjects,
      },
    ],
    if (p.location != null) 'location': p.location,
  };
}

ReservationStatus _parseReservationStatus(String? raw) => switch (raw) {
      'draft' => ReservationStatus.draft,
      'pending' => ReservationStatus.pending,
      'proposed_price' => ReservationStatus.proposedPrice,
      'negotiation' => ReservationStatus.negotiation,
      'accepted' => ReservationStatus.accepted,
      'active' => ReservationStatus.active,
      'completed' || 'all_completed' => ReservationStatus.completed,
      'rejected' => ReservationStatus.rejected,
      'cancelled' || 'all_cancelled' => ReservationStatus.cancelled,
      _ => ReservationStatus.unknown,
    };

// Liste mini — extension du ReservationSummaryDto déjà défini dans
// parent_dashboard_dto.dart pour le dashboard. On le réutilise via un
// adaptateur léger ici si besoin.
