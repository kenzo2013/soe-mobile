import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cameroon_cities_source.dart';
import '../data/cameroon_city.dart';
import 'core_providers.dart';

final cameroonCitiesSourceProvider = Provider<CameroonCitiesSource>(
    (ref) => CameroonCitiesSource(ref.watch(dioV2Provider)));

/// Every city of Cameroon, the main ones first (sign-up and address). Kept while the app
/// runs: the list barely changes.
final cameroonCitiesProvider = FutureProvider<List<CameroonCity>>(
    (ref) => ref.watch(cameroonCitiesSourceProvider).fetch());
