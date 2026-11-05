import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_ui.dart';

/// PAR-15 — invoices to pay (oldest first) and the receipts.
class ParentPaymentsPage extends ConsumerWidget {
  const ParentPaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: ParentAsyncBody<List<ParentInvoice>>(
          value: ref.watch(parentInvoicesProvider),
          onRetry: () => ref.invalidate(parentInvoicesProvider),
          builder: (invoices) {
            final due = invoices.where((invoice) => invoice.payable).toList();
            final receiptsValue = ref.watch(parentPaymentsProvider);
            final receipts =
                receiptsValue.valueOrNull ?? const <ParentPayment>[];
            return RefreshIndicator(
              onRefresh: () {
                ref.invalidate(parentPaymentsProvider);
                return ref.refresh(parentInvoicesProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(tr.payments.title,
                      style:
                          AppTypography.h1.copyWith(color: AppPalette.teal800)),
                  if (due.isNotEmpty) ParentSectionTitle(tr.payments.toPay),
                  ...due.map((invoice) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoeCard(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(
                                          tr.payments
                                              .invoice(number: invoice.number),
                                          style: AppTypography.overline
                                              .copyWith(
                                                  color: AppPalette.text2))),
                                  ParentStatusBadge(
                                      status: invoice.status,
                                      label: invoice.statusLabel),
                                ]),
                                const SizedBox(height: 6),
                                Text(
                                    ParentFormat.amount(
                                        context, invoice.balanceDue),
                                    style: AppTypography.h2),
                                if (invoice.dueOn != null)
                                  Text(
                                      tr.payments.due(
                                          date: ParentFormat.day(
                                              context, invoice.dueOn!)),
                                      style: AppTypography.caption
                                          .copyWith(color: AppPalette.text2)),
                                ...invoice.lines.map((line) => Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(line.label,
                                                style: AppTypography.bodySm)),
                                        Text(
                                            ParentFormat.amount(
                                                context, line.amount),
                                            style: AppTypography.labelSm),
                                      ]),
                                    )),
                                const SizedBox(height: 12),
                                SoeButton(
                                  label: tr.payments.pay(
                                      amount: ParentFormat.amount(
                                          context, invoice.balanceDue)),
                                  variant: invoice == due.first
                                      ? SoeButtonVariant.primary
                                      : SoeButtonVariant.secondary,
                                  fullWidth: true,
                                  onPressed: () => context
                                      .push(ParentSpaceRoutes.pay(invoice.id)),
                                ),
                              ]),
                        ),
                      )),
                  ParentSectionTitle(tr.payments.history),
                  if (receiptsValue.hasError)
                    TextButton(
                        onPressed: () => ref.invalidate(parentPaymentsProvider),
                        child: Text(tr.retry))
                  else if (receiptsValue.isLoading && receipts.isEmpty)
                    const LinearProgressIndicator()
                  else if (receipts.isEmpty)
                    SoeEmptyState(
                        title: tr.payments.empty,
                        message: tr.payments.emptyText,
                        icon: Icons.receipt_long_outlined),
                  ...receipts.map((payment) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SoeCard(
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        tr.payments.receipt(
                                            number:
                                                payment.receiptNumber ?? ''),
                                        style: AppTypography.labelSm),
                                    if (payment.paidAt != null)
                                      Text(
                                          ParentFormat.day(
                                              context, payment.paidAt!),
                                          style: AppTypography.caption.copyWith(
                                              color: AppPalette.text2)),
                                  ]),
                            ),
                            Text(ParentFormat.amount(context, payment.amount),
                                style: AppTypography.label),
                          ]),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// PAR-16 — pay an invoice: MTN MoMo or Orange Money, number prefilled.
class ParentPayPage extends ConsumerStatefulWidget {
  const ParentPayPage({super.key, required this.invoiceId});

  final int invoiceId;

  @override
  ConsumerState<ParentPayPage> createState() => _ParentPayPageState();
}

class _ParentPayPageState extends ConsumerState<ParentPayPage> {
  String _operator = 'mtn';
  late final TextEditingController _phone = TextEditingController(
      text: ref.read(currentUserProvider).valueOrNull?.phone ?? '');
  bool _sending = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _sending = true);
    try {
      final payment = await ref
          .read(parentApiProvider)
          .pay(widget.invoiceId, operator: _operator, phone: _phone.text);
      ref.invalidate(parentInvoicesProvider);
      ref.invalidate(parentHomeProvider);
      if (mounted)
        context.pushReplacement(ParentSpaceRoutes.payment(payment.id));
    } on Failure catch (failure) {
      if (mounted)
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final invoice = ref
        .watch(parentInvoicesProvider)
        .valueOrNull
        ?.where((item) => item.id == widget.invoiceId)
        .firstOrNull;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.pay.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (invoice != null) ...[
            Text(tr.pay.amount,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            Text(ParentFormat.amount(context, invoice.balanceDue),
                style: AppTypography.h1),
            const SizedBox(height: 16),
          ],
          Text(tr.pay.operator, style: AppTypography.labelSm),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'mtn', label: Text(tr.pay.mtn)),
              ButtonSegment(value: 'orange', label: Text(tr.pay.orange)),
            ],
            selected: {_operator},
            onSelectionChanged: (value) =>
                setState(() => _operator = value.first),
          ),
          const SizedBox(height: 16),
          SoeTextField(
              controller: _phone,
              label: tr.pay.phone,
              hint: tr.pay.phoneHint,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          SoeCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.pay.howCode, style: AppTypography.bodySm),
              const SizedBox(height: 6),
              Text(tr.pay.howUssd, style: AppTypography.bodySm),
            ]),
          ),
          const SizedBox(height: 20),
          SoeButton(
            label: tr.pay.submit(
                amount: invoice == null
                    ? ''
                    : ParentFormat.amount(context, invoice.balanceDue)),
            fullWidth: true,
            loading: _sending,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }
}

/// PAR-17 — the payment followed: waiting (refreshed every few seconds), checking, success, failure.
class ParentPaymentPage extends ConsumerStatefulWidget {
  const ParentPaymentPage({super.key, required this.paymentId});

  final int paymentId;

  @override
  ConsumerState<ParentPaymentPage> createState() => _ParentPaymentPageState();
}

class _ParentPaymentPageState extends ConsumerState<ParentPaymentPage> {
  static const _every = Duration(seconds: 5);
  static const _limit = Duration(minutes: 15);
  final _started = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  // One check at a time: the next one is planned once the previous answer arrived, and the
  // follow-up stops on a final state or after a while.
  void _schedule() {
    _timer = Timer(_every, () async {
      if (!mounted || DateTime.now().difference(_started) > _limit) return;
      try {
        final payment =
            await ref.refresh(parentPaymentProvider(widget.paymentId).future);
        if (payment.state == 'success') {
          ref
            ..invalidate(parentInvoicesProvider)
            ..invalidate(parentPaymentsProvider)
            ..invalidate(parentHomeProvider);
        }
        if (payment.state == 'waiting' || payment.state == 'checking')
          _schedule();
      } on Object {
        if (mounted) _schedule();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.payment;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(),
      body: ParentAsyncBody<ParentPayment>(
        value: ref.watch(parentPaymentProvider(widget.paymentId)),
        onRetry: () => ref.invalidate(parentPaymentProvider(widget.paymentId)),
        builder: (payment) {
          final amount = ParentFormat.amount(context, payment.amount);
          final (title, text, icon, color) = switch (payment.state) {
            'success' => (
                tr.successTitle,
                tr.successText(amount: amount),
                Icons.check_circle,
                AppPalette.success
              ),
            'failure' => (
                tr.failureTitle,
                tr.failureText,
                Icons.error,
                AppPalette.danger
              ),
            'checking' => (
                tr.checkingTitle,
                tr.checkingText,
                Icons.hourglass_bottom,
                AppPalette.warning
              ),
            _ => (
                tr.waitingTitle,
                tr.waitingText(amount: amount),
                Icons.phone_iphone,
                AppPalette.teal500
              ),
          };
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(icon, size: 56, color: color),
              const SizedBox(height: 16),
              Text(title, style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(text,
                  style: AppTypography.body, textAlign: TextAlign.center),
              if (payment.state == 'waiting') ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 24),
              SoeButton(
                label: payment.state == 'failure' ? tr.retry : tr.back,
                variant: payment.state == 'failure'
                    ? SoeButtonVariant.primary
                    : SoeButtonVariant.outline,
                fullWidth: true,
                onPressed: () =>
                    payment.state == 'failure' && payment.invoiceId != null
                        ? context.pushReplacement(
                            ParentSpaceRoutes.pay(payment.invoiceId!))
                        : context.pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}
