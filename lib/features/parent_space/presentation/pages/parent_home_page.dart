import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_advisor_card.dart';
import '../widgets/parent_child_avatar.dart';
import '../widgets/parent_ui.dart';
import 'parent_children_page.dart';

/// PAR-01 — « what must I do now? »: actions by deadline (one gold button: the most urgent),
/// this week's sessions, where the requests stand, children, payment of the month, advisor.
class ParentHomePage extends ConsumerWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final firstName =
        ref.watch(currentUserProvider).valueOrNull?.firstName ?? '';
    final value = ref.watch(parentHomeProvider);
    final home = value.valueOrNull;
    final band = SpaceBand(
      title: tr.home.hello(name: firstName),
      subtitle: tr.home.subtitle,
      chips: home == null || home.children.isEmpty
          ? null
          : Wrap(spacing: 10, runSpacing: 8, children: [
              for (final child in home.children)
                BandChip(
                  label: [child.firstName, child.schoolClass]
                      .whereType<String>()
                      .where((part) => part.isNotEmpty)
                      .join(' · '),
                  initial: child.firstName.isEmpty ? '?' : child.firstName[0],
                  initialBackground: ParentChildAvatar.tintOf(child).background,
                  initialColor: ParentChildAvatar.tintOf(child).color,
                  onTap: () => unawaited(
                      context.push(ParentSpaceRoutes.child(child.id))),
                ),
            ]),
    );
    return SpaceTabAsync<ParentHome>(
      band: band,
      value: value,
      onRetry: () => ref.invalidate(parentHomeProvider),
      onRefresh: () => ref.refresh(parentHomeProvider.future),
      builder: (home) => _content(context, home),
    );
  }

  List<Widget> _content(BuildContext context, ParentHome home) {
    final tr = Translations.of(context).parentSpace;
    final main = <Widget>[
      if (home.children.isEmpty) ...[
        SoeCard(
          raised: true,
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.home.emptyTitle, style: AppTypography.title),
            const SizedBox(height: 8),
            Text(tr.home.emptyText, style: AppTypography.bodySm),
            const SizedBox(height: 12),
            SoeButton(
              label: tr.home.addChild,
              fullWidth: true,
              onPressed: () =>
                  unawaited(context.push(ParentSpaceRoutes.newChild)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
      ],
      // Sorted by deadline by the server: one gold button, the most urgent.
      for (final (i, action) in home.todoActions.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ActionCard(
              action: action,
              urgent: i == 0,
              raised: i == 0 && home.children.isNotEmpty),
        ),
      if (home.requests.isNotEmpty) ...[
        _SectionTitle(tr.home.requests),
        ...home.requests.map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RequestCard(request: request),
            )),
      ],
    ];
    final week = <Widget>[
      _SectionTitle(tr.home.week,
          link: tr.home.seePlanning,
          onLink: () => context.go(RouteNames.parentPlanning)),
      if (home.weekSessions.isEmpty)
        SoeCard(
            child: Text(tr.home.noSession,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)))
      else
        for (final session in home.weekSessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WeekSessionRow(session: session),
          ),
    ];
    final children = <Widget>[
      if (home.children.isNotEmpty) ...[
        _SectionTitle(tr.home.children,
            link: tr.home.seeAll,
            onLink: () => context.go(RouteNames.parentChildren)),
        ...home.children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChildCard(
                child: child,
                request: home.requests
                    .where((request) =>
                        request.step != 'first_session' &&
                        request.children.contains(child.firstName))
                    .firstOrNull,
              ),
            )),
      ],
    ];
    final invoice = home.invoice == null
        ? const <Widget>[]
        : [_InvoiceCard(invoice: home.invoice!)];
    final side = <Widget>[
      ...week,
      ...children,
      if (invoice.isNotEmpty) ...[const SizedBox(height: 4), ...invoice],
      const SizedBox(height: 14),
      const ParentAdvisorCard(),
    ];
    if (spaceIsWide(context)) {
      // Tablet: what to do and the requests on the left; the month's payment, the advisor,
      // the week and the children on the right, both columns starting on the band.
      final left = main.isEmpty ? [...week, ...children] : main;
      final right = [
        ...invoice,
        if (invoice.isNotEmpty) const SizedBox(height: 14),
        const ParentAdvisorCard(),
        if (main.isNotEmpty) ...[...week, ...children],
      ];
      final lead = left.first is _SectionTitle
          ? const [SizedBox(height: SpaceBand.cardOverlap)]
          : const <Widget>[];
      return [
        ...lead,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: spaceColumnFlex(context).$1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: left)),
          const SizedBox(width: 16),
          Expanded(
              flex: spaceColumnFlex(context).$2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: right)),
        ]),
      ];
    }
    // A section title must not lie on the band: the content then starts below it.
    final lead = (main.isEmpty ? side : main).first is _SectionTitle
        ? const [SizedBox(height: SpaceBand.cardOverlap)]
        : const <Widget>[];
    return [...lead, ...main, ...side];
  }
}

/// A section title of the home in Literata, with its link on the right.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.link, this.onLink});

  final String title;
  final String? link;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 0, 8),
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: AppTypography.h3
                    .copyWith(fontSize: 22, color: AppPalette.teal800)),
          ),
          if (link != null)
            TextButton(
              onPressed: onLink,
              child: Text(link!,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.teal500)),
            ),
        ]),
      );
}

/// A rounded square tile holding an icon.
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

/// « Mathématiques et Physique-Chimie » (FR) or « Mathematics and Physics » (EN).
String parentSubjects(BuildContext context, List<String> subjects) {
  if (subjects.length < 2) return subjects.join();
  final and = Translations.of(context).parentSpace.home.and;
  return '${subjects.sublist(0, subjects.length - 1).join(', ')} $and ${subjects.last}';
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.action, required this.urgent, this.raised = false});

  final ParentHomeAction action;
  final bool urgent;

  /// The first card, overlapping the band.
  final bool raised;

  /// The review window of a report (PV) before an API that sends it: 72 h.
  static const _reportHours = 72;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    // The texts come with the home (as the web card): no call per card.
    final title = action.heading ??
        (action.subjects.isEmpty
            ? action.title
            : tr.home.subjectTitle(
                subjects: parentSubjects(context, action.subjects),
                children: action.children.join(', ')));
    final explanation = action.explanation ?? _explanation(tr);
    final deadline = action.deadline;
    final hours =
        deadline == null ? null : deadline.difference(DateTime.now()).inHours;
    final countdown = action.countdownLabel ??
        (deadline == null
            ? null
            : (action.overdue
                ? tr.home.overdue
                : (action.kind == 'report' && hours != null
                    ? tr.home.hours(hours: hours < 0 ? 0 : hours)
                    : ParentFormat.dayShort(context, deadline))));
    final caption = action.deadlineLabel ??
        (action.kind == 'report'
            ? tr.home.hoursOf(total: action.totalHours ?? _reportHours)
            : (action.kind == 'contract'
                ? tr.home.signBefore
                : tr.home.before));
    final tone = action.overdue
        ? (background: AppPalette.dangerBg, color: AppPalette.dangerText)
        : (action.kind == 'payment' ||
                (action.kind == 'report' && (action.hoursLeft ?? 99) <= 12)
            ? (background: AppPalette.warningBg, color: AppPalette.warningText)
            : (background: AppPalette.gold50, color: AppPalette.gold700));
    final countdownTone = action.overdue
        ? AppPalette.dangerText
        : (action.kind == 'payment' ||
                (action.kind == 'report' && (action.hoursLeft ?? 99) <= 12)
            ? AppPalette.warningText
            : AppPalette.teal800);
    return SizedBox(
      width: double.infinity,
      child: SoeCard(
        raised: raised,
        borderRadius: AppRadius.rCardLg,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _IconTile(
                icon: _icon, background: tone.background, color: tone.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text((action.kindLabel ?? action.label).toUpperCase(),
                  style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.78,
                      color: tone.color)),
            ),
            if (action.badgeLabel != null)
              ParentStatusBadge(
                  status: action.overdue ? 'overdue' : 'issued',
                  label: action.badgeLabel!),
          ]),
          const SizedBox(height: 10),
          if (title != null && title.isNotEmpty)
            Text(title,
                style: AppTypography.subtitle.copyWith(color: AppPalette.text)),
          const SizedBox(height: 6),
          Text(explanation,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          if (countdown != null) ...[
            const SizedBox(height: 14),
            Center(
              child: Column(children: [
                Text(countdown,
                    style: AppTypography.h2.copyWith(color: countdownTone)),
                Text(caption,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              ]),
            ),
          ],
          const SizedBox(height: 14),
          SoeButton(
            label: action.buttonLabel ?? _label(tr),
            variant: urgent && action.kind != 'review'
                ? SoeButtonVariant.primary
                : SoeButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => _open(context),
          ),
        ]),
      ),
    );
  }

  IconData get _icon => switch (action.kind) {
        'report' => Icons.description_outlined,
        'payment' => Icons.account_balance_wallet_outlined,
        'contract' => Icons.draw_outlined,
        'quote' => Icons.request_quote_outlined,
        'planning' => Icons.calendar_today_outlined,
        'tutor' => Icons.person_search_outlined,
        'review' => Icons.star_border,
        _ => Icons.flag_outlined,
      };

  String _explanation(TranslationsParentSpaceFr tr) => switch (action.kind) {
        'report' => tr.home.why.report,
        'payment' => tr.home.why.payment,
        'contract' => tr.home.why.contract,
        'quote' => tr.home.why.quote,
        'planning' => tr.home.why.planning,
        'tutor' => tr.home.why.tutor,
        'review' => tr.home.why.review,
        _ => tr.home.why.other,
      };

  String _label(TranslationsParentSpaceFr tr) => switch (action.kind) {
        'report' => tr.session.seeReport,
        'payment' => tr.pay.title,
        'contract' => tr.requests.contract,
        'quote' => tr.requests.quote,
        'planning' => tr.requests.planning,
        'tutor' => tr.requests.tutor,
        'review' => tr.home.giveReview,
        _ => tr.requests.title,
      };

  void _open(BuildContext context) {
    switch (action.kind) {
      case 'report':
        context.push(ParentSpaceRoutes.report(action.targetId));
      case 'payment':
        context.push(ParentSpaceRoutes.pay(action.targetId));
      case 'contract':
        context.push(ParentSpaceRoutes.contract(action.targetId));
      case 'quote':
        context.push(ParentSpaceRoutes.quote(action.targetId));
      case 'planning':
        context.push(ParentSpaceRoutes.planning(action.targetId));
      case 'tutor':
        context.push(ParentSpaceRoutes.tutors(action.targetId));
      case 'review':
        context.push(ParentSpaceRoutes.reviewForm(action.targetId));
      default:
        context.push(ParentSpaceRoutes.requests);
    }
  }
}

/// A session of the week (PAR-01): the day, subject and child, the time; below, the tutor's
/// initials and name with the status.
class _WeekSessionRow extends StatelessWidget {
  const _WeekSessionRow({required this.session});

  final ParentSession session;

  @override
  Widget build(BuildContext context) {
    final end = session.endsAt;
    final tone = session.status == 'planned'
        ? AppPalette.success
        : parentSessionTone(session.status);
    return SoeCard(
      padding: const EdgeInsets.all(14),
      onTap: () =>
          unawaited(context.push(ParentSpaceRoutes.session(session.id))),
      child: Row(children: [
        Container(
          width: 54,
          height: 60,
          decoration: BoxDecoration(
              color: tone, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(ParentFormat.weekday(context, session.startsAt),
                style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.66,
                    color: AppPalette.white)),
            Text('${session.startsAt.day}',
                style: AppTypography.title.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 24 / 22,
                    color: AppPalette.white)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label
                    .copyWith(fontSize: 15, color: AppPalette.text)),
            const SizedBox(height: 3),
            Text(
                [
                  '${ParentFormat.time(session.startsAt)}${end == null ? '' : ' – ${ParentFormat.time(end)}'}',
                  session.tutorName,
                ].where((part) => part.isNotEmpty).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ]),
        ),
        const SizedBox(width: 8),
        ParentStatusBadge(status: session.status, label: session.statusLabel),
      ]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final ParentHomeRequest request;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final current = ParentHomeRequest.steps.indexOf(request.step);
    final children = request.children.join(', ');
    final overline = request.childLabels.isEmpty
        ? children
        : request.childLabels.join(' · ');
    final title = request.title ??
        (request.subjects.isEmpty
            ? request.stepLabel
            : tr.home.requestTitle(
                subjects: parentSubjects(context, request.subjects),
                children: children));
    final validUntil = request.quoteValidUntil;
    return SoeCard(
      padding: EdgeInsets.zero,
      onTap: request.id == 0
          ? null
          : () =>
              unawaited(context.push(ParentSpaceRoutes.request(request.id))),
      child: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                tr.home
                    .requestOverline(
                        reference: request.reference, children: overline)
                    .toUpperCase(),
                style:
                    AppTypography.overline.copyWith(color: AppPalette.teal500)),
            const SizedBox(height: 6),
            Text(title,
                style: AppTypography.subtitle.copyWith(color: AppPalette.text)),
            if (validUntil != null) ...[
              const SizedBox(height: 8),
              Text(ParentFormat.dayShort(context, validUntil),
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              Text(tr.home.quoteValidUntil,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ],
            const SizedBox(height: 14),
            Row(children: [
              for (var i = 0; i < ParentHomeRequest.steps.length; i++) ...[
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: i < current
                                ? AppPalette.success
                                : (i == current
                                    ? AppPalette.gold400
                                    : AppPalette.teal100),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            '${i < current ? '✓ ' : ''}${_stepName(tr, ParentHomeRequest.steps[i])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                                fontSize: 9,
                                fontWeight: i == current
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: i == current
                                    ? AppPalette.gold700
                                    : (i < current
                                        ? AppPalette.successText
                                        : AppPalette.text3))),
                      ]),
                ),
                if (i < ParentHomeRequest.steps.length - 1)
                  const SizedBox(width: 4),
              ],
            ]),
            const SizedBox(height: 12),
            Text(request.explanation ?? _stepText(tr, request.step),
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ]),
        ),
      ),
    );
  }

  String _stepName(TranslationsParentSpaceFr tr, String step) => switch (step) {
        'quote' => tr.steps.quote,
        'tutor' => tr.steps.tutor,
        'contract' => tr.steps.contract,
        'payment' => tr.steps.payment,
        'first_session' => tr.steps.firstSession,
        _ => tr.steps.request,
      };

  String _stepText(TranslationsParentSpaceFr tr, String step) => switch (step) {
        'quote' => tr.home.stepText.quote,
        'tutor' => tr.home.stepText.tutor,
        'contract' => tr.home.stepText.contract,
        'payment' => tr.home.stepText.payment,
        'first_session' => tr.home.stepText.firstSession,
        _ => tr.home.stepText.request,
      };
}

/// A child of the home: avatar, class and section, then the web card's line: the courses in
/// place, or the step of the request on its way (orange when the parent must act).
class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.request});

  final ParentChild child;
  final ParentHomeRequest? request;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.home;
    final courses = child.courses;
    final line = child.statusLabel ??
        (request != null
            ? request!.stepLabel
            : courses.isEmpty
                ? null
                : tr.courses(
                    n: courses.length,
                    subjects:
                        courses.map((course) => course.subject).join(', ')));
    final color = switch (child.statusTone) {
      'warning' => AppPalette.warningText,
      'info' => AppPalette.teal500,
      'neutral' => AppPalette.text2,
      _ => request != null ? AppPalette.warningText : AppPalette.text2,
    };
    return SoeCard(
      onTap: () => unawaited(context.push(ParentSpaceRoutes.child(child.id))),
      child: Row(children: [
        ParentChildAvatar(child: child),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(child.firstName, style: AppTypography.label),
            Text(parentSchooling(context, child),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            if (line != null)
              Text(line, style: AppTypography.caption.copyWith(color: color)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppPalette.text2),
      ]),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final ParentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final lines = invoice.lines.map((line) => line.label).join(', ');
    final paidAt = invoice.paidAt;
    final summary = invoice.summary ??
        [
          if (lines.isNotEmpty) lines,
          if (invoice.payable && invoice.dueOn != null)
            tr.home.due(date: ParentFormat.day(context, invoice.dueOn!))
          else if (paidAt != null)
            tr.home.paidOn(date: ParentFormat.day(context, paidAt)),
        ].join(' · ');
    final canPay = invoice.canPay ?? invoice.payable;
    final receipt = invoice.receiptPaymentId;
    final month =
        invoice.monthLabel ?? ParentFormat.month(context, invoice.period);
    void openReceipt() => receipt == null
        ? context.go(RouteNames.parentPayments)
        : unawaited(context.push(ParentSpaceRoutes.payment(receipt)));
    if (!invoice.payable) {
      // Paid: the green card of the direction, « Novembre · payé », the receipt.
      return SoeCard(
        color: AppPalette.success,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$month · ${invoice.statusLabel}'.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.successBg)),
              const SizedBox(height: 2),
              Text(ParentFormat.amount(context, invoice.amount),
                  style: AppTypography.numberM.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.white)),
              if (summary.isNotEmpty)
                Text(summary,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.successBg)),
            ]),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppPalette.white,
            shape: const StadiumBorder(),
            child: InkWell(
              onTap: openReceipt,
              customBorder: const StadiumBorder(),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Text(tr.home.seeReceipt,
                    style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.successText)),
              ),
            ),
          ),
        ]),
      );
    }
    return SoeCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(month.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.warningText))),
          ParentStatusBadge(status: invoice.status, label: invoice.statusLabel),
        ]),
        const SizedBox(height: 8),
        Text(ParentFormat.amount(context, invoice.balanceDue),
            style: AppTypography.numberM.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(summary,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        if (canPay) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: tr.home
                .pay(amount: ParentFormat.amount(context, invoice.balanceDue)),
            variant: SoeButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => context.push(ParentSpaceRoutes.pay(invoice.id)),
          ),
        ],
      ]),
    );
  }
}
