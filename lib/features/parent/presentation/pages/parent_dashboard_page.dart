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
    final firstName = (user?.firstName.isNotEmpty ?? false) ? user!.firstName : 'Parent';

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
            onAddChild: () => context.go(RouteNames.parentStudents),
            onRequestQuote: () => context.go(RouteNames.parentReservations),
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
    return Column(
      children: [
        ParentGreetHeader(
          firstName: firstName,
          dateLine: _todayLine(0),
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
    return Column(
      children: [
        ParentGreetHeader(firstName: firstName, dateLine: _todayLine(0)),
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
          child: ParentGreetHeader(
            firstName: firstName,
            dateLine: _todayLine(sessions.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Container(
              decoration: const BoxDecoration(
                color: AppPalette.n100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ParentQuoteCta(onTap: onRequestQuote),
                  const SizedBox(height: 22),
                  _sectionHeader(
                    'Mes enfants',
                    action: const Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPalette.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ChildAvatarsRow(
                    students: students,
                    onAdd: onAddChild,
                  ),
                  if (sessions.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _sectionHeader(
                      'Séances du jour',
                      count: sessions.length.toString(),
                      action: const Text(
                        'Calendrier',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                      'Réservations récentes',
                      action: const Text(
                        'Tout voir',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {String? count, Widget? action}) {
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
          if (action != null) action,
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ParentGreetHeader(firstName: firstName, dateLine: 'Aucune séance prévue'),
        Transform.translate(
          offset: const Offset(0, -16),
          child: Container(
            decoration: const BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
                      const Text(
                        'Bienvenue sur SOE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pour commencer, ajoutez le profil d'un de vos enfants. "
                        "Vous pourrez ensuite demander un devis aux tuteurs.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPalette.n700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SoeButton(
                        label: 'Ajouter mon premier enfant',
                        onPressed: onAddChild,
                        icon: Icons.add,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ..._howItWorks,
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const _howItWorks = [
    _HowStep(
      n: 1,
      title: 'Ajoutez vos enfants',
      desc: 'Profil, classe, matières souhaitées',
      icon: Icons.groups_outlined,
    ),
    _HowStep(
      n: 2,
      title: 'Demandez un devis',
      desc: '3 étapes guidées · réponse en 24h',
      icon: Icons.description_outlined,
    ),
    _HowStep(
      n: 3,
      title: 'Suivez les séances',
      desc: 'Calendrier, rapports, paiements MoMo',
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

String _todayLine(int sessionCount) {
  final fmt = DateFormat('EEEE d MMMM', 'fr');
  final date = fmt.format(DateTime.now());
  if (sessionCount == 0) return '$date · Aucune séance';
  if (sessionCount == 1) return '$date · 1 séance aujourd\'hui';
  return '$date · $sessionCount séances aujourd\'hui';
}
