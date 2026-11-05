import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import 'tutor_file_section.dart';
import 'tutor_file_ui.dart';
import 'tutor_ui.dart';

/// The days of the week from Monday, as the API names them.
const tutorWeekDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

int _minutes(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

String _clock(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

/// The weekly grid of REP-06: three blocks a day (morning until 12:00, 12:00 to 16:00, then until
/// the evening), between the opening and closing times of the API. Touching blocks merge into one
/// range, so a day never holds more than the two ranges the API accepts.
class TutorAvailabilityGrid {
  TutorAvailabilityGrid(TutorAvailabilityContent content)
      : blocks = _blocks(content.opensAt, content.closesAt) {
    for (final day in tutorWeekDays) {
      final ranges = content.days[day] ?? const [];
      cells[day] = [
        for (final block in blocks)
          ranges.any(
              (r) => _minutes(r.from) < block.$2 && _minutes(r.to) > block.$1),
      ];
    }
    aligned = tutorWeekDays.every(
        (day) => _sameRanges(rangesOf(day), content.days[day] ?? const []));
  }

  /// The blocks of a day, in minutes from midnight.
  final List<(int, int)> blocks;

  /// Selected blocks by day.
  final Map<String, List<bool>> cells = {};

  /// Whether the grid shows exactly the ranges on file (else saving changes them).
  late final bool aligned;

  static List<(int, int)> _blocks(String opensAt, String closesAt) {
    final opens = _minutes(opensAt);
    final closes = _minutes(closesAt);
    final cuts = [
      opens,
      ...[12 * 60, 16 * 60].where((m) => m > opens && m < closes),
      closes,
    ];
    return [for (var i = 0; i < cuts.length - 1; i++) (cuts[i], cuts[i + 1])];
  }

  static bool _sameRanges(List<TutorTimeRange> a, List<TutorTimeRange> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String label(int block) =>
      '${_clock(blocks[block].$1)}\n${_clock(blocks[block].$2)}';

  void toggle(String day, int block) =>
      cells[day]![block] = !cells[day]![block];

  void copyMonday() {
    for (final day in tutorWeekDays.skip(1)) {
      cells[day] = [...cells['monday']!];
    }
  }

  void clear() {
    for (final day in tutorWeekDays) {
      cells[day] = List.filled(blocks.length, false);
    }
  }

  int get selectedCount =>
      cells.values.expand((c) => c).where((selected) => selected).length;

  /// The ranges of a day: touching selected blocks merged.
  List<TutorTimeRange> rangesOf(String day) {
    final ranges = <TutorTimeRange>[];
    int? start;
    final selected = cells[day]!;
    for (var i = 0; i <= blocks.length; i++) {
      final on = i < blocks.length && selected[i];
      if (on && start == null) start = blocks[i].$1;
      if (!on && start != null) {
        ranges.add(
            TutorTimeRange(from: _clock(start), to: _clock(blocks[i - 1].$2)));
        start = null;
      }
    }
    return ranges;
  }

  /// The `days` parameter of the API: every day, its ranges (an empty day clears it).
  Map<String, List<Map<String, String>>> toJson() => {
        for (final day in tutorWeekDays)
          day: rangesOf(day).map((r) => r.toJson()).toList(),
      };
}

/// REP-06 — the weekly availabilities: a grid of days and blocks, quick copy and clear; saving
/// replaces every day.
class TutorFileAvailabilityForm extends ConsumerStatefulWidget {
  const TutorFileAvailabilityForm({super.key, required this.data});

  final TutorFileSection data;

  @override
  ConsumerState<TutorFileAvailabilityForm> createState() =>
      _TutorFileAvailabilityFormState();
}

class _TutorFileAvailabilityFormState
    extends ConsumerState<TutorFileAvailabilityForm> with TutorFileSaving {
  late final TutorAvailabilityContent _onFile = widget.data.availability;
  late final TutorAvailabilityGrid _grid = TutorAvailabilityGrid(_onFile);
  bool _changed = false;

  void _update(VoidCallback change) => setState(() {
        change();
        _changed = true;
      });

  Future<void> _save() async {
    final tr = Translations.of(context).tutorSpace.file;
    final hasRanges = _onFile.days.values.any((r) => r.isNotEmpty);
    if (!_changed && hasRanges) {
      continueTutorFile(context, widget.data.section);
      return;
    }
    final ok = await runSave(
      widget.data.section,
      (api) => api.updateSection(widget.data.section, {'days': _grid.toJson()}),
      success: tr.saved,
    );
    if (ok && mounted) continueTutorFile(context, widget.data.section);
  }

  String _onFileText(BuildContext context) => [
        for (final day in tutorWeekDays)
          for (final r in _onFile.days[day] ?? const <TutorTimeRange>[])
            '${TutorFormat.weekday(context, day)} ${r.from}–${r.to}',
      ].join(', ');

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.file;
    final trA = tr.availability;
    final count = _grid.selectedCount;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TutorFileSectionHeader(
                data: widget.data,
                intro: tutorFileIntro(context, widget.data.section)),
            Wrap(spacing: 8, runSpacing: 8, children: [
              SoeButton(
                label: trA.copyMonday,
                variant: SoeButtonVariant.outline,
                size: SoeButtonSize.sm,
                onPressed: () => _update(_grid.copyMonday),
              ),
              SoeButton(
                label: trA.clear,
                variant: SoeButtonVariant.outline,
                size: SoeButtonSize.sm,
                onPressed: () => _update(_grid.clear),
              ),
            ]),
            const SizedBox(height: 12),
            if (!_grid.aligned && !_changed) ...[
              SoeAlert(
                  title: trA.week,
                  body: trA.current(ranges: _onFileText(context)),
                  tone: SoeAlertTone.info),
              const SizedBox(height: 12),
            ],
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(trA.week,
                              style: AppTypography.h3
                                  .copyWith(color: AppPalette.teal800))),
                      Text(trA.rangesCount(n: count),
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    ]),
                    const SizedBox(height: 12),
                    _Grid(
                        grid: _grid,
                        onToggle: (day, block) =>
                            _update(() => _grid.toggle(day, block))),
                    const SizedBox(height: 10),
                    Text(trA.tapHint,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]),
            ),
          ],
        ),
      ),
      TutorBottomBar(
        hint: count == 0 ? trA.hint : null,
        child: SoeButton(
          label: tr.saveContinue,
          fullWidth: true,
          loading: busy,
          onPressed: busy || count == 0 ? null : () => unawaited(_save()),
        ),
      ),
    ]);
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.grid, required this.onToggle});

  final TutorAvailabilityGrid grid;
  final void Function(String day, int block) onToggle;

  @override
  Widget build(BuildContext context) {
    final letters =
        Translations.of(context).tutorSpace.file.availability.letters;
    String letter(String day) => switch (day) {
          'monday' => letters.monday,
          'tuesday' => letters.tuesday,
          'wednesday' => letters.wednesday,
          'thursday' => letters.thursday,
          'friday' => letters.friday,
          'saturday' => letters.saturday,
          _ => letters.sunday,
        };
    return Column(children: [
      Row(children: [
        const SizedBox(width: 48),
        for (final day in tutorWeekDays)
          Expanded(
            child: Text(letter(day),
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(color: AppPalette.text2)),
          ),
      ]),
      const SizedBox(height: 6),
      for (var block = 0; block < grid.blocks.length; block++)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            SizedBox(
              width: 48,
              child: Text(grid.label(block),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ),
            for (final day in tutorWeekDays)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _Cell(
                    selected: grid.cells[day]![block],
                    label:
                        '${TutorFormat.weekday(context, day)} ${grid.label(block).replaceAll('\n', '–')}',
                    onTap: () => onToggle(day, block),
                  ),
                ),
              ),
          ]),
        ),
    ]);
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
      {required this.selected, required this.label, required this.onTap});

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        selected: selected,
        button: true,
        child: Material(
          color: selected ? AppPalette.teal500 : AppPalette.surfaceSoft,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: selected ? null : Border.all(color: AppPalette.n300),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: AppPalette.white)
                  : null,
            ),
          ),
        ),
      );
}
