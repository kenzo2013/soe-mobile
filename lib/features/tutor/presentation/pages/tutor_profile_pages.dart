import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/tutor_profile.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import '../widgets/tutor_action.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_form_sheets.dart';
import '../widgets/tutor_ui.dart';

// ════════════════════════════════════════════════════════════
// 1 · Hub du profil
// ════════════════════════════════════════════════════════════
class TutorProfileHubPage extends ConsumerWidget {
  const TutorProfileHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorProfileViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorProfile),
      appBar: TutorAppBar(
        title: tr.tutor.profile.title,
        subtitle: tr.tutor.profile.subtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorProfileViewModelProvider.notifier).refresh(),
        ),
        loaded: (p) => _HubBody(profile: p),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.profile});
  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final sections = <_HubSection>[
      _HubSection(tr.tutor.profile.hubBio, tr.tutor.profile.hubBioSub,
          Icons.description_outlined, RouteNames.tutorProfileBio, true),
      _HubSection(
          tr.tutor.profile.hubTrainings,
          tr.tutor.profile.hubTrainingsSub,
          Icons.school_outlined,
          RouteNames.tutorProfileTrainings,
          true),
      _HubSection(tr.tutor.profile.hubWorks, tr.tutor.profile.hubWorksSub,
          Icons.work_outline, RouteNames.tutorProfileWorks, true),
      _HubSection(
          tr.tutor.profile.hubIdentities,
          tr.tutor.profile.hubIdentitiesSub,
          Icons.badge_outlined,
          RouteNames.tutorProfileIdentities,
          true),
      _HubSection(tr.tutor.profile.hubCourses, tr.tutor.profile.hubCoursesSub,
          Icons.menu_book_outlined, RouteNames.tutorProfileCourses, true),
      _HubSection(
          tr.tutor.profile.hubAvailabilities,
          tr.tutor.profile.hubAvailabilitiesSub,
          Icons.calendar_month_outlined,
          RouteNames.tutorProfileAvailabilities,
          true),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Hero
        SoeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SoeAvatar(
                      name: profile.fullName,
                      imageUrl: profile.avatarUrl,
                      size: SoeAvatarSize.list,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${profile.category} · ${profile.city}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 13, color: AppPalette.yellow),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                tr.tutor.profile.reviewsSuffix(
                                    count: profile.reviews),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr.tutor.profile.completed,
                            style: const TextStyle(
                                fontSize: 12, color: AppPalette.n700)),
                        Text(
                          '${profile.completion}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: profile.completion / 100,
                        minHeight: 6,
                        backgroundColor: AppPalette.n100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppPalette.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final s in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => context.push(s.route),
              borderRadius: BorderRadius.circular(14),
              child: SoeCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppPalette.n100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, size: 18, color: AppPalette.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: s.done
                                  ? AppPalette.success
                                  : AppPalette.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppPalette.n500),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HubSection {
  const _HubSection(this.label, this.status, this.icon, this.route, this.done);
  final String label;
  final String status;
  final IconData icon;
  final String route;
  final bool done;
}

// ════════════════════════════════════════════════════════════
// 2 · Bio / Description (éditeur)
// ════════════════════════════════════════════════════════════
class TutorBioPage extends ConsumerWidget {
  const TutorBioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorProfileViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.bioTitle,
        subtitle: tr.tutor.profile.bioSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(failure: f),
        loaded: (p) => _BioEditor(bio: p.bio),
      ),
    );
  }
}

class _BioEditor extends ConsumerStatefulWidget {
  const _BioEditor({required this.bio});
  final String bio;
  @override
  ConsumerState<_BioEditor> createState() => _BioEditorState();
}

class _BioEditorState extends ConsumerState<_BioEditor> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.bio);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final submitting =
        ref.watch(tutorActionViewModelProvider('bio')) is TutorActionSubmitting;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Eyebrow(tr.tutor.profile.editor),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPalette.n300),
          ),
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _ctrl,
            maxLines: 8,
            maxLength: 800,
            decoration: InputDecoration.collapsed(
              hintText: tr.tutor.profile.bioHint,
            ),
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppPalette.ink,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SoeButton(
          label: tr.common.save,
          fullWidth: true,
          loading: submitting,
          onPressed: () => runTutorAction(
            context,
            ref,
            actionKey: 'bio',
            successMessage: tr.tutor.profile.bioSaved,
            op: () => ref.read(saveTutorBioProvider)(_ctrl.text.trim()),
            onSuccess: () =>
                ref.read(tutorProfileViewModelProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// 3 · Formations
// ════════════════════════════════════════════════════════════
class TutorTrainingsPage extends ConsumerWidget {
  const TutorTrainingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorTrainingsViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.trainingsTitle,
        subtitle: tr.tutor.profile.trainingsSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorTrainingsViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              tr.tutor.profile.trainingsCount(count: items.length),
              style: const TextStyle(fontSize: 12, color: AppPalette.n700),
            ),
            const SizedBox(height: 12),
            for (final t in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => showTrainingSheet(context, ref, existing: t),
                  borderRadius: BorderRadius.circular(14),
                  child: SoeCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.level,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.domain,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.teal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr.tutor.profile
                                    .specialtyLabel(value: t.specialty),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppPalette.n700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 12, color: AppPalette.n700),
                                  const SizedBox(width: 4),
                                  Text(
                                    tr.tutor.profile
                                        .obtainedIn(date: t.date),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppPalette.n700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (await confirmDelete(context,
                                    tr.tutor.profile.deleteThisTraining) &&
                                context.mounted) {
                              await runTutorAction(
                                context,
                                ref,
                                actionKey: 'training_del',
                                successMessage:
                                    tr.tutor.profile.trainingDeleted,
                                popOnSuccess: false,
                                op: () =>
                                    ref.read(deleteTutorTrainingProvider)(t.id),
                                onSuccess: () => ref
                                    .read(tutorTrainingsViewModelProvider
                                        .notifier)
                                    .refresh(),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.delete_outline,
                                size: 18, color: AppPalette.n700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            TutorAddTile(
              label: tr.tutor.profile.newTraining,
              onTap: () => showTrainingSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 4 · Expériences professionnelles (timeline)
// ════════════════════════════════════════════════════════════
class TutorWorksPage extends ConsumerWidget {
  const TutorWorksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorWorksViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.worksTitle,
        subtitle: tr.tutor.profile.worksSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorWorksViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final w in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14, left: 4),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: w.current
                                  ? AppPalette.yellow
                                  : AppPalette.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: w.current
                                    ? AppPalette.yellow
                                    : AppPalette.n500,
                                width: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppPalette.n300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => showWorkSheet(context, ref, existing: w),
                          borderRadius: BorderRadius.circular(14),
                          child: SoeCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        w.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppPalette.ink,
                                        ),
                                      ),
                                    ),
                                    if (w.current) ...[
                                      const SizedBox(width: 8),
                                      TutorPillBadge(
                                        label: tr.tutor.profile.currentPosition,
                                        bg: AppPalette.successBg,
                                        fg: AppPalette.success,
                                      ),
                                    ],
                                    const Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        if (await confirmDelete(
                                                context,
                                                tr.tutor.profile
                                                    .deleteThisWork) &&
                                            context.mounted) {
                                          await runTutorAction(
                                            context,
                                            ref,
                                            actionKey: 'work_del',
                                            successMessage:
                                                tr.tutor.profile.workDeleted,
                                            popOnSuccess: false,
                                            op: () => ref.read(
                                                deleteTutorWorkProvider)(w.id),
                                            onSuccess: () => ref
                                                .read(
                                                    tutorWorksViewModelProvider
                                                        .notifier)
                                                .refresh(),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(22),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(Icons.delete_outline,
                                            size: 18, color: AppPalette.n500),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  w.company,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppPalette.teal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${w.since} – ${w.until ?? tr.tutor.profile.today}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppPalette.n700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            TutorAddTile(
              label: tr.tutor.profile.addWork,
              onTap: () => showWorkSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 5 · Pièces d'identité
// ════════════════════════════════════════════════════════════
class TutorIdentitiesPage extends ConsumerWidget {
  const TutorIdentitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorIdentitiesViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.identitiesTitle,
        subtitle: tr.tutor.profile.identitiesSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorIdentitiesViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppPalette.infoBg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppPalette.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr.tutor.profile.identitiesEncryptedNote,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.info,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final d in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => showIdentitySheet(context, ref, existing: d),
                  borderRadius: BorderRadius.circular(14),
                  child: SoeCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppPalette.n100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    size: 20,
                                    color: AppPalette.teal),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          d.type,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppPalette.ink,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _identityBadge(tr, d.status),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () async {
                                            if (await confirmDelete(
                                                    context,
                                                    tr.tutor.profile
                                                        .deleteThisDocument) &&
                                                context.mounted) {
                                              await runTutorAction(
                                                context,
                                                ref,
                                                actionKey: 'identity_del',
                                                successMessage: tr.tutor.profile
                                                    .documentDeleted,
                                                popOnSuccess: false,
                                                op: () => ref.read(
                                                        deleteTutorIdentityProvider)(
                                                    d.id),
                                                onSuccess: () => ref
                                                    .read(
                                                        tutorIdentitiesViewModelProvider
                                                            .notifier)
                                                    .refresh(),
                                              );
                                            }
                                          },
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(Icons.delete_outline,
                                                size: 18,
                                                color: AppPalette.n500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tr.tutor.profile.expiresPhotos(
                                          date: d.expires, count: d.photos),
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
                        if (d.photoUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Row(
                              children: [
                                for (var i = 0; i < d.photoUrls.length; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: i < d.photoUrls.length - 1
                                              ? 8
                                              : 0),
                                      child: AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            d.photoUrls[i],
                                            fit: BoxFit.cover,
                                            loadingBuilder: (ctx, child,
                                                    progress) =>
                                                progress == null
                                                    ? child
                                                    : const _PhotoPlaceholder(
                                                        loading: true),
                                            errorBuilder: (ctx, _, __) =>
                                                const _PhotoPlaceholder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            TutorAddTile(
              label: tr.tutor.profile.addDocument,
              icon: Icons.add_a_photo_outlined,
              padding: const EdgeInsets.all(24),
              onTap: () => showIdentitySheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identityBadge(Translations tr, TutorIdentityStatus s) {
    final BadgeSpec spec = switch (s) {
      TutorIdentityStatus.approved => (
          tr.tutor.profile.identityApproved,
          AppPalette.successBg,
          AppPalette.success
        ),
      TutorIdentityStatus.pending => (
          tr.tutor.profile.identityPending,
          AppPalette.warningBg,
          AppPalette.warning
        ),
      TutorIdentityStatus.rejected => (
          tr.tutor.profile.identityRejected,
          AppPalette.dangerBg,
          AppPalette.danger
        ),
      TutorIdentityStatus.unknown => ('—', AppPalette.n100, AppPalette.n700),
    };
    return TutorPillBadge(label: spec.$1, bg: spec.$2, fg: spec.$3);
  }
}

// ════════════════════════════════════════════════════════════
// 6 · Matières enseignées par niveau
// ════════════════════════════════════════════════════════════
class TutorCoursesProfilePage extends ConsumerWidget {
  const TutorCoursesProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorTeachingCoursesViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.teachingCoursesTitle,
        subtitle: tr.tutor.profile.teachingCoursesSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () => ref
              .read(tutorTeachingCoursesViewModelProvider.notifier)
              .refresh(),
        ),
        loaded: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final c in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () =>
                      showTeachingCourseSheet(context, ref, existing: c),
                  borderRadius: BorderRadius.circular(14),
                  child: SoeCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppPalette.teal.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                c.classe,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tr.tutor.profile
                                    .subjectsCount(count: c.subjects.length),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppPalette.n700,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if (await confirmDelete(context,
                                        tr.tutor.profile.deleteThisClass) &&
                                    context.mounted) {
                                  await runTutorAction(
                                    context,
                                    ref,
                                    actionKey: 'course_del',
                                    successMessage:
                                        tr.tutor.profile.classDeleted,
                                    popOnSuccess: false,
                                    op: () => ref.read(
                                            deleteTutorTeachingCourseProvider)(
                                        c.id),
                                    onSuccess: () => ref
                                        .read(
                                            tutorTeachingCoursesViewModelProvider
                                                .notifier)
                                        .refresh(),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.delete_outline,
                                    size: 18, color: AppPalette.n700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final s in c.subjects) TutorTagChip(label: s),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            TutorAddTile(
              label: tr.tutor.profile.addClass,
              onTap: () => showTeachingCourseSheet(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// 7 · Disponibilités hebdomadaires
// ════════════════════════════════════════════════════════════
class TutorAvailabilitiesPage extends ConsumerWidget {
  const TutorAvailabilitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(tutorAvailabilitiesViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: tr.tutor.profile.availabilitiesTitle,
        subtitle: tr.tutor.profile.availabilitiesSubtitle,
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorAvailabilitiesViewModelProvider.notifier).refresh(),
        ),
        loaded: (days) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              tr.tutor.profile.availabilitiesIntro,
              style: const TextStyle(fontSize: 12, color: AppPalette.n700),
            ),
            const SizedBox(height: 14),
            for (final d in days)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoeCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: d.isAvailable
                                  ? AppPalette.teal
                                  : AppPalette.n100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              d.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: d.isAvailable
                                    ? Colors.white
                                    : AppPalette.n500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              d.isAvailable
                                  ? tr.tutor.profile
                                      .slotsCount(count: d.slots.length)
                                  : tr.tutor.profile.unavailable,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: d.isAvailable
                                    ? AppPalette.ink
                                    : AppPalette.n500,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => showAvailabilitySheet(context, ref),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppPalette.n100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add,
                                  size: 14, color: AppPalette.teal),
                            ),
                          ),
                        ],
                      ),
                      if (d.isAvailable) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final s in d.slots)
                              Container(
                                padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppPalette.yellow.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${s.from} – ${s.to}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppPalette.ink,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: d.recordId == null
                                          ? null
                                          : () async {
                                              if (await confirmDelete(
                                                      context,
                                                      tr.tutor.profile
                                                          .deleteAvailabilityOf(
                                                              day: d.label)) &&
                                                  context.mounted) {
                                                await runTutorAction(
                                                  context,
                                                  ref,
                                                  actionKey: 'avail_del',
                                                  successMessage: tr.tutor
                                                      .profile
                                                      .availabilityDeleted,
                                                  popOnSuccess: false,
                                                  op: () => ref.read(
                                                      deleteTutorAvailabilityProvider)(
                                                    d.recordId!,
                                                  ),
                                                  onSuccess: () => ref
                                                      .read(
                                                          tutorAvailabilitiesViewModelProvider
                                                              .notifier)
                                                      .refresh(),
                                                );
                                              }
                                            },
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: AppPalette.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 12, color: AppPalette.n700),
                                      ),
                                    ),
                                  ],
                                ),
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

// ── Helpers locaux ───────────────────────────────────────────
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppPalette.teal,
            letterSpacing: 1,
          ),
        ),
      );
}

/// Vignette de remplacement d'une photo de document (chargement / erreur).
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({this.loading = false});
  final bool loading;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppPalette.n100, AppPalette.n300],
          ),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPalette.n500,
                  ),
                )
              : const Icon(Icons.image_outlined,
                  size: 20, color: AppPalette.n500),
        ),
      );
}

/// Action mock : aucune écriture côté API tant qu'elle n'est pas branchée.
void stubAction(BuildContext context) => SoeToast.show(
      context,
      message: Translations.of(context).tutor.profile.stubAction,
      tone: SoeToastTone.info,
    );
