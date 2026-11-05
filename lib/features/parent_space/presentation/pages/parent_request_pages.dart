import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_ui.dart';

/// Refreshes what a request step changes: the requests, the home actions.
void _refreshRequests(WidgetRef ref) => ref
  ..invalidate(parentRequestsProvider)
  ..invalidate(parentHomeProvider);

/// The next screen of a request for its holder action (or its contract to sign).
/// A presented tutor is accepted by signing the contract; a signed one leads to the payment.
String? parentRequestTarget(ParentRequest request) => switch (request.action) {
      'quote' => ParentSpaceRoutes.quote(request.id),
      'planning' => ParentSpaceRoutes.planning(request.id),
      'payment' => RouteNames.parentPayments,
      _ => request.contractId != null &&
              request.step == 'contract' &&
              request.contractStatus == 'sent'
          ? ParentSpaceRoutes.contract(request.contractId!)
          : null,
    };

/// PAR-06 — the family's requests with their step and the one action to take.
class ParentRequestsPage extends ConsumerWidget {
  const ParentRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.requests;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: ParentAsyncBody<List<ParentRequest>>(
        value: ref.watch(parentRequestsProvider),
        onRetry: () => ref.invalidate(parentRequestsProvider),
        builder: (requests) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (requests.isEmpty)
              SoeEmptyState(
                  title: tr.empty,
                  message: tr.emptyText,
                  icon: Icons.assignment_outlined),
            ...requests.map((request) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RequestCard(request: request),
                )),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final ParentRequest request;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    final target = parentRequestTarget(request);
    final label = switch (request.action) {
      'quote' => tr.quote,
      'planning' => tr.planning,
      'payment' => tr.payFirst,
      _ => target != null ? tr.contract : null,
    };
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              [request.reference, ...request.children]
                  .join(' · ')
                  .toUpperCase(),
              style: AppTypography.overline.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 6),
          Text(request.stepLabel, style: AppTypography.h3),
          if (request.quoteAmount != null) ...[
            const SizedBox(height: 4),
            Text(
                tr.perMonth(
                    amount: ParentFormat.amount(context, request.quoteAmount!)),
                style: AppTypography.body.copyWith(color: AppPalette.text2)),
          ],
          if (label != null) ...[
            const SizedBox(height: 12),
            SoeButton(
              label: label,
              fullWidth: true,
              size: SoeButtonSize.md,
              variant: target != null
                  ? SoeButtonVariant.primary
                  : SoeButtonVariant.outline,
              onPressed: target == null
                  ? null
                  : () => request.action == 'payment'
                      ? context.go(target)
                      : context.push(target),
            ),
          ],
        ],
      ),
    );
  }
}

/// PAR-08 — the current quote: lines, monthly total, validity; accept, negotiate, decline.
class ParentQuotePage extends ConsumerStatefulWidget {
  const ParentQuotePage({super.key, required this.requestId});

  final int requestId;

  @override
  ConsumerState<ParentQuotePage> createState() => _ParentQuotePageState();
}

class _ParentQuotePageState extends ConsumerState<ParentQuotePage> {
  bool _busy = false;

  Future<void> _answer(String decision,
      {String? message, int? proposedAmount, String? reason}) async {
    final tr = Translations.of(context).parentSpace.requests;
    setState(() => _busy = true);
    try {
      await ref.read(parentApiProvider).answerQuote(widget.requestId, decision,
          message: message, proposedAmount: proposedAmount, reason: reason);
      if (!mounted) return;
      ref.invalidate(parentQuoteProvider(widget.requestId));
      _refreshRequests(ref);
      SoeToast.show(context,
          message: switch (decision) {
            'accept' => tr.accepted,
            'negotiate' => tr.negotiated,
            'decline' => tr.declined,
            _ => tr.reactivated,
          });
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _negotiate() async {
    final result = await showModalBottomSheet<_Negotiation>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NegotiationSheet(),
    );
    if (result != null) {
      await _answer('negotiate',
          message: result.message, proposedAmount: result.amount);
    }
  }

  Future<void> _decline() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ReasonSheet(),
    );
    if (reason != null) await _answer('decline', reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.quoteTitle)),
      body: ParentAsyncBody<ParentQuote>(
        value: ref.watch(parentQuoteProvider(widget.requestId)),
        onRetry: () => ref.invalidate(parentQuoteProvider(widget.requestId)),
        builder: (quote) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Text(tr.version(version: quote.version),
                  style:
                      AppTypography.overline.copyWith(color: AppPalette.text2)),
              const Spacer(),
              Text(quote.statusLabel, style: AppTypography.label),
            ]),
            const SizedBox(height: 12),
            SoeCard(
              child: Column(children: [
                ...quote.lines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.label, style: AppTypography.label),
                              Text(line.rhythm,
                                  style: AppTypography.caption
                                      .copyWith(color: AppPalette.text2)),
                            ],
                          ),
                        ),
                        Text(ParentFormat.amount(context, line.amount),
                            style: AppTypography.label),
                      ]),
                    )),
                const Divider(),
                Row(children: [
                  Expanded(child: Text(tr.total, style: AppTypography.h3)),
                  Text(ParentFormat.amount(context, quote.totalAmount),
                      style:
                          AppTypography.h3.copyWith(color: AppPalette.teal800)),
                ]),
              ]),
            ),
            if (quote.validUntil != null) ...[
              const SizedBox(height: 8),
              Text(
                  tr.validUntil(
                      date: ParentFormat.dayLong(context, quote.validUntil!)),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ],
            const SizedBox(height: 20),
            if (quote.canAnswer) ...[
              SoeButton(
                label: tr.accept(
                    amount: ParentFormat.amount(context, quote.totalAmount)),
                fullWidth: true,
                loading: _busy,
                onPressed: _busy ? null : () => unawaited(_answer('accept')),
              ),
              const SizedBox(height: 10),
              SoeButton(
                label: tr.negotiate,
                fullWidth: true,
                variant: SoeButtonVariant.outline,
                onPressed: _busy ? null : () => unawaited(_negotiate()),
              ),
              const SizedBox(height: 10),
              SoeButton(
                label: tr.decline,
                fullWidth: true,
                variant: SoeButtonVariant.tertiary,
                onPressed: _busy ? null : () => unawaited(_decline()),
              ),
            ],
            if (quote.canReactivate)
              SoeButton(
                label: tr.reactivate,
                fullWidth: true,
                loading: _busy,
                onPressed:
                    _busy ? null : () => unawaited(_answer('reactivate')),
              ),
          ],
        ),
      ),
    );
  }
}

typedef _Negotiation = ({String message, int? amount});

class _NegotiationSheet extends StatefulWidget {
  const _NegotiationSheet();

  @override
  State<_NegotiationSheet> createState() => _NegotiationSheetState();
}

class _NegotiationSheetState extends State<_NegotiationSheet> {
  final _amount = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return _Sheet(children: [
      SoeTextField(
          controller: _amount,
          label: tr.proposal,
          keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      SoeTextField(controller: _message, label: tr.message, maxLines: 4),
      const SizedBox(height: 16),
      ListenableBuilder(
        listenable: _message,
        builder: (context, _) => SoeButton(
          label: tr.send,
          fullWidth: true,
          onPressed: _message.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop<_Negotiation>((
                    message: _message.text.trim(),
                    amount: int.tryParse(
                        _amount.text.replaceAll(RegExp(r'\D'), '')),
                  )),
        ),
      ),
    ]);
  }
}

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet();

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return _Sheet(children: [
      SoeTextField(controller: _reason, label: tr.reason, maxLines: 4),
      const SizedBox(height: 16),
      ListenableBuilder(
        listenable: _reason,
        builder: (context, _) => SoeButton(
          label: tr.decline,
          fullWidth: true,
          variant: SoeButtonVariant.danger,
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
        ),
      ),
    ]);
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 20, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
}

/// PAR-10 — the contract: read to the end, then signed with the finger.
class ParentContractPage extends ConsumerStatefulWidget {
  const ParentContractPage({super.key, required this.contractId});

  final int contractId;

  @override
  ConsumerState<ParentContractPage> createState() => _ParentContractPageState();
}

class _ParentContractPageState extends ConsumerState<ParentContractPage> {
  static const double _padHeight = 130;

  final _signature = SoeSignatureController();
  final _scroll = ScrollController();
  bool _readToEnd = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_check);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _signature.dispose();
    super.dispose();
  }

  // Read once the end of the text was reached, or at once when it fits on the screen.
  void _check() {
    if (_readToEnd || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 40) setState(() => _readToEnd = true);
  }

  Future<void> _sign() async {
    final tr = Translations.of(context).parentSpace.requests;
    setState(() => _busy = true);
    try {
      final png = await _signature
          .toPng(Size(MediaQuery.sizeOf(context).width - 32, _padHeight));
      if (png == null) return;
      await ref.read(parentApiProvider).signContract(widget.contractId, png);
      if (!mounted) return;
      ref.invalidate(parentContractProvider(widget.contractId));
      _refreshRequests(ref);
      SoeToast.show(context, message: tr.signed, tone: SoeToastTone.success);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.contractTitle)),
      body: ParentAsyncBody<ParentContract>(
        value: ref.watch(parentContractProvider(widget.contractId)),
        onRetry: () =>
            ref.invalidate(parentContractProvider(widget.contractId)),
        builder: (contract) => Column(children: [
          Expanded(
            child: Builder(builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _check();
              });
              return ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(contract.reference,
                            style: AppTypography.overline
                                .copyWith(color: AppPalette.text2))),
                    Text(contract.statusLabel, style: AppTypography.label),
                  ]),
                  const SizedBox(height: 12),
                  SoeCard(
                      child: Text(contract.text,
                          style: AppTypography.body.copyWith(height: 1.5))),
                  if (contract.signedAt != null) ...[
                    const SizedBox(height: 12),
                    Text(
                        tr.signedOn(
                            date: ParentFormat.dayLong(
                                context, contract.signedAt!)),
                        style: AppTypography.label
                            .copyWith(color: AppPalette.successText)),
                  ],
                ],
              );
            }),
          ),
          if (contract.canSign)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _readToEnd
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(tr.signHere, style: AppTypography.label),
                        const SizedBox(height: 8),
                        SoeSignaturePad(
                            controller: _signature,
                            clearLabel: tr.clear,
                            height: _padHeight),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: _signature,
                          builder: (context, _) => SoeButton(
                            label: tr.sign,
                            fullWidth: true,
                            loading: _busy,
                            onPressed: _busy || _signature.isEmpty
                                ? null
                                : () => unawaited(_sign()),
                          ),
                        ),
                      ])
                    : Text(tr.readFirst,
                        textAlign: TextAlign.center,
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// PAR-11 — the weekly times proposed by the tutor, by slot; approve or ask for others.
class ParentPlanningProposalPage extends ConsumerStatefulWidget {
  const ParentPlanningProposalPage({super.key, required this.requestId});

  final int requestId;

  @override
  ConsumerState<ParentPlanningProposalPage> createState() =>
      _ParentPlanningProposalPageState();
}

class _ParentPlanningProposalPageState
    extends ConsumerState<ParentPlanningProposalPage> {
  int? _busySlot;

  Future<void> _answer(ParentPlanningSlot slot, {required bool approve}) async {
    final tr = Translations.of(context).parentSpace.requests;
    String? comment;
    if (!approve) {
      comment = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _CommentSheet(),
      );
      if (comment == null || !mounted) return;
    }
    setState(() => _busySlot = slot.id);
    try {
      await ref.read(parentApiProvider).answerPlanning(
          widget.requestId, slot.id,
          approve: approve, comment: comment);
      if (!mounted) return;
      ref.invalidate(parentPlanningProvider(widget.requestId));
      _refreshRequests(ref);
      SoeToast.show(context,
          message: approve ? tr.approved : tr.changeRequested,
          tone: SoeToastTone.success);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busySlot = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.planningTitle)),
      body: ParentAsyncBody<List<ParentPlanningSlot>>(
        value: ref.watch(parentPlanningProvider(widget.requestId)),
        onRetry: () => ref.invalidate(parentPlanningProvider(widget.requestId)),
        builder: (slots) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (slots.every((slot) => slot.times.isEmpty))
              SoeEmptyState(
                  title: tr.planningTitle,
                  message: tr.waiting,
                  icon: Icons.schedule_outlined),
            ...slots.where((slot) => slot.times.isNotEmpty).map(
                  (slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(slot.title, style: AppTypography.h3),
                          Text(slot.tutorName,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
                          const SizedBox(height: 8),
                          ...slot.times.map((time) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                    '${time.day} · ${time.from} – ${time.to}',
                                    style: AppTypography.body),
                              )),
                          if (slot.canAnswer) ...[
                            const SizedBox(height: 10),
                            SoeButton(
                              label: tr.approve,
                              fullWidth: true,
                              size: SoeButtonSize.md,
                              loading: _busySlot == slot.id,
                              onPressed: _busySlot != null
                                  ? null
                                  : () =>
                                      unawaited(_answer(slot, approve: true)),
                            ),
                            const SizedBox(height: 8),
                            SoeButton(
                              label: tr.otherTimes,
                              fullWidth: true,
                              size: SoeButtonSize.md,
                              variant: SoeButtonVariant.outline,
                              onPressed: _busySlot != null
                                  ? null
                                  : () =>
                                      unawaited(_answer(slot, approve: false)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet();

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return _Sheet(children: [
      SoeTextField(controller: _comment, label: tr.comment, maxLines: 4),
      const SizedBox(height: 16),
      ListenableBuilder(
        listenable: _comment,
        builder: (context, _) => SoeButton(
          label: tr.send,
          fullWidth: true,
          onPressed: _comment.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_comment.text.trim()),
        ),
      ),
    ]);
  }
}
