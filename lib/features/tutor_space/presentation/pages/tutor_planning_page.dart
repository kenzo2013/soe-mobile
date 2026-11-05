import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-16 — the planning on mobile: a week strip, then the sessions of the week as a list.
class TutorPlanningPage extends ConsumerStatefulWidget {
  const TutorPlanningPage({super.key});

  @override
  ConsumerState<TutorPlanningPage> createState() => _TutorPlanningPageState();
}

class _TutorPlanningPageState extends ConsumerState<TutorPlanningPage> {
  late DateTime _monday = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.planning;
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(children: [
              Expanded(
                  child: Text(tr.title,
                      style: AppTypography.h1
                          .copyWith(color: AppPalette.teal800))),
              IconButton(
                tooltip: tr.previous,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                    () => _monday = _monday.subtract(const Duration(days: 7))),
              ),
              IconButton(
                tooltip: tr.next,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                    () => _monday = _monday.add(const Duration(days: 7))),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  tr.weekOf(date: TutorFormat.dayLong(context, _monday)),
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                    child: _DayCell(
                        day: _monday.add(Duration(days: i)), today: today)),
            ]),
          ),
          Expanded(
            child: TutorAsyncBody<List<TutorSession>>(
              value: ref.watch(tutorWeekSessionsProvider(_monday)),
              onRetry: () => ref.invalidate(tutorWeekSessionsProvider(_monday)),
              builder: (sessions) => sessions.isEmpty
                  ? SoeEmptyState(
                      title: tr.empty,
                      message: tr.emptyText,
                      icon: Icons.event_available_outlined)
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .refresh(tutorWeekSessionsProvider(_monday).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => TutorSessionTile(
                          session: sessions[i],
                          onTap: () => context
                              .push(TutorSpaceRoutes.session(sessions[i].id)),
                        ),
                      ),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.today});

  final DateTime day;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isToday ? AppPalette.teal500 : AppPalette.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isToday ? AppPalette.teal500 : AppPalette.n300),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(TutorFormat.day(context, day).split(' ').first.toUpperCase(),
            style: AppTypography.caption.copyWith(
                color: isToday ? AppPalette.white : AppPalette.text2)),
        Text('${day.day}',
            style: AppTypography.label
                .copyWith(color: isToday ? AppPalette.white : AppPalette.text)),
      ]),
    );
  }
}
