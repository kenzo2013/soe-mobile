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
    String? classe,
    String? section,
    @JsonKey(name: 'education_level') String? educationLevel,
    @Default(<String>[]) List<String> subjects,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? address,
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
        classe: classe,
        section: section,
        education: _parseEducation(educationLevel),
        subjects: subjects,
        avatarUrl: avatarUrl,
        address: address,
      );
}

Map<String, dynamic> childParamsToJson(ChildFormParams p) => {
      'first_name': p.firstName,
      'last_name': p.lastName,
      'age': p.age,
      'gender': _serializeGender(p.gender),
      if (p.classe != null) 'classe': p.classe,
      if (p.section != null) 'section': p.section,
      if (p.education != null) 'education_level': _serializeEducation(p.education!),
      if (p.subjects.isNotEmpty) 'subjects': p.subjects,
      if (p.address != null) 'address': p.address,
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
      'secondary' => ChildEducation.secondary,
      'general' => ChildEducation.general,
      'technical' => ChildEducation.technical,
      _ => ChildEducation.unknown,
    };

String _serializeEducation(ChildEducation e) => switch (e) {
      ChildEducation.primary => 'primary',
      ChildEducation.secondary => 'secondary',
      ChildEducation.general => 'general',
      ChildEducation.technical => 'technical',
      ChildEducation.unknown => 'general',
    };
