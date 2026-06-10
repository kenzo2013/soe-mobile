import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/tutor_course.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import '../widgets/tutor_action.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_ui.dart';

// ════════════════════════════════════════════════════════════
// Cours actifs
// ════════════════════════════════════════════════════════════
class TutorActiveCoursesPage extends ConsumerWidget {
  const TutorActiveCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorActiveCoursesViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorCourses),
      appBar: const TutorAppBar(
        title: 'Mes cours actifs',
        subtitle: 'Réservations en cours',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorActiveCoursesViewModelProvider.notifier).refresh(),
        ),
        loaded: (courses) => RefreshIndicator(
          color: AppPalette.teal,
          onRefresh: () =>
              ref.read(tutorActiveCoursesViewModelProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Builder(
                builder: (_) {
                  final subjects = <String>{
                    for (final c in courses) ...c.subjects,
                  };
                  return Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                            value: '${courses.length}', label: 'Élèves'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                            value: '${subjects.length}', label: 'Matières'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                            value: '${courses.length}', label: 'Cours'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              for (final c in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CourseCard(
                    course: c,
                    onTap: () =>
                        context.push(RouteNames.tutorCourseDetail(c.id)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return SoeCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppPalette.n700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});
  final TutorActiveCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SoeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TutorPillBadge(
                  label: 'En cours',
                  bg: AppPalette.successBg,
                  fg: AppPalette.success,
                ),
                Text(
                  course.reference,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppPalette.n700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SoeAvatar(name: course.student, size: SoeAvatarSize.mini),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.student,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.classe} · démarré le ${course.start}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in course.subjects) TutorTagChip(label: s)
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppPalette.n50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_outlined,
                      size: 12, color: AppPalette.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      course.schedule,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.ink,
                      ),
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
}

// ════════════════════════════════════════════════════════════
// Détail cours (élève + emploi du temps)
// ════════════════════════════════════════════════════════════
class TutorCourseDetailPage extends ConsumerWidget {
  const TutorCourseDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorCourseDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Détail du cours',
        subtitle: 'Profil et emploi du temps',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () => ref
              .read(tutorCourseDetailViewModelProvider(id).notifier)
              .load(id),
        ),
        loaded: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SoeCard(
              child: Row(
                children: [
                  SoeAvatar(name: c.student, size: SoeAvatarSize.list),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.student,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                          ),
                        ),
                        Text(
                          '${c.age} ans · ${c.gender}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppPalette.n700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TutorTagChip(
                          label: c.classe,
                          bg: AppPalette.teal.withValues(alpha: 0.10),
                          fg: AppPalette.teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _title('Matières concernées'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in c.subjects)
                  TutorTagChip(
                    label: s,
                    bg: AppPalette.yellow.withValues(alpha: 0.13),
                    fg: AppPalette.ink,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _title("Emploi du temps")),
                InkWell(
                  onTap: () =>
                      context.push(RouteNames.tutorCourseSchedules(c.id)),
                  child: const Text(
                    'Modifier',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppPalette.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            for (final s in c.slots)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoeCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppPalette.teal.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.day.length >= 3 ? s.day.substring(0, 3) : s.day,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.subject,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.ink,
                              ),
                            ),
                            Text(
                              '${s.day} · ${s.timeRange}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppPalette.n700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppPalette.n500),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════
// Gérer les horaires
// ════════════════════════════════════════════════════════════
class TutorManageSchedulesPage extends ConsumerWidget {
  const TutorManageSchedulesPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorCourseDetailViewModelProvider(id));
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    const activeDays = {'Lundi', 'Mercredi', 'Vendredi'};
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Gérer les horaires',
        subtitle: 'Ajuster les créneaux (avec accord parent)',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(failure: f),
        loaded: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.warningBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppPalette.warning.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      size: 16, color: AppPalette.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Modifier les horaires nécessite l'accord du parent. Une "
                      'notification sera envoyée pour validation.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppPalette.warning,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                '${c.student} · ${c.classe}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
            ),
            for (final d in days)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoeCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: activeDays.contains(d)
                              ? AppPalette.teal
                              : AppPalette.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: activeDays.contains(d)
                                ? AppPalette.teal
                                : AppPalette.n500,
                            width: 2,
                          ),
                        ),
                        child: activeDays.contains(d)
                            ? const Icon(Icons.check,
                                size: 10, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: activeDays.contains(d)
                                ? AppPalette.ink
                                : AppPalette.n500,
                          ),
                        ),
                      ),
                      if (activeDays.contains(d))
                        Row(
                          children: [
                            _timePill('10:00'),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text('→',
                                  style: TextStyle(
                                      fontSize: 11, color: AppPalette.n700)),
                            ),
                            _timePill('12:00'),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SoeButton(
              label: 'Demander la modification',
              fullWidth: true,
              loading: ref.watch(tutorActionViewModelProvider('schedules:$id'))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                context,
                ref,
                actionKey: 'schedules:$id',
                successMessage: 'Demande envoyée au parent',
                op: () => ref.read(manageTutorSchedulesProvider)({
                  'student_id': id,
                  'note': 'Demande de modification des horaires',
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePill(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppPalette.n100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppPalette.ink,
          ),
        ),
      );
}
