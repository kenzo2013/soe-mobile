import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/payment.dart';
import '../providers.dart';

class ParentPaymentReceiptPage extends ConsumerWidget {
  const ParentPaymentReceiptPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(paymentReceiptViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        title: Text(tr.parent.paymentReceipt.title),
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
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(paymentReceiptViewModelProvider(id).notifier).load(id),
        ),
        loaded: (r) {
          final p = r.payment;
          final f = NumberFormat.decimalPattern('fr_FR');
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _bgFor(p.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconFor(p.status),
                    size: 36,
                    color: _fgFor(p.status),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _statusTitle(tr, p.status),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${f.format(p.amount)} FCFA',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SoeCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _row(tr.parent.paymentReceipt.reference, p.reference),
                    if (p.reservationRef != null)
                      _row(
                        tr.parent.paymentReceipt.reservation,
                        '#${p.reservationRef}',
                      ),
                    _row(
                      tr.parent.paymentReceipt.date,
                      DateFormat('d MMM yyyy · HH:mm', 'fr')
                          .format(p.createdAt),
                    ),
                    _row(
                      tr.parent.paymentReceipt.method,
                      _methodLabel(p.method),
                    ),
                    if (p.phone != null)
                      _row(tr.parent.paymentReceipt.phone, p.phone!),
                    if (r.childName != null)
                      _row(tr.parent.paymentReceipt.child, r.childName!),
                    if (r.tutorName != null)
                      _row(
                        tr.parent.paymentReceipt.tutor,
                        r.tutorName!,
                        last: true,
                      )
                    else
                      _row(
                        tr.parent.paymentReceipt.status,
                        _statusTitle(tr, p.status),
                        last: true,
                      ),
                  ],
                ),
              ),
              if (r.pdfUrl != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: Text(tr.parent.paymentReceipt.downloadPdf),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Color _bgFor(PaymentStatus s) => switch (s) {
        PaymentStatus.completed => AppPalette.successBg,
        PaymentStatus.failed => AppPalette.dangerBg,
        _ => AppPalette.infoBg,
      };
  Color _fgFor(PaymentStatus s) => switch (s) {
        PaymentStatus.completed => AppPalette.success,
        PaymentStatus.failed => AppPalette.danger,
        _ => AppPalette.teal,
      };
  IconData _iconFor(PaymentStatus s) => switch (s) {
        PaymentStatus.completed => Icons.check_circle_outline,
        PaymentStatus.failed => Icons.error_outline,
        PaymentStatus.processing => Icons.hourglass_top_outlined,
        _ => Icons.receipt_long_outlined,
      };
  String _statusTitle(Translations tr, PaymentStatus s) => switch (s) {
        PaymentStatus.completed => tr.parent.paymentReceipt.statusCompleted,
        PaymentStatus.failed => tr.parent.paymentReceipt.statusFailed,
        PaymentStatus.processing => tr.parent.paymentReceipt.statusProcessing,
        PaymentStatus.pending => tr.parent.paymentReceipt.statusPending,
        PaymentStatus.cancelled => tr.parent.paymentReceipt.statusCancelled,
        PaymentStatus.unknown => tr.parent.paymentReceipt.statusUnknown,
      };
  String _methodLabel(PaymentMethod m) => switch (m) {
        PaymentMethod.mtnMomo => 'MTN Mobile Money',
        PaymentMethod.orangeMoney => 'Orange Money',
        PaymentMethod.unknown => '—',
      };

  Widget _row(String k, String v, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
