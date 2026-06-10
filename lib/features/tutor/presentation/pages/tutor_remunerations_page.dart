import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/tutor_remuneration.dart';
import '../providers.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_ui.dart';
import 'tutor_profile_pages.dart' show stubAction;

class TutorRemunerationsPage extends ConsumerWidget {
  const TutorRemunerationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorRemunerationsViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorRemunerations),
      appBar: TutorAppBar(
        title: tr.tutor.remunerations.title,
        subtitle: tr.tutor.remunerations.subtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorRemunerationsViewModelProvider.notifier).refresh(),
        ),
        loaded: (data) => RefreshIndicator(
          color: AppPalette.teal,
          onRefresh: () =>
              ref.read(tutorRemunerationsViewModelProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Hero(summary: data.summary),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  tr.tutor.remunerations.history,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              for (final r in data.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RemunerationCard(
                    item: r,
                    onDownload: () => stubAction(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.summary});
  final TutorEarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppPalette.brandGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.tutor.remunerations.totalEarnedIn(year: summary.year),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fcfa(summary.totalEarned),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat(tr.tutor.remunerations.sessions,
                    '${summary.totalSessions}'),
                _sep(),
                _stat(tr.tutor.remunerations.students,
                    '${summary.totalStudents}'),
                _sep(),
                _stat(tr.tutor.remunerations.averageRate,
                    NumberFormatHelper.spaced(summary.averageRate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      );

  Widget _sep() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white.withValues(alpha: 0.15),
      );
}

class _RemunerationCard extends StatelessWidget {
  const _RemunerationCard({required this.item, required this.onDownload});
  final TutorRemuneration item;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final paid = item.status == RemunerationStatus.paid;
    return SoeCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.period,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TutorPillBadge(
                      label: paid
                          ? tr.tutor.remunerations.paid
                          : tr.tutor.remunerations.pending,
                      bg: paid ? AppPalette.successBg : AppPalette.warningBg,
                      fg: paid ? AppPalette.success : AppPalette.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  paid
                      ? tr.tutor.remunerations.paidLine(
                          count: item.sessions,
                          date: item.paidOn ?? '',
                          method: item.method ?? '',
                        )
                      : tr.tutor.remunerations.pendingLine(
                          count: item.sessions,
                          date: '02 juin',
                        ),
                  style: const TextStyle(fontSize: 11, color: AppPalette.n700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fcfa(item.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
              if (paid) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: onDownload,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.teal.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download_outlined,
                            size: 11, color: AppPalette.teal),
                        SizedBox(width: 4),
                        Text('PDF',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.teal)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Petit utilitaire local pour afficher le taux moyen espacé (4 757).
abstract final class NumberFormatHelper {
  static String spaced(int n) => fcfa(n).replaceAll(' FCFA', '');
}
