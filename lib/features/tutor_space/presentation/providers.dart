import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/tutor_api.dart';
import '../data/tutor_models.dart';

/// Reads of the tutor space v2 (lot 4). Each screen refreshes its provider after an action.
final tutorApiProvider =
    Provider<TutorApi>((ref) => TutorApi(ref.watch(dioV2Provider)));

/// The last home read and when (kept for the app's life): shown « Hors connexion » when a
/// new read fails for lack of network.
final tutorHomeCacheProvider =
    StateProvider<({TutorHome home, DateTime at})?>((ref) => null);

final tutorHomeProvider = FutureProvider.autoDispose<TutorHome>((ref) async {
  final home = await ref.watch(tutorApiProvider).home();
  ref.read(tutorHomeCacheProvider.notifier).state =
      (home: home, at: DateTime.now());
  return home;
});

/// « Offres pour moi » on the home (the two first offers).
final tutorHomeOffersProvider =
    FutureProvider.autoDispose<List<TutorOfferPreview>>(
        (ref) => ref.watch(tutorApiProvider).homeOffers());

/// The sessions of a period (31 days at most) with an optional filter (REP-16).
typedef TutorSessionsQuery = ({DateTime from, DateTime to, String? filter});

final tutorSessionsProvider = FutureProvider.autoDispose
    .family<List<TutorSession>, TutorSessionsQuery>((ref, query) => ref
        .watch(tutorApiProvider)
        .sessions(query.from, query.to, filter: query.filter));

/// The sessions of the week starting on the given Monday.
final tutorWeekSessionsProvider = FutureProvider.autoDispose
    .family<List<TutorSession>, DateTime>((ref, monday) => ref
        .watch(tutorApiProvider)
        .sessions(monday, DateTime(monday.year, monday.month, monday.day + 6)));

/// A tick every 30 seconds: screens that watch it re-read « now » (the check-in window and the
/// report opening on time, without a pull to refresh).
final tutorClockProvider = StreamProvider.autoDispose<DateTime>((ref) =>
    Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now()));

final tutorSessionProvider = FutureProvider.autoDispose
    .family<TutorSessionDetail, int>(
        (ref, id) => ref.watch(tutorApiProvider).session(id));

/// The report of a session, null while none is sent.
final tutorReportProvider = FutureProvider.autoDispose
    .family<TutorReport?, int>(
        (ref, sessionId) => ref.watch(tutorApiProvider).report(sessionId));

final tutorProposalProvider = FutureProvider.autoDispose
    .family<TutorProposal, int>(
        (ref, id) => ref.watch(tutorApiProvider).proposal(id));

final tutorPlanningProvider = FutureProvider.autoDispose
    .family<TutorPlanning, int>(
        (ref, slotId) => ref.watch(tutorApiProvider).planning(slotId));

final tutorEarningsProvider = FutureProvider.autoDispose<TutorEarnings>(
    (ref) => ref.watch(tutorApiProvider).earnings());

final tutorContractsProvider = FutureProvider.autoDispose<List<TutorContract>>(
    (ref) => ref.watch(tutorApiProvider).contracts());

final tutorContractProvider = FutureProvider.autoDispose
    .family<TutorContract, int>(
        (ref, id) => ref.watch(tutorApiProvider).contract(id));

/// Refreshes what a session action changes: the session, its report, the home, the planning.
void refreshTutorSession(WidgetRef ref, int sessionId) => ref
  ..invalidate(tutorSessionProvider(sessionId))
  ..invalidate(tutorReportProvider(sessionId))
  ..invalidate(tutorHomeProvider)
  ..invalidate(tutorWeekSessionsProvider)
  ..invalidate(tutorSessionsProvider);

/// The private quality view (REP-22).
final tutorQualityProvider = FutureProvider.autoDispose<TutorQuality>(
    (ref) => ref.watch(tutorApiProvider).quality());
