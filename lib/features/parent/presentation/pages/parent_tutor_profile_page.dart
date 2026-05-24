import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/tutor_profile.dart';
import '../providers.dart';

class ParentTutorProfilePage extends ConsumerStatefulWidget {
  const ParentTutorProfilePage({super.key, required this.tutorId});
  final String tutorId;

  @override
  ConsumerState<ParentTutorProfilePage> createState() =>
      _ParentTutorProfilePageState();
}

class _ParentTutorProfilePageState
    extends ConsumerState<ParentTutorProfilePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorProfileViewModelProvider(widget.tutorId));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      body: state.when(
        initial: _loading,
        loading: _loading,
        error: (f) => ErrorView(
          failure: f,
          onRetry: () => ref
              .read(tutorProfileViewModelProvider(widget.tutorId).notifier)
              .load(widget.tutorId),
        ),
        loaded: (p) => _Body(
          profile: p,
          tab: _tab,
          onTabChanged: (i) => setState(() => _tab = i),
        ),
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());
}

class _Body extends StatelessWidget {
  const _Body({
    required this.profile,
    required this.tab,
    required this.onTabChanged,
  });
  final TutorProfile profile;
  final int tab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(profile: profile)),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              decoration: const BoxDecoration(
                color: AppPalette.n100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _Tabs(active: tab, onChanged: onTabChanged),
                  const SizedBox(height: 18),
                  if (tab == 0) _Identity(profile: profile),
                  if (tab == 1) _Courses(profile: profile),
                  if (tab == 2) _Reviews(profile: profile),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.chat_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SoeButton(
                          label: 'Demander un devis',
                          icon: Icons.add,
                          fullWidth: true,
                          onPressed: () =>
                              context.push(RouteNames.parentReservations),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.profile});
  final TutorProfile profile;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 4),
            SoeAvatar(
              name: profile.fullName,
              imageUrl: profile.avatarUrl,
              size: SoeAvatarSize.detail,
            ),
            const SizedBox(height: 12),
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppPalette.yellow.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 12,
                    color: AppPalette.yellow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${profile.category} · ${profile.subjects.firstOrNull ?? ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.yellow,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                    value: profile.rating.toStringAsFixed(1),
                    label: '${profile.reviewCount} avis',
                    icon: Icons.star,
                    color: AppPalette.yellow,
                  ),
                  _Stat(
                    value: '${profile.sessionCount}',
                    label: 'Séances',
                    icon: Icons.calendar_month_outlined,
                    color: Colors.white,
                  ),
                  _Stat(
                    value: '${profile.experienceYears} ans',
                    label: 'Expérience',
                    icon: Icons.work_outline,
                    color: Colors.white,
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.onChanged});
  final int active;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    const labels = ['Identité', 'Cours', 'Avis'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.n300),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == active ? AppPalette.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == active ? Colors.white : AppPalette.n700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});
  final TutorProfile profile;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('À propos'),
        SoeCard(
          child: Text(
            profile.bio ?? 'Aucune biographie renseignée.',
            style: const TextStyle(
              fontSize: 12,
              color: AppPalette.ink,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _sectionTitle('Formations', count: profile.trainings.length),
        Column(
          children: [
            for (final t in profile.trainings)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoeCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppPalette.infoBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: AppPalette.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${t.degree} · ${t.field}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                t.year,
                                if (t.institution != null) t.institution!,
                              ].join(' · '),
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
              ),
          ],
        ),
        const SizedBox(height: 18),
        _sectionTitle('Disponibilités'),
        _AvailabilityWidget(profile: profile),
      ],
    );
  }

  Widget _sectionTitle(String title, {int? count}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
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
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.n700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
}

class _AvailabilityWidget extends StatelessWidget {
  const _AvailabilityWidget({required this.profile});
  final TutorProfile profile;
  @override
  Widget build(BuildContext context) {
    final activeDays =
        profile.availabilities.map((a) => a.weekday).toSet();
    return SoeCard(
      child: Column(
        children: [
          Row(
            children: [
              for (var d = 1; d <= 7; d++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: activeDays.contains(d)
                            ? AppPalette.successBg
                            : AppPalette.n100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _weekdayInitial(d),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: activeDays.contains(d)
                              ? AppPalette.success
                              : AppPalette.n700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (profile.availabilities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                profile.availabilities
                    .map((a) => '${_weekdayLabel(a.weekday)} ${a.timeRange}')
                    .join(' · '),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppPalette.n700,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _weekdayInitial(int d) => const ['L', 'M', 'M', 'J', 'V', 'S', 'D'][d - 1];
  String _weekdayLabel(int d) =>
      const ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][
          d - 1];
}

class _Courses extends StatelessWidget {
  const _Courses({required this.profile});
  final TutorProfile profile;
  @override
  Widget build(BuildContext context) {
    return SoeCard(
      child: profile.subjects.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Matières non renseignées',
                style: TextStyle(color: AppPalette.n700, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in profile.subjects)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.infoBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.teal,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.profile});
  final TutorProfile profile;
  @override
  Widget build(BuildContext context) {
    if (profile.reviews.isEmpty) {
      return SoeCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Aucun avis pour ce tuteur',
            style: TextStyle(color: AppPalette.n700, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final r in profile.reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SoeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.author,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppPalette.yellow,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            r.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.comment,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.ink,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMM yyyy', 'fr').format(r.date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppPalette.teal, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: AppPalette.teal),
      ),
    );
  }
}
