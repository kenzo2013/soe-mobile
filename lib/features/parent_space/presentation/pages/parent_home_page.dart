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
import '../../../common/presentation/widgets/notification_bell.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_advisor_card.dart';
import '../widgets/parent_more_links.dart';
import '../widgets/parent_session_tile.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';

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
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(parentHomeProvider.future),
          child: ParentAsyncBody<ParentHome>(
            value: ref.watch(parentHomeProvider),
            onRetry: () => ref.invalidate(parentHomeProvider),
            builder: (home) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Row(children: [
                  Expanded(
                    child: Text(tr.home.hello(name: firstName),
                        style: AppTypography.h1
                            .copyWith(color: AppPalette.teal800)),
                  ),
                  const NotificationBell(),
                ]),
                Text(tr.home.subtitle,
                    style:
                        AppTypography.bodySm.copyWith(color: AppPalette.text2)),
                if (home.children.isEmpty) ...[
                  const SizedBox(height: 20),
                  SoeCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr.home.emptyTitle, style: AppTypography.title),
                          const SizedBox(height: 8),
                          Text(tr.home.emptyText, style: AppTypography.bodySm),
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
                        onPressed: () => context.go(RouteNames.parentSessions),
                        child: Text(tr.home.seePlanning))),
                if (home.weekSessions.isEmpty)
                  SoeCard(
                      child: Text(tr.home.noSession,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2)))
                else
                  ...home.weekSessions.map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ParentSessionTile(
                            session: session,
                            onTap: () => context
                                .push(ParentSpaceRoutes.session(session.id))),
                      )),
                if (home.requests.isNotEmpty) ...[
                  ParentSectionTitle(tr.home.requests),
                  ...home.requests.map((request) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RequestCard(request: request),
                      )),
                ],
                if (home.children.isNotEmpty) ...[
                  ParentSectionTitle(tr.home.children),
                  ...home.children.map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SoeCard(
                          onTap: () =>
                              context.push(ParentSpaceRoutes.child(child.id)),
                          child: Row(children: [
                            CircleAvatar(
                                backgroundColor: AppPalette.gold100,
                                child: Text(
                                    child.firstName.isEmpty
                                        ? '?'
                                        : child.firstName[0],
                                    style: AppTypography.label
                                        .copyWith(color: AppPalette.ink900))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(child.firstName,
                                        style: AppTypography.label),
                                    if (child.schoolClass != null)
                                      Text(child.schoolClass!,
                                          style: AppTypography.caption.copyWith(
                                              color: AppPalette.text2)),
                                  ]),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppPalette.text2),
                          ]),
                        ),
                      )),
                ],
                if (home.invoice != null) ...[
                  const SizedBox(height: 12),
                  _InvoiceCard(invoice: home.invoice!),
                ],
                const SizedBox(height: 12),
                const ParentAdvisorCard(),
                // Until the « Plus » menu renders them, the parent screens open from here.
                ParentPanel(children: [
                  SoeButton(
                    label: tr.home.newRequest,
                    variant: SoeButtonVariant.outline,
                    fullWidth: true,
                    onPressed: () =>
                        unawaited(context.push(ParentSpaceRoutes.newRequest)),
                  ),
                  const SizedBox(height: 8),
                  const ParentMoreLinks(),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.urgent});

  final ParentHomeAction action;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final deadline = action.deadline;
    final hours =
        deadline == null ? null : deadline.difference(DateTime.now()).inHours;
    return SizedBox(
      width: double.infinity,
      child: SoeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(action.label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                  color: action.overdue
                      ? AppPalette.dangerText
                      : AppPalette.teal800)),
          const SizedBox(height: 6),
          if (action.title != null)
            Text(action.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h3),
          const SizedBox(height: 4),
          if (action.kind == 'report' && hours != null)
            Text(tr.home.hoursLeft(hours: hours < 0 ? 0 : hours),
                style: AppTypography.title)
          else if (deadline != null)
            Text(
                action.overdue
                    ? tr.home.overdue
                    : ParentFormat.day(context, deadline),
                style: AppTypography.label),
          const SizedBox(height: 12),
          SoeButton(
            label: _label(tr),
            size: SoeButtonSize.sm,
            variant:
                urgent ? SoeButtonVariant.primary : SoeButtonVariant.outline,
            fullWidth: true,
            onPressed: () => _open(context),
          ),
        ]),
      ),
    );
  }

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

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final ParentHomeRequest request;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final current = ParentHomeRequest.steps.indexOf(request.step);
    return SoeCard(
      onTap: request.id == 0
          ? null
          : () => unawaited(context.push(ParentSpaceRoutes.request(request.id))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            '${request.reference} · ${request.children.join(', ')}'
                .toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 4),
        Text(request.stepLabel, style: AppTypography.label),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < ParentHomeRequest.steps.length; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < current
                        ? AppPalette.teal500
                        : (i == current ? AppPalette.gold400 : AppPalette.n300),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i < ParentHomeRequest.steps.length - 1)
                const SizedBox(width: 4),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(_stepName(tr, request.step),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
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
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final ParentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(
                  ParentFormat.dayLong(context, invoice.period).split(' ').last,
                  style: AppTypography.labelSm)),
          ParentStatusBadge(status: invoice.status, label: invoice.statusLabel),
        ]),
        const SizedBox(height: 6),
        Text(
            ParentFormat.amount(
                context, invoice.payable ? invoice.balanceDue : invoice.amount),
            style: AppTypography.h2),
        if (invoice.dueOn != null && invoice.payable)
          Text(tr.home.due(date: ParentFormat.day(context, invoice.dueOn!)),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        if (invoice.payable) ...[
          const SizedBox(height: 10),
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
