import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/tutor_profile.dart';

part 'tutor_profile_state.freezed.dart';

@freezed
sealed class TutorProfileState with _$TutorProfileState {
  const factory TutorProfileState.initial() = _Initial;
  const factory TutorProfileState.loading() = _Loading;
  const factory TutorProfileState.loaded(TutorProfile profile) = _Loaded;
  const factory TutorProfileState.error(Failure failure) = _Error;
}
