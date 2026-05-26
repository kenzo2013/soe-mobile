import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_tutor_profile.dart';
import 'tutor_profile_state.dart';

class TutorProfileViewModel extends StateNotifier<TutorProfileState> {
  TutorProfileViewModel(this._get) : super(const TutorProfileState.initial());
  final GetTutorProfile _get;

  Future<void> load({
    required String studentId,
    required String tutorId,
  }) async {
    state = const TutorProfileState.loading();
    final r = await _get(studentId: studentId, tutorId: tutorId);
    state = switch (r) {
      Ok(:final value) => TutorProfileState.loaded(value),
      Err(:final failure) => TutorProfileState.error(failure),
    };
  }
}
