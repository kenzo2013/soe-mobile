import 'package:freezed_annotation/freezed_annotation.dart';

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
        section: section,
        education: _parseEducation(education),
        subjects: subjects,
        avatarUrl: avatarUrl,
        address: _formatAddress(address),
      );
}

/// Payload pour POST/PATCH /parents/students.
/// CDC §11.5 : valeurs `gender` = male|feminine, `education` = general|technic|primary.
/// CDC §11.6 : avec photo, utiliser multipart/form-data (champ `student[photo]`).
/// 422 observe : `city` est obligatoire dans address_attributes ;
/// `class_name` est rejete (l'API attend un school_class_id UUID — TODO
/// quand l'endpoint /references/school_classes sera disponible §7.7).
Map<String, dynamic> childParamsToJson(ChildFormParams p) => {
      'first_name': p.firstName,
      'last_name': p.lastName,
      'age': p.age,
      'gender': _serializeGender(p.gender),
      if (p.section != null) 'section': p.section,
      if (p.education != null) 'education': _serializeEducation(p.education!),
      'address_attributes': {
        if (p.neighborhood != null && p.neighborhood!.isNotEmpty)
          'neighborhood': p.neighborhood,
        'city': p.city,
        'country': p.country,
        'country_code': p.countryCode,
      },
    };

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

ChildEducation _parseEducation(String? raw) => switch (raw) {
      'primary' => ChildEducation.primary,
      'general' => ChildEducation.general,
      'technic' => ChildEducation.technic,
      _ => ChildEducation.unknown,
    };

String _serializeEducation(ChildEducation e) => switch (e) {
      ChildEducation.primary => 'primary',
      ChildEducation.general => 'general',
      ChildEducation.technic => 'technic',
      ChildEducation.unknown => 'general',
    };

String? _formatAddress(Map<String, dynamic>? a) {
  if (a == null) return null;
  final parts = [
    a['neighborhood'],
    a['city'],
  ].whereType<String>().where((s) => s.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}
