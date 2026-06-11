import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soe/features/tutor/data/dtos/tutor_session_dto.dart';
import 'package:soe/features/tutor/domain/entities/tutor_dashboard.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('TutorSessionDto · combinaison date + heures', () {
    test('recombine `date` (jour) et `start_at`/`end_at` (heures 2000)', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'date': '2026-05-14',
        'start_at': '2000-01-01T10:00:00',
        'end_at': '2000-01-01T12:00:00',
        'subject': 'Maths',
      });
      // startDate dérive de startAt recombiné (jour réel + heure).
      expect(dto.startDate, DateTime.parse('2026-05-14T10:00:00'));
      final e = dto.toEntity();
      expect(e.timeRange, '10:00 – 12:00');
    });

    test('sans `date` → utilise directement start_at/end_at', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'start_at': '2026-05-14T10:00:00',
        'end_at': '2026-05-14T11:30:00',
      });
      expect(dto.toEntity().timeRange, '10:00 – 11:30');
    });

    test('date présente mais heure non parsable → renvoie le jour brut', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'date': '2026-05-14',
        'start_at': 'pas-une-heure',
      });
      // _combineDateTime renvoie `d` (le jour) car l'heure n'est pas parsable.
      expect(dto.startAt, '2026-05-14');
      // '2026-05-14' reste une date valide → minuit local.
      expect(dto.startDate, DateTime.parse('2026-05-14'));
    });

    test('aucune date ni heure → startAt null, timeRange vide', () {
      final dto = TutorSessionDto.fromJson(const {'id': 's1'});
      expect(dto.startAt, isNull);
      expect(dto.startDate, isNull);
      expect(dto.toEntity().timeRange, '');
    });
  });

  group('TutorSessionDto · student imbriqué', () {
    test('student map first_name + last_name', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'student': {'first_name': 'Junior', 'last_name': 'Kamga'},
      });
      expect(dto.student, 'Junior Kamga');
    });

    test('student map sans prénom/nom → name', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'student': {'name': 'Junior K.'},
      });
      expect(dto.student, 'Junior K.');
    });

    test('fallback sur `child` puis `student_name`', () {
      final dtoChild = TutorSessionDto.fromJson(const {
        'id': 's1',
        'child': {'first_name': 'Ada'},
      });
      expect(dtoChild.student, 'Ada');

      final dtoName = TutorSessionDto.fromJson(const {
        'id': 's1',
        'student_name': 'Marc',
      });
      expect(dtoName.student, 'Marc');
    });

    test('student chaîne brute', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'student': 'Direct String',
      });
      expect(dto.student, 'Direct String');
    });
  });

  group('TutorSessionDto · subject imbriqué', () {
    test('subject map → name', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'subject': {'name': 'Physique'},
      });
      expect(dto.subject, 'Physique');
    });

    test('subjects liste de maps → premier name', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'subjects': [
          {'name': 'Chimie'},
          {'name': 'Bio'},
        ],
      });
      expect(dto.subject, 'Chimie');
    });

    test('subjects liste de strings → premier', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'subjects': ['Anglais', 'Espagnol'],
      });
      expect(dto.subject, 'Anglais');
    });
  });

  group('TutorSessionDto · editable / report (clés avec ?)', () {
    test('`editable?` = true', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'editable?': true,
      });
      expect(dto.editable, isTrue);
    });

    test('`editable` (sans ?) chaîne "true"', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'editable': 'true',
      });
      expect(dto.editable, isTrue);
    });

    test('`report_available?` explicite gagne sur la dérivation', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'report_available?': true,
        'status': 'pending',
      });
      expect(dto.reportAvailable, isTrue);
    });

    test('reportAvailable dérivé : status approved + non soumis → true', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'status': 'approved',
        'has_report': false,
      });
      expect(dto.reportAvailable, isTrue);
    });

    test('reportAvailable dérivé : approved mais has_report=true → false', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'status': 'approved',
        'has_report': true,
      });
      expect(dto.reportAvailable, isFalse);
      expect(dto.reportSubmitted, isTrue);
    });

    test('reportSubmitted via report_submitted', () {
      final dto = TutorSessionDto.fromJson(const {
        'id': 's1',
        'report_submitted': true,
      });
      expect(dto.reportSubmitted, isTrue);
    });

    test('toEntity propage editable/report flags', () {
      final e = TutorSessionDto.fromJson(const {
        'id': 's1',
        'editable?': true,
        'report_available?': true,
        'has_report': true,
      }).toEntity();
      expect(e.editable, isTrue);
      expect(e.reportAvailable, isTrue);
      expect(e.reportSubmitted, isTrue);
    });
  });

  group('TutorSessionDetailDto', () {
    test('classe lue depuis school_class imbriqué dans student', () {
      final dto = TutorSessionDetailDto.fromJson(const {
        'id': 's1',
        'student': {
          'first_name': 'Junior',
          'school_class': {'name': '4ème'},
        },
        'date': '2026-05-14',
        'start_at': '2000-01-01T10:00:00',
        'end_at': '2000-01-01T12:00:00',
      });
      final e = dto.toEntity();
      expect(e.student, 'Junior');
      expect(e.classe, '4ème');
      expect(e.timeRange, '10:00 – 12:00');
      expect(e.dateLine, contains('·'));
    });

    test('classe via school_class abbr si pas de name', () {
      final dto = TutorSessionDetailDto.fromJson(const {
        'id': 's1',
        'school_class': {'abbr': '4e'},
      });
      expect(dto.toEntity().classe, '4e');
    });

    test('reservationRef via reservation.reference', () {
      final dto = TutorSessionDetailDto.fromJson(const {
        'id': 's1',
        'reservation': {'reference': 'RES-9'},
      });
      expect(dto.toEntity().reservationRef, 'RES-9');
    });

    test('reservationRef fallback reservation_ref', () {
      final dto = TutorSessionDetailDto.fromJson(const {
        'id': 's1',
        'reservation_ref': 'RES-X',
      });
      expect(dto.toEntity().reservationRef, 'RES-X');
    });

    test('editableReason / reportReason selon flags', () {
      final editable = TutorSessionDetailDto.fromJson(const {
        'id': 's1',
        'editable?': true,
        'report_available?': true,
      }).toEntity();
      expect(editable.editableReason, contains('Oui'));
      expect(editable.reportReason, contains('à soumettre'));

      final locked = TutorSessionDetailDto.fromJson(const {
        'id': 's2',
        'editable?': false,
        'report_available?': false,
      }).toEntity();
      expect(locked.editableReason, contains('Non'));
      expect(locked.reportReason, contains('après la séance'));
    });
  });

  group('groupSessionsByDay · libellés relatifs', () {
    test('séance sans date → groupe "Planifiées"', () {
      final groups = groupSessionsByDay([
        TutorSessionDto.fromJson(const {'id': 's1', 'subject': 'Maths'}),
      ]);
      expect(groups, hasLength(1));
      expect(groups.single.day, 'Planifiées');
      expect(groups.single.items, hasLength(1));
    });

    test('aujourd\'hui / demain / hier préfixés', () {
      String iso(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final now = DateTime.now();
      final today = now;
      final tomorrow = now.add(const Duration(days: 1));
      final yesterday = now.subtract(const Duration(days: 1));

      final groups = groupSessionsByDay([
        TutorSessionDto.fromJson({
          'id': 's1',
          'start_at': '${iso(today)}T10:00:00',
        }),
        TutorSessionDto.fromJson({
          'id': 's2',
          'start_at': '${iso(tomorrow)}T10:00:00',
        }),
        TutorSessionDto.fromJson({
          'id': 's3',
          'start_at': '${iso(yesterday)}T10:00:00',
        }),
      ]);
      final labels = groups.map((g) => g.day).toList();
      expect(labels.any((l) => l.startsWith("Aujourd'hui")), isTrue);
      expect(labels.any((l) => l.startsWith('Demain')), isTrue);
      expect(labels.any((l) => l.startsWith('Hier')), isTrue);
    });

    test('jour éloigné → libellé capitalisé sans préfixe', () {
      final groups = groupSessionsByDay([
        TutorSessionDto.fromJson(const {
          'id': 's1',
          'start_at': '2030-12-25T10:00:00',
        }),
      ]);
      final label = groups.single.day;
      // Pas de préfixe relatif et première lettre majuscule.
      expect(label.startsWith("Aujourd'hui"), isFalse);
      expect(label.startsWith('Demain'), isFalse);
      expect(label.startsWith('Hier'), isFalse);
      expect(label[0], label[0].toUpperCase());
    });

    test('liste vide → aucun groupe', () {
      expect(groupSessionsByDay(const []), isEmpty);
    });

    test('regroupe plusieurs séances du même jour dans l\'ordre d\'arrivée',
        () {
      final groups = groupSessionsByDay([
        TutorSessionDto.fromJson(const {
          'id': 's1',
          'start_at': '2030-12-25T10:00:00',
        }),
        TutorSessionDto.fromJson(const {
          'id': 's2',
          'start_at': '2030-12-25T15:00:00',
        }),
      ]);
      expect(groups, hasLength(1));
      expect(groups.single.items, hasLength(2));
    });
  });

  test('TutorSessionDto.toEntity mappe le status via parseSessionStatus', () {
    final pending = TutorSessionDto.fromJson(const {
      'id': 's1',
      'status': 'pending',
    }).toEntity();
    expect(pending.status, TutorSessionStatus.pending);

    final unknown = TutorSessionDto.fromJson(const {
      'id': 's2',
      'status': 'cancelled',
    }).toEntity();
    expect(unknown.status, TutorSessionStatus.unknown);
  });
}
