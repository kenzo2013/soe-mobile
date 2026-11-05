import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../data/tutor_offer_api.dart';
import '../data/tutor_offer_models.dart';
import '../data/tutor_student_models.dart';

/// Reads of the offers, applications and pupils (REP-10 to REP-14).
final tutorOfferApiProvider =
    Provider<TutorOfferApi>((ref) => TutorOfferApi(ref.watch(dioV2Provider)));

/// One page of the offers for some filters; the list screen watches pages 1..n (« load more »).
final tutorOffersPageProvider = FutureProvider.autoDispose
    .family<Paginated<TutorOffer>, TutorOfferPageKey>((ref, key) =>
        ref.watch(tutorOfferApiProvider).offers(key.filters, page: key.page));

final tutorOfferProvider = FutureProvider.autoDispose.family<TutorOffer, int>(
    (ref, id) => ref.watch(tutorOfferApiProvider).offer(id));

final tutorApplicationsProvider =
    FutureProvider.autoDispose<List<TutorApplication>>(
        (ref) => ref.watch(tutorOfferApiProvider).applications());

final tutorStudentsProvider = FutureProvider.autoDispose<List<TutorPupil>>(
    (ref) => ref.watch(tutorOfferApiProvider).students());

final tutorStudentProvider = FutureProvider.autoDispose
    .family<TutorPupilFile, int>(
        (ref, id) => ref.watch(tutorOfferApiProvider).student(id));

/// Refreshes what an application changes: the offer, the offers list, the applications.
void refreshTutorApplication(WidgetRef ref, int offerId) => ref
  ..invalidate(tutorOfferProvider(offerId))
  ..invalidate(tutorOffersPageProvider)
  ..invalidate(tutorApplicationsProvider);
