import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/references_remote_datasource.dart';
import '../data/repositories/references_repository_impl.dart';
import '../domain/entities/school_class.dart';
import '../domain/repositories/references_repository.dart';

final referencesRemoteDatasourceProvider =
    Provider<ReferencesRemoteDatasource>(
  (ref) => ReferencesRemoteDatasource(ref.watch(dioProvider)),
);

final referencesRepositoryProvider = Provider<ReferencesRepository>(
  (ref) =>
      ReferencesRepositoryImpl(ref.watch(referencesRemoteDatasourceProvider)),
);

/// Liste des classes scolaires (fetch lazy, cache pendant la session).
/// `null` si l'endpoint échoue → la UI peut afficher un état dégradé.
final schoolClassesProvider = FutureProvider<List<SchoolClass>>((ref) async {
  final r = await ref.read(referencesRepositoryProvider).listSchoolClasses();
  return r.valueOrNull ?? const [];
});
