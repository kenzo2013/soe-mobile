import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../../data/tutor_money_models.dart';
import '../providers.dart';
import '../tutor_money_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_download.dart';
import '../widgets/tutor_panel.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

String _number(int value) =>
    NumberFormat.decimalPattern('fr').format(value).replaceAll(',', ' ');

String _locale(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// REP-19 — the « Revenus » tab: the pay of the month (approved sessions only), by pupil, the
/// payout, the latest statements with their receipt, the full history.
class TutorEarningsPage extends ConsumerWidget {
  const TutorEarningsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.earnings;
    return SpaceTabAsync<TutorEarnings>(
      band: SpaceBand(title: tr.title, subtitle: tr.onlyApproved),
      value: ref.watch(tutorEarningsProvider),
      onRetry: () => ref.invalidate(tutorEarningsProvider),
      onRefresh: () => ref.refresh(tutorEarningsProvider.future),
      builder: (earnings) {
        final empty = earnings.amount == 0 &&
            earnings.pupils.isEmpty &&
            earnings.history.isEmpty;
        if (empty) {
          return [
            SoeCard(
              raised: true,
              child: SoeEmptyState(
                title: tr.emptyTitle,
                message: tr.emptyText,
                icon: Icons.payments_outlined,
              ),
            ),
          ];
        }
        final panels = [
          _PupilsPanel(earnings: earnings),
          _PayoutPanel(earnings: earnings),
          _HistoryPanel(earnings: earnings),
        ];
        if (spaceIsWide(context)) {
          return [
            _MonthCard(earnings: earnings),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(children: [panels[0], panels[1]])),
              const SizedBox(width: 16),
              Expanded(child: panels[2]),
            ]),
          ];
        }
        return [_MonthCard(earnings: earnings), ...panels];
      },
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.earnings});

  final TutorEarnings earnings;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final month = toBeginningOfSentenceCase(
        DateFormat('MMMM', _locale(context)).format(DateTime.now()));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SoeCard(
        color: AppPalette.success,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${tr.current.toUpperCase()} · ${month.toUpperCase()}',
              style:
                  AppTypography.overline.copyWith(color: AppPalette.successBg)),
          const SizedBox(height: 8),
          Text(TutorFormat.amount(context, earnings.amount),
              style: AppTypography.numberL.copyWith(color: AppPalette.white)),
          Text(
              earnings.approved == 0
                  ? tr.noneApproved
                  : tr.estimated(n: earnings.approved),
              style:
                  AppTypography.caption.copyWith(color: AppPalette.successBg)),
        ]),
      ),
    );
  }
}

class _PupilsPanel extends StatelessWidget {
  const _PupilsPanel({required this.earnings});

  final TutorEarnings earnings;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final waiting = earnings.pendingAmount > 0 || earnings.disputedAmount > 0;
    return TutorPanel(
      title: tr.byPupil,
      footer: waiting
          ? Text(tr.waitingNote(
              pending: TutorFormat.amount(context, earnings.pendingAmount),
              disputed: TutorFormat.amount(context, earnings.disputedAmount)))
          : null,
      children: earnings.pupils.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Text(tr.noSession,
                    style:
                        AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              )
            ]
          : earnings.pupils.map((pupil) {
              final details = [
                if (pupil.rate != null)
                  tr.approvedTimes(
                      n: pupil.approved,
                      rate: TutorFormat.amount(context, pupil.rate!))
                else
                  tr.approvedCount(n: pupil.approved),
                if (pupil.pending > 0) tr.pending(n: pupil.pending),
                if (pupil.disputed > 0) tr.disputed(n: pupil.disputed),
              ];
              return TutorPanelRow(
                initials: tutorInitials(pupil.name ?? tr.pupil),
                title: pupil.name ?? tr.pupil,
                subtitle: details.join(' · '),
                trailing: Text(_number(pupil.amount),
                    style:
                        AppTypography.label.copyWith(color: AppPalette.text)),
              );
            }).toList(),
    );
  }
}

class _PayoutPanel extends StatelessWidget {
  const _PayoutPanel({required this.earnings});

  final TutorEarnings earnings;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final now = DateTime.now();
    final nextMonth = DateFormat('MMM', _locale(context))
        .format(DateTime(now.year, now.month + 1));
    final payoutOn = earnings.payoutOn;
    return TutorPanel(
      title: tr.payout,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                payoutOn == null
                    ? tr.payoutEarly(month: nextMonth)
                    : TutorFormat.dayLong(context, payoutOn),
                style: AppTypography.h2),
            if (payoutOn == null)
              Text(tr.payoutTbc,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 16),
            Row(children: [
              Text(tr.onMethod,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(earnings.defaultMethodLabel ?? tr.noMethod,
                    textAlign: TextAlign.end,
                    style:
                        AppTypography.labelSm.copyWith(color: AppPalette.text)),
              ),
            ]),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    unawaited(context.push(TutorSpaceRoutes.payoutMethods)),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppPalette.teal500),
                child: Text(tr.methods),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _HistoryPanel extends ConsumerWidget {
  const _HistoryPanel({required this.earnings});

  final TutorEarnings earnings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.earnings;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TutorPanel(
        title: tr.history,
        footer: earnings.history.isEmpty ? null : Text(tr.receiptHint),
        children: earnings.history.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Text(tr.noHistory,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2)),
                )
              ]
            : earnings.history
                .map((payout) => TutorPanelRow(
                      icon: Icons.receipt_long_outlined,
                      title: payout.period == null
                          ? '—'
                          : toBeginningOfSentenceCase(
                                  DateFormat('MMMM', _locale(context))
                                      .format(payout.period!)) ??
                              '',
                      subtitle: [
                        if (payout.paidAt != null)
                          tr.paidOn(
                              date: DateFormat('d MMM', _locale(context))
                                  .format(payout.paidAt!)),
                        tr.sessions(n: payout.sessions),
                      ].join(' · '),
                      trailing: Text(_number(payout.amount),
                          style: AppTypography.label
                              .copyWith(color: AppPalette.text)),
                      onTap: () => unawaited(openTutorDownload(
                          context,
                          ref,
                          () => ref
                              .read(tutorMoneyApiProvider)
                              .receiptLink(payout.id))),
                    ))
                .toList(),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () =>
              unawaited(context.push(TutorSpaceRoutes.earningsHistory)),
          style: TextButton.styleFrom(foregroundColor: AppPalette.teal500),
          child: Text(tr.fullHistory),
        ),
      ),
    ]);
  }
}

/// REP-19 — every pay statement, page by page, latest first, with its receipt once paid.
class TutorEarningsHistoryPage extends ConsumerStatefulWidget {
  const TutorEarningsHistoryPage({super.key});

  @override
  ConsumerState<TutorEarningsHistoryPage> createState() =>
      _TutorEarningsHistoryPageState();
}

class _TutorEarningsHistoryPageState
    extends ConsumerState<TutorEarningsHistoryPage> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.tutor.earnings,
          title: tr.historyTitle),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorStatementsProvider(_page).future),
        child: TutorAsyncBody(
          value: ref.watch(tutorStatementsProvider(_page)),
          onRetry: () => ref.invalidate(tutorStatementsProvider(_page)),
          builder: (statements) => ListView(
            padding: spacePagePadding(context, top: 8, bottom: 32),
            children: [
              Text(tr.historyIntro,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 16),
              if (statements.items.isEmpty)
                SoeEmptyState(
                    title: tr.historyEmpty,
                    message: tr.historyEmptyText,
                    icon: Icons.receipt_long_outlined)
              else
                TutorPanel(
                    children: statements.items
                        .map((s) => _StatementRow(statement: s))
                        .toList()),
              if (statements.totalPages > 1)
                Row(children: [
                  Expanded(
                    child: SoeButton(
                      label: tr.newer,
                      variant: SoeButtonVariant.tertiary,
                      size: SoeButtonSize.sm,
                      onPressed:
                          _page > 1 ? () => setState(() => _page--) : null,
                    ),
                  ),
                  Text(tr.page(page: _page, pages: statements.totalPages),
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.text2)),
                  Expanded(
                    child: SoeButton(
                      label: tr.older,
                      variant: SoeButtonVariant.tertiary,
                      size: SoeButtonSize.sm,
                      onPressed: statements.hasMore
                          ? () => setState(() => _page++)
                          : null,
                    ),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatementRow extends ConsumerWidget {
  const _StatementRow({required this.statement});

  final TutorStatement statement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final title = statement.period != null
        ? TutorFormat.month(context, statement.period!)
        : statement.receiptNumber ?? '—';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(title, style: AppTypography.label)),
          Text(TutorFormat.amount(context, statement.amount),
              style: AppTypography.label.copyWith(color: AppPalette.teal800)),
        ]),
        const SizedBox(height: 2),
        Text(
            [
              if (statement.receiptNumber != null && statement.period != null)
                tr.receiptNumber(number: statement.receiptNumber!),
              tr.sessions(n: statement.sessions),
              if (statement.paidAt != null)
                tr.paidOn(date: TutorFormat.day(context, statement.paidAt!)),
            ].join(' · '),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        Row(children: [
          SoeBadge(
              label: statement.statusLabel,
              tone: switch (statement.status) {
                'paid' => SoeBadgeTone.success,
                'processing' => SoeBadgeTone.info,
                'failed' => SoeBadgeTone.danger,
                _ => SoeBadgeTone.warning,
              }),
          const Spacer(),
          if (statement.hasReceipt)
            TutorDownloadButton(
              label: tr.receipt,
              fetch: () =>
                  ref.read(tutorMoneyApiProvider).receiptLink(statement.id),
            ),
        ]),
      ]),
    );
  }
}
