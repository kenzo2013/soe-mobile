import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/parent_dashboard.dart';

part 'parent_dashboard_state.freezed.dart';

@freezed
sealed class ParentDashboardState with _$ParentDashboardState {
  const factory ParentDashboardState.initial() = _Initial;
  const factory ParentDashboardState.loading() = _Loading;
  const factory ParentDashboardState.loaded(ParentDashboard data) = _Loaded;
  const factory ParentDashboardState.error(Failure failure) = _Error;
}
