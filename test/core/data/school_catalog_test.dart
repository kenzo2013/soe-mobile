import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/school_catalog.dart';

Map<String, dynamic> _subject(int id, String name,
        {String? nameEn, bool active = true}) =>
    {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'abbr': null,
      'key': null,
      'category': null,
      'active': active
    };

Map<String, dynamic> _class(int id, String name,
        {String subsystem = 'francophone',
        String track = 'general',
        String cycle = 'upper_secondary',
        bool active = true,
        List<int> subjects = const [],
        String? nameEn}) =>
    {
      'id': id,
      'key': 'k$id',
      'name': name,
      'name_en': nameEn,
      'abbr': null,
      'level': null,
      'subsystem': subsystem,
      'track': track,
      'cycle': cycle,
      'active': active,
      'subjects': [
        for (final s in subjects) {'id': s, 'status': 'core', 'verified': true}
      ],
    };

final _json = {
  'subjects': [
    _subject(1, 'Mathématiques', nameEn: 'Mathematics'),
    _subject(2, 'Philosophie', nameEn: 'Philosophy'),
    _subject(3, 'Physique'),
    _subject(4, 'Latin', active: false),
  ],
  'school_classes': <Object>[],
  'classes': [
    _class(10, 'Terminale C', subjects: [1, 2, 3]),
    _class(11, 'Sixième (6e)', cycle: 'lower_secondary', subjects: [1]),
    _class(12, 'Troisième Latin',
        cycle: 'lower_secondary', active: false, subjects: [1, 4]),
    _class(13, 'Form 1',
        subsystem: 'anglophone', cycle: 'lower_secondary', nameEn: 'Form 1'),
    _class(14, 'Seconde F3', track: 'technic'),
  ],
};

void main() {
  final catalog = SchoolCatalog.fromJson(_json);

  test(
      'reads classes with the subjects taught, and subjects with their English name',
      () {
    expect(catalog.classes.map((c) => c.id), [10, 11, 12, 13, 14]);
    expect(catalog.classById(10)!.subjectIds, [1, 2, 3]);
    expect(catalog.subjectById(1)!.label('en'), 'Mathematics');
    expect(catalog.subjectById(3)!.label('en'), 'Physique',
        reason: 'no English name: the French one');
    expect(catalog.subjectById(1)!.label('fr'), 'Mathématiques');
  });

  test('offers active classes of the sub-system, plus the one already chosen',
      () {
    expect(catalog.offeredClasses(subsystem: 'francophone').map((c) => c.id),
        [10, 11, 14]);
    expect(
        catalog
            .offeredClasses(subsystem: 'francophone', currentId: 12)
            .map((c) => c.id),
        [10, 11, 12, 14]);
    expect(catalog.offeredClasses().map((c) => c.id), [10, 11, 13, 14]);
  });

  test(
      'a class offers its subjects; a class listing none offers every active subject',
      () {
    expect(catalog.subjectsFor(11).map((s) => s.id), [1]);
    expect(catalog.subjectsFor(13).map((s) => s.id), [1, 2, 3]);
    expect(catalog.subjectsFor(null).map((s) => s.id), [1, 2, 3]);
    expect(catalog.subjectsFor(11, keep: [2]).map((s) => s.id), [1, 2],
        reason: 'a subject already on a sent request stays');
    expect(catalog.teaches(11, 2), isFalse);
    expect(catalog.teaches(13, 2), isTrue);
  });

  test('groups: technical together, else by cycle', () {
    expect(catalog.classById(14)!.group, 'technical');
    expect(catalog.classById(11)!.group, 'lower_secondary');
  });

  test('an older server (school_classes only): every class, any subject', () {
    final legacy = SchoolCatalog.fromJson({
      'subjects': [_subject(1, 'Mathématiques')],
      'school_classes': [
        {
          'id': 5,
          'name': 'Sixième',
          'abbr': '6e',
          'education': 'general',
          'section': 'francophone'
        }
      ],
    });
    expect(legacy.classes.single.subsystem, 'francophone');
    expect(legacy.subjectsFor(5).map((s) => s.id), [1]);
    expect(legacy.teaches(5, 99), isTrue);
  });
}
