import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import 'parent_home_page.dart' show parentSubjects;
import '../providers.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';
import 'parent_contract_pages.dart';

/// Refreshes what a request step changes: the requests, the home actions.
void _refreshRequests(WidgetRef ref) => ref
  ..invalidate(parentRequestsProvider)
  ..invalidate(parentHomeProvider);

/// The next screen of a request for its holder action (or its contract to sign).
/// A presented tutor is accepted by signing the contract; a signed one leads to the payment.
/// None while a tutor has still to sign: the parent has nothing left to do.
String? parentRequestTarget(ParentRequest request) =>
    request.awaitingTutorSignature ? null : _actionTarget(request);

String? _actionTarget(ParentRequest request) => switch (request.action) {
      'quote' => ParentSpaceRoutes.quote(request.id),
      'tutor' => ParentSpaceRoutes.tutors(request.id),
      'planning' => ParentSpaceRoutes.planning(request.id),
      'payment' => RouteNames.parentPayments,
      _ => request.contractId != null &&
              request.step == 'contract' &&
              request.contractStatus == 'sent'
          ? ParentSpaceRoutes.contract(request.contractId!)
          : null,
    };

enum _RequestFilter { all, toHandle, inPlace, closed }

/// PAR-06 — the family's requests with their step and the one action to take, filtered
/// (all, to handle, courses in place, closed); a card opens the request (PAR-07);
/// « Nouvelle demande » starts the wizard (PAR-05).
class ParentRequestsPage extends ConsumerStatefulWidget {
  const ParentRequestsPage({super.key});

  @override
  ConsumerState<ParentRequestsPage> createState() => _ParentRequestsPageState();
}

class _ParentRequestsPageState extends ConsumerState<ParentRequestsPage> {
  _RequestFilter _filter = _RequestFilter.all;

  static const _inPlace = ['first_month_paid', 'scheduled', 'active', 'paused'];

  bool _matches(ParentRequest request, _RequestFilter filter) =>
      switch (filter) {
        _RequestFilter.all => true,
        _RequestFilter.toHandle => parentRequestTarget(request) != null,
        _RequestFilter.inPlace => _inPlace.contains(request.stage),
        _RequestFilter.closed => request.step == 'closed',
      };

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: ParentAsyncBody<List<ParentRequest>>(
        value: ref.watch(parentRequestsProvider),
        onRetry: () => ref.invalidate(parentRequestsProvider),
        builder: (requests) => ListView(
          padding: spacePagePadding(context, top: 8, bottom: 32),
          children: [
            Text(tr.title,
                style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: SoeButton(
                label: Translations.of(context).parentSpace.requestDetail.kNew,
                size: SoeButtonSize.md,
                onPressed: () =>
                    unawaited(context.push(ParentSpaceRoutes.newRequest)),
              ),
            ),
            const SizedBox(height: 16),
            if (requests.isNotEmpty) ...[
              ParentChoiceChips<_RequestFilter>(
                options: [
                  for (final (filter, label) in [
                    (_RequestFilter.all, tr.filterAll),
                    (_RequestFilter.toHandle, tr.filterToHandle),
                    (_RequestFilter.inPlace, tr.filterInPlace),
                    (_RequestFilter.closed, tr.filterClosed),
                  ])
                    if (filter == _RequestFilter.all ||
                        requests.any((request) => _matches(request, filter)))
                      (
                        filter,
                        '$label ${requests.where((request) => _matches(request, filter)).length}'
                      ),
                ],
                selected: {_filter},
                onToggle: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 16),
            ],
            if (requests.isEmpty)
              SoeEmptyState(
                  title: tr.empty,
                  message: tr.emptyText,
                  icon: Icons.assignment_outlined),
            ...requests
                .where((request) => _matches(request, _filter))
                .map((request) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RequestCard(request: request),
                    )),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.request});

  final ParentRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.requests;
    final home = Translations.of(context).parentSpace.home;
    final needs =
        ref.watch(parentRequestDetailProvider(request.id)).valueOrNull?.needs ??
            const <ParentNeed>[];
    final subjects = {
      for (final need in needs) ...need.subjects.where((s) => s.isNotEmpty)
    }.toList();
    final children = request.children.join(', ');
    // The server's sentence first; the app's text of the step only without one. A contract
    // the parent no longer has to sign gets no « il reste à signer » (its label says it).
    final stepText = request.explanation ??
        switch (request.step) {
          _ when request.awaitingTutorSignature => null,
          'quote' => home.stepText.quote,
          'tutor' => home.stepText.tutor,
          'contract'
              when request.contractStatus != null &&
                  request.contractStatus != 'sent' =>
            null,
          'contract' => home.stepText.contract,
          'payment' => home.stepText.payment,
          'first_session' => home.stepText.firstSession,
          'closed' => null,
          _ => home.stepText.request,
        };
    final target = parentRequestTarget(request);
    final label = switch (request.action) {
      'quote' => tr.quote,
      'tutor' => tr.tutor,
      'planning' => tr.planning,
      'payment' => tr.payFirst,
      _ => target != null ? tr.contract : null,
    };
    return SoeCard(
      onTap: () =>
          unawaited(context.push(ParentSpaceRoutes.request(request.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.description_outlined,
                size: 16, color: AppPalette.text2),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                  [
                    request.reference,
                    if (request.createdAt != null)
                      tr.createdOn(
                          date: ParentFormat.day(context, request.createdAt!)),
                  ].join(' · '),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ),
            SoeBadge(
                label: request.stepLabel,
                tone: request.step == 'closed'
                    ? SoeBadgeTone.neutral
                    : request.awaitingTutorSignature
                        ? SoeBadgeTone.info
                        : (target != null
                            ? SoeBadgeTone.warning
                            : SoeBadgeTone.success)),
          ]),
          const SizedBox(height: 10),
          Text(
              subjects.isEmpty
                  ? children
                  : home.requestTitle(
                      subjects: parentSubjects(context, subjects),
                      children: children),
              style: AppTypography.label.copyWith(color: AppPalette.text)),
          const SizedBox(height: 4),
          Text(
              [
                if (stepText != null) stepText,
                if (request.quoteAmount != null)
                  tr.perMonth(
                      amount:
                          ParentFormat.amount(context, request.quoteAmount!)),
              ].join(' · '),
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 12),
          if (label != null && target != null)
            SoeButton(
              label: label,
              fullWidth: true,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.outline,
              onPressed: () => request.action == 'payment'
                  ? context.go(target)
                  : unawaited(context.push(target)),
            )
          else
            SoeButton(
              label: tr.open,
              fullWidth: true,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.tertiary,
              onPressed: () => unawaited(
                  context.push(ParentSpaceRoutes.request(request.id))),
            ),
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
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab,
          title: tr.quoteTitle),
      body: ParentAsyncBody<ParentQuote>(
        value: ref.watch(parentQuoteProvider(widget.requestId)),
        onRetry: () => ref.invalidate(parentQuoteProvider(widget.requestId)),
        builder: (quote) => ListView(
          padding: spacePagePadding(context),
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

/// PAR-10 — the contract: read to the end, then signed with the finger; its PDF and its
/// amendments (COM-08). Legacy contracts (former platform) are signed the same way.
class ParentContractPage extends ConsumerWidget {
  const ParentContractPage({super.key, required this.contractId});

  final int contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final value = ref.watch(parentContractProvider(contractId));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
        section: Translations.of(context).shell.more.tab,
        title: tr.requests.contractTitle,
        actions: [
          IconButton(
            tooltip: tr.common.pdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => unawaited(openParentPdf(
                context,
                ref,
                () => ref.read(parentApiProvider).contractPdf(contractId,
                    lang: Localizations.localeOf(context).languageCode),
                '${value.valueOrNull?.reference ?? 'contract_$contractId'}.pdf')),
          ),
        ],
      ),
      body: ParentAsyncBody<ParentContract>(
        value: value,
        onRetry: () => ref.invalidate(parentContractProvider(contractId)),
        builder: (contract) => ParentSignableText(
          header: [
            Row(children: [
              Expanded(
                  child: Text(contract.reference,
                      style: AppTypography.overline
                          .copyWith(color: AppPalette.text2))),
              Text(contract.statusLabel, style: AppTypography.label),
            ]),
          ],
          text: contract.text,
          signedAt: contract.signedAt,
          canSign: contract.canSign,
          signLabel: tr.requests.sign,
          footer: [
            const SizedBox(height: 12),
            ParentAmendmentsSection(contractId: contractId),
          ],
          onSign: (png) async {
            final signed = await runParentAction(
                context,
                () =>
                    ref.read(parentApiProvider).signContract(contractId, png));
            if (signed == null || !context.mounted) return;
            ref
              ..invalidate(parentContractProvider(contractId))
              ..invalidate(parentContractsProvider);
            _refreshRequests(ref);
            SoeToast.show(context,
                message: tr.requests.signed, tone: SoeToastTone.success);
          },
        ),
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
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab,
          title: tr.planningTitle),
      body: ParentAsyncBody<List<ParentPlanningSlot>>(
        value: ref.watch(parentPlanningProvider(widget.requestId)),
        onRetry: () => ref.invalidate(parentPlanningProvider(widget.requestId)),
        builder: (slots) => ListView(
          padding: spacePagePadding(context),
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
