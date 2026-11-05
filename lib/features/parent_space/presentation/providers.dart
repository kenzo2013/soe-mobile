import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/parent_api.dart';
import '../data/parent_files.dart';
import '../data/parent_flow_models.dart';
import '../data/parent_models.dart';

/// Reads of the parent space v2 (lot 3). Each screen refreshes its provider after an action.
final parentApiProvider =
    Provider<ParentApi>((ref) => ParentApi(ref.watch(dioV2Provider)));

final parentHomeProvider = FutureProvider.autoDispose<ParentHome>(
    (ref) => ref.watch(parentApiProvider).home());

final parentChildrenProvider = FutureProvider.autoDispose<List<ParentChild>>(
    (ref) => ref.watch(parentApiProvider).children());

final parentChildProvider = FutureProvider.autoDispose.family<ParentChild, int>(
    (ref, id) => ref.watch(parentApiProvider).child(id));

/// The sessions of the week starting on the given Monday.
final parentWeekSessionsProvider = FutureProvider.autoDispose
    .family<List<ParentSession>, DateTime>((ref, monday) => ref
        .watch(parentApiProvider)
        .sessions(monday, monday.add(const Duration(days: 6))));

final parentSessionProvider = FutureProvider.autoDispose
    .family<ParentSessionDetail, int>(
        (ref, id) => ref.watch(parentApiProvider).session(id));

final parentReportProvider = FutureProvider.autoDispose
    .family<ParentReport, int>(
        (ref, sessionId) => ref.watch(parentApiProvider).report(sessionId));

final parentInvoicesProvider = FutureProvider.autoDispose<List<ParentInvoice>>(
    (ref) => ref.watch(parentApiProvider).invoices());

final parentPaymentsProvider = FutureProvider.autoDispose<List<ParentPayment>>(
    (ref) => ref.watch(parentApiProvider).payments());

final parentPaymentProvider = FutureProvider.autoDispose
    .family<ParentPayment, int>(
        (ref, id) => ref.watch(parentApiProvider).payment(id));

final parentRequestsProvider = FutureProvider.autoDispose<List<ParentRequest>>(
    (ref) => ref.watch(parentApiProvider).requests());

final parentRequestProvider = FutureProvider.autoDispose
    .family<ParentRequest, int>(
        (ref, id) => ref.watch(parentApiProvider).request(id));

final parentQuoteProvider = FutureProvider.autoDispose.family<ParentQuote, int>(
    (ref, requestId) => ref.watch(parentApiProvider).quote(requestId));

final parentContractProvider = FutureProvider.autoDispose
    .family<ParentContract, int>(
        (ref, id) => ref.watch(parentApiProvider).contract(id));

final parentPlanningProvider = FutureProvider.autoDispose
    .family<List<ParentPlanningSlot>, int>(
        (ref, requestId) => ref.watch(parentApiProvider).planning(requestId));

/// Opens the PDFs (overridden in the tests).
final parentFilesProvider = Provider<ParentFiles>((ref) => const ParentFiles());

/// The lists of the forms: kept for the session (they rarely change).
final parentReferencesProvider = FutureProvider<ParentReferences>(
    (ref) => ref.watch(parentApiProvider).references());

/// The sessions of a child over the last two months and the next one (PAR-03).
final parentChildSessionsProvider = FutureProvider.autoDispose
    .family<List<ParentSession>, int>((ref, childId) {
  final today = DateTime.now();
  final from = DateTime(today.year, today.month, today.day)
      .subtract(const Duration(days: 31));
  return ref
      .watch(parentApiProvider)
      .childSessions(childId, from, from.add(const Duration(days: 62)));
});

final parentDraftProvider = FutureProvider.autoDispose<ParentRequestDraft>(
    (ref) => ref.watch(parentApiProvider).draft());

final parentRequestDetailProvider = FutureProvider.autoDispose
    .family<ParentRequestDetail, int>(
        (ref, id) => ref.watch(parentApiProvider).requestDetail(id));

final parentTutorsProvider = FutureProvider.autoDispose
    .family<List<ParentTutorProfile>, int>(
        (ref, requestId) => ref.watch(parentApiProvider).tutors(requestId));

final parentTutorReviewsProvider = FutureProvider.autoDispose
    .family<List<ParentTutorReview>, ({int requestId, int tutorId})>(
        (ref, key) => ref
            .watch(parentApiProvider)
            .tutorReviews(key.requestId, key.tutorId));

final parentContractsProvider =
    FutureProvider.autoDispose<List<ParentContract>>(
        (ref) => ref.watch(parentApiProvider).contracts());

final parentAmendmentsProvider = FutureProvider.autoDispose
    .family<List<ParentAmendment>, int>((ref, contractId) =>
        ref.watch(parentApiProvider).amendments(contractId));

final parentAmendmentProvider = FutureProvider.autoDispose
    .family<ParentAmendment, ({int contractId, int id})>((ref, key) =>
        ref.watch(parentApiProvider).amendment(key.contractId, key.id));

final parentReviewsProvider = FutureProvider.autoDispose<List<ParentReview>>(
    (ref) => ref.watch(parentApiProvider).reviews());

final parentReviewTutorsProvider =
    FutureProvider.autoDispose<List<ParentReviewTutor>>(
        (ref) => ref.watch(parentApiProvider).reviewTutors());

final parentCoParentsProvider =
    FutureProvider.autoDispose<List<ParentCoParent>>(
        (ref) => ref.watch(parentApiProvider).coParents());

final parentInvitationsProvider =
    FutureProvider.autoDispose<List<ParentInvitation>>(
        (ref) => ref.watch(parentApiProvider).invitations());

/// A short-lived URL of a child's photo (null without photo).
final parentChildPhotoProvider = FutureProvider.autoDispose
    .family<String?, int>(
        (ref, childId) => ref.watch(parentApiProvider).childPhotoUrl(childId));
