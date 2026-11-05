import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';

/// REP-19 — the pay of the month (approved sessions only), by pupil, the payout, the history.
class TutorEarningsPage extends ConsumerWidget {
  const TutorEarningsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.earnings;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(tutorEarningsProvider.future),
          child: TutorAsyncBody<TutorEarnings>(
            value: ref.watch(tutorEarningsProvider),
            onRetry: () => ref.invalidate(tutorEarningsProvider),
            builder: (earnings) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(tr.title,
                    style:
                        AppTypography.h1.copyWith(color: AppPalette.teal800)),
                Text(tr.onlyApproved,
                    style:
                        AppTypography.bodySm.copyWith(color: AppPalette.text2)),
                const SizedBox(height: 16),
                _AmountCard(earnings: earnings),
                TutorSectionTitle(tr.byPupil),
                if (earnings.pupils.isEmpty)
                  SoeCard(
                      child: Text(tr.noSession,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2)))
                else
                  ...earnings.pupils.map((pupil) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PupilCard(pupil: pupil),
                      )),
                TutorSectionTitle(tr.history),
                if (earnings.history.isEmpty)
                  SoeCard(
                      child: Text(tr.noHistory,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2)))
                else
                  ...earnings.history.map((payout) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PayoutTile(payout: payout),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.earnings});

  final TutorEarnings earnings;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final hasWaiting =
        earnings.pendingAmount > 0 || earnings.disputedAmount > 0;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.current.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 4),
        Text(TutorFormat.amount(context, earnings.amount),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        Text(tr.estimated(count: earnings.approved),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        if (hasWaiting) ...[
          const SizedBox(height: 8),
          Text(
              tr.waitingNote(
                  pending: TutorFormat.amount(context, earnings.pendingAmount),
                  disputed:
                      TutorFormat.amount(context, earnings.disputedAmount)),
              style: AppTypography.bodySm),
        ],
        const Divider(height: 24),
        Row(children: [
          Expanded(child: Text(tr.payout, style: AppTypography.label)),
          Text(
              earnings.payoutOn == null
                  ? tr.payoutTbc
                  : TutorFormat.dayLong(context, earnings.payoutOn!),
              style: AppTypography.bodySm),
        ]),
        const SizedBox(height: 4),
        Text(
            earnings.defaultMethodLabel == null
                ? tr.noMethod
                : tr.onMethod(method: earnings.defaultMethodLabel!),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}

class _PupilCard extends StatelessWidget {
  const _PupilCard({required this.pupil});

  final TutorEarningsPupil pupil;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    final details = [
      if (pupil.rate != null)
        tr.approvedTimes(
            count: pupil.approved,
            rate: TutorFormat.amount(context, pupil.rate!))
      else
        tr.approvedCount(count: pupil.approved),
      if (pupil.pending > 0) tr.pending(count: pupil.pending),
      if (pupil.disputed > 0) tr.disputed(count: pupil.disputed),
    ];
    return SoeCard(
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pupil.name ?? tr.pupil, style: AppTypography.label),
            Text(details.join(' · '),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(TutorFormat.amount(context, pupil.amount),
            style: AppTypography.label.copyWith(color: AppPalette.teal800)),
      ]),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});

  final TutorPayout payout;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.earnings;
    return SoeCard(
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (payout.period != null)
              Text(TutorFormat.month(context, payout.period!),
                  style: AppTypography.label),
            Text(
                [
                  if (payout.paidAt != null)
                    tr.paidOn(date: TutorFormat.day(context, payout.paidAt!)),
                  tr.sessions(count: payout.sessions),
                ].join(' · '),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ]),
        ),
        Text(TutorFormat.amount(context, payout.amount),
            style: AppTypography.label),
      ]),
    );
  }
}
