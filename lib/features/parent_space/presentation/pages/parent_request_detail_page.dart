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
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_need_fields.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';
import 'parent_request_pages.dart';

/// Stages where the tutor's times and the sessions exist (planning, payments in place).
const _plannedStages = [
  'first_month_paid',
  'scheduled',
  'active',
  'paused',
  'finished'
];

/// PAR-07 — a request: its state and the one action, then need, quote, tutor, contract,
/// planning, payments and the history (SOE's actions included). Cancel while possible.
class ParentRequestDetailPage extends ConsumerWidget {
  const ParentRequestDetailPage({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(parentRequestDetailProvider(requestId));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).parentSpace.requests.title,
          title: value.valueOrNull?.request.reference ??
              Translations.of(context).parentSpace.requests.title),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(parentRequestDetailProvider(requestId).future),
        child: ParentAsyncBody<ParentRequestDetail>(
          value: value,
          onRetry: () => ref.invalidate(parentRequestDetailProvider(requestId)),
          builder: (detail) => _Detail(detail: detail),
        ),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.detail});

  final ParentRequestDetail detail;

  void _refresh(WidgetRef ref) => ref
    ..invalidate(parentRequestDetailProvider(detail.request.id))
    ..invalidate(parentRequestsProvider)
    ..invalidate(parentHomeProvider);

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final tr = Translations.of(context).parentSpace.requestDetail;
    final reason = TextEditingController();
    final confirmed = await showParentSheet<bool>(
      context,
      title: tr.cancel,
      text: tr.cancelText,
      builder: (sheet) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 12),
        SoeTextField(controller: reason, label: tr.reason, maxLines: 3),
        const SizedBox(height: 16),
        SoeButton(
            label: tr.confirmCancel,
            variant: SoeButtonVariant.danger,
            onPressed: () => Navigator.pop(sheet, true)),
      ]),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (confirmed != true || !context.mounted) return;
    final done = await runParentAction(
        context,
        () =>
            ref.read(parentApiProvider).cancelRequest(detail.request.id, text));
    if (done == null || !context.mounted) return;
    _refresh(ref);
    SoeToast.show(context, message: tr.cancelled, tone: SoeToastTone.success);
  }

  Future<void> _editNeed(
      BuildContext context, WidgetRef ref, ParentNeed need) async {
    final saved = await showParentSheet<bool>(
      context,
      title: Translations.of(context).parentSpace.requestDetail.need,
      builder: (sheet) => _NeedSheet(requestId: detail.request.id, need: need),
    );
    if (saved == true && context.mounted) {
      _refresh(ref);
      SoeToast.show(context,
          message: Translations.of(context).parentSpace.requestDetail.needSaved,
          tone: SoeToastTone.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final request = detail.request;
    final subjects =
        {for (final need in detail.needs) ...need.subjects}.join(', ');
    final target = parentRequestTarget(request);
    final actionLabel = switch (request.action) {
      'quote' => tr.requests.quote,
      'tutor' => tr.requests.tutor,
      'planning' => tr.requests.planning,
      'payment' => tr.requests.payFirst,
      _ => target != null ? tr.requests.contract : null,
    };
    final steps = ParentHomeRequest.steps;
    final current = steps.indexOf(request.step);
    final planned = _plannedStages.contains(request.stage);
    return ListView(
      padding: spacePagePadding(context),
      children: [
        ParentHeading(
          overline: tr.requestDetail.overline(reference: request.reference),
          title: subjects.isEmpty
              ? request.children.join(', ')
              : tr.requestDetail.titleFor(
                  subjects: subjects, children: request.children.join(', ')),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SoeBadge(
              label: request.stepLabel,
              tone: request.step == 'closed'
                  ? SoeBadgeTone.neutral
                  : (request.awaitingTutorSignature
                      ? SoeBadgeTone.info
                      : SoeBadgeTone.warning)),
        ),
        if (actionLabel != null && target != null) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: actionLabel,
              size: SoeButtonSize.md,
              onPressed: () => request.action == 'payment'
                  ? context.go(target)
                  : unawaited(context.push(target)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (current >= 0)
          ParentPanel(soft: true, children: [
            Text(tr.requestDetail.progress.toUpperCase(),
                style:
                    AppTypography.overline.copyWith(color: AppPalette.teal700)),
            Text(request.stepLabel,
                style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 10),
            Row(children: [
              for (var i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < current
                          ? AppPalette.success
                          : (i == current
                              ? AppPalette.gold400
                              : AppPalette.teal100),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 4),
              ],
            ]),
          ]),
        for (final need in detail.needs)
          ParentPanel(
            title: tr.requestDetail.need,
            trailing: detail.needEditable && need.id != null
                ? TextButton(
                    onPressed: () => unawaited(_editNeed(context, ref, need)),
                    child: Text(tr.requestDetail.editNeed))
                : null,
            children: [
              ParentInfoRow(tr.requestDetail.child, need.childName ?? ''),
              ParentInfoRow(tr.wizard.subjects, need.subjects.join(', ')),
              if (need.sessionsPerWeek != null)
                ParentInfoRow(
                    tr.wizard.rhythm,
                    tr.wizard.rhythmValue(
                        count: need.sessionsPerWeek!,
                        duration: _minutes(need.sessionMinutes))),
              if (need.startOn != null)
                ParentInfoRow(tr.wizard.startOn,
                    ParentFormat.dayLong(context, need.startOn!),
                    last: true),
            ],
          ),
        if (request.quoteAmount != null)
          ParentPanel(
            title: tr.requestDetail.quote,
            trailing: TextButton(
                onPressed: () => unawaited(
                    context.push(ParentSpaceRoutes.quote(request.id))),
                child: Text(tr.requestDetail.seeQuote)),
            children: [
              Text(ParentFormat.amount(context, request.quoteAmount!),
                  style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
              Text(tr.requestDetail.perMonth,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ],
          ),
        ParentPanel(
          title: tr.requestDetail.tutor,
          soft: !detail.tutorsPresented,
          children: [
            if (!detail.tutorsPresented)
              Text(tr.requestDetail.tutorPending,
                  style: AppTypography.bodySm.copyWith(color: AppPalette.text2))
            else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: SoeButton(
                  label: tr.requestDetail.seeProfile,
                  size: SoeButtonSize.md,
                  variant: SoeButtonVariant.outline,
                  onPressed: () => unawaited(
                      context.push(ParentSpaceRoutes.tutors(request.id))),
                ),
              ),
              if (detail.replacementEvents.isNotEmpty)
                TextButton(
                  onPressed: () => unawaited(
                      context.push(ParentSpaceRoutes.replacement(request.id))),
                  child: Text(tr.requestDetail.replacementFollow),
                ),
            ],
          ],
        ),
        if (request.contractId != null)
          ParentPanel(
            title: tr.requestDetail.contract,
            trailing: SoeBadge(
                label: request.contractStatus == 'signed'
                    ? tr.requestDetail.signed
                    : tr.requestDetail.toSign,
                tone: request.contractStatus == 'signed'
                    ? SoeBadgeTone.success
                    : SoeBadgeTone.warning),
            children: [
              SoeButton(
                label: tr.requestDetail.seeContract,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.outline,
                onPressed: () => unawaited(context
                    .push(ParentSpaceRoutes.contract(request.contractId!))),
              ),
            ],
          ),
        ParentPanel(
          title: tr.requestDetail.planning,
          soft: !planned,
          children: [
            if (planned)
              SoeButton(
                label: tr.requestDetail.seePlanning,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.outline,
                onPressed: () => unawaited(
                    context.push(ParentSpaceRoutes.planning(request.id))),
              )
            else
              Text(tr.requestDetail.planningLater,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ],
        ),
        ParentPanel(
          title: tr.requestDetail.payments,
          soft: request.contractStatus != 'signed',
          children: [
            if (request.contractStatus == 'signed')
              SoeButton(
                label: tr.requestDetail.seePayments,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.outline,
                onPressed: () => context.go(RouteNames.parentPayments),
              )
            else
              Text(tr.requestDetail.paymentsLater,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ],
        ),
        if (detail.history.isNotEmpty)
          ParentPanel(soft: true, title: tr.requestDetail.history, children: [
            ParentTimeline(items: [
              for (final (i, event) in detail.history.indexed)
                (
                  title: event.label,
                  subtitle: [
                    if (event.at != null)
                      ParentFormat.dateTime(context, event.at!),
                    switch (event.actor) {
                      'you' => tr.common.you,
                      'family' => tr.common.family,
                      _ => tr.common.soe,
                    },
                  ].join(' · '),
                  state: i == 0 ? 'current' : 'done',
                ),
            ]),
          ]),
        if (detail.canCancel)
          SoeButton(
            label: tr.requestDetail.cancel,
            variant: SoeButtonVariant.dangerOutline,
            fullWidth: true,
            onPressed: () => unawaited(_cancel(context, ref)),
          ),
      ],
    );
  }

  String _minutes(int? minutes) {
    if (minutes == null) return '';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest';
  }
}

/// « Modifier le besoin »: the need's fields, saved on the request.
class _NeedSheet extends ConsumerStatefulWidget {
  const _NeedSheet({required this.requestId, required this.need});

  final int requestId;
  final ParentNeed need;

  @override
  ConsumerState<_NeedSheet> createState() => _NeedSheetState();
}

class _NeedSheetState extends ConsumerState<_NeedSheet> {
  late ParentNeed _need = widget.need;
  Set<String> _missing = const {};
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(parentApiProvider).updateNeed(widget.requestId, _need);
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationFailure catch (failure) {
      if (mounted) setState(() => _missing = failure.errors.keys.toSet());
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
    final draft = ref.watch(parentDraftProvider).valueOrNull;
    final references = ref.watch(parentReferencesProvider).valueOrNull;
    if (draft == null || references == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ParentNeedFields(
        need: _need,
        draft: draft,
        subjects: references.subjects,
        missing: _missing,
        onChanged: (next) => setState(() => _need = next),
      ),
      const SizedBox(height: 16),
      SoeButton(
        label: Translations.of(context).parentSpace.common.save,
        variant: SoeButtonVariant.secondary,
        loading: _busy,
        onPressed: _busy ? null : () => unawaited(_save()),
      ),
    ]);
  }
}
