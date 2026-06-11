/// 4 pages mini-features regroupées : reviews, programs, invitations, contracts.
/// UI minimaliste (liste + état vide/erreur). Le polish design sera fait
/// dans une vague d'enrichissement dédiée.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/countries.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_phone_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/providers.dart';
import '../../../common/presentation/widgets/contract_card.dart';
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
    this.subtitle,
    this.actions,
  });
  final String title;
  final String? subtitle;
  final String activeRoute;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: ParentDrawer(activeRoute: activeRoute),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: hasSubtitle ? 64 : 56,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppPalette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hasSubtitle) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppPalette.n700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: actions,
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
    final tr = Translations.of(context);
    final state = ref.watch(reviewsListViewModelProvider(null));
    return _Shell(
      title: tr.parent.reviews.title,
      activeRoute: '/parent/reviews',
      body: _asyncList<ParentReview>(
        state: state as AsyncListState<ParentReview>,
        onRetry: () =>
            ref.read(reviewsListViewModelProvider(null).notifier).refresh(),
        onLoaded: (items) => items.isEmpty
            ? _EmptyState(message: tr.parent.reviews.empty)
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
                      '${review.subjects.join(", ")} · ${DateFormat('d MMM', "fr").format(review.createdAt)}',
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
                      color: n <= review.rating
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
    final tr = Translations.of(context);
    final state = ref.watch(programsListViewModelProvider(null));
    return _Shell(
      title: tr.parent.programs.title,
      activeRoute: '/parent/programs',
      body: _asyncList<ParentProgram>(
        state: state as AsyncListState<ParentProgram>,
        onRetry: () =>
            ref.read(programsListViewModelProvider(null).notifier).refresh(),
        onLoaded: (items) => items.isEmpty
            ? _EmptyState(message: tr.parent.programs.empty)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ProgramCard(program: items[i]),
              ),
      ),
    );
  }
}

String _programQuoteLabel(Translations tr, String status) {
  final s = status.toLowerCase();
  if (s.contains('accept')) return tr.parent.programs.quoteAccepted;
  if (s.contains('reject') || s.contains('refus')) {
    return tr.parent.programs.quoteRejected;
  }
  if (s.contains('negocia') || s.contains('negotia')) {
    return tr.parent.programs.quoteNegotiating;
  }
  if (s.contains('propos') || s.contains('price')) {
    return tr.parent.programs.quoteProposed;
  }
  return tr.parent.programs.quotePending;
}

String _formatAmount(int amount) => amount
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});
  final ParentProgram program;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : référence + statut devis + montant mensuel
          Row(
            children: [
              Expanded(
                child: Text(
                  program.reference,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.infoBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  _programQuoteLabel(tr, program.quoteStatus),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.teal,
                  ),
                ),
              ),
            ],
          ),
          if (program.totalAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              tr.parent.programs.perMonth(
                amount: _formatAmount(program.totalAmount),
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppPalette.teal,
              ),
            ),
          ],
          for (final line in program.lines) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppPalette.n300),
            ),
            _ProgramLineView(line: line),
          ],
        ],
      ),
    );
  }
}

class _ProgramLineView extends StatelessWidget {
  const _ProgramLineView({required this.line});
  final ProgramLine line;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Élève + classe
        Text(
          line.studentName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
        if (line.schoolClass.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              line.schoolClass,
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
          ),
        const SizedBox(height: 10),
        if (line.subjects.isNotEmpty)
          _ProgramRow(
            label: tr.parent.programs.subjects,
            value: line.subjects.join(', '),
          ),
        if (line.tutors.isNotEmpty)
          _ProgramRow(
            label: tr.parent.programs.tutor,
            value: line.tutors.join(', '),
          ),
        if (line.frequency > 0)
          _ProgramRow(
            label: tr.parent.programs.schedule,
            value: tr.parent.programs.frequency(n: line.frequency),
          ),
        if (line.startDate != null && line.endDate != null)
          _ProgramRow(
            label: '',
            value: tr.parent.programs
                .period(from: line.startDate!, to: line.endDate!),
          ),
        if (line.schedules.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in line.schedules)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppPalette.n100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${s.day} · ${s.timeSlot}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppPalette.n700),
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppPalette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Invitations
// ────────────────────────────────────────────────────────────────
class ParentInvitationsListPage extends ConsumerWidget {
  const ParentInvitationsListPage({super.key});

  void _openInvite(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InviteSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(invitationsListViewModelProvider(null));
    final items = state is AsyncListLoaded<ParentInvitation>
        ? state.items
        : const <ParentInvitation>[];
    final count = items.length;
    final subtitle = count == 0
        ? null
        : (count > 1
            ? tr.parent.invitations.countMany(count: count)
            : tr.parent.invitations.countOne(count: count));
    return _Shell(
      title: tr.parent.invitations.title,
      subtitle: subtitle,
      activeRoute: '/parent/invitations',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _AddIconBtn(onTap: () => _openInvite(context)),
        ),
      ],
      body: _asyncList<ParentInvitation>(
        state: state as AsyncListState<ParentInvitation>,
        onRetry: () =>
            ref.read(invitationsListViewModelProvider(null).notifier).refresh(),
        onLoaded: (items) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(child: _IntroCard()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
              sliver: SliverToBoxAdapter(
                child: Text(
                  tr.parent.invitations.invitedPeople,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                // L'enfant `_EmptyState` est lui-même un ListView (scrollable) :
                // `hasScrollBody: true` évite le calcul d'intrinsèques interdit
                // dans un viewport (sinon crash + page blanche).
                hasScrollBody: true,
                child: _EmptyState(
                  message: tr.parent.invitations.empty,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _InvitationCard(invitation: items[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddIconBtn extends StatelessWidget {
  const _AddIconBtn({required this.onTap});
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

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SoeCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.infoBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 20,
              color: AppPalette.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.parent.invitations.introTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tr.parent.invitations.introBody,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                    height: 1.4,
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

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});
  final ParentInvitation invitation;

  String? _roleLabel(Translations tr) {
    final rel = invitation.relationship;
    if (rel == null || rel.isEmpty) return null;
    return switch (rel) {
      'father' => tr.parent.invitations.roleFather,
      'mother' => tr.parent.invitations.roleMother,
      'guardian' => tr.parent.invitations.roleGuardian,
      _ => rel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final role = _roleLabel(tr);
    // unknown : on suppose que l'invitation est juste partie sans statut
    // explicite cote back → fallback "Envoyée" (style info teal).
    final (label, bg, fg) = switch (invitation.status) {
      InvitationStatus.pending || InvitationStatus.unknown => (
          tr.parent.invitations.statusSent,
          AppPalette.infoBg,
          AppPalette.teal
        ),
      InvitationStatus.accepted => (
          tr.parent.invitations.statusAccepted,
          AppPalette.successBg,
          AppPalette.success,
        ),
      InvitationStatus.rejected => (
          tr.parent.invitations.statusRejected,
          AppPalette.dangerBg,
          AppPalette.danger,
        ),
      InvitationStatus.expired => (
          tr.parent.invitations.statusExpired,
          AppPalette.n100,
          AppPalette.n700,
        ),
    };
    final name = (invitation.fullName ?? '').isEmpty
        ? invitation.email
        : invitation.fullName!;
    return SoeCard(
      child: Row(
        children: [
          SoeAvatar(name: name, size: SoeAvatarSize.list),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                    ),
                    if (role != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.infoBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.teal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  invitation.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                  ),
                ),
                if ((invitation.phone ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    // Normalise un éventuel « ++ » hérité (données créées avant
                    // le fix d'envoi) en un seul « + ».
                    invitation.phone!.replaceFirst(RegExp(r'^\++'), '+'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge status — taille sm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: fg,
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

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();
  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  Country _country = Countries.cameroon;
  String _civility = 'Mr';
  InvitationLink _link = InvitationLink.father;
  bool _sending = false;
  String? _phoneError;

  @override
  void dispose() {
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = Translations.of(context);
    if (_email.text.trim().isEmpty ||
        _firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty) return;
    final phoneDigits = _phone.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 6) {
      setState(() => _phoneError = tr.parent.invitations.invalidPhone);
      return;
    }
    setState(() {
      _phoneError = null;
      _sending = true;
    });
    final repo = ref.read(invitationsRepositoryProvider);
    final r = await repo.invite(InviteParams(
      email: _email.text.trim(),
      civility: _civility,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      // `callingCode` inclut déjà le « + » (ex. « +237 ») → ne pas le doubler.
      phone: '${_country.callingCode}$phoneDigits',
      linkWithChildren: _link,
    ));
    if (!mounted) return;
    setState(() => _sending = false);
    r.isOk
        ? Navigator.of(context).pop(true)
        : ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr.parent.invitations.inviteFailed)),
          );
    if (r.isOk) {
      ref.read(invitationsListViewModelProvider(null).notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
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
          Text(
            tr.parent.invitations.sheetTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _civility,
                decoration: InputDecoration(
                  labelText: tr.parent.invitations.civility,
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Mr', child: Text('Mr')),
                  DropdownMenuItem(value: 'Mme', child: Text('Mme')),
                ],
                onChanged: (v) => setState(() => _civility = v ?? 'Mr'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _firstName,
                decoration: InputDecoration(
                  labelText: tr.parent.invitations.firstName,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextField(
            controller: _lastName,
            decoration: InputDecoration(
              labelText: tr.parent.invitations.lastName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr.parent.invitations.email,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SoePhoneField(
            country: _country,
            onCountryChanged: (c) => setState(() => _country = c),
            controller: _phone,
            hint: tr.parent.invitations.phone,
            errorText: _phoneError,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<InvitationLink>(
            value: _link,
            decoration: InputDecoration(
              labelText: tr.parent.invitations.linkWithChildren,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                  value: InvitationLink.father,
                  child: Text(tr.parent.invitations.roleFather)),
              DropdownMenuItem(
                  value: InvitationLink.mother,
                  child: Text(tr.parent.invitations.roleMother)),
              DropdownMenuItem(
                  value: InvitationLink.guardian,
                  child: Text(tr.parent.invitations.roleGuardian)),
            ],
            onChanged: (v) =>
                setState(() => _link = v ?? InvitationLink.father),
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
                : Text(tr.parent.invitations.sendInvitation),
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
    final tr = Translations.of(context);
    final async = ref.watch(contractsProvider);
    final lang = ref.watch(currentUserProvider).asData?.value?.lang ?? 'fr';
    return _Shell(
      title: tr.contracts.title,
      activeRoute: '/parent/contracts',
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(contractsProvider),
        ),
        data: (items) => items.isEmpty
            ? _EmptyState(message: tr.contracts.empty)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => ContractCard(
                  contract: items[i],
                  lang: lang,
                  onTap: () => context.push(
                    RouteNames.contractDetail,
                    extra: items[i],
                  ),
                ),
              ),
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
