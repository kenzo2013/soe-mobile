import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../domain/entities/tutor_job.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import '../widgets/tutor_action.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_ui.dart';

// ════════════════════════════════════════════════════════════
// Liste des offres
// ════════════════════════════════════════════════════════════
class TutorJobsListPage extends ConsumerWidget {
  const TutorJobsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorJobsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorJobs),
      appBar: const TutorAppBar(
        title: "Offres d'emploi",
        subtitle: 'Demandes correspondant à votre profil',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorJobsListViewModelProvider.notifier).refresh(),
        ),
        loaded: (jobs) => RefreshIndicator(
          color: AppPalette.teal,
          onRefresh: () =>
              ref.read(tutorJobsListViewModelProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in const [
                      ('Toutes', true),
                      ('Maths', false),
                      ('Physique', false),
                      ('Yaoundé', false),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _FilterPill(label: f.$1, on: f.$2),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${jobs.length} offres correspondent à votre profil',
                style: const TextStyle(fontSize: 11, color: AppPalette.n700),
              ),
              const SizedBox(height: 10),
              for (final j in jobs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _JobCard(
                    job: j,
                    onTap: () => context.push(RouteNames.tutorJobDetail(j.id)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.on});
  final String label;
  final bool on;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: on ? AppPalette.teal : AppPalette.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: on ? AppPalette.teal : AppPalette.n300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: on ? Colors.white : AppPalette.ink,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onTap});
  final TutorJob job;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.location} · ${job.posted}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (job.applied)
                  const TutorPillBadge(
                    label: 'Postulé',
                    bg: AppPalette.infoBg,
                    fg: AppPalette.info,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in job.subjects)
                  TutorTagChip(
                    label: s,
                    bg: AppPalette.teal.withValues(alpha: 0.10),
                    fg: AppPalette.teal,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppPalette.n300),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            fcfa(job.pricePerHour),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.ink,
                            ),
                          ),
                          const Text(
                            '/h',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppPalette.n700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${job.frequency} · début ${job.start}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppPalette.n700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: job.applied ? AppPalette.n100 : AppPalette.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    job.applied ? 'Voir candidature' : 'Postuler',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Détail d'une offre
// ════════════════════════════════════════════════════════════
class TutorJobDetailPage extends ConsumerWidget {
  const TutorJobDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorJobDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: "Détail de l'offre",
        subtitle: 'Détail complet de la demande',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorJobDetailViewModelProvider(id).notifier).load(id),
        ),
        loaded: (j) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                SoeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Publiée ${j.posted}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppPalette.yellow.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_outlined,
                                size: 16, color: AppPalette.yellow),
                            const SizedBox(width: 6),
                            Text(
                              fcfa(j.pricePerHour),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.ink,
                              ),
                            ),
                            Text(
                              '/heure · ${j.frequency}',
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
                ),
                const SizedBox(height: 14),
                _sectionTitle('Description'),
                SoeCard(
                  child: Text(
                    j.summary,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _sectionTitle('Détails'),
                SoeCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date de début',
                          value: j.start),
                      _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Fréquence',
                          value: j.frequency),
                      _DetailRow(
                          icon: Icons.school_outlined,
                          label: 'Classes',
                          value: j.classes.join(', ')),
                      _DetailRow(
                          icon: Icons.place_outlined,
                          label: 'Localisation',
                          value: j.location,
                          last: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _sectionTitle('Matières requises'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in j.subjects)
                      TutorTagChip(
                        label: s,
                        bg: AppPalette.teal,
                        fg: Colors.white,
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: AppPalette.n100,
                  border: Border(top: BorderSide(color: AppPalette.n300)),
                ),
                child: SoeButton(
                  label: j.applied
                      ? 'Voir ma candidature'
                      : 'Postuler à cette offre',
                  fullWidth: true,
                  onPressed: () => context.push(RouteNames.tutorJobApply(j.id)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppPalette.n300)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppPalette.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppPalette.n700)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.ink,
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

// ════════════════════════════════════════════════════════════
// Postuler à une offre
// ════════════════════════════════════════════════════════════
class TutorJobApplyPage extends ConsumerWidget {
  const TutorJobApplyPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorJobDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Postuler',
        subtitle: 'Envoyer votre candidature',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(failure: f),
        loaded: (j) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SoeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vous postulez à',
                      style: TextStyle(fontSize: 11, color: AppPalette.n700)),
                  const SizedBox(height: 4),
                  Text(
                    j.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fcfa(j.pricePerHour)}/h · ${j.location}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _label('Message au parent (optionnel)'),
            Container(
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.n300),
              ),
              padding: const EdgeInsets.all(14),
              child: TextFormField(
                maxLines: 6,
                maxLength: 500,
                initialValue:
                    "Bonjour,\n\nDoctorant en mathématiques, j'ai 6 ans "
                    "d'expérience en préparation d'examens. Je serais ravi "
                    "d'accompagner votre enfant.",
                decoration: const InputDecoration.collapsed(
                  hintText: 'Votre message…',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppPalette.ink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _label('Mon profil sera partagé'),
            Builder(
              builder: (context) {
                final user = ref.watch(currentUserProvider).asData?.value;
                final name = (user?.fullName ?? '').trim();
                return SoeCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SoeAvatar(
                        name: name.isEmpty ? '?' : name,
                        imageUrl: user?.photoUrl,
                        size: SoeAvatarSize.mini,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Mon profil' : name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Votre profil tuteur sera transmis au parent',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppPalette.n700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          size: 18, color: AppPalette.success),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SoeButton(
              label: 'Envoyer ma candidature',
              fullWidth: true,
              loading: ref.watch(tutorActionViewModelProvider('candidacy:$id'))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                context,
                ref,
                actionKey: 'candidacy:$id',
                successMessage: 'Candidature envoyée',
                op: () => ref.read(applyToJobProvider)(id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
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
