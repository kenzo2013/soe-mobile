import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';

/// PAR-13 — a session: check-in, report, backup code (check-in window only), cancel,
/// a problem for the advisor or serious behaviour (SOE steps in).
class ParentSessionPage extends ConsumerStatefulWidget {
  const ParentSessionPage(
      {super.key, required this.sessionId, this.openSerious = false});

  final int sessionId;

  /// Opens the serious behaviour sheet once loaded (from the child's « Sécurité »).
  final bool openSerious;

  @override
  ConsumerState<ParentSessionPage> createState() => _ParentSessionPageState();
}

class _ParentSessionPageState extends ConsumerState<ParentSessionPage> {
  late bool _pendingSerious = widget.openSerious;

  int get sessionId => widget.sessionId;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.session;
    final value = ref.watch(parentSessionProvider(sessionId));
    if (_pendingSerious && value.hasValue) {
      _pendingSerious = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(showParentProblemSheet(context, ref, value.requireValue,
              serious: true));
        }
      });
    }
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: ParentAsyncBody<ParentSessionDetail>(
        value: value,
        onRetry: () => ref.invalidate(parentSessionProvider(sessionId)),
        builder: (detail) {
          final session = detail.session;
          final held = session.startsAt.isBefore(DateTime.now()) &&
              session.status != 'cancelled';
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(ParentFormat.dayLong(context, session.startsAt),
                style:
                    AppTypography.overline.copyWith(color: AppPalette.text2)),
            Text(session.title,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 6),
            Align(
                alignment: Alignment.centerLeft,
                child: ParentStatusBadge(
                    status: session.status, label: session.statusLabel)),
            const SizedBox(height: 16),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.checkIn, style: AppTypography.title),
                    const SizedBox(height: 6),
                    if (detail.arrivedAt == null)
                      Text(tr.noCheckIn,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2))
                    else ...[
                      Text(
                          '${tr.arrival} : ${ParentFormat.time(detail.arrivedAt!)}'
                          '${detail.distanceMeters == null ? '' : ' · ${tr.distance(meters: detail.distanceMeters!)}'}'),
                      if (detail.leftAt != null)
                        Text(
                            '${tr.departure} : ${ParentFormat.time(detail.leftAt!)}'),
                    ],
                  ]),
            ),
            const SizedBox(height: 10),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.report, style: AppTypography.title),
                    const SizedBox(height: 6),
                    if (detail.reportSubmittedAt == null)
                      Text(tr.reportPending,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2))
                    else ...[
                      if (detail.reportAutoValidatesAt != null)
                        Text(
                            tr.autoIn(
                                date: ParentFormat.dateTime(
                                    context, detail.reportAutoValidatesAt!)),
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      const SizedBox(height: 8),
                      SoeButton(
                        label: tr.seeReport,
                        size: SoeButtonSize.md,
                        variant: session.status == 'report_to_approve'
                            ? SoeButtonVariant.primary
                            : SoeButtonVariant.outline,
                        onPressed: () =>
                            context.push(ParentSpaceRoutes.report(session.id)),
                      ),
                    ],
                  ]),
            ),
            const SizedBox(height: 10),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tr.time} : ${ParentFormat.time(session.startsAt)}'
                        '${session.endsAt == null ? '' : ' – ${ParentFormat.time(session.endsAt!)}'}'),
                    Text('${tr.tutor} : ${session.tutorName}'),
                    if (detail.backupCode != null) ...[
                      const SizedBox(height: 8),
                      Text(tr.backupCode, style: AppTypography.labelSm),
                      Text(detail.backupCode!, style: AppTypography.h2),
                      Text(tr.backupHint,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    ],
                  ]),
            ),
            if (detail.canCancel) ...[
              const SizedBox(height: 16),
              SoeButton(
                label: tr.cancel,
                variant: SoeButtonVariant.dangerOutline,
                fullWidth: true,
                onPressed: () => _cancel(context, ref, detail),
              ),
            ],
            const SizedBox(height: 16),
            SoeButton(
              label: Translations.of(context).parentSpace.problem.action,
              variant: SoeButtonVariant.outline,
              fullWidth: true,
              onPressed: () =>
                  unawaited(showParentProblemSheet(context, ref, detail)),
            ),
            if (held)
              SoeButton(
                label: Translations.of(context).parentSpace.problem.serious,
                variant: SoeButtonVariant.tertiary,
                fullWidth: true,
                onPressed: () => unawaited(showParentProblemSheet(
                    context, ref, detail,
                    serious: true)),
              ),
          ]);
        },
      ),
    );
  }

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, ParentSessionDetail detail) async {
    final tr = Translations.of(context).parentSpace.session;
    final reason = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tr.cancel, style: AppTypography.title),
              if (detail.lateCancellation) ...[
                const SizedBox(height: 8),
                SoeAlert(
                    tone: SoeAlertTone.warning,
                    title: tr.cancel,
                    body: tr.lateWarning),
              ],
              const SizedBox(height: 12),
              SoeTextField(controller: reason, label: tr.reason),
              const SizedBox(height: 12),
              SoeButton(
                  label: tr.confirmCancel,
                  variant: SoeButtonVariant.danger,
                  onPressed: () => Navigator.pop(sheet, true)),
            ]),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(parentApiProvider).cancel(detail.session.id, reason.text);
      ref.invalidate(parentSessionProvider(detail.session.id));
      if (context.mounted) SoeToast.show(context, message: tr.cancelled);
    } on Failure catch (failure) {
      if (context.mounted)
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
    }
  }
}

/// PAR-14 — the report: times, topics, homework, observations; approve or dispute (reason).
class ParentReportPage extends ConsumerStatefulWidget {
  const ParentReportPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ParentReportPage> createState() => _ParentReportPageState();
}

class _ParentReportPageState extends ConsumerState<ParentReportPage> {
  final _reason = TextEditingController();
  bool _disputing = false;
  bool _sending = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _answer({required bool approve}) async {
    final tr = Translations.of(context).parentSpace.report;
    setState(() => _sending = true);
    try {
      await ref.read(parentApiProvider).answerReport(widget.sessionId,
          approve: approve, reason: _reason.text);
      ref
        ..invalidate(parentReportProvider(widget.sessionId))
        ..invalidate(parentSessionProvider(widget.sessionId))
        ..invalidate(parentHomeProvider);
      if (mounted)
        SoeToast.show(context, message: approve ? tr.approved : tr.disputed);
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
    final tr = Translations.of(context).parentSpace.report;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: ParentAsyncBody<ParentReport>(
        value: ref.watch(parentReportProvider(widget.sessionId)),
        onRetry: () => ref.invalidate(parentReportProvider(widget.sessionId)),
        builder: (report) {
          final state = report.disputeReason != null
              ? (tr.stateDisputed, 'disputed')
              : report.validated == true
                  ? (tr.stateApproved, 'approved')
                  : (tr.stateToApprove, 'report_to_approve');
          Widget field(String label, String? value) =>
              value == null || value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label.toUpperCase(),
                                style: AppTypography.overline
                                    .copyWith(color: AppPalette.text2)),
                            const SizedBox(height: 2),
                            Text(value, style: AppTypography.body),
                          ]),
                    );
          return ListView(padding: const EdgeInsets.all(16), children: [
            Align(
                alignment: Alignment.centerLeft,
                child: ParentStatusBadge(status: state.$2, label: state.$1)),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    field(
                        tr.times,
                        [report.startAt, report.endAt]
                            .whereType<String>()
                            .join(' → ')),
                    field(tr.topics, report.topics.join(', ')),
                    field(tr.homework, report.homework),
                    field(tr.observations, report.observations),
                    field(tr.comment, report.comment),
                  ]),
            ),
            if (report.canAnswer) ...[
              const SizedBox(height: 12),
              if (report.autoValidatesAt != null)
                Text(
                    tr.autoOn(
                        date: ParentFormat.dateTime(
                            context, report.autoValidatesAt!)),
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              const SizedBox(height: 12),
              if (!_disputing) ...[
                SoeButton(
                    label: tr.approve,
                    fullWidth: true,
                    loading: _sending,
                    onPressed: () => _answer(approve: true)),
                const SizedBox(height: 8),
                SoeButton(
                  label: tr.dispute,
                  variant: SoeButtonVariant.dangerOutline,
                  fullWidth: true,
                  onPressed: () => setState(() => _disputing = true),
                ),
              ] else ...[
                Text(tr.disputeHint, style: AppTypography.bodySm),
                const SizedBox(height: 8),
                SoeTextField(controller: _reason, label: tr.reason),
                const SizedBox(height: 8),
                SoeButton(
                  label: tr.sendDispute,
                  variant: SoeButtonVariant.danger,
                  fullWidth: true,
                  loading: _sending,
                  onPressed: () => _answer(approve: false),
                ),
              ],
            ],
          ]);
        },
      ),
    );
  }
}


/// Problem types of a session (Reports::ParentProblem::TYPES).
const _problemTypes = [
  'repeated_lateness',
  'no_show',
  'incorrect_check_in',
  'unprofessional_conduct',
  'other'
];

/// « Signaler un problème » (goes to the advisor; no messaging with the tutor) or, with
/// [serious], serious behaviour: SOE calls and suspends the tutor's sessions.
Future<void> showParentProblemSheet(
    BuildContext context, WidgetRef ref, ParentSessionDetail detail,
    {bool serious = false}) async {
  final tr = Translations.of(context).parentSpace.problem;
  final session = detail.session;
  final sent = await showParentSheet<bool>(
    context,
    title: serious ? tr.serious : tr.action,
    text: serious
        ? tr.seriousText
        : '${tr.overline(date: ParentFormat.day(context, session.startsAt))} · ${session.title}',
    builder: (sheet) => _ProblemForm(detail: detail, serious: serious),
  );
  if (sent == true && context.mounted) {
    SoeToast.show(context,
        message: serious ? tr.seriousSent : tr.sent,
        tone: SoeToastTone.success);
  }
}

class _ProblemForm extends ConsumerStatefulWidget {
  const _ProblemForm({required this.detail, required this.serious});

  final ParentSessionDetail detail;
  final bool serious;

  @override
  ConsumerState<_ProblemForm> createState() => _ProblemFormState();
}

class _ProblemFormState extends ConsumerState<_ProblemForm> {
  final _description = TextEditingController();
  String? _type;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final tr = Translations.of(context).parentSpace.problem;
    if ((!widget.serious && _type == null) ||
        _description.text.trim().isEmpty) {
      setState(() => _error = tr.describeMissing);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(parentApiProvider).reportProblem(
          widget.detail.session.id,
          serious: widget.serious,
          reportType: _type,
          description: _description.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (failure) {
      if (mounted) setState(() => _error = parentFailureMessage(context, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.problem;
    final labels = {
      'repeated_lateness': tr.lateness,
      'no_show': tr.noShow,
      'incorrect_check_in': tr.checkIn,
      'unprofessional_conduct': tr.conduct,
      'other': tr.other,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!widget.serious) ...[
        ParentFieldLabel(tr.subject),
        ParentChoiceChips<String>(
          options: [for (final type in _problemTypes) (type, labels[type]!)],
          selected: {if (_type != null) _type!},
          onToggle: (type) => setState(() => _type = type),
        ),
      ],
      ParentFieldLabel(widget.serious ? tr.describe : tr.message),
      ParentCountedField(controller: _description, errorText: _error),
      if (!widget.serious)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppPalette.surfaceSoft,
              borderRadius: BorderRadius.circular(14)),
          child: Text(tr.hint,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        ),
      const SizedBox(height: 16),
      SoeButton(
        label: widget.serious ? tr.serious : tr.send,
        variant:
            widget.serious ? SoeButtonVariant.danger : SoeButtonVariant.secondary,
        loading: _busy,
        onPressed: _busy ? null : () => unawaited(_send()),
      ),
      SoeButton(
        label: Translations.of(context).parentSpace.common.cancel,
        variant: SoeButtonVariant.tertiary,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ]);
  }
}
