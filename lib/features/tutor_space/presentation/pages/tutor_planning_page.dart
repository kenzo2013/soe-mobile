import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_pill_switch.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';

/// The colour of a session state (planning dots, the list's bar, the legend).
Color tutorStateColor(String state) => switch (state) {
      'to_report' => AppPalette.warning,
      'report_sent' => AppPalette.info,
      'approved' => AppPalette.success,
      'disputed' => AppPalette.danger,
      'suspended' || 'cancelled' => AppPalette.n500,
      _ => AppPalette.teal800,
    };

/// REP-16 — the planning: filters (à venir, PV à rédiger, contestées, suspendues), a week or a
/// month with a dot on the days that have sessions, the sessions of the period, the legend.
class TutorPlanningPage extends ConsumerStatefulWidget {
  const TutorPlanningPage({super.key});

  @override
  ConsumerState<TutorPlanningPage> createState() => _TutorPlanningPageState();
}

class _TutorPlanningPageState extends ConsumerState<TutorPlanningPage> {
  /// The API filters, null for « Toutes ».
  static const _filters = [
    null,
    'upcoming',
    'to_report',
    'disputed',
    'suspended'
  ];

  late DateTime _anchor = _mondayOf(DateTime.now());
  bool _month = false;
  String? _filter;

  static DateTime _mondayOf(DateTime day) =>
      DateTime(day.year, day.month, day.day - (day.weekday - 1));

  TutorSessionsQuery get _query => _month
      ? (
          from: DateTime(_anchor.year, _anchor.month),
          to: DateTime(_anchor.year, _anchor.month + 1, 0),
          filter: _filter
        )
      : (
          from: _anchor,
          to: DateTime(_anchor.year, _anchor.month, _anchor.day + 6),
          filter: _filter
        );

  void _move(int direction) => setState(() => _anchor = _month
      ? DateTime(_anchor.year, _anchor.month + direction)
      : DateTime(_anchor.year, _anchor.month, _anchor.day + 7 * direction));

  void _switch(bool month) => setState(() {
        _month = month;
        _anchor = month
            ? DateTime(_anchor.year, _anchor.month)
            : _mondayOf(_anchor.month == DateTime.now().month &&
                    _anchor.year == DateTime.now().year
                ? DateTime.now()
                : _anchor);
      });

  String _filterLabel(TranslationsTutorSpacePlanningFr tr, String? filter) =>
      switch (filter) {
        'upcoming' => tr.filters.upcoming,
        'to_report' => tr.filters.toReport,
        'disputed' => tr.filters.disputed,
        'suspended' => tr.filters.suspended,
        _ => tr.filters.all,
      };

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.planning;
    final query = _query;
    final value = ref.watch(tutorSessionsProvider(query));
    final sessions = value.valueOrNull ?? const <TutorSession>[];
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: TabBody(
        title: Translations.of(context).shell.tutor.planning,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(tutorSessionsProvider(query).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(tr.title,
                  style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
              Text(tr.subtitle,
                  style: AppTypography.body.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final filter in _filters)
                  SoeChip(
                    label: _filterLabel(tr, filter),
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
              ]),
              const SizedBox(height: 16),
              SoeCard(
                padding: EdgeInsets.zero,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _periodHeader(tr),
                      const Divider(height: 1, color: AppPalette.n300),
                      _calendar(sessions),
                      const Divider(height: 1, color: AppPalette.n300),
                      value.when(
                        data: (sessions) => sessions.isEmpty
                            ? _empty(tr)
                            : Column(children: [
                                for (final session in sessions)
                                  _SessionRow(session: session),
                              ]),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            SoeSkeleton(height: 56),
                            SizedBox(height: 12),
                            SoeSkeleton(height: 56),
                          ]),
                        ),
                        error: (error, _) => ErrorView(
                            failure: asFailure(error),
                            onRetry: () =>
                                ref.invalidate(tutorSessionsProvider(query))),
                      ),
                      if (_filter == 'disputed')
                        _footer(Text(tr.disputedNote,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)))
                      else
                        _footer(_Legend(tr: tr.legend)),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(Widget child) => Container(
        color: AppPalette.surfaceSoft,
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Widget _periodHeader(TranslationsTutorSpacePlanningFr tr) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(
              tooltip: tr.previous,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _move(-1),
            ),
            IconButton(
              tooltip: tr.next,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _move(1),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                  _month
                      ? TutorFormat.month(context, _anchor)
                      : tr.weekOf(
                          date: TutorFormat.dayLong(context, _anchor)
                              .split(' ')
                              .skip(1)
                              .join(' ')),
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
            ),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SoePillSwitch<bool>(
              options: [
                (value: false, label: tr.views.week),
                (value: true, label: tr.views.month),
              ],
              selected: _month,
              onChanged: _switch,
            ),
          ),
        ]),
      );

  Widget _calendar(List<TutorSession> sessions) {
    final today = DateTime.now();
    final busy = {
      for (final s in sessions) DateTime(s.date.year, s.date.month, s.date.day)
    };
    Widget cell(DateTime day, {bool faded = false}) {
      final isToday = day.year == today.year &&
          day.month == today.month &&
          day.day == today.day;
      return SizedBox(
        height: 44,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: isToday ? AppPalette.teal800 : null,
                shape: BoxShape.circle),
            child: Text('${day.day}',
                style: AppTypography.label.copyWith(
                    color: isToday
                        ? AppPalette.white
                        : (faded ? AppPalette.text3 : AppPalette.text))),
          ),
          const SizedBox(height: 2),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: busy.contains(day) && !faded
                    ? AppPalette.teal800
                    : Colors.transparent),
          ),
        ]),
      );
    }

    final monday = _month ? _mondayOf(_anchor) : _anchor;
    final header = Row(children: [
      for (var i = 0; i < 7; i++)
        Expanded(
          child: Text(
              TutorFormat.weekdayShort(context,
                      DateTime(monday.year, monday.month, monday.day + i))
                  .replaceAll('.', '')
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ),
    ]);
    final weeks = <List<DateTime>>[];
    if (_month) {
      final last = DateTime(_anchor.year, _anchor.month + 1, 0);
      var start = monday;
      while (!start.isAfter(last)) {
        weeks.add([
          for (var i = 0; i < 7; i++)
            DateTime(start.year, start.month, start.day + i)
        ]);
        start = DateTime(start.year, start.month, start.day + 7);
      }
    } else {
      weeks.add([
        for (var i = 0; i < 7; i++)
          DateTime(monday.year, monday.month, monday.day + i)
      ]);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(children: [
        header,
        const SizedBox(height: 6),
        for (final week in weeks)
          Row(children: [
            for (final day in week)
              Expanded(
                  child:
                      cell(day, faded: _month && day.month != _anchor.month)),
          ]),
      ]),
    );
  }

  Widget _empty(TranslationsTutorSpacePlanningFr tr) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppPalette.infoBg, shape: BoxShape.circle),
            child: const Icon(Icons.calendar_today_outlined,
                color: AppPalette.teal800),
          ),
          const SizedBox(height: 12),
          Text(_filter == null ? tr.empty : tr.emptyFilter,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 6),
          Text(_filter == null ? tr.emptyText : tr.emptyFilterText,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        ]),
      );
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final TutorSession session;

  @override
  Widget build(BuildContext context) {
    final color = tutorStateColor(session.state);
    final pupil = [session.pupil, session.schoolClass]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');
    return InkWell(
      onTap: () => context.push(TutorSpaceRoutes.session(session.id)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppPalette.n300))),
        child: IntrinsicHeight(
          child: Row(children: [
            SizedBox(
              width: 40,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        TutorFormat.weekdayShort(context, session.date)
                            .replaceAll('.', '')
                            .toUpperCase(),
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                    Text('${session.date.day}',
                        style: AppTypography.h3
                            .copyWith(color: AppPalette.teal800)),
                  ]),
            ),
            const SizedBox(width: 10),
            Container(
              width: 3,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        [session.subject, pupil]
                            .whereType<String>()
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: AppTypography.label),
                    Text(TutorFormat.hours(session),
                        style: AppTypography.bodySm
                            .copyWith(color: AppPalette.text2)),
                    const SizedBox(height: 4),
                    TutorStateBadge(
                        state: session.state, label: session.stateLabel),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppPalette.text2),
          ]),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.tr});

  final TranslationsTutorSpacePlanningLegendFr tr;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('planned', tr.planned),
      ('to_report', tr.toReport),
      ('report_sent', tr.reportSent),
      ('approved', tr.approved),
      ('disputed', tr.disputed),
      ('suspended', tr.suspended),
    ];
    return Wrap(spacing: 14, runSpacing: 8, children: [
      for (final (state, label) in items)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: tutorStateColor(state), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
    ]);
  }
}
