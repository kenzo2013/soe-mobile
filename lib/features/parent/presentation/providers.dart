import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/parent_remote_datasource.dart';
import '../data/repositories/parent_dashboard_repository_impl.dart';
import '../domain/repositories/parent_dashboard_repository.dart';
import '../domain/usecases/get_parent_dashboard.dart';
import 'viewmodels/parent_dashboard_state.dart';
import 'viewmodels/parent_dashboard_viewmodel.dart';

final parentRemoteDatasourceProvider = Provider<ParentRemoteDatasource>(
  (ref) => ParentRemoteDatasource(ref.watch(dioProvider)),
);

final parentDashboardRepositoryProvider = Provider<ParentDashboardRepository>(
  (ref) =>
      ParentDashboardRepositoryImpl(ref.watch(parentRemoteDatasourceProvider)),
);

final getParentDashboardProvider = Provider<GetParentDashboard>(
  (ref) => GetParentDashboard(ref.watch(parentDashboardRepositoryProvider)),
);

final parentDashboardViewModelProvider =
    StateNotifierProvider.autoDispose<ParentDashboardViewModel,
        ParentDashboardState>(
  (ref) => ParentDashboardViewModel(ref.watch(getParentDashboardProvider))
    ..load(),
);
