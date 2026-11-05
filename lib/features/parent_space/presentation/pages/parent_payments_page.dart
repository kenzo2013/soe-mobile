import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// PAR-15 — invoices to pay (oldest first) and the receipts.
class ParentPaymentsPage extends ConsumerWidget {
  const ParentPaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    return SpaceTabAsync<List<ParentInvoice>>(
      band: SpaceBand(title: tr.payments.title),
      value: ref.watch(parentInvoicesProvider),
      onRetry: () => ref.invalidate(parentInvoicesProvider),
      onRefresh: () {
        ref.invalidate(parentPaymentsProvider);
        return ref.refresh(parentInvoicesProvider.future);
      },
      builder: (invoices) {
        final due = invoices.where((invoice) => invoice.payable).toList();
        final receiptsValue = ref.watch(parentPaymentsProvider);
        final receipts = receiptsValue.valueOrNull ?? const <ParentPayment>[];
        return [
          // The lists start under the band (their first line is a title).
          const SizedBox(height: SpaceBand.cardOverlap - 12),
          if (due.isNotEmpty) ParentSectionTitle(tr.payments.toPay),
          ...due.map((invoice) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoeCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          tr.payments
                                              .invoice(number: invoice.number)
                                              .toUpperCase(),
                                          style: AppTypography.overline
                                              .copyWith(
                                                  color: AppPalette.teal700)),
                                      const SizedBox(height: 4),
                                      Text(
                                          toBeginningOfSentenceCase(
                                              DateFormat.yMMMM(
                                                      Localizations.localeOf(
                                                              context)
                                                          .languageCode)
                                                  .format(invoice.period)),
                                          style: AppTypography.h3.copyWith(
                                              color: AppPalette.teal800)),
                                    ]),
                              ),
                              ParentStatusBadge(
                                  status: invoice.status,
                                  label: invoice.statusLabel),
                            ]),
                        const SizedBox(height: 10),
                        Text(ParentFormat.amount(context, invoice.balanceDue),
                            style: AppTypography.h1
                                .copyWith(color: AppPalette.teal800)),
                        Text(
                            [
                              if (invoice.issuedOn != null)
                                tr.payments.issued(
                                    date: ParentFormat.day(
                                        context, invoice.issuedOn!)),
                              if (invoice.dueOn != null)
                                tr.payments.dueShort(
                                    date: ParentFormat.dayLong(
                                        context, invoice.dueOn!)),
                            ].join(' · '),
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                        const SizedBox(height: 6),
                        ...invoice.lines.map((line) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(children: [
                                Expanded(
                                    child: Text(line.label,
                                        style: AppTypography.bodySm)),
                                Text(ParentFormat.amount(context, line.amount),
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
                          onPressed: () =>
                              context.push(ParentSpaceRoutes.pay(invoice.id)),
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
          for (final payment in receipts.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ParentPaymentTile(payment: payment),
            ),
          if (receipts.isNotEmpty)
            SoeButton(
              label: tr.history.seeAll,
              variant: SoeButtonVariant.tertiary,
              fullWidth: true,
              onPressed: () =>
                  unawaited(context.push(ParentSpaceRoutes.paymentsHistory)),
            ),
          const SizedBox(height: 12),
          ParentPanel(soft: true, title: tr.history.howTitle, children: [
            for (final rule in [
              tr.history.how1,
              tr.history.how2,
              tr.history.how3,
              tr.history.how4
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 8),
                        child: Icon(Icons.info_outline,
                            size: 16, color: AppPalette.teal600),
                      ),
                      Expanded(child: Text(rule, style: AppTypography.bodySm)),
                    ]),
              ),
          ]),
        ];
      },
    );
  }
}

/// A payment of the history: what, when, state, amount; its receipt once paid.
class ParentPaymentTile extends ConsumerWidget {
  const ParentPaymentTile({super.key, required this.payment});

  final ParentPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final when = payment.paidAt ?? payment.createdAt;
    final period = payment.period;
    final phone = payment.phone;
    return SoeCard(
      onTap: () =>
          unawaited(context.push(ParentSpaceRoutes.payment(payment.id))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.receipt_long_outlined,
              size: 16, color: AppPalette.text2),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
                [
                  payment.receiptNumber ?? '',
                  if (when != null)
                    payment.state == 'success'
                        ? tr.history
                            .paidOn(date: ParentFormat.day(context, when))
                        : ParentFormat.day(context, when),
                ].where((part) => part.isNotEmpty).join(' · '),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ),
          ParentStatusBadge(
              status: switch (payment.state) {
                'success' => 'paid',
                'failure' => 'overdue',
                _ => 'issued',
              },
              label: payment.statusLabel ?? ''),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // « Novembre · Yann (premier mois) », as on the web, else the month.
              Text(
                  payment.title ??
                      (period == null
                          ? (payment.methodLabel ?? payment.method)
                          : toBeginningOfSentenceCase(DateFormat.yMMMM(
                                      Localizations.localeOf(context)
                                          .languageCode)
                                  .format(period)) ??
                              ''),
                  style: AppTypography.label),
              Text(
                  [
                    if (payment.subjects.isNotEmpty)
                      payment.subjects.join(', '),
                    payment.meansLabel ??
                        [
                          payment.methodLabel ?? payment.method,
                          if (phone != null && phone.length > 4)
                            '•• ${phone.substring(phone.length - 4)}',
                        ].join(' · '),
                  ].join(' · '),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
          Text(ParentFormat.amount(context, payment.amount),
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        ]),
        if (payment.hasReceipt) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: tr.history.download,
            icon: Icons.download_outlined,
            variant: SoeButtonVariant.outline,
            fullWidth: true,
            size: SoeButtonSize.md,
            onPressed: () => unawaited(openParentPdf(
                context,
                ref,
                () => ref.read(parentApiProvider).receiptPdf(payment.id),
                'receipt_${payment.receiptNumber}.pdf')),
          ),
          Center(
            child: TextButton(
              onPressed: () => unawaited(launchUrl(
                  Uri.https('wa.me', '/', {
                    'text': tr.history.shareText(
                        number: payment.receiptNumber ?? '',
                        amount: ParentFormat.amount(context, payment.amount)),
                  }),
                  mode: LaunchMode.externalApplication)),
              child: Text(tr.history.shareWhatsapp),
            ),
          ),
        ],
      ]),
    );
  }
}

/// PAR-15 « Historique » — every payment of the family, newest first, page by page.
class ParentPaymentsHistoryPage extends ConsumerStatefulWidget {
  const ParentPaymentsHistoryPage({super.key});

  @override
  ConsumerState<ParentPaymentsHistoryPage> createState() =>
      _ParentPaymentsHistoryPageState();
}

class _ParentPaymentsHistoryPageState
    extends ConsumerState<ParentPaymentsHistoryPage> {
  final _payments = <ParentPayment>[];
  int _page = 0;
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_more());
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(parentApiProvider).paymentsPage(_page + 1);
      if (!mounted) return;
      setState(() {
        _page++;
        _payments.addAll(page);
        _done = page.length < 50;
      });
    } on Failure catch (failure) {
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.parent.payments,
          title: tr.history.title),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 200) unawaited(_more());
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_payments.isEmpty && _done)
              SoeEmptyState(
                  title: tr.payments.empty,
                  message: tr.payments.emptyText,
                  icon: Icons.receipt_long_outlined),
            for (final payment in _payments)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ParentPaymentTile(payment: payment),
              ),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              TextButton(onPressed: _more, child: Text(tr.retry)),
          ],
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
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.parent.payments,
          title: tr.pay.title),
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
  DateTime _started = DateTime.now();
  Timer? _timer;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  // One check at a time: the next one is planned once the previous answer arrived, and the
  // follow-up stops on a final state or after a while.
  void _schedule() {
    _timer = Timer(_every, () async {
      if (!mounted) return;
      if (DateTime.now().difference(_started) > _limit) {
        setState(() => _stopped = true);
        return;
      }
      try {
        final payment =
            await ref.refresh(parentPaymentProvider(widget.paymentId).future);
        if (!mounted) return;
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

  void _checkAgain() {
    setState(() {
      _stopped = false;
      _started = DateTime.now();
    });
    ref.invalidate(parentPaymentProvider(widget.paymentId));
    _schedule();
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
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.parent.payments,
          title: Translations.of(context).parentSpace.pay.title),
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
              if (_stopped &&
                  (payment.state == 'waiting' ||
                      payment.state == 'checking')) ...[
                const SizedBox(height: 24),
                SoeButton(
                    label: tr.checkAgain,
                    fullWidth: true,
                    onPressed: _checkAgain),
              ] else if (payment.state == 'waiting') ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              if (payment.hasReceipt) ...[
                const SizedBox(height: 24),
                SoeButton(
                  label: Translations.of(context).parentSpace.history.receipt,
                  icon: Icons.download_outlined,
                  variant: SoeButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () => unawaited(openParentPdf(
                      context,
                      ref,
                      () => ref.read(parentApiProvider).receiptPdf(payment.id),
                      'receipt_${payment.receiptNumber}.pdf')),
                ),
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
