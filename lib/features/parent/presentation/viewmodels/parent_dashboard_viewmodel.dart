import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_parent_dashboard.dart';
import 'parent_dashboard_state.dart';

class ParentDashboardViewModel extends StateNotifier<ParentDashboardState> {
  ParentDashboardViewModel(this._getDashboard)
      : super(const ParentDashboardState.initial());

  final GetParentDashboard _getDashboard;

  Future<void> load() async {
    state = const ParentDashboardState.loading();
    final result = await _getDashboard();
    state = switch (result) {
      Ok(:final value) => ParentDashboardState.loaded(value),
      Err(:final failure) => ParentDashboardState.error(failure),
    };
  }

  Future<void> refresh() => load();
}
