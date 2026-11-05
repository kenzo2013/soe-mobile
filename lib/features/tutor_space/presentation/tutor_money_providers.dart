import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../data/tutor_models.dart';
import '../data/tutor_money_api.dart';
import '../data/tutor_money_models.dart';

/// Reads of the tutor's money and documents (REP-19 history, REP-20, REP-21 text, COM-08).
final tutorMoneyApiProvider =
    Provider<TutorMoneyApi>((ref) => TutorMoneyApi(ref.watch(dioV2Provider)));

/// A page of the pay statements.
final tutorStatementsProvider = FutureProvider.autoDispose
    .family<Paginated<TutorStatement>, int>(
        (ref, page) => ref.watch(tutorMoneyApiProvider).statements(page: page));

final tutorPayoutMethodsProvider =
    FutureProvider.autoDispose<List<TutorPayoutMethod>>(
        (ref) => ref.watch(tutorMoneyApiProvider).payoutMethods());

/// A contract with its text in a language (fr or en).
final tutorContractTextProvider = FutureProvider.autoDispose
    .family<TutorContract, ({int id, String lang})>((ref, key) =>
        ref.watch(tutorMoneyApiProvider).contract(key.id, key.lang));

final tutorAmendmentsProvider = FutureProvider.autoDispose
    .family<List<TutorAmendment>, int>((ref, contractId) =>
        ref.watch(tutorMoneyApiProvider).amendments(contractId));

/// An amendment with its text in a language (fr or en).
final tutorAmendmentProvider = FutureProvider.autoDispose
    .family<TutorAmendment, ({int contractId, int id, String lang})>(
        (ref, key) => ref
            .watch(tutorMoneyApiProvider)
            .amendment(key.contractId, key.id, key.lang));
