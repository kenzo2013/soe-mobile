import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_navigation.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/pages/account_hub_page.dart'
    show formatCameroonPhone;

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
    final tr = Translations.of(context).tutorSpace.home;
    final value = ref.watch(tutorHomeProvider);
    final cache = ref.watch(tutorHomeCacheProvider);
    final firstName =
        ref.watch(currentUserProvider).valueOrNull?.firstName ?? '';
    void retry() => ref.invalidate(tutorHomeProvider);
    Future<void> refresh() => ref.refresh(tutorHomeProvider.future);

    if (value.hasError && _offline(value.error) && cache != null) {
      return _HomeView(
          home: cache.home,
          offlineSince: cache.at,
          onRetry: retry,
          onRefresh: refresh);
    }
    return value.when(
      data: (home) => _HomeView(home: home, onRetry: retry, onRefresh: refresh),
      loading: () => SpaceTabView(
        band: SpaceBand(title: tr.hello(name: firstName)),
        children: const [
          SoeSkeleton(height: 180, borderRadius: AppRadius.rCardLg),
          SizedBox(height: 14),
          SoeSkeleton(height: 120, borderRadius: AppRadius.rCard),
        ],
      ),
      error: (error, _) => SpaceTabView(
        band: SpaceBand(title: tr.hello(name: firstName)),
        children: [
          SoeCard(
            raised: true,
            child: ErrorView(failure: asFailure(error), onRetry: retry),
          ),
        ],
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
      'disputed' => TutorSpaceRoutes.report(action.targetId, fromToday: true),
      _ => TutorSpaceRoutes.report(action.targetId, fromToday: true),
    };

/// « 4 500 » (the amount without its currency, for the band's figure).
String _figure(int value) =>
    NumberFormat.decimalPattern('fr').format(value).replaceAll(',', ' ');

class _HomeView extends ConsumerWidget {
  const _HomeView(
      {required this.home,
      this.offlineSince,
      required this.onRetry,
      required this.onRefresh});

  final TutorHome home;

  /// When the data shown was read (offline only).
  final DateTime? offlineSince;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.home;
    final firstName =
        ref.watch(currentUserProvider).valueOrNull?.firstName ?? '';
    final sessions = home.mayTeach ? home.todaySessions : <TutorSession>[];
    final offline = offlineSince != null;
    final recruitment = home.active ? null : home.recruitment;
    final wide = spaceIsWide(context);

    final Widget chips;
    if (recruitment != null) {
      final total = recruitment.totalSteps > 0
          ? recruitment.totalSteps
          : tutorJourney.length;
      final complete = recruitment.sectionsComplete;
      final sections = recruitment.sectionsTotal;
      final offers = home.offers?.length ?? 0;
      chips = Row(children: [
        Expanded(
            child: BandStat.gold(
                value: '${recruitment.step}/$total', label: tr.chips.step)),
        const SizedBox(width: 8),
        Expanded(
          child: complete != null && sections != null
              ? BandStat(value: '$complete/$sections', label: tr.chips.sections)
              : BandStat(
                  value: '${recruitment.missingDocuments.length}',
                  label: tr.chips.todo),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: BandStat.green(
                value: '$offers',
                label: tr.chips.offers(n: offers),
                onTap: () =>
                    openTutorScreen(context, TutorSpaceRoutes.offers))),
      ]);
    } else {
      chips = Row(children: [
        Expanded(
            child: BandStat.gold(
                value: '${home.mayTeach ? home.actions.length : 0}',
                label: tr.chips.todo)),
        const SizedBox(width: 8),
        Expanded(
            child: BandStat(
                value: '${sessions.length}',
                label: tr.chips.today(n: sessions.length),
                onTap: () => context.go(RouteNames.tutorPlanning))),
        const SizedBox(width: 8),
        Expanded(
            child: BandStat.green(
                value: _figure(home.month.amount),
                label: tr.chips.month,
                onTap: () => context.go(RouteNames.tutorEarnings))),
      ]);
    }

    final band = SpaceBand(
      title: tr.hello(name: firstName),
      subtitle: recruitment == null
          ? null
          : (recruitment.subtitle ??
              (recruitment.refused
                  ? tr.recruitment.refused
                  : tr.recruitment.subtitle)),
      chips: chips,
    );

    final notices = <Widget>[
      if (offline) ...[
        _OfflineBanner(since: offlineSince!, onRetry: onRetry),
        const SizedBox(height: 14),
      ],
      if (home.active && !home.mayTeach) ...[
        SoeAlert(
            tone: SoeAlertTone.warning,
            title: tr.onHold,
            body: tr.onHoldDetail),
        const SizedBox(height: 14),
      ],
    ];

    // Phone: one column. Tablet: what to do then the offers on the left, the month (or the
    // delay) on the right, both overlapping the band.
    var left = <Widget>[];
    var right = <Widget>[];
    var below = <Widget>[];
    if (recruitment != null) {
      left = [
        if (!recruitment.refused) ...[
          _NextStepCard(recruitment: recruitment),
          const SizedBox(height: 14),
        ],
        _JourneyCard(recruitment: recruitment, raised: recruitment.refused),
      ];
      if (!recruitment.refused) {
        right = [_DelayCard(recruitment: recruitment)];
        below = [_OffersCard(home: home, recruiting: true)];
      }
    } else if (home.active) {
      left = [
        if (home.mayTeach) ...[
          if (home.actions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SoeCard(
                raised: true,
                child: Row(children: [
                  const _IconTile(
                      icon: Icons.check_rounded,
                      background: AppPalette.successBg,
                      color: AppPalette.successText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tr.nothingToDo,
                        style: AppTypography.label
                            .copyWith(color: AppPalette.text)),
                  ),
                ]),
              ),
            )
          else
            for (var i = 0; i < home.actions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ActionCard(
                    action: home.actions[i],
                    urgent: i == home.urgentIndex,
                    raised: i == 0,
                    offline: offline),
              ),
          for (final session in sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TodayCard(session: session),
            ),
        ],
      ];
      right = [_MonthCard(month: home.month)];
      below = [_OffersCard(home: home)];
      if (left.isEmpty) {
        left = right;
        right = [];
      }
    }

    final List<Widget> children;
    if (wide && left.isNotEmpty && right.isNotEmpty) {
      children = [
        ...notices,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: spaceColumnFlex(context).$1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [...left, ...below])),
          const SizedBox(width: 16),
          Expanded(
              flex: spaceColumnFlex(context).$2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: right)),
        ]),
      ];
    } else {
      children = [
        ...notices,
        ...left,
        if (left.isNotEmpty && right.isNotEmpty) const SizedBox(height: 14),
        ...right,
        if (below.isNotEmpty) ...[const SizedBox(height: 14), ...below],
      ];
    }
    return SpaceTabView(band: band, onRefresh: onRefresh, children: children);
  }
}

/// A rounded square tile holding an icon (tinted ground, coloured icon).
class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.icon, required this.background, required this.color});

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 18, color: color),
      );
}

/// A small pill (countdown, « SOE examine »).
class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.background, required this.color});

  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: AppTypography.labelSm.copyWith(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );
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
      {required this.action,
      required this.urgent,
      required this.offline,
      this.raised = false});

  final TutorHomeAction action;
  final bool urgent;
  final bool offline;

  /// The first card, overlapping the band.
  final bool raised;

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
      final day =
          DateFormat('EEE d MMM', Localizations.localeOf(context).languageCode)
              .format(session.date);
      return '${who(session.pupil, session.schoolClass)} · ${tr.sessionOf(date: day)}';
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
    final tone = disputed || action.overdue
        ? (background: AppPalette.warningBg, color: AppPalette.warningText)
        : (background: AppPalette.gold50, color: AppPalette.gold700);
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
    final minutesLeft = deadline?.difference(DateTime.now()).inMinutes;
    final Widget? pill = disputed
        ? _Pill(
            label: tr.soeReviews,
            background: AppPalette.infoBg,
            color: AppPalette.infoText)
        : action.overdue
            ? _Pill(
                label: tr.action.overdue,
                background: AppPalette.dangerBg,
                color: AppPalette.dangerText)
            : (minutesLeft != null && minutesLeft > 0 && minutesLeft < 72 * 60
                ? _Pill(
                    label: tr.action.left(
                        time: TutorFormat.duration(
                            context,
                            minutesLeft < 60
                                ? minutesLeft
                                : minutesLeft ~/ 60 * 60)),
                    background: AppPalette.warningBg,
                    color: AppPalette.warningText)
                : null);
    return SoeCard(
      raised: raised,
      borderRadius: AppRadius.rCardLg,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _IconTile(
              icon: _icon(action.kind),
              background: tone.background,
              color: tone.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(action.label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.78,
                    color: tone.color)),
          ),
          if (pill != null) ...[const SizedBox(width: 8), pill],
        ]),
        const SizedBox(height: 12),
        if (title != null && title.isNotEmpty)
          Text(title,
              style: AppTypography.subtitle.copyWith(color: AppPalette.text)),
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
              style: AppTypography.h2.copyWith(color: AppPalette.warningText)),
          Text(
              tr.action
                  .toAnswer(date: TutorFormat.dateTime(context, deadline!)),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
        const SizedBox(height: 14),
        SoeButton(
          label: offline ? tr.action.offline : _label(tr),
          size: urgent ? SoeButtonSize.lg : SoeButtonSize.md,
          variant:
              urgent ? SoeButtonVariant.primary : SoeButtonVariant.secondary,
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
    final parent = [
      detail?.parentName,
      if (detail?.parentPhone != null) formatCameroonPhone(detail?.parentPhone)
    ].whereType<String>().join(' · ');
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
            style:
                AppTypography.overline.copyWith(color: AppPalette.successText)),
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
    Widget row(String label, String value, {Color? valueColor}) =>
        LayoutBuilder(builder: (context, constraints) {
          final labelText = Text(label,
              style:
                  AppTypography.bodySm.copyWith(color: AppPalette.successBg));
          final valueText = Text(value,
              style: AppTypography.label
                  .copyWith(color: valueColor ?? AppPalette.white));
          // In a narrow card the label sits above its value.
          if (constraints.maxWidth < 360) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [labelText, valueText]),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: labelText),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: AppTypography.label
                        .copyWith(color: valueColor ?? AppPalette.white)),
              ),
            ]),
          );
        });
    return SoeCard(
      color: AppPalette.success,
      padding: const EdgeInsets.all(18),
      onTap: () => context.go(RouteNames.tutorEarnings),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${monthName.toUpperCase()} · ${tr.title.toUpperCase()}',
            style:
                AppTypography.overline.copyWith(color: AppPalette.successBg)),
        const SizedBox(height: 4),
        Text(TutorFormat.amount(context, month.amount),
            style: AppTypography.numberL.copyWith(color: AppPalette.white)),
        Text(tr.caption,
            style: AppTypography.caption.copyWith(color: AppPalette.successBg)),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
          decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                valueColor:
                    month.disputedCount > 0 ? AppPalette.gold100 : null),
            row(
                tr.payout,
                month.payoutOn == null
                    ? tr.payoutTbc(month: nextMonth)
                    : TutorFormat.dayLong(context, month.payoutOn!)),
          ]),
        ),
      ]),
    );
  }
}

/// « Offres pour moi » (« Offres près de chez vous » for a candidate, who may already apply):
/// the two offers the home sends, with the tutor's pay per session.
class _OffersCard extends StatelessWidget {
  const _OffersCard({required this.home, this.recruiting = false});

  final TutorHome home;
  final bool recruiting;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.offers;
    final offers = home.offers ?? const <TutorOfferPreview>[];
    final title = home.offersTitle ?? (recruiting ? tr.nearTitle : tr.title);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 0, 10),
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: AppTypography.h3
                    .copyWith(fontSize: 22, color: AppPalette.teal800)),
          ),
          TextButton(
            onPressed: () => openTutorScreen(context, TutorSpaceRoutes.offers),
            child: Text(tr.seeAllShort,
                semanticsLabel: tr.seeAll,
                style: AppTypography.label.copyWith(color: AppPalette.teal500)),
          ),
        ]),
      ),
      if (offers.isEmpty)
        SoeCard(
          child: Text(tr.empty,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        )
      else
        LayoutBuilder(builder: (context, constraints) {
          // A tablet column about a phone wide: one offer per row, so nothing is cut.
          final columns = constraints.maxWidth >= 900
              ? 4
              : (constraints.maxWidth >= 600
                  ? 3
                  : (spaceIsWide(context) && constraints.maxWidth < 420
                      ? 1
                      : 2));
          final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            for (final offer in offers)
              SizedBox(width: width, child: _OfferTile(offer: offer)),
          ]);
        }),
      // The server's note, else ours for a file not validated yet; none for an active tutor.
      if (home.offersNote != null || !home.active) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppPalette.gold50,
              borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 18, color: AppPalette.gold700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(home.offersNote ?? tr.note,
                  style: AppTypography.bodySm.copyWith(color: AppPalette.text)),
            ),
          ]),
        ),
      ],
    ]);
  }
}

/// An offer on the colour of its first subject: the subject, the class, the neighbourhood,
/// the pay per session in gold.
class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer});

  final TutorOfferPreview offer;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.offers;
    final start = TutorFormat.offerStart(context,
        label: offer.startLabel,
        date: offer.startDate,
        passed: offer.startPassed);
    final subject = offer.subjects.isEmpty ? null : offer.subjects.first;
    final color = SubjectColors.of(subject);
    final ink = SubjectColors.onColor(color);
    final soft = ink == AppPalette.white
        ? const Color(0xD9FFFFFF)
        : AppPalette.ink900.withValues(alpha: 0.75);
    final rateColor =
        color == AppPalette.subjectEnglish || ink != AppPalette.white
            ? (ink == AppPalette.white ? AppPalette.gold100 : AppPalette.ink900)
            : AppPalette.gold400;
    return Semantics(
      button: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () =>
              openTutorScreen(context, TutorSpaceRoutes.offer(offer.id)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (subject != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999)),
                  // The whole list of subjects, on two lines if needed.
                  child: Text(offer.subjects.join(', '),
                      style: AppTypography.labelSm.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ink)),
                ),
              const SizedBox(height: 6),
              if (offer.schoolClasses.isNotEmpty)
                Text(offer.schoolClasses.first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.label.copyWith(fontSize: 15, color: ink)),
              if (offer.neighborhood != null)
                Text(offer.neighborhood!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: soft)),
              if (start != null)
                Text(start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: soft)),
              if (offer.sessionRate != null) ...[
                const SizedBox(height: 6),
                Text(
                    tr.rate(
                        amount:
                            TutorFormat.amount(context, offer.sessionRate!)),
                    style: AppTypography.label.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: rateColor)),
              ],
            ]),
          ),
        ),
      ),
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
    final complete = recruitment.sectionsComplete;
    final total = recruitment.sectionsTotal;
    final fileStage = stage == 'file' && complete != null && total != null;
    return SoeCard(
      raised: true,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _IconTile(
              icon: Icons.assignment_outlined,
              background: AppPalette.gold50,
              color: AppPalette.gold700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                (recruitment.nextLabel ?? tr.next(step: label)).toUpperCase(),
                style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.78,
                    color: AppPalette.gold700)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(tr.missingTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        if (fileStage) ...[
          // « 5 / 7 sections complètes », then each section to complete or redo.
          Text('$complete / $total',
              style: AppTypography.h1.copyWith(color: AppPalette.successText)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : complete / total,
              minHeight: 6,
              color: AppPalette.success,
              backgroundColor: AppPalette.teal100,
            ),
          ),
          const SizedBox(height: 6),
          Text(tr.sectionsComplete,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 8),
          for (final section in recruitment.missingSections)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppPalette.warningText),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('${section.label} : ${section.reason}',
                        style: AppTypography.bodySm)),
              ]),
            ),
        ] else if (recruitment.missingDocuments.isEmpty)
          Text(recruitment.waitingText ?? waiting,
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
            fullWidth: true,
            onPressed: () => openTutorScreen(context, target),
          ),
        ],
      ]),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.recruitment, this.raised = false});

  final TutorRecruitment recruitment;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.recruitment;
    final total = recruitment.totalSteps > 0
        ? recruitment.totalSteps
        : tutorJourney.length;
    final step = recruitment.step;
    return SoeCard(
      raised: raised,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(tr.journey,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
          Text(recruitment.stepOfLabel ?? tr.stepOf(step: step, total: total),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
        const SizedBox(height: 8),
        if (recruitment.journey.isNotEmpty)
          for (final item in recruitment.journey)
            _JourneyStep(
              label: item.label,
              done: item.state == 'done',
              current: item.state == 'current',
            )
        else
          for (var i = 0; i < tutorJourney.length; i++)
            _JourneyStep(
              label: _stepLabel(tr, tutorJourney[i]),
              done: i + 1 < step,
              current: i + 1 == step,
            ),
      ]),
    );
  }
}

/// « Délai de validation »: the review delay SOE sets, « à confirmer » until then.
class _DelayCard extends StatelessWidget {
  const _DelayCard({required this.recruitment});

  final TutorRecruitment recruitment;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.home.recruitment;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppPalette.gold50, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.delayTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(recruitment.delayLabel ?? tr.delayTbc,
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
                    ? AppPalette.success
                    : (current ? AppPalette.gold400 : AppPalette.white),
                border: done || current
                    ? null
                    : Border.all(color: AppPalette.teal100, width: 2),
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
