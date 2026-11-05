/// Folds [text] for a search: lower case, accents removed (precomposed or combining marks),
/// every run of other characters (apostrophes ’ or ', hyphens, spaces) turned into one space.
/// « Ngaoundéré », « ngaoundere » and « NGAOUNDÉRÉ » give the same key; so do « Sa’a » and
/// « Sa'a ». Same rule as the server (CameroonCities.comparable).
String soeSearchKey(String text) {
  const from = 'àâäáãåèéêëìíîïòóôöõùúûüçñÿý';
  const to = 'aaaaaaeeeeiiiiooooouuuucnyy';
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    if (rune >= 0x300 && rune <= 0x36f)
      continue; // combining accent of a decomposed letter
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString().replaceAll(RegExp('[^a-z0-9]+'), ' ').trim();
}
