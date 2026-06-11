import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/payment.dart';
import '../providers.dart';
import '../widgets/parent_drawer.dart';

class ParentPaymentsListPage extends ConsumerWidget {
  const ParentPaymentsListPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(paymentsListViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const ParentDrawer(activeRoute: RouteNames.parentPayments),
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          tr.parent.payments.title,
          style: const TextStyle(
            color: AppPalette.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(paymentsListViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) => RefreshIndicator(
          onRefresh: () =>
              ref.read(paymentsListViewModelProvider.notifier).refresh(),
          child: _Loaded(items: items),
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.items});
  final List<Payment> items;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final now = DateTime.now();
    final thisMonth = items
        .where((p) =>
            p.createdAt.year == now.year && p.createdAt.month == now.month)
        .toList();
    final totalSpent = thisMonth
        .where((p) => p.status == PaymentStatus.completed)
        .fold<int>(0, (s, p) => s + p.amount);
    final ok =
        thisMonth.where((p) => p.status == PaymentStatus.completed).length;
    final processing =
        thisMonth.where((p) => p.status == PaymentStatus.processing).length;
    final failed =
        thisMonth.where((p) => p.status == PaymentStatus.failed).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.parent.payments.totalSpent(
                  month: DateFormat.MMMM("fr").format(now),
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fcfa(totalSpent),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _miniStat(
                      '$ok', tr.parent.payments.statSucceeded, Colors.white),
                  const SizedBox(width: 22),
                  _miniStat('$processing', tr.parent.payments.statProcessing,
                      AppPalette.warning),
                  const SizedBox(width: 22),
                  _miniStat('$failed', tr.parent.payments.statFailed,
                      const Color(0xFFFF8A8A)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Row(
            children: [
              Text(
                tr.parent.payments.history,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                items.length > 1
                    ? tr.parent.payments.transactionsMany(count: items.length)
                    : tr.parent.payments.transactionsOne(count: items.length),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.n700,
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          SoeCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                tr.parent.payments.empty,
                style: const TextStyle(color: AppPalette.n700, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SoeCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  InkWell(
                    onTap: () =>
                        context.push('/parent/payments/${items[i].id}'),
                    child: _PaymentRow(payment: items[i]),
                  ),
                  if (i < items.length - 1)
                    Container(height: 1, color: AppPalette.n100),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _miniStat(String v, String l, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      );
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final Payment payment;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _methodBadge(payment.method),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fcfa(payment.amount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                    ),
                    _statusBadge(tr, payment.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (payment.reservationRef != null)
                      '#${payment.reservationRef}',
                    DateFormat('d MMM y', 'fr').format(payment.createdAt),
                    if (payment.phone != null) payment.phone!,
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
    );
  }

  Widget _methodBadge(PaymentMethod m) {
    final color = switch (m) {
      PaymentMethod.mtnMomo => const Color(0xFFFFCC00),
      PaymentMethod.orangeMoney => const Color(0xFFFF6600),
      PaymentMethod.unknown => AppPalette.n500,
    };
    final fg = m == PaymentMethod.mtnMomo ? AppPalette.ink : Colors.white;
    final label = switch (m) {
      PaymentMethod.mtnMomo => 'MTN',
      PaymentMethod.orangeMoney => 'OM',
      PaymentMethod.unknown => '?',
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _statusBadge(Translations tr, PaymentStatus s) {
    final (label, bg, fg) = switch (s) {
      PaymentStatus.completed => (
          tr.parent.payments.statusCompleted,
          AppPalette.successBg,
          AppPalette.success
        ),
      PaymentStatus.processing => (
          tr.parent.payments.statusProcessing,
          AppPalette.infoBg,
          AppPalette.teal
        ),
      PaymentStatus.pending => (
          tr.parent.payments.statusPending,
          AppPalette.warningBg,
          AppPalette.warning
        ),
      PaymentStatus.failed => (
          tr.parent.payments.statusFailed,
          AppPalette.dangerBg,
          AppPalette.danger
        ),
      PaymentStatus.cancelled => (
          tr.parent.payments.statusCancelled,
          AppPalette.n100,
          AppPalette.n700
        ),
      PaymentStatus.unknown => ('—', AppPalette.n100, AppPalette.n700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

String _fcfa(int n) => '${NumberFormat.decimalPattern("fr_FR").format(n)} FCFA';
