/// 4 pages mini-features regroupées : reviews, programs, invitations, contracts.
/// UI minimaliste (liste + état vide/erreur). Le polish design sera fait
/// dans une vague d'enrichissement dédiée.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/parent_invitation.dart';
import '../../domain/entities/parent_program.dart';
import '../../domain/entities/parent_review.dart';
import '../providers.dart';
import '../viewmodels/misc_viewmodels.dart';
import '../widgets/parent_drawer.dart';

class _Shell extends StatelessWidget {
  const _Shell({
    required this.title,
    required this.activeRoute,
    required this.body,
  });
  final String title;
  final String activeRoute;
  final Widget body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: ParentDrawer(activeRoute: activeRoute),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppPalette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: body,
    );
  }
}

Widget _asyncList<T>({
  required AsyncListState<T> state,
  required Widget Function(List<T>) onLoaded,
  required VoidCallback onRetry,
}) {
  if (state is AsyncListInitial<T> || state is AsyncListLoading<T>) {
    return const Center(child: CircularProgressIndicator());
  }
  if (state is AsyncListError<T>) {
    return ErrorView(failure: state.failure, onRetry: onRetry);
  }
  final loaded = state as AsyncListLoaded<T>;
  return RefreshIndicator(
    onRefresh: () async => onRetry(),
    child: onLoaded(loaded.items),
  );
}

// ────────────────────────────────────────────────────────────────
// Reviews
// ────────────────────────────────────────────────────────────────
class ParentReviewsListPage extends ConsumerWidget {
  const ParentReviewsListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsListViewModelProvider(null));
    return _Shell(
      title: 'Mes avis',
      activeRoute: '/parent/reviews',
      body: _asyncList<ParentReview>(
        state: state as AsyncListState<ParentReview>,
        onRetry: () =>
            ref.read(reviewsListViewModelProvider(null).notifier).refresh(),
        onLoaded: (items) => items.isEmpty
            ? const _EmptyState(message: 'Aucun avis donné pour le moment')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ReviewCard(review: items[i]),
              ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ParentReview review;
  @override
  Widget build(BuildContext context) {
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoeAvatar(name: review.tutorName, size: SoeAvatarSize.mini),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.tutorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                      ),
                    ),
                    Text(
                      '${review.subject} · ${DateFormat('d MMM', "fr").format(review.createdAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.n700,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var n = 1; n <= 5; n++)
                    Icon(
                      Icons.star,
                      size: 12,
                      color: n <= review.score
                          ? AppPalette.yellow
                          : AppPalette.n300,
                    ),
                ],
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.ink,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Programs
// ────────────────────────────────────────────────────────────────
class ParentProgramsListPage extends ConsumerWidget {
  const ParentProgramsListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programsListViewModelProvider(null));
    return _Shell(
      title: 'Programmes',
      activeRoute: '/parent/programs',
      body: _asyncList<ParentProgram>(
        state: state as AsyncListState<ParentProgram>,
        onRetry: () =>
            ref.read(programsListViewModelProvider(null).notifier).refresh(),
        onLoaded: (items) => items.isEmpty
            ? const _EmptyState(message: 'Aucun programme disponible')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = items[i];
                  return SoeCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.subject} · ${p.level}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppPalette.n700,
                          ),
                        ),
                        if (p.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            p.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.ink,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppPalette.n300,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: p.progress.clamp(0.0, 1.0),
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppPalette.success,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(p.progress * 100).round()}% complet',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppPalette.n700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Invitations
// ────────────────────────────────────────────────────────────────
class ParentInvitationsListPage extends ConsumerWidget {
  const ParentInvitationsListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invitationsListViewModelProvider(null));
    return _Shell(
      title: 'Invitations',
      activeRoute: '/parent/invitations',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const _InviteSheet(),
                );
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Inviter une personne'),
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.yellow,
                foregroundColor: AppPalette.ink,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          Expanded(
            child: _asyncList<ParentInvitation>(
              state: state as AsyncListState<ParentInvitation>,
              onRetry: () => ref
                  .read(invitationsListViewModelProvider(null).notifier)
                  .refresh(),
              onLoaded: (items) => items.isEmpty
                  ? const _EmptyState(message: 'Aucune invitation envoyée')
                  : ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _InvitationCard(
                        invitation: items[i],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});
  final ParentInvitation invitation;
  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (invitation.status) {
      InvitationStatus.pending => (
        'En attente',
        AppPalette.warningBg,
        AppPalette.warning
      ),
      InvitationStatus.accepted => (
        'Acceptée',
        AppPalette.successBg,
        AppPalette.success
      ),
      InvitationStatus.rejected => (
        'Refusée',
        AppPalette.dangerBg,
        AppPalette.danger
      ),
      InvitationStatus.expired => (
        'Expirée',
        AppPalette.n100,
        AppPalette.n700
      ),
      InvitationStatus.unknown => ('—', AppPalette.n100, AppPalette.n700),
    };
    return SoeCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.fullName ?? invitation.email,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${invitation.relationship ?? "—"} · ${DateFormat('d MMM y', "fr").format(invitation.sentAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();
  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _relation = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _relation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final repo = ref.read(invitationsRepositoryProvider);
    final r = await repo.invite(InviteParams(
      email: _email.text.trim(),
      fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      relationship:
          _relation.text.trim().isEmpty ? null : _relation.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _sending = false);
    r.isOk
        ? Navigator.of(context).pop(true)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'invitation')),
          );
    if (r.isOk) {
      ref.read(invitationsListViewModelProvider(null).notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Inviter une personne',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _relation,
            decoration: const InputDecoration(
              labelText: 'Relation (ex: co-parent, grand-parent)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.yellow,
              foregroundColor: AppPalette.ink,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Envoyer l\'invitation'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Contracts
// ────────────────────────────────────────────────────────────────
class ParentContractsListPage extends ConsumerWidget {
  const ParentContractsListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contractsListViewModelProvider(null));
    return _Shell(
      title: 'Contrats',
      activeRoute: '/parent/contracts',
      body: _asyncList<Contract>(
        state: state as AsyncListState<Contract>,
        onRetry: () => ref
            .read(contractsListViewModelProvider(null).notifier)
            .refresh(),
        onLoaded: (items) => items.isEmpty
            ? const _EmptyState(message: 'Aucun contrat pour le moment')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ContractCard(contract: items[i]),
              ),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract});
  final Contract contract;
  @override
  Widget build(BuildContext context) {
    final signed = contract.status == ContractStatus.signed;
    final (label, bg, fg) = switch (contract.status) {
      ContractStatus.signed => ('Signé', AppPalette.successBg, AppPalette.success),
      ContractStatus.unsigned => ('À signer', AppPalette.warningBg, AppPalette.warning),
      ContractStatus.expired => ('Expiré', AppPalette.n100, AppPalette.n700),
      ContractStatus.terminated => ('Résilié', AppPalette.dangerBg, AppPalette.danger),
      ContractStatus.unknown => ('—', AppPalette.n100, AppPalette.n700),
    };
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contract.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (contract.childName != null) contract.childName!,
              if (contract.tutorName != null) contract.tutorName!,
              DateFormat('d MMM y', 'fr').format(contract.createdAt),
            ].join(' · '),
            style: const TextStyle(fontSize: 11, color: AppPalette.n700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (contract.pdfUrl != null)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('PDF', style: TextStyle(fontSize: 12)),
                ),
              const Spacer(),
              if (!signed)
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Signer', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      children: [
        const Center(
          child: Icon(
            Icons.inbox_outlined,
            size: 56,
            color: AppPalette.n500,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppPalette.n700,
            ),
          ),
        ),
      ],
    );
  }
}
