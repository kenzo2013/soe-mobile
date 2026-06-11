import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../domain/entities/tutor_dashboard.dart';
import '../providers.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_ui.dart';

/// Date du jour capitalisée (ex: « Jeudi 14 mai »).
String _todayLine() {
  final s = DateFormat('EEEE d MMMM', 'fr').format(DateTime.now());
  return s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class TutorDashboardPage extends ConsumerWidget {
  const TutorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorDashboardViewModelProvider);
    final user = ref.watch(currentUserProvider).asData?.value;
    final firstName = (user?.firstName ?? '').trim();
    final dateLine = _todayLine();
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorDashboard),
      body: state.when(
        initial: () => _DashboardShell(
            firstName: firstName,
            dateLine: dateLine,
            child: const TutorLoading()),
        loading: () => _DashboardShell(
            firstName: firstName,
            dateLine: dateLine,
            child: const TutorLoading()),
        error: (f) => _DashboardShell(
          firstName: firstName,
          dateLine: dateLine,
          child: ErrorView(
            failure: f,
            onRetry: () =>
                ref.read(tutorDashboardViewModelProvider.notifier).refresh(),
          ),
        ),
        loaded: (d) => RefreshIndicator(
          color: AppPalette.teal,
          onRefresh: () =>
              ref.read(tutorDashboardViewModelProvider.notifier).refresh(),
          child: _Loaded(data: d, firstName: firstName, dateLine: dateLine),
        ),
      ),
    );
  }
}

/// Coquille (header dégradé + corps) partagée par loading/error.
class _DashboardShell extends StatelessWidget {
  const _DashboardShell({
    required this.child,
    required this.firstName,
    required this.dateLine,
  });
  final Widget child;
  final String firstName;
  final String dateLine;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(firstName: firstName, dateLine: dateLine, stats: null),
        Expanded(child: child),
      ],
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.data,
    required this.firstName,
    required this.dateLine,
  });
  final TutorDashboard data;
  final String firstName;
  final String dateLine;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(
          firstName: firstName.isEmpty ? data.firstName : firstName,
          dateLine: dateLine,
          stats: data.stats,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Séances du jour
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.tutor.dashboard.todaySessions,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr.tutor.dashboard
                                .planned(count: data.todaySessions.length),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppPalette.n700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push(RouteNames.tutorSessions),
                      child: Text(
                        tr.common.seeAll,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < data.todaySessions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TodaySessionCard(
                    session: data.todaySessions[i],
                    highlight: i == 0,
                    onReport: () => context.push(
                      RouteNames.tutorSessionReport(data.todaySessions[i].id),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  tr.tutor.dashboard.quickActions,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.55,
                children: [
                  _QuickAction(
                    icon: Icons.work_outline,
                    label: tr.tutor.dashboard.qaJobs,
                    sub: tr.tutor.dashboard.qaJobsSub,
                    onTap: () => context.push(RouteNames.tutorJobs),
                  ),
                  _QuickAction(
                    icon: Icons.draw_outlined,
                    label: tr.tutor.dashboard.qaReport,
                    sub: tr.tutor.dashboard.qaReportSub,
                    accent: true,
                    onTap: () => context.push(RouteNames.tutorSessions),
                  ),
                  _QuickAction(
                    icon: Icons.calendar_month_outlined,
                    label: tr.tutor.dashboard.qaAvailabilities,
                    sub: tr.tutor.dashboard.qaAvailabilitiesSub,
                    onTap: () =>
                        context.push(RouteNames.tutorProfileAvailabilities),
                  ),
                  _QuickAction(
                    icon: Icons.payments_outlined,
                    label: tr.tutor.dashboard.qaRemunerations,
                    sub: tr.tutor.dashboard.qaRemunerationsSub,
                    onTap: () => context.push(RouteNames.tutorRemunerations),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.firstName,
    required this.dateLine,
    required this.stats,
  });
  final String firstName;
  final String dateLine;
  final TutorStats? stats;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 4,
        16,
        20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.tutor.dashboard.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstName.isEmpty
                          ? dateLine
                          : tr.tutor.dashboard
                              .greeting(name: firstName, date: dateLine),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.notifications),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (stats != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.groups_outlined,
                          label: tr.tutor.dashboard.statStudents,
                          value: stats!.totalStudents,
                          accent: AppPalette.yellow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.calendar_month_outlined,
                          label: tr.tutor.dashboard.statSessions,
                          value: stats!.totalSessions,
                          accent: const Color(0xFF7DD3FC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.schedule_outlined,
                          label: tr.tutor.dashboard.statPending,
                          value: stats!.pendingSessions,
                          accent: const Color(0xFFFCA5A5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.check_circle_outline,
                          label: tr.tutor.dashboard.statCompleted,
                          value: stats!.completedSessions,
                          accent: const Color(0xFF86EFAC),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  const _TodaySessionCard({
    required this.session,
    required this.highlight,
    required this.onReport,
  });
  final TutorTodaySession session;
  final bool highlight;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final spec = sessionStatusSpec(tr, session.status);
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppPalette.yellow : AppPalette.n300,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: highlight ? AppPalette.yellow : AppPalette.teal,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          session.timeRange,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.teal,
                            letterSpacing: 0.2,
                          ),
                        ),
                        TutorPillBadge(
                          label: spec.$1,
                          bg: spec.$2,
                          fg: spec.$3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${session.subject} · ${session.classe}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SoeAvatar(
                          name: session.student,
                          size: SoeAvatarSize.mini,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${session.student} · ${session.address}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.n700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (highlight) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppPalette.n300),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: onReport,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppPalette.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.draw_outlined,
                                        size: 14, color: AppPalette.ink),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr.tutor.dashboard.doReport,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppPalette.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppPalette.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppPalette.n300),
                            ),
                            child: const Icon(Icons.call_outlined,
                                size: 14, color: AppPalette.teal),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SoeCard(
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent
                    ? AppPalette.yellow.withValues(alpha: 0.13)
                    : AppPalette.n100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: accent ? AppPalette.yellow : AppPalette.teal,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11, color: AppPalette.n700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
