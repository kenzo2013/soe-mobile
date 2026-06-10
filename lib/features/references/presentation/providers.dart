import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/references_remote_datasource.dart';
import '../data/repositories/references_repository_impl.dart';
import '../domain/entities/school_class.dart';
import '../domain/entities/subject.dart';
import '../domain/repositories/references_repository.dart';

final referencesRemoteDatasourceProvider = Provider<ReferencesRemoteDatasource>(
  (ref) => ReferencesRemoteDatasource(ref.watch(dioProvider)),
);

final referencesRepositoryProvider = Provider<ReferencesRepository>(
  (ref) =>
      ReferencesRepositoryImpl(ref.watch(referencesRemoteDatasourceProvider)),
);

/// Clé du family : couple (education, section) pour filtrer côté serveur.
typedef SchoolClassFilter = ({String? education, String? section});

/// Charge les classes filtrées par niveau + section. Cache par clé pendant
/// la session — un changement de filtre déclenche un fetch.
final schoolClassesProvider = FutureProvider.autoDispose
    .family<SchoolClassReferences, SchoolClassFilter>((ref, filter) async {
  final r = await ref.read(referencesRepositoryProvider).listSchoolClasses(
        education: filter.education,
        section: filter.section,
      );
  return r.valueOrNull ?? SchoolClassReferences.empty;
});

/// Catalogue des matières (`GET /common/subjects`). Mis en cache pour la
/// session (autoDispose : rechargé quand plus aucun écran ne l'observe).
final subjectsProvider = FutureProvider.autoDispose<List<Subject>>((ref) async {
  final r = await ref.read(referencesRepositoryProvider).listSubjects();
  return r.valueOrNull ?? const [];
});
