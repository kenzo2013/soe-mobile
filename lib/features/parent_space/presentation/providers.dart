import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/parent_api.dart';
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
