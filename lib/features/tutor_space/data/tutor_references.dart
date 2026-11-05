import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/data/school_catalog.dart';
import '../../../core/providers/core_providers.dart';

/// An item of a list of the forms (a subject, a school class).
class TutorReference {
  const TutorReference({required this.id, required this.name, this.abbr});

  factory TutorReference.fromJson(Map<String, dynamic> json) => TutorReference(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        abbr: json['abbr'] as String?,
      );

  final int id;
  final String name;
  final String? abbr;
}

/// A city and its suggested neighborhoods.
class TutorCity {
  const TutorCity({required this.name, required this.neighborhoods});

  factory TutorCity.fromJson(Map<String, dynamic> json) => TutorCity(
        name: json['name'] as String? ?? '',
        neighborhoods: (json['neighborhoods'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(),
      );

  final String name;
  final List<String> neighborhoods;
}

/// The lists of the forms (`GET /references` of the API v2): the classes × subjects referential
/// ([catalog], the single source of subjects), the plain class names of the offer filter, cities.
class TutorReferences {
  const TutorReferences({
    required this.schoolClasses,
    required this.cities,
    this.catalog = SchoolCatalog.empty,
  });

  factory TutorReferences.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    return TutorReferences(
      catalog: SchoolCatalog.fromJson(json),
      schoolClasses:
          list('school_classes').map(TutorReference.fromJson).toList(),
      cities: list('cities').map(TutorCity.fromJson).toList(),
    );
  }

  final List<TutorReference> schoolClasses;
  final List<TutorCity> cities;

  /// The classes × subjects referential (which subjects each class teaches).
  final SchoolCatalog catalog;
}

/// The references, read once while a screen needs them.
final tutorReferencesProvider =
    FutureProvider.autoDispose<TutorReferences>((ref) async {
  try {
    final r =
        await ref.watch(dioV2Provider).get<Map<String, dynamic>>('/references');
    return TutorReferences.fromJson(
        (r.data?['data'] as Map<String, dynamic>?) ?? const {});
  } on DioException catch (e) {
    throw ExceptionMapper.fromDio(e);
  }
});
