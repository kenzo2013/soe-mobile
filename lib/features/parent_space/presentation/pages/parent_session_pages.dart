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

String _failureMessage(BuildContext context, Failure failure) =>
    switch (failure) {
      ConflictFailure(:final message) =>
        message ?? Translations.of(context).parentSpace.retry,
      ValidationFailure(:final message) =>
        message ?? Translations.of(context).parentSpace.retry,
      _ => Translations.of(context).parentSpace.retry,
    };

/// PAR-13 — a session: check-in, report, backup code (check-in window only), cancel.
class ParentSessionPage extends ConsumerWidget {
  const ParentSessionPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.session;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: ParentAsyncBody<ParentSessionDetail>(
        value: ref.watch(parentSessionProvider(sessionId)),
        onRetry: () => ref.invalidate(parentSessionProvider(sessionId)),
        builder: (detail) {
          final session = detail.session;
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
            message: _failureMessage(context, failure),
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
            message: _failureMessage(context, failure),
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
