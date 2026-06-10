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
import '../../domain/entities/tutor_form_params.dart';
import '../../domain/entities/tutor_session.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import '../widgets/tutor_action.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_signature.dart';
import '../widgets/tutor_ui.dart';

// ════════════════════════════════════════════════════════════
// Liste des séances (groupée par jour)
// ════════════════════════════════════════════════════════════
class TutorSessionsListPage extends ConsumerWidget {
  const TutorSessionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorSessionsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorSessions),
      appBar: const TutorAppBar(
        title: 'Mes séances',
        subtitle: 'Vos cours planifiés',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorSessionsListViewModelProvider.notifier).refresh(),
        ),
        loaded: (groups) => RefreshIndicator(
          color: AppPalette.teal,
          onRefresh: () =>
              ref.read(tutorSessionsListViewModelProvider.notifier).refresh(),
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
                      ('À venir', false),
                      ('Terminées', false),
                      ('Rapport dû', false),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _FilterPill(label: f.$1, on: f.$2),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final g in groups) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    g.day.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.teal,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                for (final s in g.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SessionRow(
                      session: s,
                      onTap: () =>
                          context.push(RouteNames.tutorSessionDetail(s.id)),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
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

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.onTap});
  final TutorSession session;
  final VoidCallback onTap;

  Color get _accent => switch (session.status) {
        TutorSessionStatus.completed => AppPalette.success,
        TutorSessionStatus.inProgress => AppPalette.warning,
        _ => AppPalette.teal,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SoeCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.timeRange,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (session.reportAvailable && !session.reportSubmitted)
                        const TutorPillBadge(
                          label: 'Rapport dû',
                          bg: AppPalette.warningBg,
                          fg: AppPalette.warning,
                        ),
                      if (session.reportSubmitted)
                        const TutorPillBadge(
                          label: 'Rapport ✓',
                          bg: AppPalette.successBg,
                          fg: AppPalette.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.subject,
                    style: const TextStyle(fontSize: 12, color: AppPalette.ink),
                  ),
                  Text(
                    session.student,
                    style:
                        const TextStyle(fontSize: 11, color: AppPalette.n700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppPalette.n500),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Détail séance
// ════════════════════════════════════════════════════════════
class TutorSessionDetailPage extends ConsumerWidget {
  const TutorSessionDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorSessionDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Détail séance',
        subtitle: 'Informations et actions disponibles',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () => ref
              .read(tutorSessionDetailViewModelProvider(id).notifier)
              .load(id),
        ),
        loaded: (s) {
          final spec = sessionStatusSpec(s.status);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TutorPillBadge(label: spec.$1, bg: spec.$2, fg: spec.$3),
                    const SizedBox(height: 10),
                    Text(
                      s.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppPalette.n700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.dateLine,
                            style: const TextStyle(
                                fontSize: 12, color: AppPalette.n700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppPalette.n300),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SoeAvatar(name: s.student, size: SoeAvatarSize.mini),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.student,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppPalette.ink,
                                ),
                              ),
                              Text(
                                '${s.classe} · Réservation ${s.reservationRef}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppPalette.n700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppPalette.n100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.call_outlined,
                              size: 14, color: AppPalette.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _title('État de la séance'),
              SoeCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _FlagRow(
                      icon: Icons.tune,
                      label: 'Modifiable',
                      value: s.editableReason,
                      ok: s.editable,
                    ),
                    const Divider(height: 1, color: AppPalette.n300),
                    _FlagRow(
                      icon: Icons.draw_outlined,
                      label: 'Rapport disponible',
                      value: s.reportReason,
                      ok: s.reportAvailable,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _title('Actions'),
              _ActionTile(
                icon: Icons.draw_outlined,
                title: 'Soumettre le rapport',
                sub: 'Avec contenu et signature',
                enabled: s.reportAvailable,
                accent: true,
                onTap: () => context.push(RouteNames.tutorSessionReport(s.id)),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.edit_calendar_outlined,
                title: 'Modifier la séance',
                sub: s.editable
                    ? 'Reporter ou ajuster'
                    : 'Indisponible (> 24h requis)',
                enabled: s.editable,
                onTap: () => context.push(RouteNames.tutorSessionEdit(s.id)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _title(String t) => Padding(
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

class _FlagRow extends StatelessWidget {
  const _FlagRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final fg = ok ? AppPalette.success : AppPalette.n700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: AppPalette.n700)),
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.enabled,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String title;
  final String sub;
  final bool enabled;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? AppPalette.yellow : AppPalette.white,
        borderRadius: BorderRadius.circular(12),
        border: accent ? null : Border.all(color: AppPalette.n300),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent
                  ? Colors.black.withValues(alpha: 0.08)
                  : AppPalette.n100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 18, color: accent ? AppPalette.ink : AppPalette.n700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: accent
                        ? AppPalette.ink.withValues(alpha: 0.65)
                        : AppPalette.n700,
                  ),
                ),
              ],
            ),
          ),
          if (accent)
            const Icon(Icons.chevron_right, size: 16, color: AppPalette.ink),
        ],
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: body,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Modifier la séance
// ════════════════════════════════════════════════════════════
class TutorSessionEditPage extends ConsumerWidget {
  const TutorSessionEditPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorSessionDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Modifier la séance',
        subtitle: 'Reporter ou ajuster un cours',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(failure: f),
        loaded: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _title('Date et horaires'),
            SoeCard(
              child: Column(
                children: [
                  const _Field(
                      label: 'Date',
                      value: 'Vendredi 15 mai 2026',
                      icon: Icons.calendar_today_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                            label: 'Début',
                            value: s.timeRange.split('–').first.trim(),
                            icon: Icons.schedule_outlined),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                            label: 'Fin',
                            value: s.timeRange.split('–').last.trim(),
                            icon: Icons.schedule_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _title('Lieu'),
            const SoeCard(
              child: _Field(
                label: 'Adresse',
                value: "Bastos · Rue de l'Étoile, Yaoundé",
                icon: Icons.place_outlined,
              ),
            ),
            const SizedBox(height: 14),
            _title('Note au parent (optionnel)'),
            Container(
              decoration: BoxDecoration(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.n300),
              ),
              padding: const EdgeInsets.all(14),
              child: const TextField(
                maxLines: 3,
                decoration: InputDecoration.collapsed(
                  hintText: 'Décalage demandé suite à un imprévu…',
                ),
                style: TextStyle(fontSize: 13, color: AppPalette.ink),
              ),
            ),
            const SizedBox(height: 20),
            SoeButton(
              label: 'Enregistrer les modifications',
              fullWidth: true,
              loading:
                  ref.watch(tutorActionViewModelProvider('session_edit:$id'))
                      is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                context,
                ref,
                actionKey: 'session_edit:$id',
                successMessage: 'Demande envoyée',
                op: () => ref.read(updateTutorSessionProvider)(
                  id,
                  const TutorSessionEditParams(note: 'Demande de modification'),
                ),
                onSuccess: () => ref
                    .read(tutorSessionDetailViewModelProvider(id).notifier)
                    .load(id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppPalette.n700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppPalette.n50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppPalette.n300),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppPalette.teal),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// Rapport de séance (avec signature)
// ════════════════════════════════════════════════════════════
class TutorSessionReportPage extends ConsumerStatefulWidget {
  const TutorSessionReportPage({super.key, required this.id});
  final String id;

  @override
  ConsumerState<TutorSessionReportPage> createState() =>
      _TutorSessionReportPageState();
}

class _TutorSessionReportPageState
    extends ConsumerState<TutorSessionReportPage> {
  final _signature = TutorSignatureController();
  final _proceedings = TextEditingController(
    text: 'Chapitre : Théorème de Pythagore\n'
        '- Énoncé et démonstration\n'
        "- 5 exercices d'application",
  );

  @override
  void dispose() {
    _signature.dispose();
    _proceedings.dispose();
    super.dispose();
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final file = await _signature.toTempFile(const Size(320, 160));
    if (!mounted) return;
    if (file == null) {
      SoeToast.show(context,
          message: 'Veuillez signer le rapport', tone: SoeToastTone.warning);
      return;
    }
    await runTutorAction(
      context,
      ref,
      actionKey: 'report:${widget.id}',
      successMessage: 'Rapport soumis',
      op: () => ref.read(submitTutorSessionReportProvider)(
        widget.id,
        TutorSessionReportParams(
          date: _today(),
          startAt: '10:05',
          endAt: '12:00',
          proceedings: _proceedings.text.trim(),
          signature: file,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(
      tutorActionViewModelProvider('report:${widget.id}'),
    ) is TutorActionSubmitting;
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const TutorAppBar(
        title: 'Rapport de séance',
        subtitle: 'Compte-rendu avec signature',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppPalette.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 14, color: AppPalette.teal),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Junior Talla · Mathématiques · 13 mai 2026',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _title('Heures effectives'),
          const SoeCard(
            child: Row(
              children: [
                Expanded(
                  child: _Field(
                      label: 'Début effectif',
                      value: '10:05',
                      icon: Icons.schedule_outlined),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _Field(
                      label: 'Fin effective',
                      value: '12:00',
                      icon: Icons.schedule_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _title('Contenu de la séance'),
          Container(
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.n300),
            ),
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _proceedings,
              maxLines: 5,
              decoration: const InputDecoration.collapsed(
                hintText: 'Ce qui a été couvert pendant la séance…',
              ),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppPalette.ink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _title('Signature du tuteur'),
          TutorSignaturePad(controller: _signature),
          const SizedBox(height: 6),
          const Text(
            'Signez avec votre doigt dans le cadre',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppPalette.n700),
          ),
          const SizedBox(height: 20),
          SoeButton(
            label: 'Soumettre le rapport',
            fullWidth: true,
            loading: submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
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
