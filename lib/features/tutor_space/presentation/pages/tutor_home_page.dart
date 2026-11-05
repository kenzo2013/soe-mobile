import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/widgets/notification_bell.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-01 — « what must I do now? »: actions by deadline (one gold button: the most urgent),
/// today's session (where, the parent, « J'arrive »), the month, offers for me. A candidate
/// sees the journey, what is missing and the next action. Without network, the last home
/// read stays on screen with « Hors connexion » and « Réessayer ».
class TutorHomePage extends ConsumerWidget {
  const TutorHomePage({super.key});

  static bool _offline(Object? error) =>
      error is NetworkFailure || error is TimeoutFailure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(tutorHomeProvider);
    final cache = ref.watch(tutorHomeCacheProvider);
    void retry() => ref.invalidate(tutorHomeProvider);
    Widget content(TutorHome home, {DateTime? offlineSince}) =>
        RefreshIndicator(
          onRefresh: () => ref.refresh(tutorHomeProvider.future),
          child: _HomeContent(
              home: home, offlineSince: offlineSince, onRetry: retry),
        );
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: value.hasError && _offline(value.error) && cache != null
            ? content(cache.home, offlineSince: cache.at)
            : TutorAsyncBody<TutorHome>(
                value: value, onRetry: retry, builder: content),
      ),
    );
  }
}

/// The screen an action of the home opens: the proposal, the report to write, the times to
/// propose, the letter to sign, the disputed report (its session's report).
String tutorActionTarget(TutorHomeAction action) => switch (action.kind) {
      'assignment' => TutorSpaceRoutes.proposal(action.targetId),
      'planning' => TutorSpaceRoutes.times(action.targetId),
      'contract' => TutorSpaceRoutes.contract(action.targetId),
      'disputed' => TutorSpaceRoutes.report(action.targetId),
      _ => TutorSpaceRoutes.report(action.targetId),
    };

class _HomeContent extends ConsumerWidget {
  const _HomeContent(
      {required this.home, required this.offlineSince, required this.onRetry});

  final TutorHome home;

  /// When the data shown was read (offline only).
  final DateTime? offlineSince;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home;
    final firstName =
        ref.watch(currentUserProvider).valueOrNull?.firstName ?? '';
    final now = DateTime.now();
    final sessions = home.mayTeach ? home.todaySessions : <TutorSession>[];
    final offline = offlineSince != null;
    final recruitment = home.active ? null : home.recruitment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(TutorFormat.dayLong(context, now),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
              Text(home.active ? tr.title : tr.fileTitle,
                  style: AppTypography.label),
            ]),
          ),
          const NotificationBell(),
        ]),
        const SizedBox(height: 16),
        Text(tr.hello(name: firstName),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        Text(
            recruitment == null
                ? '${TutorFormat.dayLong(context, now)} · ${tr.todayCount(n: sessions.length)}'
                : (recruitment.refused
                    ? tr.recruitment.refused
                    : tr.recruitment.subtitle),
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
        if (offline) ...[
          const SizedBox(height: 16),
          _OfflineBanner(since: offlineSince!, onRetry: onRetry),
        ],
        if (home.active && !home.mayTeach) ...[
          const SizedBox(height: 16),
          SoeAlert(
              tone: SoeAlertTone.warning,
              title: tr.onHold,
              body: tr.onHoldDetail),
        ],
        if (recruitment != null)
          ..._recruitment(context, recruitment)
        else if (home.active) ...[
          if (home.mayTeach) ...[
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
              for (var i = 0; i < home.actions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActionCard(
                      action: home.actions[i],
                      urgent: i == home.urgentIndex,
                      offline: offline),
                ),
            for (final session in sessions)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 10),
                child: _TodayCard(session: session),
              ),
          ],
          const SizedBox(height: 6),
          _MonthCard(month: home.month),
          const SizedBox(height: 16),
          const _OffersCard(),
        ],
      ],
    );
  }

  List<Widget> _recruitment(
      BuildContext context, TutorRecruitment recruitment) {
    if (recruitment.refused) {
      return [
        const SizedBox(height: 16),
        _JourneyCard(recruitment: recruitment),
      ];
    }
    return [
      const SizedBox(height: 16),
      _NextStepCard(recruitment: recruitment),
      const SizedBox(height: 16),
      _JourneyCard(recruitment: recruitment),
      const SizedBox(height: 16),
      const _OffersCard(recruiting: true),
    ];
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.since, required this.onRetry});

  final DateTime since;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.offline;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppPalette.warningBg, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.wifi_off, size: 18, color: AppPalette.warningText),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.title(time: TutorFormat.time(since)),
                style: AppTypography.label
                    .copyWith(color: AppPalette.warningText)),
            const SizedBox(height: 2),
            Text(tr.body, style: AppTypography.bodySm),
          ]),
        ),
        TextButton(onPressed: onRetry, child: Text(tr.retry)),
      ]),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  const _ActionCard(
      {required this.action, required this.urgent, required this.offline});

  final TutorHomeAction action;
  final bool urgent;
  final bool offline;

  static IconData _icon(String kind) => switch (kind) {
        'assignment' => Icons.people_outline,
        'planning' => Icons.calendar_today_outlined,
        'contract' => Icons.draw_outlined,
        _ => Icons.description_outlined,
      };

  /// « Samuel, 1re C · Mathématiques », « Léa M., CM2 · séance du dim. 1 nov. »: read in the
  /// proposal, the session or the contract; else the title the home gives.
  static String? _title(
      BuildContext context, TutorHomeAction action, TutorActionSubject? about) {
    final tr = Translations.of(context).tutorSpace.home.action;
    String who(String pupil, String? schoolClass) => [pupil, schoolClass]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(', ');
    final proposal = about?.proposal;
    final session = about?.session;
    final contract = about?.contract;
    if (proposal != null) {
      return [who(proposal.pupil, proposal.schoolClass), proposal.subject]
          .whereType<String>()
          .where((part) => part.isNotEmpty)
          .join(' · ');
    }
    if (session != null) {
      return '${who(session.pupil, session.schoolClass)} · ${tr.sessionOf(date: TutorFormat.day(context, session.date))}';
    }
    if (contract != null) {
      return [contract.pupil, contract.subject]
          .whereType<String>()
          .where((part) => part.isNotEmpty)
          .join(' · ');
    }
    return action.title;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home;
    final about = ref
        .watch(tutorActionSubjectProvider(
            (kind: action.kind, targetId: action.targetId)))
        .valueOrNull;
    final title = _title(context, action, about);
    final proposal = about?.proposal;
    final deadline = action.deadline;
    final disputed = action.kind == 'disputed';
    final labelColor =
        disputed || action.overdue ? AppPalette.dangerText : AppPalette.gold700;
    final hours = deadline == null
        ? null
        : deadline.difference(DateTime.now()).inHours.clamp(0, 9999);
    final proposalLine = proposal == null
        ? null
        : [
            if (proposal.neighborhood != null) proposal.neighborhood!,
            if (proposal.sessionsPerWeek != null)
              Translations.of(context)
                  .tutorSpace
                  .proposal
                  .perWeek(n: proposal.sessionsPerWeek!),
            if (proposal.sessionRate > 0)
              tr.action.perSession(
                  amount: TutorFormat.amount(context, proposal.sessionRate)),
          ].join(' · ');
    final detail = switch (action.kind) {
      'assignment' => [
          if (proposalLine != null && proposalLine.isNotEmpty) proposalLine,
          tr.action.assignmentDetail,
        ].join('. '),
      'planning' => tr.action.planningDetail,
      'contract' => tr.action.contractDetail,
      'disputed' => tr.action.disputedDetail,
      _ => action.overdue
          ? tr.action.late
          : (deadline == null
              ? null
              : tr.action.due(date: TutorFormat.dateTime(context, deadline))),
    };
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(_icon(action.kind), size: 16, color: labelColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(action.label,
                style: AppTypography.labelSm.copyWith(color: labelColor)),
          ),
          if (disputed)
            SoeBadge(label: tr.soeReviews, tone: SoeBadgeTone.danger),
        ]),
        const SizedBox(height: 8),
        if (title != null && title.isNotEmpty)
          Text(title, style: AppTypography.label),
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(detail,
              style: AppTypography.bodySm.copyWith(
                  color: action.overdue && action.kind == 'report'
                      ? AppPalette.dangerText
                      : AppPalette.text2)),
        ],
        if (action.kind == 'assignment' && hours != null) ...[
          const SizedBox(height: 10),
          Text(tr.action.hours(hours: hours),
              style: AppTypography.h2.copyWith(color: AppPalette.gold700)),
          Text(
              tr.action
                  .toAnswer(date: TutorFormat.dateTime(context, deadline!)),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
        const SizedBox(height: 12),
        SoeButton(
          label: offline ? tr.action.offline : _label(tr),
          size: SoeButtonSize.md,
          variant: urgent
              ? SoeButtonVariant.primary
              : (disputed
                  ? SoeButtonVariant.tertiary
                  : SoeButtonVariant.outline),
          fullWidth: true,
          onPressed:
              offline ? null : () => context.push(tutorActionTarget(action)),
        ),
      ]),
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

/// Today's session: when, what, where (neighbourhood, landmark), the parent once the contract is
/// signed, « J'arrive », the directions and the call.
class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.session});

  final TutorSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home.today;
    final detail = ref.watch(tutorSessionProvider(session.id)).valueOrNull;
    final now = DateTime.now();
    final startsIn = session.startsAt.difference(now);
    final when = [
      tr.overline,
      TutorFormat.hours(session),
      if (startsIn.inMinutes > 0)
        tr.startsIn(time: TutorFormat.duration(context, startsIn.inMinutes))
      else if (session.endsAt != null && now.isBefore(session.endsAt!))
        tr.now,
    ].join(' · ');
    final title = [
      session.subject,
      [session.pupil, session.schoolClass]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(', '),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final parent = [detail?.parentName, detail?.parentPhone]
        .whereType<String>()
        .join(' · ');
    final place =
        [detail?.address, detail?.neighborhood].whereType<String>().join(', ');
    final rows = <(String, String)>[
      if (detail?.neighborhood != null)
        (tr.neighborhood, detail!.neighborhood!),
      if (detail?.landmark != null) (tr.landmark, detail!.landmark!),
      if (parent.isNotEmpty) (tr.parent, parent),
    ];
    return SoeCard(
      onTap: () => context.push(TutorSpaceRoutes.session(session.id)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(when.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        Text(title,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(tr.hint,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 6),
        for (var i = 0; i < rows.length; i++)
          TutorInfoRow(
              label: rows[i].$1, value: rows[i].$2, last: i == rows.length - 1),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (session.state == 'planned')
            SoeButton(
              label: tr.arrive,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.secondary,
              onPressed: () =>
                  context.push(TutorSpaceRoutes.session(session.id)),
            ),
          if (detail?.address != null)
            SoeButton(
              label: tr.directions,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.outline,
              onPressed: () => unawaited(tutorDirections(place)),
            ),
          if (detail?.parentPhone != null)
            SoeButton(
              label: tr.call,
              size: SoeButtonSize.md,
              variant: SoeButtonVariant.tertiary,
              onPressed: () => unawaited(tutorCall(detail!.parentPhone!)),
            ),
        ]),
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
    final now = DateTime.now();
    final monthName = TutorFormat.month(context, now).split(' ').first;
    final nextMonth =
        TutorFormat.month(context, DateTime(now.year, now.month + 1))
            .split(' ')
            .first
            .toLowerCase();
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(monthName.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal800)),
        Text(tr.title,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        Text(TutorFormat.amount(context, month.amount),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        Text(tr.caption,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        TutorInfoRow(label: tr.approved, value: '${month.approved}'),
        TutorInfoRow(
            label: tr.pending,
            value: tr.line(
                count: month.pendingCount,
                amount: TutorFormat.amount(context, month.pendingAmount))),
        TutorInfoRow(
            label: tr.disputed,
            value: tr.line(
                count: month.disputedCount,
                amount: TutorFormat.amount(context, month.disputedAmount)),
            valueColor: month.disputedCount > 0 ? AppPalette.dangerText : null),
        TutorInfoRow(
            label: tr.payout,
            last: true,
            value: month.payoutOn == null
                ? tr.payoutTbc(month: nextMonth)
                : TutorFormat.dayLong(context, month.payoutOn!)),
      ]),
    );
  }
}

/// « Offres pour moi » (« Offres près de chez vous » for a candidate, who may already apply).
class _OffersCard extends ConsumerWidget {
  const _OffersCard({this.recruiting = false});

  final bool recruiting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home.offers;
    final offers = ref.watch(tutorHomeOffersProvider).valueOrNull ?? const [];
    return SoeCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(recruiting ? tr.nearTitle : tr.title,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        ),
        if (offers.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(tr.empty,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ),
        for (final offer in offers)
          InkWell(
            onTap: () => context.push(TutorSpaceRoutes.offer(offer.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: AppPalette.teal50, shape: BoxShape.circle),
                  child: const Icon(Icons.work_outline,
                      size: 18, color: AppPalette.teal800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.title, style: AppTypography.label),
                        if (offer.neighborhood != null)
                          Text(offer.neighborhood!,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
                      ]),
                ),
                if (offer.sessionRate != null)
                  Text(TutorFormat.amount(context, offer.sessionRate!),
                      style: AppTypography.labelSm),
                const Icon(Icons.chevron_right, color: AppPalette.text2),
              ]),
            ),
          ),
        TextButton(
          onPressed: () => context.push(TutorSpaceRoutes.offers),
          child: Text(tr.seeAll),
        ),
        if (recruiting)
          Container(
            color: AppPalette.surfaceSoft,
            padding: const EdgeInsets.all(16),
            child: Text(tr.note,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ),
      ]),
    );
  }
}

/// The journey of a candidate, in the order of the API (`stage`).
const tutorJourney = [
  'file',
  'documents_check',
  'interview',
  'test',
  'charter',
  'active'
];

String _stepLabel(TranslationsTutorSpaceHomeRecruitmentFr tr, String stage) =>
    switch (stage) {
      'file' => tr.steps.file,
      'documents_check' => tr.steps.documentsCheck,
      'interview' => tr.steps.interview,
      'test' => tr.steps.test,
      'charter' => tr.steps.charter,
      _ => tr.steps.active,
    };

/// The screen that moves the candidate's current stage on (null: nothing to do, SOE acts).
String? tutorRecruitmentTarget(String stage) => switch (stage) {
      'file' || 'documents_check' => TutorSpaceRoutes.file,
      'interview' || 'test' => TutorSpaceRoutes.interview,
      'charter' => TutorSpaceRoutes.charter,
      _ => null,
    };

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.recruitment});

  final TutorRecruitment recruitment;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.recruitment;
    final stage = recruitment.stage;
    final target = tutorRecruitmentTarget(stage);
    final action = switch (stage) {
      'file' => tr.actions.file,
      'documents_check' => tr.actions.documentsCheck,
      'interview' => tr.actions.interview,
      'test' => tr.actions.test,
      _ => tr.actions.charter,
    };
    final waiting = switch (stage) {
      'file' => tr.waiting.file,
      'documents_check' => tr.waiting.documentsCheck,
      'interview' => tr.waiting.interview,
      'test' => tr.waiting.test,
      'charter' => tr.waiting.charter,
      _ => tr.waiting.active,
    };
    final label = recruitment.stageLabel.isNotEmpty
        ? recruitment.stageLabel
        : _stepLabel(tr, stage);
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.next(step: label).toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        Text(tr.missingTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        if (recruitment.missingDocuments.isEmpty)
          Text(waiting,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2))
        else
          for (final document in recruitment.missingDocuments)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(
                    switch (document.state) {
                      'in_review' => Icons.schedule,
                      'redo' => Icons.warning_amber_rounded,
                      _ => Icons.error_outline,
                    },
                    size: 18,
                    color: switch (document.state) {
                      'in_review' => AppPalette.teal500,
                      'redo' => AppPalette.dangerText,
                      _ => AppPalette.warningText,
                    }),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('${document.label} · ${document.stateLabel}',
                        style: AppTypography.bodySm)),
              ]),
            ),
        if (target != null) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: action,
            size: SoeButtonSize.md,
            onPressed: () => context.push(target),
          ),
        ],
      ]),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.recruitment});

  final TutorRecruitment recruitment;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.recruitment;
    final total = recruitment.totalSteps > 0
        ? recruitment.totalSteps
        : tutorJourney.length;
    final step = recruitment.step;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppPalette.surfaceSoft,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(tr.journey,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
          Text(tr.stepOf(step: step, total: total),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < tutorJourney.length; i++)
          _JourneyStep(
            label: _stepLabel(tr, tutorJourney[i]),
            done: i + 1 < step,
            current: i + 1 == step,
          ),
        const SizedBox(height: 12),
        Text(tr.delayTitle, style: AppTypography.label),
        const SizedBox(height: 2),
        Text(tr.delayTbc,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep(
      {required this.label, required this.done, required this.current});

  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: current,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppPalette.teal500
                    : (current ? AppPalette.gold400 : AppPalette.white),
                border: done || current
                    ? null
                    : Border.all(color: AppPalette.n300, width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: AppPalette.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: current
                      ? AppTypography.label
                      : AppTypography.bodySm.copyWith(
                          color: done ? AppPalette.text : AppPalette.text2)),
            ),
          ]),
        ),
      );
}
