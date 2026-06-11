import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/child.dart';
import '../providers.dart';
import '../widgets/parent_drawer.dart';

class ParentChildrenListPage extends ConsumerWidget {
  const ParentChildrenListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(childrenListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(activeRoute: RouteNames.parentStudents),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: state.maybeWhen(
          loaded: (children) => _Title(count: children.length),
          orElse: () => const _Title(count: null),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _AddButton(
              onTap: () => context.push(RouteNames.parentStudentNew),
            ),
          ),
        ],
      ),
      body: state.when(
        initial: () => const _Skeleton(),
        loading: () => const _Skeleton(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(childrenListViewModelProvider.notifier).refresh(),
        ),
        loaded: (children) => RefreshIndicator(
          onRefresh: () =>
              ref.read(childrenListViewModelProvider.notifier).refresh(),
          child: children.isEmpty
              ? _Empty(
                  onAdd: () => context.push(RouteNames.parentStudentNew),
                )
              : _LoadedList(children: children),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.count});
  final int? count;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final c = count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tr.parent.children.title,
          style: const TextStyle(
            color: AppPalette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (c != null) ...[
          const SizedBox(height: 2),
          Text(
            c == 0
                ? tr.parent.children.countNone
                : c == 1
                    ? tr.parent.children.countOne
                    : tr.parent.children.countMany(count: c),
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.n700,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppPalette.yellow,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppPalette.yellow.withValues(alpha: 0.35),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppPalette.ink, size: 20),
      ),
    );
  }
}

class _LoadedList extends StatelessWidget {
  const _LoadedList({required this.children});
  final List<Child> children;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: children.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == children.length) {
          return _AddChildCta(
            onTap: () => context.push(RouteNames.parentStudentNew),
          );
        }
        final c = children[i];
        return _ChildCard(child: c);
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});
  final Child child;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => context.push(RouteNames.parentStudentDetail(child.id)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SoeAvatar(
                    name: child.fullName,
                    imageUrl: child.avatarUrl,
                    size: SoeAvatarSize.list,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            if (child.classe != null) child.classe!,
                            '${child.age} ans',
                            child.genderLabel,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.n700,
                          ),
                        ),
                        if (child.subjects.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final s in child.subjects.take(2))
                                _SubjectPill(label: s, primary: true),
                              if (child.subjects.length > 2)
                                _SubjectPill(
                                  label: '+${child.subjects.length - 2}',
                                  primary: false,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppPalette.n500,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppPalette.n100),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  icon: Icons.calendar_month_outlined,
                  label: tr.parent.children.schedule,
                  onTap: () =>
                      context.push(RouteNames.parentStudentDetail(child.id)),
                ),
              ),
              Container(width: 1, height: 36, color: AppPalette.n100),
              Expanded(
                child: _CardAction(
                  icon: Icons.description_outlined,
                  label: tr.parent.children.requestTutor,
                  onTap: () => context.push(RouteNames.parentReservations),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectPill extends StatelessWidget {
  const _SubjectPill({required this.label, required this.primary});
  final String label;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary ? AppPalette.infoBg : AppPalette.n100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: primary ? AppPalette.teal : AppPalette.n700,
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppPalette.teal),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppPalette.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChildCta extends StatelessWidget {
  const _AddChildCta({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DottedBorder(
        radius: 14,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 18, color: AppPalette.teal),
              const SizedBox(width: 8),
              Text(
                tr.parent.children.addAnother,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordure pointillée custom (pas de dépendance externe).
class DottedBorder extends StatelessWidget {
  const DottedBorder({super.key, required this.child, this.radius = 14});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.radius});
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.n500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppPalette.infoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 44,
              color: AppPalette.teal,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          tr.parent.children.emptyTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr.parent.children.emptyBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13, color: AppPalette.n700, height: 1.5),
        ),
        const SizedBox(height: 24),
        _AddChildCta(onTap: onAdd),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => SoeCard(
        child: Row(
          children: const [
            SoeSkeleton(
              width: 52,
              height: 52,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoeSkeleton(width: 140, height: 14),
                  SizedBox(height: 8),
                  SoeSkeleton(width: 100, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
