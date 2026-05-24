import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/children_remote_datasource.dart';
import '../data/datasources/parent_remote_datasource.dart';
import '../data/datasources/reservations_remote_datasource.dart';
import '../data/datasources/tutor_profile_remote_datasource.dart';
import '../data/repositories/children_repository_impl.dart';
import '../data/repositories/parent_dashboard_repository_impl.dart';
import '../data/repositories/reservations_repository_impl.dart';
import '../data/repositories/tutor_profile_repository_impl.dart';
import '../domain/repositories/children_repository.dart';
import '../domain/repositories/parent_dashboard_repository.dart';
import '../domain/repositories/reservations_repository.dart';
import '../domain/repositories/tutor_profile_repository.dart';
import '../domain/usecases/get_parent_dashboard.dart';
import '../domain/usecases/get_tutor_profile.dart';
import '../domain/usecases/list_children.dart';
import '../domain/usecases/reservations_usecases.dart';
import '../domain/usecases/save_child.dart';
import 'viewmodels/child_form_state.dart';
import 'viewmodels/child_form_viewmodel.dart';
import 'viewmodels/children_list_state.dart';
import 'viewmodels/children_list_viewmodel.dart';
import 'viewmodels/parent_dashboard_state.dart';
import 'viewmodels/parent_dashboard_viewmodel.dart';
import 'viewmodels/reservations_states.dart';
import 'viewmodels/reservations_viewmodels.dart';
import 'viewmodels/tutor_profile_state.dart';
import 'viewmodels/tutor_profile_viewmodel.dart';

// ── Dashboard ────────────────────────────────────────────────
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

// ── Children ─────────────────────────────────────────────────
final childrenRemoteDatasourceProvider = Provider<ChildrenRemoteDatasource>(
  (ref) => ChildrenRemoteDatasource(ref.watch(dioProvider)),
);

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) =>
      ChildrenRepositoryImpl(ref.watch(childrenRemoteDatasourceProvider)),
);

final listChildrenProvider = Provider<ListChildren>(
  (ref) => ListChildren(ref.watch(childrenRepositoryProvider)),
);

final saveChildProvider = Provider<SaveChild>(
  (ref) => SaveChild(ref.watch(childrenRepositoryProvider)),
);

final childrenListViewModelProvider = StateNotifierProvider.autoDispose<
    ChildrenListViewModel, ChildrenListState>(
  (ref) => ChildrenListViewModel(ref.watch(listChildrenProvider))..load(),
);

final childFormViewModelProvider = StateNotifierProvider.autoDispose<
    ChildFormViewModel, ChildFormState>(
  (ref) => ChildFormViewModel(ref.watch(saveChildProvider)),
);

// ── Reservations ─────────────────────────────────────────────
final reservationsRemoteDatasourceProvider =
    Provider<ReservationsRemoteDatasource>(
  (ref) => ReservationsRemoteDatasource(ref.watch(dioProvider)),
);

final reservationsRepositoryProvider = Provider<ReservationsRepository>(
  (ref) => ReservationsRepositoryImpl(
      ref.watch(reservationsRemoteDatasourceProvider)),
);

final listReservationsProvider = Provider<ListReservations>(
  (ref) => ListReservations(ref.watch(reservationsRepositoryProvider)),
);

final getReservationDetailProvider = Provider<GetReservationDetail>(
  (ref) => GetReservationDetail(ref.watch(reservationsRepositoryProvider)),
);

final createReservationProvider = Provider<CreateReservation>(
  (ref) => CreateReservation(ref.watch(reservationsRepositoryProvider)),
);

final acceptReservationProvider = Provider<AcceptReservation>(
  (ref) => AcceptReservation(ref.watch(reservationsRepositoryProvider)),
);

final rejectReservationProvider = Provider<RejectReservation>(
  (ref) => RejectReservation(ref.watch(reservationsRepositoryProvider)),
);

final negotiateReservationProvider = Provider<NegotiateReservation>(
  (ref) => NegotiateReservation(ref.watch(reservationsRepositoryProvider)),
);

final reservationsListViewModelProvider = StateNotifierProvider.autoDispose<
    ReservationsListViewModel, ReservationsListState>(
  (ref) => ReservationsListViewModel(ref.watch(listReservationsProvider))
    ..load(),
);

final reservationDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReservationDetailViewModel, ReservationDetailState, String>(
  (ref, id) => ReservationDetailViewModel(
    getDetail: ref.watch(getReservationDetailProvider),
    accept: ref.watch(acceptReservationProvider),
    reject: ref.watch(rejectReservationProvider),
    negotiate: ref.watch(negotiateReservationProvider),
  )..load(id),
);

final newReservationViewModelProvider = StateNotifierProvider.autoDispose<
    NewReservationViewModel, NewReservationState>(
  (ref) => NewReservationViewModel(ref.watch(createReservationProvider)),
);

// ── Tutor profile ────────────────────────────────────────────
final tutorProfileRemoteDatasourceProvider =
    Provider<TutorProfileRemoteDatasource>(
  (ref) => TutorProfileRemoteDatasource(ref.watch(dioProvider)),
);

final tutorProfileRepositoryProvider = Provider<TutorProfileRepository>(
  (ref) => TutorProfileRepositoryImpl(
      ref.watch(tutorProfileRemoteDatasourceProvider)),
);

final getTutorProfileProvider = Provider<GetTutorProfile>(
  (ref) => GetTutorProfile(ref.watch(tutorProfileRepositoryProvider)),
);

final tutorProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorProfileViewModel, TutorProfileState, String>(
  (ref, tutorId) => TutorProfileViewModel(ref.watch(getTutorProfileProvider))
    ..load(tutorId),
);
