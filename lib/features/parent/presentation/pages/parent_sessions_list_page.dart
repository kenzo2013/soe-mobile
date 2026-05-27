import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/session_summary.dart';
import '../providers.dart';
import '../widgets/parent_drawer.dart';

/// Page Séances — toggle Calendrier / Liste.
class ParentSessionsListPage extends ConsumerStatefulWidget {
  const ParentSessionsListPage({super.key});

  @override
  ConsumerState<ParentSessionsListPage> createState() =>
      _ParentSessionsListPageState();
}

enum _ViewMode { calendar, list }

class _ParentSessionsListPageState
    extends ConsumerState<ParentSessionsListPage> {
  _ViewMode _mode = _ViewMode.calendar;

  /// Lundi de la semaine affichée (calendar view).
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekStart =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));
  }

  void _prevWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
      });
  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
      });

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    final sameMonth = _weekStart.month == end.month;
    final monthFmt = DateFormat.MMMM('fr');
    if (sameMonth) {
      return '${_weekStart.day} – ${end.day} ${monthFmt.format(end)} ${end.year}';
    }
    return '${_weekStart.day} ${monthFmt.format(_weekStart).substring(0, 3)} – ${end.day} ${monthFmt.format(end).substring(0, 3)} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(activeRoute: RouteNames.parentSessions),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: _mode == _ViewMode.calendar ? 64 : 56,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Séances',
              style: TextStyle(
                color: AppPalette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_mode == _ViewMode.calendar) ...[
              const SizedBox(height: 2),
              Text(
                'Semaine du ${DateFormat('d MMMM', 'fr').format(_weekStart)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppPalette.n700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: _NotificationBtn(),
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(sessionsListViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) => RefreshIndicator(
          onRefresh: () =>
              ref.read(sessionsListViewModelProvider.notifier).refresh(),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ViewToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _mode == _ViewMode.calendar
                    ? _CalendarView(
                        weekStart: _weekStart,
                        sessions: items,
                        weekLabel: _weekLabel(),
                        onPrev: _prevWeek,
                        onNext: _nextWeek,
                      )
                    : _ListView(sessions: items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Bouton notification (cloche + dot non-lu)
// ═══════════════════════════════════════════════════════════════
class _NotificationBtn extends StatelessWidget {
  const _NotificationBtn();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: navigation vers /notifications quand la feature sera prete
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppPalette.n300),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: AppPalette.ink,
            ),
            Positioned(
              top: 9,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppPalette.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppPalette.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Toggle Calendrier / Liste
// ═══════════════════════════════════════════════════════════════
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.mode, required this.onChanged});
  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.n300),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleTab(
              icon: Icons.calendar_month_outlined,
              label: 'Calendrier',
              active: mode == _ViewMode.calendar,
              onTap: () => onChanged(_ViewMode.calendar),
            ),
          ),
          Expanded(
            child: _ToggleTab(
              icon: Icons.list_alt_outlined,
              label: 'Liste',
              active: mode == _ViewMode.list,
              onTap: () => onChanged(_ViewMode.list),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppPalette.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppPalette.n700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppPalette.n700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Vue calendrier (hebdo)
// ═══════════════════════════════════════════════════════════════
class _CalendarView extends StatelessWidget {
  const _CalendarView({
    required this.weekStart,
    required this.sessions,
    required this.weekLabel,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime weekStart;
  final List<SessionSummary> sessions;
  final String weekLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const int _startHour = 8;
  static const int _endHour = 21;
  static const double _hourPx = 36;
  static const List<String> _daysShort = [
    'LUN',
    'MAR',
    'MER',
    'JEU',
    'VEN',
    'SAM',
    'DIM',
  ];

  /// Couleur stable selon le sujet — palette du design SOE.
  Color _colorFor(String subject) {
    const palette = [
      AppPalette.teal,
      Color(0xFF3DAA7A), // vert
      Color(0xFF7B5BD9), // violet
      Color(0xFFF08C2E), // orange
      Color(0xFFD9619E), // rose
      Color(0xFF5B7FD9), // bleu
    ];
    final h = subject.codeUnits.fold<int>(0, (a, b) => (a + b) % palette.length);
    return palette[h];
  }

  /// Index 0..6 du jour de la session dans la semaine affichée. Null si hors.
  int? _dayIndex(DateTime date) {
    final d0 = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final diff = d1.difference(d0).inDays;
    return (diff >= 0 && diff < 7) ? diff : null;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayIdx = _dayIndex(today);
    final totalH = (_endHour - _startHour) * _hourPx;
    final weekSessions = sessions
        .where((s) => _dayIndex(s.startAt) != null)
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Week nav
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavBtn(icon: Icons.chevron_left, onTap: onPrev),
            Text(
              weekLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
              ),
            ),
            _NavBtn(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
        const SizedBox(height: 14),
        // Day strip
        Row(
          children: [
            const SizedBox(width: 32),
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _DayHeader(
                  label: _daysShort[i],
                  day: weekStart.add(Duration(days: i)).day,
                  isToday: i == todayIdx,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Grid (hours + days)
        SizedBox(
          height: totalH,
          child: Row(
            children: [
              // Hours column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    for (var h = _startHour; h < _endHour; h++)
                      SizedBox(
                        height: _hourPx,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4, top: 1),
                          child: Text(
                            '${h.toString().padLeft(2, '0')}h',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppPalette.n500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Day columns
              for (var di = 0; di < 7; di++)
                Expanded(
                  child: _DayColumn(
                    totalHeight: totalH,
                    isToday: di == todayIdx,
                    nowOffset: (di == todayIdx) ? _nowOffset(today) : null,
                    sessions: weekSessions
                        .where((s) => _dayIndex(s.startAt) == di)
                        .toList(),
                    colorFor: _colorFor,
                  ),
                ),
            ],
          ),
        ),
        if (sessions.isEmpty) ...[
          const SizedBox(height: 18),
          const _CalendarEmptyHint(),
        ],
      ],
    );
  }

  /// Position verticale (px) du marqueur "now" depuis le haut de la grille,
  /// ou null si l'heure courante est hors plage 8h–21h.
  double? _nowOffset(DateTime now) {
    final hourFloat = now.hour + now.minute / 60.0;
    if (hourFloat < _startHour || hourFloat > _endHour) return null;
    return (hourFloat - _startHour) * _hourPx;
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppPalette.n300),
        ),
        child: Icon(icon, size: 16, color: AppPalette.ink),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.label,
    required this.day,
    required this.isToday,
  });
  final String label;
  final int day;
  final bool isToday;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppPalette.n700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 26,
          width: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? AppPalette.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$day',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.totalHeight,
    required this.isToday,
    required this.nowOffset,
    required this.sessions,
    required this.colorFor,
  });
  final double totalHeight;
  final bool isToday;
  final double? nowOffset;
  final List<SessionSummary> sessions;
  final Color Function(String) colorFor;

  static const int _startHour = _CalendarView._startHour;
  static const int _endHour = _CalendarView._endHour;
  static const double _hourPx = _CalendarView._hourPx;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: isToday
            ? AppPalette.yellow.withValues(alpha: 0.04)
            : Colors.transparent,
        border: const Border(
          left: BorderSide(color: AppPalette.n300, width: 1),
        ),
      ),
      child: Stack(
        children: [
          // Lignes horaires
          for (var h = 0; h < _endHour - _startHour; h++)
            Positioned(
              top: h * _hourPx,
              left: 0,
              right: 0,
              child: const SizedBox(
                height: 1,
                child: ColoredBox(color: AppPalette.n100),
              ),
            ),
          // Sessions
          for (final s in sessions) _sessionBlock(s),
          // Now indicator
          if (nowOffset != null)
            Positioned(
              top: nowOffset! - 1,
              left: -3,
              right: -3,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppPalette.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppPalette.danger,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sessionBlock(SessionSummary s) {
    final hourFloat = s.startAt.hour + s.startAt.minute / 60.0;
    final top = (hourFloat - _startHour) * _hourPx + 1;
    final durH = s.durationMinutes / 60.0;
    final height = (durH * _hourPx - 2).clamp(20.0, double.infinity);
    final color = colorFor(s.subject);
    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            if (height > 28)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  s.tutorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarEmptyHint extends StatelessWidget {
  const _CalendarEmptyHint();
  @override
  Widget build(BuildContext context) {
    return SoeCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.infoBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 18,
              color: AppPalette.teal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucune séance cette semaine',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Vos séances planifiées s'afficheront ici. Naviguez entre les semaines avec les flèches.",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Vue Liste — groupes par jour
// ═══════════════════════════════════════════════════════════════
class _ListView extends StatelessWidget {
  const _ListView({required this.sessions});
  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const _ListEmptyView();
    }
    // Group by day
    final byDay = <String, List<SessionSummary>>{};
    for (final s in sessions) {
      final k =
          '${s.startAt.year}-${s.startAt.month.toString().padLeft(2, "0")}-${s.startAt.day.toString().padLeft(2, "0")}';
      byDay.putIfAbsent(k, () => []).add(s);
    }
    final keys = byDay.keys.toList()..sort();
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}';

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: keys.length,
      itemBuilder: (_, gi) {
        final dayKey = keys[gi];
        final daySessions = byDay[dayKey]!
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
        final date = daySessions.first.startAt;
        final isToday = dayKey == todayKey;
        final label = isToday
            ? "AUJOURD'HUI · ${DateFormat('EEEE d MMMM', 'fr').format(date).toUpperCase()}"
            : DateFormat('EEEE d MMMM', 'fr').format(date).toUpperCase();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.n700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SoeCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < daySessions.length; i++) ...[
                      _SessionRow(session: daySessions[i]),
                      if (i < daySessions.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppPalette.n100,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final SessionSummary session;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endAt = session.startAt.add(Duration(minutes: session.durationMinutes));
    final isLive = session.status == SessionStatus.pending &&
        now.isAfter(session.startAt) &&
        now.isBefore(endAt);
    final timeFmt = DateFormat.Hm('fr');
    final dur = _formatDuration(session.durationMinutes);
    return InkWell(
      onTap: () => context.push('/parent/sessions/${session.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isLive ? AppPalette.successBg : AppPalette.n100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    timeFmt.format(session.startAt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: isLive ? AppPalette.success : AppPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dur,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isLive
                          ? AppPalette.success.withValues(alpha: 0.7)
                          : AppPalette.ink.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                          ),
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppPalette.successBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 5,
                                height: 5,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppPalette.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'EN COURS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.success,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${session.childName} · avec ${session.tutorName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppPalette.n500,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    if (h > 0) return '${h}h';
    return '${m}min';
  }
}

class _ListEmptyView extends StatelessWidget {
  const _ListEmptyView();

  @override
  Widget build(BuildContext context) {
    // Affiche 3 jours "skeletons" pour montrer la structure même sans données
    final today = DateTime.now();
    final days = [today, today.add(const Duration(days: 1)), today.add(const Duration(days: 2))];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: days.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: SoeCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppPalette.infoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppPalette.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aucune séance planifiée',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Les séances de tutorat apparaîtront ici dès qu'elles seront planifiées.",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppPalette.n700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final day = days[i - 1];
        final isToday = i == 1;
        final label = isToday
            ? "AUJOURD'HUI · ${DateFormat('EEEE d MMMM', 'fr').format(day).toUpperCase()}"
            : DateFormat('EEEE d MMMM', 'fr').format(day).toUpperCase();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.n700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SoeCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 22,
                ),
                child: Center(
                  child: Text(
                    'Aucune séance ce jour',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.n500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
