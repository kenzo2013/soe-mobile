import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/child.dart';
import '../providers.dart';

/// Libellé du genre traduit (remplace `child.genderLabel` côté entité).
String _genderLabel(Translations tr, ChildGender gender) => switch (gender) {
      ChildGender.male => tr.parent.childDetail.genderBoy,
      ChildGender.feminine => tr.parent.childDetail.genderGirl,
      ChildGender.unknown => '—',
    };

class ParentChildDetailPage extends ConsumerStatefulWidget {
  const ParentChildDetailPage({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ParentChildDetailPage> createState() =>
      _ParentChildDetailPageState();
}

class _ParentChildDetailPageState extends ConsumerState<ParentChildDetailPage> {
  int _tab = 2; // emploi du temps par défaut

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    // On lit la liste pour récupérer l'enfant — évite un nouvel endpoint.
    final list = ref.watch(childrenListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      body: list.when(
        initial: _loading,
        loading: _loading,
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(childrenListViewModelProvider.notifier).refresh(),
        ),
        loaded: (children) {
          final child = children.where((c) => c.id == widget.id).firstOrNull;
          if (child == null) {
            return Center(child: Text(tr.parent.childDetail.notFound));
          }
          return _DetailBody(
            child: child,
            tab: _tab,
            onTabChanged: (i) => setState(() => _tab = i),
          );
        },
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.child,
    required this.tab,
    required this.onTabChanged,
  });
  final Child child;
  final int tab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(child: child)),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -32),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppPalette.n100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatsRow(subjects: child.subjects.length),
                  const SizedBox(height: 18),
                  _Tabs(active: tab, onChanged: onTabChanged),
                  const SizedBox(height: 18),
                  if (tab == 0) _DetailsTab(child: child),
                  if (tab == 1) _SubjectsTab(subjects: child.subjects),
                  if (tab == 2) const _ScheduleTab(),
                  const SizedBox(height: 22),
                  SoeButton(
                    label: tr.parent.childDetail.requestNewTutor,
                    icon: Icons.add,
                    fullWidth: true,
                    onPressed: () =>
                        context.push(RouteNames.parentReservations),
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
  const _Hero({required this.child});
  final Child child;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 60),
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
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () =>
                      context.push(RouteNames.parentStudentEdit(child.id)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            SoeAvatar(
              name: child.fullName,
              imageUrl: child.avatarUrl,
              size: SoeAvatarSize.profile,
            ),
            const SizedBox(height: 12),
            Text(
              child.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              [
                if (child.classe != null) child.classe!,
                tr.parent.childDetail.ageValue(age: child.age),
                if (child.section != null)
                  tr.parent.childDetail.sectionValue(section: child.section!),
              ].join(' · '),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.subjects});
  final int subjects;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
              child: _stat('$subjects', tr.parent.childDetail.statSubjects)),
          Container(width: 1, height: 44, color: AppPalette.n100),
          Expanded(child: _stat('—', tr.parent.childDetail.statSessions)),
          Container(width: 1, height: 44, color: AppPalette.n100),
          Expanded(child: _stat('—', tr.parent.childDetail.statAverage)),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              v,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l,
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
          ],
        ),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.onChanged});
  final int active;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final labels = [
      tr.parent.childDetail.tabDetails,
      tr.parent.childDetail.tabSubjects,
      tr.parent.childDetail.tabSchedule,
    ];
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
                      fontSize: 11,
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

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.child});
  final Child child;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(tr.parent.childDetail.firstName, child.firstName),
          _row(tr.parent.childDetail.lastName, child.lastName),
          _row(tr.parent.childDetail.age,
              tr.parent.childDetail.ageValue(age: child.age)),
          _row(tr.parent.childDetail.gender, _genderLabel(tr, child.gender)),
          if (child.classe != null)
            _row(tr.parent.childDetail.schoolClass, child.classe!),
          if (child.section != null)
            _row(tr.parent.childDetail.section, child.section!),
          if (child.address != null)
            _row(tr.parent.childDetail.address, child.address!),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.n700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.ink,
                ),
              ),
            ),
          ],
        ),
      );
}

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab({required this.subjects});
  final List<String> subjects;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    if (subjects.isEmpty) {
      return SoeCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              tr.parent.childDetail.noSubjects,
              style: const TextStyle(color: AppPalette.n700, fontSize: 12),
            ),
          ),
        ),
      );
    }
    return SoeCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in subjects)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            tr.parent.childDetail.noSessionsPlanned,
            style: const TextStyle(color: AppPalette.n700, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
