import 'search_key.dart';

/// A city of Cameroon offered by the sign-up and the address (API v2 `City`): [name] is the
/// value sent as `city`; the [major] ones come first, with their [region]. [searchKey] is
/// folded once ([soeSearchKey]) so the picker's search compares names and regions cheaply.
class CameroonCity {
  CameroonCity({required this.name, this.major = false, this.region})
      : searchKey = soeSearchKey('$name ${region ?? ''}');

  factory CameroonCity.fromJson(Map<String, dynamic> json) => CameroonCity(
        name: json['name'] as String? ?? '',
        major: json['major'] as bool? ?? false,
        region: json['region'] as String?,
      );

  final String name;
  final bool major;
  final String? region;
  final String searchKey;
}
