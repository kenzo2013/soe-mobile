import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/cameroon_city.dart';
import 'package:soe/core/data/search_key.dart';

void main() {
  test('folds case, precomposed and decomposed accents, like the server', () {
    expect(soeSearchKey('NGAOUNDÉRÉ'), 'ngaoundere');
    expect(soeSearchKey('Yaoundé'), 'yaounde'); // e + combining acute
    expect(soeSearchKey('  Limbé  '), 'limbe');
  });

  test('turns apostrophes, hyphens and spaces into one space', () {
    expect(soeSearchKey('Sa’a'), soeSearchKey("Sa'a"));
    expect(soeSearchKey("Sa'a"), 'sa a');
    expect(soeSearchKey('Biyem-Assi'), 'biyem assi');
  });

  test('a city is found by its name or its region, folded once', () {
    final city =
        CameroonCity(name: 'Ngaoundéré', major: true, region: 'Adamaoua');

    expect(city.searchKey, 'ngaoundere adamaoua');
    expect(city.searchKey.contains(soeSearchKey('NGAOUNDERE')), isTrue);
    expect(city.searchKey.contains(soeSearchKey('adamaoua')), isTrue);
  });
}
