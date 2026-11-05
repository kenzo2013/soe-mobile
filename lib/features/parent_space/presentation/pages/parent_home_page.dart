import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../../data/parent_flow_models.dart';
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
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: Column(children: [
          TabTopBar(title: Translations.of(context).shell.parent.home),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(parentHomeProvider.future),
              child: ParentAsyncBody<ParentHome>(
                value: ref.watch(parentHomeProvider),
                onRetry: () => ref.invalidate(parentHomeProvider),
                builder: (home) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    Text(tr.home.hello(name: firstName),
                        style: AppTypography.h1
                            .copyWith(color: AppPalette.teal800)),
                    const SizedBox(height: 4),
                    Text(tr.home.subtitle,
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
                    if (home.children.isEmpty) ...[
                      const SizedBox(height: 20),
                      SoeCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr.home.emptyTitle,
                                  style: AppTypography.title),
                              const SizedBox(height: 8),
                              Text(tr.home.emptyText,
                                  style: AppTypography.bodySm),
                              const SizedBox(height: 12),
                              SoeButton(
                                label: tr.home.addChild,
                                fullWidth: true,
                                onPressed: () => unawaited(
                                    context.push(ParentSpaceRoutes.newChild)),
                              ),
                            ]),
                      ),
                    ],
                    if (home.actions.isNotEmpty) ...[
                      ParentSectionTitle(tr.home.todo,
                          trailing: Text(tr.home.sorted,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2))),
                      // Sorted by deadline by the server: one gold button, the most urgent.
                      for (final (i, action) in home.actions.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ActionCard(action: action, urgent: i == 0),
                        ),
                    ],
                    ParentSectionTitle(tr.home.week,
                        trailing: TextButton(
                            onPressed: () =>
                                context.go(RouteNames.parentPlanning),
                            child: Text(tr.home.seePlanning))),
                    if (home.weekSessions.isEmpty)
                      SoeCard(
                          child: Text(tr.home.noSession,
                              style: AppTypography.bodySm
                                  .copyWith(color: AppPalette.text2)))
                    else
                      SoeCard(
                        padding: EdgeInsets.zero,
                        child: Column(children: [
                          for (final (i, session) in home.weekSessions.indexed)
                            _WeekSessionRow(
                                session: session,
                                divider: i < home.weekSessions.length - 1),
                        ]),
                      ),
                    if (home.requests.isNotEmpty) ...[
                      ParentSectionTitle(tr.home.requests),
                      ...home.requests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _RequestCard(request: request),
                          )),
                    ],
                    if (home.children.isNotEmpty) ...[
                      ParentSectionTitle(tr.home.children,
                          trailing: TextButton(
                              onPressed: () =>
                                  context.go(RouteNames.parentChildren),
                              child: Text(tr.home.seeAll))),
                      ...home.children.map((child) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ChildCard(
                              child: child,
                              request: home.requests
                                  .where((request) =>
                                      request.step != 'first_session' &&
                                      request.children
                                          .contains(child.firstName))
                                  .firstOrNull,
                            ),
                          )),
                    ],
                    if (home.invoice != null) ...[
                      const SizedBox(height: 12),
                      _InvoiceCard(invoice: home.invoice!),
                    ],
                    const SizedBox(height: 12),
                    const ParentAdvisorCard(),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// « Mathématiques et Physique-Chimie » (FR) or « Mathematics and Physics » (EN).
String parentSubjects(BuildContext context, List<String> subjects) {
  if (subjects.length < 2) return subjects.join();
  final and = Translations.of(context).parentSpace.home.and;
  return '${subjects.sublist(0, subjects.length - 1).join(', ')} $and ${subjects.last}';
}

class _ActionCard extends ConsumerWidget {
  const _ActionCard({required this.action, required this.urgent});

  final ParentHomeAction action;
  final bool urgent;

  /// The review window of a report (PV): 72 h, then validated automatically.
  static const _reportHours = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final subject = ref
        .watch(parentActionSubjectProvider(
            (kind: action.kind, targetId: action.targetId)))
        .valueOrNull;
    final title = subject == null || subject.subjects.isEmpty
        ? action.title
        : tr.home.subjectTitle(
            subjects: parentSubjects(context, subject.subjects),
            children: subject.children.join(', '));
    final session = subject?.session;
    final explanation = [
      if (session != null)
        tr.home.sessionOf(
            date: ParentFormat.dayLong(context, session.startsAt),
            tutor: session.tutorName),
      _explanation(tr),
    ].join(' · ');
    final deadline = action.deadline;
    final hours =
        deadline == null ? null : deadline.difference(DateTime.now()).inHours;
    final tone = action.overdue
        ? AppPalette.dangerText
        : (action.kind == 'contract' || action.kind == 'payment'
            ? AppPalette.warningText
            : AppPalette.teal700);
    return SizedBox(
      width: double.infinity,
      child: SoeCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_icon, size: 16, color: tone),
            const SizedBox(width: 6),
            Expanded(
              child: Text(action.label,
                  style: AppTypography.labelSm.copyWith(color: tone)),
            ),
          ]),
          const SizedBox(height: 10),
          if (title != null && title.isNotEmpty)
            Text(title,
                style: AppTypography.label.copyWith(color: AppPalette.text)),
          const SizedBox(height: 6),
          Text(explanation,
              style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          if (deadline != null) ...[
            const SizedBox(height: 14),
            Center(
              child: Column(children: [
                Text(
                    action.overdue
                        ? tr.home.overdue
                        : (action.kind == 'report' && hours != null
                            ? tr.home.hours(hours: hours < 0 ? 0 : hours)
                            : ParentFormat.dayShort(context, deadline)),
                    style: AppTypography.h2.copyWith(
                        color: action.overdue
                            ? AppPalette.dangerText
                            : AppPalette.teal800)),
                Text(
                    action.kind == 'report'
                        ? tr.home.hoursOf(total: _reportHours)
                        : (action.kind == 'contract'
                            ? tr.home.signBefore
                            : tr.home.before),
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              ]),
            ),
          ],
          const SizedBox(height: 14),
          SoeButton(
            label: _label(tr),
            variant:
                urgent ? SoeButtonVariant.primary : SoeButtonVariant.outline,
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
  const _WeekSessionRow({required this.session, required this.divider});

  final ParentSession session;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final end = session.endsAt;
    return InkWell(
      onTap: () =>
          unawaited(context.push(ParentSpaceRoutes.session(session.id))),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: divider
              ? const Border(bottom: BorderSide(color: AppPalette.n300))
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 44,
                child: Column(children: [
                  Text(ParentFormat.weekday(context, session.startsAt),
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.text2)),
                  Text('${session.startsAt.day}',
                      style: AppTypography.title
                          .copyWith(color: AppPalette.teal800)),
                ]),
              ),
              Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: parentSessionTone(session.status),
                      borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(session.title,
                          style: AppTypography.labelSm,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          '${ParentFormat.time(session.startsAt)}${end == null ? '' : ' – ${ParentFormat.time(end)}'}',
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            ParentInitials(name: session.tutorName),
            const SizedBox(width: 8),
            Flexible(
              child: Text(session.tutorName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(color: AppPalette.text)),
            ),
            const SizedBox(width: 10),
            ParentStatusBadge(
                status: session.status, label: session.statusLabel),
          ]),
        ]),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.request});

  final ParentHomeRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final current = ParentHomeRequest.steps.indexOf(request.step);
    final children = request.children.join(', ');
    final detail = request.id == 0
        ? null
        : ref.watch(parentRequestDetailProvider(request.id)).valueOrNull;
    final subjects = {
      for (final need in detail?.needs ?? const <ParentNeed>[])
        ...need.subjects.where((subject) => subject.isNotEmpty)
    }.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.n300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: request.id == 0
              ? null
              : () => unawaited(
                  context.push(ParentSpaceRoutes.request(request.id))),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  tr.home
                      .requestOverline(
                          reference: request.reference, children: children)
                      .toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal700)),
              const SizedBox(height: 6),
              Text(
                  subjects.isEmpty
                      ? request.stepLabel
                      : tr.home.requestTitle(
                          subjects: parentSubjects(context, subjects),
                          children: children),
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 14),
              Row(children: [
                for (var i = 0; i < ParentHomeRequest.steps.length; i++) ...[
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: i < current
                                  ? AppPalette.teal700
                                  : (i == current
                                      ? AppPalette.gold400
                                      : AppPalette.teal100),
                              borderRadius: BorderRadius.circular(2),
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
                                  color: i <= current
                                      ? AppPalette.text
                                      : AppPalette.text3)),
                        ]),
                  ),
                  if (i < ParentHomeRequest.steps.length - 1)
                    const SizedBox(width: 4),
                ],
              ]),
              const SizedBox(height: 12),
              Text(_stepText(tr, request.step),
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ]),
          ),
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

/// A child of the home: avatar, class and section, the courses (from the child's file) or
/// the step of the request in progress.
class _ChildCard extends ConsumerWidget {
  const _ChildCard({required this.child, required this.request});

  final ParentChild child;
  final ParentHomeRequest? request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.home;
    final courses =
        ref.watch(parentChildProvider(child.id)).valueOrNull?.courses ??
            const <ParentCourse>[];
    final active = courses.where((course) => course.active).toList();
    final line = request != null
        ? request!.stepLabel
        : active.isEmpty
            ? null
            : tr.courses(
                n: active.length,
                subjects: active.map((course) => course.subject).join(', '));
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
              Text(line,
                  style: AppTypography.caption.copyWith(
                      color: request != null
                          ? AppPalette.warningText
                          : AppPalette.text2)),
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
    return SoeCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(ParentFormat.month(context, invoice.period),
                  style: AppTypography.labelSm)),
          ParentStatusBadge(status: invoice.status, label: invoice.statusLabel),
        ]),
        const SizedBox(height: 8),
        Text(
            ParentFormat.amount(
                context, invoice.payable ? invoice.balanceDue : invoice.amount),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(
            [
              if (lines.isNotEmpty) lines,
              if (invoice.payable && invoice.dueOn != null)
                tr.home.due(date: ParentFormat.day(context, invoice.dueOn!))
              else if (paidAt != null)
                tr.home.paidOn(date: ParentFormat.day(context, paidAt)),
            ].join(' · '),
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 12),
        if (invoice.payable)
          SoeButton(
            label: tr.home
                .pay(amount: ParentFormat.amount(context, invoice.balanceDue)),
            variant: SoeButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => context.push(ParentSpaceRoutes.pay(invoice.id)),
          )
        else
          Center(
            child: TextButton(
              onPressed: () => context.go(RouteNames.parentPayments),
              child: Text(tr.home.seeReceipt),
            ),
          ),
      ]),
    );
  }
}
