import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-01 — « what must I do now? »: actions by deadline (one gold button: the most urgent),
/// today's sessions, the month; a candidate sees where the recruitment stands.
class TutorHomePage extends ConsumerWidget {
  const TutorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home;
    final firstName =
        ref.watch(currentUserProvider).valueOrNull?.firstName ?? '';
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(tutorHomeProvider.future),
          child: TutorAsyncBody<TutorHome>(
            value: ref.watch(tutorHomeProvider),
            onRetry: () => ref.invalidate(tutorHomeProvider),
            builder: (home) {
              final urgent = home.urgentIndex;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(tr.hello(name: firstName),
                      style:
                          AppTypography.h1.copyWith(color: AppPalette.teal800)),
                  Text(tr.subtitle,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2)),
                  if (home.active && !home.mayTeach) ...[
                    const SizedBox(height: 16),
                    SoeAlert(
                        tone: SoeAlertTone.warning,
                        title: tr.onHold,
                        body: tr.onHoldDetail),
                  ],
                  if (!home.active && home.recruitment != null) ...[
                    const SizedBox(height: 16),
                    _RecruitmentCard(recruitment: home.recruitment!),
                  ],
                  if (home.active) ...[
                    TutorSectionTitle(tr.todo,
                        trailing: home.actions.isEmpty
                            ? null
                            : Text(tr.sorted,
                                style: AppTypography.caption
                                    .copyWith(color: AppPalette.text2))),
                    if (home.actions.isEmpty)
                      SoeCard(
                          child: Text(tr.nothingToDo,
                              style: AppTypography.bodySm
                                  .copyWith(color: AppPalette.text2)))
                    else
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: home.actions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) => _ActionCard(
                              action: home.actions[i], urgent: i == urgent),
                        ),
                      ),
                    TutorSectionTitle(tr.today),
                    if (home.todaySessions.isEmpty)
                      SoeCard(
                          child: Text(tr.noSession,
                              style: AppTypography.bodySm
                                  .copyWith(color: AppPalette.text2)))
                    else
                      ...home.todaySessions.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TodayCard(
                                session: session, mayTeach: home.mayTeach),
                          )),
                    TutorSectionTitle(tr.month.title),
                    _MonthCard(month: home.month),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The screen an action of the home opens.
String tutorActionTarget(TutorHomeAction action) => switch (action.kind) {
      'assignment' => TutorSpaceRoutes.proposal(action.targetId),
      'planning' => TutorSpaceRoutes.times(action.targetId),
      'contract' => TutorSpaceRoutes.contract(action.targetId),
      _ => TutorSpaceRoutes.report(action.targetId),
    };

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.urgent});

  final TutorHomeAction action;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home;
    final deadline = action.deadline;
    final disputed = action.kind == 'disputed';
    final hours =
        deadline == null ? null : deadline.difference(DateTime.now()).inHours;
    return SizedBox(
      width: 260,
      child: SoeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(action.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.overline.copyWith(
                  color: action.overdue
                      ? AppPalette.dangerText
                      : (disputed ? AppPalette.infoText : AppPalette.teal800))),
          const SizedBox(height: 6),
          if (action.title != null)
            Text(action.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h3),
          const SizedBox(height: 4),
          if (disputed)
            SoeBadge(label: tr.soeReviews, tone: SoeBadgeTone.info)
          else if (action.overdue)
            Text(tr.overdue,
                style:
                    AppTypography.label.copyWith(color: AppPalette.dangerText))
          else if (action.kind == 'report' && hours != null)
            Text(tr.hoursLeft(hours: hours < 0 ? 0 : hours),
                style: AppTypography.label)
          else if (deadline != null)
            Text(tr.dueOn(date: TutorFormat.dateTime(context, deadline)),
                style: AppTypography.label),
          const Spacer(),
          SoeButton(
            label: _label(tr),
            size: SoeButtonSize.sm,
            variant: urgent && !disputed
                ? SoeButtonVariant.primary
                : SoeButtonVariant.outline,
            fullWidth: true,
            onPressed: () => context.push(tutorActionTarget(action)),
          ),
        ]),
      ),
    );
  }

  String _label(TranslationsTutorSpaceHomeFr tr) => switch (action.kind) {
        'assignment' => tr.buttons.assignment,
        'planning' => tr.buttons.planning,
        'contract' => tr.buttons.contract,
        'disputed' => tr.buttons.disputed,
        _ => tr.buttons.report,
      };
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.session, required this.mayTeach});

  final TutorSession session;
  final bool mayTeach;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home;
    final canArrive = mayTeach && session.state == 'planned';
    return SoeCard(
      onTap: () => context.push(TutorSpaceRoutes.session(session.id)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(TutorFormat.hours(session),
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
          TutorStateBadge(state: session.state, label: session.stateLabel),
        ]),
        const SizedBox(height: 4),
        Text(session.title, style: AppTypography.label),
        if (session.schoolClass != null)
          Text(session.schoolClass!,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        if (canArrive) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: tr.arrive,
            size: SoeButtonSize.md,
            variant: SoeButtonVariant.secondary,
            icon: Icons.location_on_outlined,
            fullWidth: true,
            onPressed: () => context.push(TutorSpaceRoutes.session(session.id)),
          ),
        ],
      ]),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month});

  final TutorMonth month;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.month;
    Widget row(String label, String value, {Color? color}) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: AppTypography.bodySm
                        .copyWith(color: AppPalette.text2))),
            Text(value,
                style: AppTypography.label
                    .copyWith(color: color ?? AppPalette.text)),
          ]),
        );
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(TutorFormat.amount(context, month.amount),
            style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
        Text(tr.caption,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 4),
        row(tr.approved, '${month.approved}'),
        row(
            tr.pending,
            tr.line(
                count: month.pendingCount,
                amount: TutorFormat.amount(context, month.pendingAmount))),
        row(
            tr.disputed,
            tr.line(
                count: month.disputedCount,
                amount: TutorFormat.amount(context, month.disputedAmount)),
            color: month.disputedCount > 0 ? AppPalette.dangerText : null),
        row(
            tr.payout,
            month.payoutOn == null
                ? tr.payoutTbc
                : TutorFormat.dayLong(context, month.payoutOn!)),
      ]),
    );
  }
}

class _RecruitmentCard extends StatelessWidget {
  const _RecruitmentCard({required this.recruitment});

  final TutorRecruitment recruitment;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.recruitment;
    if (recruitment.refused) {
      return SoeAlert(
          tone: SoeAlertTone.danger,
          title: recruitment.stageLabel,
          body: tr.refused);
    }
    final total = recruitment.totalSteps < 1 ? 1 : recruitment.totalSteps;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.subtitle,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 10),
        Text(
            tr
                .stepOf(step: recruitment.step, total: recruitment.totalSteps)
                .toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        Text(tr.next(step: recruitment.stageLabel), style: AppTypography.h3),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (recruitment.step / total).clamp(0, 1).toDouble(),
            minHeight: 6,
            color: AppPalette.teal500,
            backgroundColor: AppPalette.n300,
          ),
        ),
        if (recruitment.missingDocuments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(tr.missingTitle, style: AppTypography.title),
          ...recruitment.missingDocuments.map((document) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  Expanded(
                      child: Text(document.label, style: AppTypography.bodySm)),
                  SoeBadge(
                    label: document.stateLabel,
                    tone: switch (document.state) {
                      'in_review' => SoeBadgeTone.info,
                      'redo' => SoeBadgeTone.danger,
                      _ => SoeBadgeTone.warning,
                    },
                  ),
                ]),
              )),
        ],
        const SizedBox(height: 16),
        Text(tr.webNote,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}
