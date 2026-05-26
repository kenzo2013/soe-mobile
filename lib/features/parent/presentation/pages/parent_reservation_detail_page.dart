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
import '../../../../core/widgets/soe_toast.dart';
import '../../domain/entities/reservation_detail.dart';
import '../../domain/entities/reservation_summary.dart';
import '../providers.dart';
import '../viewmodels/reservations_viewmodels.dart';

class ParentReservationDetailPage extends ConsumerWidget {
  const ParentReservationDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reservationDetailViewModelProvider(id));

    ref.listen(reservationDetailViewModelProvider(id), (prev, next) {
      next.whenOrNull(
        actionSuccess: (_) {
          SoeToast.show(context, message: 'Réservation mise à jour.');
        },
        error: (f) => SoeToast.show(
          context,
          message: 'Action impossible — réessayez.',
          tone: SoeToastTone.danger,
        ),
      );
    });

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        title: Text(state.maybeWhen(
          loaded: (d) => '#${d.reference}',
          actionSuccess: (d) => '#${d.reference}',
          orElse: () => 'Réservation',
        )),
        titleTextStyle: const TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppPalette.ink),
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        acting: () => const Center(child: CircularProgressIndicator()),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () => ref
              .read(reservationDetailViewModelProvider(id).notifier)
              .load(id),
        ),
        loaded: (d) => _DetailView(detail: d, id: id),
        actionSuccess: (d) => _DetailView(detail: d, id: id),
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.detail,
    required this.id,
  });
  final ReservationDetail detail;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(reservationDetailViewModelProvider(id).notifier);
    final isQuote = detail.status == ReservationStatus.proposedPrice;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (isQuote) _StatusBanner(tutorName: detail.tutor?.fullName ?? '—'),
        if (detail.amount != null) ...[
          if (isQuote) const SizedBox(height: 16),
          _AmountCard(
            amount: detail.amount!,
            perSession: detail.amountPerSession,
            sessions: detail.sessionCount,
          ),
        ],
        if (detail.tutor != null) ...[
          const SizedBox(height: 16),
          _sectionTitle('Tuteur proposé'),
          _TutorCard(tutor: detail.tutor!, studentId: detail.childId),
        ],
        const SizedBox(height: 16),
        _sectionTitle('Détails de la demande'),
        SoeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Row('Élève', detail.childName),
              _Row('Matières', detail.subjects.join(' · ')),
              _Row(
                'Fréquence',
                detail.frequency == 1
                    ? '1 séance / semaine'
                    : '${detail.frequency} séances / semaine',
              ),
              _Row(
                'Démarrage',
                DateFormat('EEEE d MMMM yyyy', 'fr')
                    .format(detail.estimatedStartDate),
              ),
              _Row('Lieu', detail.location, last: true),
            ],
          ),
        ),
        if (detail.programText != null) ...[
          const SizedBox(height: 16),
          _sectionTitle('Programme proposé'),
          SoeCard(
            child: Text(
              detail.programText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.n700,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (isQuote) ...[
          const SizedBox(height: 22),
          SoeButton(
            label: 'Accepter le devis',
            icon: Icons.check,
            fullWidth: true,
            onPressed: () => vm.doAccept(id),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoeButton(
                  label: 'Négocier',
                  variant: SoeButtonVariant.secondary,
                  icon: Icons.handshake_outlined,
                  onPressed: () => _openNegotiate(context, vm),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoeButton(
                  label: 'Rejeter',
                  variant: SoeButtonVariant.danger,
                  icon: Icons.close,
                  onPressed: () => vm.doReject(id),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _openNegotiate(BuildContext context, ReservationDetailViewModel vm) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Votre proposition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Montant proposé (FCFA)',
                  filled: true,
                  fillColor: AppPalette.n50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SoeButton(
                label: 'Envoyer la contre-proposition',
                fullWidth: true,
                onPressed: () {
                  final amount = int.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;
                  Navigator.of(sheetCtx).pop();
                  vm.doNegotiate(id, amount);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
            letterSpacing: -0.1,
          ),
        ),
      );
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.tutorName});
  final String tutorName;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.warning),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppPalette.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devis reçu de $tutorName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Acceptez, proposez un autre prix ou rejetez la proposition.',
                  style: TextStyle(fontSize: 11, color: AppPalette.n700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
    this.perSession,
    this.sessions,
  });
  final int amount;
  final int? perSession;
  final int? sessions;
  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.decimalPattern('fr_FR');
    return SoeCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Montant proposé',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${f.format(amount)} FCFA',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                if (perSession != null && sessions != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '= ${f.format(perSession!)} FCFA / séance · $sessions séances',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 22,
              color: AppPalette.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  const _TutorCard({required this.tutor, required this.studentId});
  final TutorMini tutor;
  final String studentId;
  @override
  Widget build(BuildContext context) {
    return SoeCard(
      child: Row(
        children: [
          SoeAvatar(
            name: tutor.fullName,
            imageUrl: tutor.avatarUrl,
            size: SoeAvatarSize.list,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutor.fullName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (tutor.category != null) tutor.category!,
                    if (tutor.rating != null)
                      '${tutor.rating!.toStringAsFixed(1)} ★',
                    if (tutor.reviewCount != null)
                      '(${tutor.reviewCount} avis)',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.push(RouteNames.parentTutorProfile(
              studentId: studentId,
              tutorId: tutor.id,
            )),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPalette.teal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Profil', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.k, this.v, {this.last = false});
  final String k;
  final String v;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppPalette.n100, width: 1),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(
                fontSize: 11,
                color: AppPalette.n700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppPalette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
