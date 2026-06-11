import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tutor_profile.dart';

part 'tutor_profile_dto.freezed.dart';
part 'tutor_profile_dto.g.dart';

@freezed
abstract class TutorTrainingDto with _$TutorTrainingDto {
  const factory TutorTrainingDto({
    required String degree,
    required String field,
    @JsonKey(name: 'year') String? year,
    String? institution,
  }) = _TutorTrainingDto;
  factory TutorTrainingDto.fromJson(Map<String, dynamic> json) =>
      _$TutorTrainingDtoFromJson(json);
}

@freezed
abstract class TutorWorkDto with _$TutorWorkDto {
  const factory TutorWorkDto({
    required String position,
    required String organization,
    @JsonKey(name: 'period') String? period,
  }) = _TutorWorkDto;
  factory TutorWorkDto.fromJson(Map<String, dynamic> json) =>
      _$TutorWorkDtoFromJson(json);
}

@freezed
abstract class TutorAvailabilityDto with _$TutorAvailabilityDto {
  const factory TutorAvailabilityDto({
    @Default(1) int weekday,
    @JsonKey(name: 'time_range') String? timeRange,
  }) = _TutorAvailabilityDto;
  factory TutorAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$TutorAvailabilityDtoFromJson(json);
}

@freezed
abstract class TutorReviewDto with _$TutorReviewDto {
  const factory TutorReviewDto({
    @JsonKey(name: 'author_name') String? authorName,
    @Default(0.0) double rating,
    String? comment,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _TutorReviewDto;
  factory TutorReviewDto.fromJson(Map<String, dynamic> json) =>
      _$TutorReviewDtoFromJson(json);
}

@freezed
abstract class TutorProfileDto with _$TutorProfileDto {
  const factory TutorProfileDto({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    String? category,
    @Default(<String>[]) List<String> subjects,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? city,
    @JsonKey(name: 'experience_years') @Default(0) int experienceYears,
    @JsonKey(name: 'session_count') @Default(0) int sessionCount,
    @Default(<TutorTrainingDto>[]) List<TutorTrainingDto> trainings,
    @Default(<TutorWorkDto>[]) List<TutorWorkDto> works,
    @Default(<TutorAvailabilityDto>[])
    List<TutorAvailabilityDto> availabilities,
    @Default(<TutorReviewDto>[]) List<TutorReviewDto> reviews,
  }) = _TutorProfileDto;
  factory TutorProfileDto.fromJson(Map<String, dynamic> json) =>
      _$TutorProfileDtoFromJson(json);
}

extension TutorProfileDtoX on TutorProfileDto {
  TutorProfile toEntity() => TutorProfile(
        id: id,
        firstName: firstName,
        lastName: lastName,
        rating: rating,
        reviewCount: reviewCount,
        category: category ?? '—',
        subjects: subjects,
        bio: bio,
        avatarUrl: avatarUrl,
        city: city,
        experienceYears: experienceYears,
        sessionCount: sessionCount,
        trainings: trainings
            .map((e) => TutorTraining(
                  degree: e.degree,
                  field: e.field,
                  year: e.year ?? '',
                  institution: e.institution,
                ))
            .toList(),
        works: works
            .map((e) => TutorWork(
                  position: e.position,
                  organization: e.organization,
                  period: e.period ?? '',
                ))
            .toList(),
        availabilities: availabilities
            .map((e) => TutorAvailability(
                  weekday: e.weekday,
                  timeRange: e.timeRange ?? '',
                ))
            .toList(),
        reviews: reviews
            .map((e) => TutorReview(
                  author: e.authorName ?? '—',
                  rating: e.rating,
                  comment: e.comment ?? '',
                  date: DateTime.tryParse(e.createdAt ?? '') ?? DateTime.now(),
                ))
            .toList(),
      );
}
