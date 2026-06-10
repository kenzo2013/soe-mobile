import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../references/data/school_meta_mapping.dart';
import '../../domain/entities/child.dart';

part 'child_dto.freezed.dart';
part 'child_dto.g.dart';

@freezed
abstract class ChildDto with _$ChildDto {
  const factory ChildDto({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @Default(0) int age,
    String? gender,
    @JsonKey(name: 'school_class') Map<String, dynamic>? schoolClass,
    String? section,
    String? education,
    @Default(<String>[]) List<String> subjects,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    Map<String, dynamic>? address,
  }) = _ChildDto;

  factory ChildDto.fromJson(Map<String, dynamic> json) =>
      _$ChildDtoFromJson(json);
}

extension ChildDtoX on ChildDto {
  Child toEntity() => Child(
        id: id,
        firstName: firstName,
        lastName: lastName,
        age: age,
        gender: _parseGender(gender),
        classe: schoolClass?['name']?.toString(),
        schoolClassId: schoolClass?['id']?.toString(),
        // L'API renvoie l'enum lowercase (ex: "francophone", "general") —
        // on remappe vers le libellé affichable ("Francophone", "Général")
        // pour qu'il matche les options des pickers.
        section: SchoolMetaMapping.sectionApiToLabel(section),
        education: SchoolMetaMapping.educationApiToLabel(education),
        subjects: subjects,
        avatarUrl: avatarUrl,
        address: _formatAddress(address),
      );
}

/// Payload pour POST/PATCH /parents/students.
/// `gender` = male|feminine.
/// `education` et `section` sont envoyés en libellé brut tel que choisi
/// par l'utilisateur dans les listes `data.educations` / `data.sections`
/// retournées par `GET /common/school_classes`.
/// `school_class_id` est obligatoire ("Classe doit exister") — UUID
/// récupéré via `data.school_classes[].id`.
Map<String, dynamic> childParamsToJson(ChildFormParams p) {
  // Convertit les libellés affichés vers les enums attendus en payload :
  // "Général"      → "general"
  // "Francophone"  → "francophone"
  final eduApi = SchoolMetaMapping.educationLabelToApi(p.education);
  final secApi = SchoolMetaMapping.sectionLabelToApi(p.section);
  return {
    'first_name': p.firstName,
    'last_name': p.lastName,
    'age': p.age,
    'gender': _serializeGender(p.gender),
    if (secApi != null && secApi.isNotEmpty) 'section': secApi,
    if (eduApi != null && eduApi.isNotEmpty) 'education': eduApi,
    if (p.schoolClassId != null && p.schoolClassId!.isNotEmpty)
      'school_class_id': p.schoolClassId,
    'address_attributes': {
      if (p.neighborhood != null && p.neighborhood!.isNotEmpty)
        'neighborhood': p.neighborhood,
      'city': p.city,
      'country': p.country,
      'country_code': p.countryCode,
    },
  };
}

ChildGender _parseGender(String? raw) => switch (raw) {
      'male' => ChildGender.male,
      'feminine' || 'female' => ChildGender.feminine,
      _ => ChildGender.unknown,
    };

String _serializeGender(ChildGender g) => switch (g) {
      ChildGender.male => 'male',
      ChildGender.feminine => 'feminine',
      ChildGender.unknown => 'male',
    };

String? _formatAddress(Map<String, dynamic>? a) {
  if (a == null) return null;
  final parts = [
    a['neighborhood'],
    a['city'],
  ].whereType<String>().where((s) => s.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}
