import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_pill_switch.dart';
import '../../../../i18n/translations.g.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_session_tile.dart';
import '../widgets/parent_ui.dart';

enum _View { week, month }

/// PAR-12 — the planning on mobile: the children as filters, then a card with the week strip
/// (or the month as a list), the sessions and the legend of the statuses.
class ParentPlanningPage extends ConsumerStatefulWidget {
  const ParentPlanningPage({super.key});

  @override
  ConsumerState<ParentPlanningPage> createState() => _ParentPlanningPageState();
}

class _ParentPlanningPageState extends ConsumerState<ParentPlanningPage> {
  late DateTime _monday = _mondayOf(DateTime.now());
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  _View _view = _View.week;
  int? _childId;

  static DateTime _mondayOf(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  ({DateTime from, DateTime to}) get _range => _view == _View.week
      ? (from: _monday, to: _monday.add(const Duration(days: 6)))
      : (from: _month, to: DateTime(_month.year, _month.month + 1, 0));

  void _move(int step) => setState(() {
        if (_view == _View.week) {
          _monday = _monday.add(Duration(days: 7 * step));
        } else {
          _month = DateTime(_month.year, _month.month + step);
        }
      });

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final locale = Localizations.localeOf(context).languageCode;
    final children =
        ref.watch(parentChildrenProvider).valueOrNull ?? const <ParentChild>[];
    final value = ref.watch(parentSessionsRangeProvider(_range));
    final names = children.map((child) => child.firstName).toList();
    final title = _view == _View.week
        ? tr.planning.weekOf(date: DateFormat('d MMMM', locale).format(_monday))
        : toBeginningOfSentenceCase(
            DateFormat('MMMM y', locale).format(_month));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: Column(children: [
          TabTopBar(title: Translations.of(context).shell.parent.planning),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(parentSessionsRangeProvider(_range).future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(tr.planning.title,
                      style:
                          AppTypography.h1.copyWith(color: AppPalette.teal800)),
                  if (names.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                        tr.planning.subtitle(
                            names: names.length < 2
                                ? names.join()
                                : '${names.sublist(0, names.length - 1).join(', ')} ${tr.home.and} ${names.last}'),
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
                  ],
                  if (children.length > 1) ...[
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      SoeChip(
                        label: tr.planning.allChildren,
                        selected: _childId == null,
                        onTap: () => setState(() => _childId = null),
                      ),
                      for (final child in children)
                        SoeChip(
                          label: child.firstName,
                          selected: _childId == child.id,
                          onTap: () => setState(() => _childId = child.id),
                        ),
                    ]),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppPalette.n300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(children: [
                              _RoundButton(
                                  icon: Icons.chevron_left,
                                  tooltip: tr.planning.previous,
                                  onTap: () => _move(-1)),
                              const SizedBox(width: 8),
                              _RoundButton(
                                  icon: Icons.chevron_right,
                                  tooltip: tr.planning.next,
                                  onTap: () => _move(1)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(title,
                                    style: AppTypography.h3
                                        .copyWith(color: AppPalette.teal800)),
                              ),
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SoePillSwitch<_View>(
                                options: [
                                  (value: _View.week, label: tr.planning.week),
                                  (
                                    value: _View.month,
                                    label: tr.planning.month
                                  ),
                                ],
                                selected: _view,
                                onChanged: (view) =>
                                    setState(() => _view = view),
                              ),
                            ),
                          ),
                          ...value.when(
                            loading: () => const [
                              Padding(
                                padding: EdgeInsets.all(24),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            ],
                            error: (error, _) => [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ParentAsyncBody<void>(
                                  value: AsyncValue.error(
                                      error, StackTrace.current),
                                  onRetry: () => ref.invalidate(
                                      parentSessionsRangeProvider(_range)),
                                  builder: (_) => const SizedBox.shrink(),
                                ),
                              ),
                            ],
                            data: (all) {
                              final sessions = _childId == null
                                  ? all
                                  : all
                                      .where((session) =>
                                          session.childId == _childId)
                                      .toList();
                              return [
                                if (_view == _View.week)
                                  _WeekStrip(
                                      monday: _monday, sessions: sessions),
                                const Divider(
                                    height: 1, color: AppPalette.n300),
                                if (sessions.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(children: [
                                      Text(
                                          _view == _View.week
                                              ? tr.planning.empty
                                              : tr.planning.emptyMonth,
                                          style: AppTypography.label),
                                      const SizedBox(height: 4),
                                      Text(tr.planning.emptyText,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.bodySm.copyWith(
                                              color: AppPalette.text2)),
                                    ]),
                                  )
                                else
                                  for (final (i, session) in sessions.indexed)
                                    ParentSessionTile(
                                      session: session,
                                      divider: i < sessions.length - 1,
                                      onTap: () => context.push(
                                          ParentSpaceRoutes.session(
                                              session.id)),
                                    ),
                                const _Legend(),
                              ];
                            },
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton(
      {required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
            backgroundColor: AppPalette.surfaceSoft,
            foregroundColor: AppPalette.text,
            minimumSize: const Size(40, 40)),
        icon: Icon(icon, size: 20),
      );
}

/// The seven days of the week: today on a teal disc, a dot under the days with a session.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.monday, required this.sessions});

  final DateTime monday;
  final List<ParentSession> sessions;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(children: [
        for (var i = 0; i < 7; i++)
          Builder(builder: (context) {
            final day = monday.add(Duration(days: i));
            final isToday = same(day, today);
            final busy = sessions.any((s) => same(s.startsAt, day));
            return Expanded(
              child: Column(children: [
                Text(ParentFormat.weekday(context, day),
                    style: AppTypography.caption
                        .copyWith(fontSize: 11, color: AppPalette.text2)),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: isToday ? AppPalette.teal700 : null,
                      shape: BoxShape.circle),
                  child: Text('${day.day}',
                      style: AppTypography.labelSm.copyWith(
                          color: isToday ? AppPalette.white : AppPalette.text)),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      color: busy ? AppPalette.teal700 : Colors.transparent,
                      shape: BoxShape.circle),
                ),
              ]),
            );
          }),
      ]),
    );
  }
}

/// The statuses of the sessions (PAR-12): planned, in progress, report to approve, approved,
/// disputed, cancelled, suspended.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.planning.legend;
    final items = [
      ('pending', tr.pending),
      ('in_progress', tr.inProgress),
      ('report_to_approve', tr.reportToApprove),
      ('approved', tr.approved),
      ('disputed', tr.disputed),
      ('cancelled', tr.cancelled),
      ('suspended', tr.suspended),
    ];
    return Container(
      color: AppPalette.surfaceSoft,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Wrap(spacing: 14, runSpacing: 6, children: [
        for (final (status, label) in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: parentSessionTone(status), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ]),
      ]),
    );
  }
}
