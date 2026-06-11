import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../domain/entities/parent_dashboard.dart';
import '../providers.dart';
import '../widgets/child_avatars_row.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/parent_drawer.dart';
import '../widgets/parent_greet_header.dart';
import '../widgets/parent_quote_cta.dart';
import '../widgets/recent_reservation_row.dart';
import '../widgets/today_session_row.dart';

class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentDashboardViewModelProvider);
    final user = ref.watch(currentUserProvider).asData?.value;
    final firstName =
        (user?.firstName.isNotEmpty ?? false) ? user!.firstName : 'Parent';

    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(
        activeRoute: RouteNames.parentDashboard,
      ),
      body: state.when(
        initial: () => _LoadingShell(firstName: firstName),
        loading: () => _LoadingShell(firstName: firstName),
        error: (f) => _ErrorShell(
          firstName: firstName,
          failure: f,
          onRetry: () =>
              ref.read(parentDashboardViewModelProvider.notifier).refresh(),
        ),
        loaded: (d) => RefreshIndicator(
          onRefresh: () =>
              ref.read(parentDashboardViewModelProvider.notifier).refresh(),
          child: _LoadedView(
            firstName: firstName,
            data: d,
            onAddChild: () => context.push(RouteNames.parentStudentNew),
            onRequestQuote: () => context.push(RouteNames.parentReservationNew),
          ),
        ),
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell({required this.firstName});
  final String firstName;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      children: [
        ParentGreetHeader(
          firstName: firstName,
          dateLine: _todayLine(tr, 0),
        ),
        const Expanded(child: DashboardSkeleton()),
      ],
    );
  }
}

class _ErrorShell extends StatelessWidget {
  const _ErrorShell({
    required this.firstName,
    required this.failure,
    required this.onRetry,
  });
  final String firstName;
  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      children: [
        ParentGreetHeader(firstName: firstName, dateLine: _todayLine(tr, 0)),
        Expanded(
          child: ErrorView(
            failure: failure,
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.firstName,
    required this.data,
    required this.onAddChild,
    required this.onRequestQuote,
  });
  final String firstName;
  final ParentDashboard data;
  final VoidCallback onAddChild;
  final VoidCallback onRequestQuote;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final sessions = data.todaySessions;
    final reservations = data.recentReservations;
    final students = data.students;

    if (data.isEmpty) {
      return _EmptyDashboard(
        firstName: firstName,
        onAddChild: onAddChild,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          // Header + feuille de contenu dans une SEULE Column : la feuille,
          // peinte APRES le header dans la meme Column, remonte par-dessus lui
          // (Transform -24) et ses coins arrondis laissent voir le degrade
          // derriere → effet "pull-up". En slivers separes, le header peignait
          // au-dessus de la feuille → transition plate.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ParentGreetHeader(
                firstName: firstName,
                dateLine: _todayLine(tr, sessions.length),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppPalette.n100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ParentQuoteCta(onTap: onRequestQuote),
                      const SizedBox(height: 22),
                      _sectionHeader(
                        tr.parent.dashboard.myChildren,
                        actionLabel: tr.common.seeAll,
                        onAction: () => context.push(RouteNames.parentStudents),
                      ),
                      ChildAvatarsRow(
                        students: students,
                        onAdd: onAddChild,
                      ),
                      if (sessions.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _sectionHeader(
                          tr.parent.dashboard.todaySessions,
                          count: sessions.length.toString(),
                          actionLabel: tr.parent.dashboard.calendar,
                          onAction: () =>
                              context.push(RouteNames.parentSessions),
                        ),
                        SoeCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (var i = 0; i < sessions.length; i++) ...[
                                TodaySessionRow(session: sessions[i]),
                                if (i < sessions.length - 1)
                                  Container(
                                    height: 1,
                                    color: AppPalette.n100,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (reservations.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _sectionHeader(
                          tr.parent.dashboard.recentReservations,
                          actionLabel: tr.common.seeAll,
                          onAction: () =>
                              context.push(RouteNames.parentReservations),
                        ),
                        SoeCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (var i = 0; i < reservations.length; i++) ...[
                                RecentReservationRow(
                                  reservation: reservations[i],
                                ),
                                if (i < reservations.length - 1)
                                  Container(
                                    height: 1,
                                    color: AppPalette.n100,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    String title, {
    String? count,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
              letterSpacing: -0.1,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.n700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPalette.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.firstName, required this.onAddChild});

  final String firstName;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header + feuille dans une SEULE Column pour que la feuille remonte
        // par-dessus le header (coins arrondis visibles), cf. _LoadedView.
        Column(
          children: [
            ParentGreetHeader(
              firstName: firstName,
              dateLine: tr.parent.dashboard.noSessionPlanned,
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppPalette.n100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppPalette.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppPalette.n300),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(
                              color: AppPalette.infoBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups_outlined,
                              size: 36,
                              color: AppPalette.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr.parent.dashboard.welcomeTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr.parent.dashboard.welcomeBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppPalette.n700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SoeButton(
                            label: tr.parent.dashboard.addFirstChild,
                            onPressed: onAddChild,
                            icon: Icons.add,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ..._howItWorks(tr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<Widget> _howItWorks(Translations tr) => [
        _HowStep(
          n: 1,
          title: tr.parent.dashboard.howStep1Title,
          desc: tr.parent.dashboard.howStep1Desc,
          icon: Icons.groups_outlined,
        ),
        _HowStep(
          n: 2,
          title: tr.parent.dashboard.howStep2Title,
          desc: tr.parent.dashboard.howStep2Desc,
          icon: Icons.description_outlined,
        ),
        _HowStep(
          n: 3,
          title: tr.parent.dashboard.howStep3Title,
          desc: tr.parent.dashboard.howStep3Desc,
          icon: Icons.calendar_month_outlined,
        ),
      ];
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.n,
    required this.title,
    required this.desc,
    required this.icon,
  });
  final int n;
  final String title;
  final String desc;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.n300),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppPalette.yellow,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 18, color: AppPalette.n500),
          ],
        ),
      ),
    );
  }
}

String _todayLine(Translations tr, int sessionCount) {
  final fmt = DateFormat('EEEE d MMMM', 'fr');
  final date = fmt.format(DateTime.now());
  if (sessionCount == 0)
    return tr.parent.dashboard.dateLineNoSession(date: date);
  if (sessionCount == 1)
    return tr.parent.dashboard.dateLineOneSession(date: date);
  return tr.parent.dashboard.dateLineManySessions(
    date: date,
    count: sessionCount,
  );
}
