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

class ParentSessionsListPage extends ConsumerWidget {
  const ParentSessionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(activeRoute: RouteNames.parentSessions),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Séances',
          style: TextStyle(
            color: AppPalette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
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
          child: items.isEmpty
              ? const _Empty()
              : _GroupedList(items: items),
        ),
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items});
  final List<SessionSummary> items;
  @override
  Widget build(BuildContext context) {
    // group by day (YYYY-MM-DD)
    final byDay = <String, List<SessionSummary>>{};
    for (final s in items) {
      final k =
          '${s.startAt.year}-${s.startAt.month.toString().padLeft(2, "0")}-${s.startAt.day.toString().padLeft(2, "0")}';
      byDay.putIfAbsent(k, () => []).add(s);
    }
    final keys = byDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: keys.length,
      itemBuilder: (_, gi) {
        final dayKey = keys[gi];
        final daySessions = byDay[dayKey]!
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
        final date = daySessions.first.startAt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  DateFormat('EEEE d MMMM', 'fr').format(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              for (final s in daySessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(session: s),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final SessionSummary session;
  @override
  Widget build(BuildContext context) {
    final isLive = session.status == SessionStatus.inProgress;
    final timeFmt = DateFormat.Hm('fr');
    final endAt =
        session.startAt.add(Duration(minutes: session.durationMinutes));
    return SoeCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            context.push('/parent/sessions/${session.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: isLive ? AppPalette.success : AppPalette.teal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.subject,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${session.childName} · ${session.tutorName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.n700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${timeFmt.format(session.startAt)} → ${timeFmt.format(endAt)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                  if (isLive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.successBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'EN COURS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      children: const [
        Center(
          child: Icon(
            Icons.calendar_today_outlined,
            size: 56,
            color: AppPalette.n500,
          ),
        ),
        SizedBox(height: 18),
        Center(
          child: Text(
            'Aucune séance planifiée',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppPalette.ink,
            ),
          ),
        ),
      ],
    );
  }
}
