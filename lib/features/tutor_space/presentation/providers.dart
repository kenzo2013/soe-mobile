import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/tutor_api.dart';
import '../data/tutor_models.dart';

/// Reads of the tutor space v2 (lot 4). Each screen refreshes its provider after an action.
final tutorApiProvider =
    Provider<TutorApi>((ref) => TutorApi(ref.watch(dioV2Provider)));

final tutorHomeProvider = FutureProvider.autoDispose<TutorHome>(
    (ref) => ref.watch(tutorApiProvider).home());

/// The sessions of the week starting on the given Monday.
final tutorWeekSessionsProvider = FutureProvider.autoDispose
    .family<List<TutorSession>, DateTime>((ref, monday) => ref
        .watch(tutorApiProvider)
        .sessions(monday, monday.add(const Duration(days: 6))));

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
  ..invalidate(tutorWeekSessionsProvider);
