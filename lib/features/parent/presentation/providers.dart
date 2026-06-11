import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/children_remote_datasource.dart';
import '../data/datasources/parent_remote_datasource.dart';
import '../data/datasources/misc_remote_datasource.dart';
import '../data/datasources/payments_remote_datasource.dart';
import '../data/datasources/reservations_remote_datasource.dart';
import '../data/datasources/sessions_remote_datasource.dart';
import '../data/datasources/tutor_profile_remote_datasource.dart';
import '../data/repositories/children_repository_impl.dart';
import '../data/repositories/parent_dashboard_repository_impl.dart';
import '../data/repositories/misc_repositories_impl.dart';
import '../data/repositories/payments_repository_impl.dart';
import '../data/repositories/reservations_repository_impl.dart';
import '../data/repositories/sessions_repository_impl.dart';
import '../data/repositories/tutor_profile_repository_impl.dart';
import '../domain/repositories/children_repository.dart';
import '../domain/repositories/parent_dashboard_repository.dart';
import '../domain/repositories/misc_repositories.dart';
import '../domain/repositories/payments_repository.dart';
import '../domain/repositories/reservations_repository.dart';
import '../domain/repositories/sessions_repository.dart';
import '../domain/repositories/tutor_profile_repository.dart';
import '../domain/usecases/get_parent_dashboard.dart';
import '../domain/usecases/get_tutor_profile.dart';
import '../domain/usecases/list_children.dart';
import '../domain/usecases/payments_usecases.dart';
import '../domain/usecases/reservations_usecases.dart';
import '../domain/usecases/save_child.dart';
import '../domain/usecases/sessions_usecases.dart';
import 'viewmodels/child_form_state.dart';
import 'viewmodels/child_form_viewmodel.dart';
import 'viewmodels/children_list_state.dart';
import 'viewmodels/children_list_viewmodel.dart';
import 'viewmodels/parent_dashboard_state.dart';
import 'viewmodels/parent_dashboard_viewmodel.dart';
import 'viewmodels/misc_viewmodels.dart';
import 'viewmodels/payments_states.dart';
import 'viewmodels/payments_viewmodels.dart';
import 'viewmodels/reservations_states.dart';
import 'viewmodels/reservations_viewmodels.dart';
import 'viewmodels/sessions_states.dart';
import 'viewmodels/sessions_viewmodels.dart';
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

final parentDashboardViewModelProvider = StateNotifierProvider.autoDispose<
    ParentDashboardViewModel, ParentDashboardState>(
  (ref) =>
      ParentDashboardViewModel(ref.watch(getParentDashboardProvider))..load(),
);

// ── Children ─────────────────────────────────────────────────
final childrenRemoteDatasourceProvider = Provider<ChildrenRemoteDatasource>(
  (ref) => ChildrenRemoteDatasource(ref.watch(dioProvider)),
);

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepositoryImpl(ref.watch(childrenRemoteDatasourceProvider)),
);

final listChildrenProvider = Provider<ListChildren>(
  (ref) => ListChildren(ref.watch(childrenRepositoryProvider)),
);

final saveChildProvider = Provider<SaveChild>(
  (ref) => SaveChild(ref.watch(childrenRepositoryProvider)),
);

final childrenListViewModelProvider =
    StateNotifierProvider.autoDispose<ChildrenListViewModel, ChildrenListState>(
  (ref) => ChildrenListViewModel(ref.watch(listChildrenProvider))..load(),
);

final childFormViewModelProvider =
    StateNotifierProvider.autoDispose<ChildFormViewModel, ChildFormState>(
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
  (ref) =>
      ReservationsListViewModel(ref.watch(listReservationsProvider))..load(),
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

// ── Misc (reviews/programs/invitations/contracts) ────────────
final miscRemoteDatasourceProvider = Provider<MiscRemoteDatasource>(
  (ref) => MiscRemoteDatasource(ref.watch(dioProvider)),
);

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ReviewsRepositoryImpl(ref.watch(miscRemoteDatasourceProvider)),
);
final programsRepositoryProvider = Provider<ProgramsRepository>(
  (ref) => ProgramsRepositoryImpl(ref.watch(miscRemoteDatasourceProvider)),
);
final invitationsRepositoryProvider = Provider<InvitationsRepository>(
  (ref) => InvitationsRepositoryImpl(ref.watch(miscRemoteDatasourceProvider)),
);
final contractsRepositoryProvider = Provider<ContractsRepository>(
  (ref) => ContractsRepositoryImpl(ref.watch(miscRemoteDatasourceProvider)),
);

final reviewsListViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReviewsListViewModel, AsyncListState, Object?>(
  (ref, _) =>
      ReviewsListViewModel(ref.watch(reviewsRepositoryProvider))..load(),
);

final programsListViewModelProvider = StateNotifierProvider.autoDispose
    .family<ProgramsListViewModel, AsyncListState, Object?>(
  (ref, _) =>
      ProgramsListViewModel(ref.watch(programsRepositoryProvider))..load(),
);

final invitationsListViewModelProvider = StateNotifierProvider.autoDispose
    .family<InvitationsListViewModel, AsyncListState, Object?>(
  (ref, _) => InvitationsListViewModel(ref.watch(invitationsRepositoryProvider))
    ..load(),
);

final contractsListViewModelProvider = StateNotifierProvider.autoDispose
    .family<ContractsListViewModel, AsyncListState, Object?>(
  (ref, _) =>
      ContractsListViewModel(ref.watch(contractsRepositoryProvider))..load(),
);

// ── Payments ─────────────────────────────────────────────────
final paymentsRemoteDatasourceProvider = Provider<PaymentsRemoteDatasource>(
  (ref) => PaymentsRemoteDatasource(ref.watch(dioProvider)),
);

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepositoryImpl(ref.watch(paymentsRemoteDatasourceProvider)),
);

final listPaymentsProvider = Provider<ListPayments>(
  (ref) => ListPayments(ref.watch(paymentsRepositoryProvider)),
);

final initiatePaymentProvider = Provider<InitiatePayment>(
  (ref) => InitiatePayment(ref.watch(paymentsRepositoryProvider)),
);

final getPaymentReceiptProvider = Provider<GetPaymentReceipt>(
  (ref) => GetPaymentReceipt(ref.watch(paymentsRepositoryProvider)),
);

final paymentsListViewModelProvider =
    StateNotifierProvider.autoDispose<PaymentsListViewModel, PaymentsListState>(
  (ref) => PaymentsListViewModel(ref.watch(listPaymentsProvider))..load(),
);

final checkoutViewModelProvider =
    StateNotifierProvider.autoDispose<CheckoutViewModel, CheckoutState>(
  (ref) => CheckoutViewModel(ref.watch(initiatePaymentProvider)),
);

final paymentReceiptViewModelProvider = StateNotifierProvider.autoDispose
    .family<PaymentReceiptViewModel, PaymentReceiptState, String>(
  (ref, id) =>
      PaymentReceiptViewModel(ref.watch(getPaymentReceiptProvider))..load(id),
);

// ── Sessions ─────────────────────────────────────────────────
final sessionsRemoteDatasourceProvider = Provider<SessionsRemoteDatasource>(
  (ref) => SessionsRemoteDatasource(ref.watch(dioProvider)),
);

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepositoryImpl(ref.watch(sessionsRemoteDatasourceProvider)),
);

final listSessionsProvider = Provider<ListSessions>(
  (ref) => ListSessions(ref.watch(sessionsRepositoryProvider)),
);

final getSessionDetailProvider = Provider<GetSessionDetail>(
  (ref) => GetSessionDetail(ref.watch(sessionsRepositoryProvider)),
);

final sessionsListViewModelProvider =
    StateNotifierProvider.autoDispose<SessionsListViewModel, SessionsListState>(
  (ref) => SessionsListViewModel(ref.watch(listSessionsProvider))..load(),
);

final sessionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<SessionDetailViewModel, SessionDetailState, String>(
  (ref, id) =>
      SessionDetailViewModel(ref.watch(getSessionDetailProvider))..load(id),
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

/// Family key = `(studentId, tutorId)` — CDC §4.3 le profil est scopé enfant.
typedef TutorProfileKey = ({String studentId, String tutorId});

final tutorProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<TutorProfileViewModel, TutorProfileState, TutorProfileKey>(
  (ref, key) => TutorProfileViewModel(ref.watch(getTutorProfileProvider))
    ..load(studentId: key.studentId, tutorId: key.tutorId),
);
