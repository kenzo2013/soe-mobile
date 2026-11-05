/// A city of Cameroon offered by the sign-up and the address (API v2 `City`): [name] is the
/// value sent as `city`; the [major] ones come first, with their [region].
class CameroonCity {
  const CameroonCity({required this.name, this.major = false, this.region});

  factory CameroonCity.fromJson(Map<String, dynamic> json) => CameroonCity(
        name: json['name'] as String? ?? '',
        major: json['major'] as bool? ?? false,
        region: json['region'] as String?,
      );

  final String name;
  final bool major;
  final String? region;

  /// Lower case, without accents: « yaounde » finds « Yaoundé ».
  static String comparable(String text) {
    const from = 'àâäáãèéêëìíîïòóôöõùúûüçñÿ';
    const to = 'aaaaaeeeeiiiiooooouuuucny';
    final lower = text.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString();
  }

  bool matches(String query) =>
      query.trim().isEmpty ||
      comparable(name).contains(comparable(query)) ||
      comparable(region ?? '').contains(comparable(query));
}
