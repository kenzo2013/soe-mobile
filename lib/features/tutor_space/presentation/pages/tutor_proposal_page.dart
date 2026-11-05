import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// REP-13 — a family proposed to the tutor: the pupil and the need, the time left to answer,
/// the pay; accept, or decline with a reason. Expired, accepted and declined proposals show
/// their outcome.
class TutorProposalPage extends ConsumerStatefulWidget {
  const TutorProposalPage({super.key, required this.proposalId});

  final int proposalId;

  @override
  ConsumerState<TutorProposalPage> createState() => _TutorProposalPageState();
}

class _TutorProposalPageState extends ConsumerState<TutorProposalPage> {
  Timer? _ticker;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // The countdown moves on while the screen is open.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _answer({required bool accept}) async {
    final tr = Translations.of(context).tutorSpace.proposal;
    String? reason;
    if (!accept) {
      reason = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _DeclineSheet(),
      );
      if (reason == null || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(tutorApiProvider)
          .answerProposal(widget.proposalId, accept: accept, reason: reason);
      if (!mounted) return;
      ref
        ..invalidate(tutorProposalProvider(widget.proposalId))
        ..invalidate(tutorHomeProvider);
      SoeToast.show(context, message: accept ? tr.accepted : tr.declined);
    } on Failure catch (failure) {
      // Only a failure frees the button: after a success the screen refreshes, never a 2nd send.
      if (!mounted) return;
      setState(() => _busy = false);
      SoeToast.show(context,
          message: tutorFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
  }

  void _back() =>
      context.canPop() ? context.pop() : Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.tutor.today, title: tr.title),
      body: TutorAsyncBody<TutorProposal>(
        value: ref.watch(tutorProposalProvider(widget.proposalId)),
        onRetry: () => ref.invalidate(tutorProposalProvider(widget.proposalId)),
        builder: (proposal) => switch (proposal.status) {
          'accepted' => _outcome(_Accepted()),
          'expired' => _outcome(TutorStatusCard(
              icon: Icons.timer_outlined,
              tone: SoeBadgeTone.warning,
              title: tr.expiredTitle,
              body: tr.expiredBody,
              children: [_backButton(tr)],
            )),
          'declined' => _outcome(TutorStatusCard(
              icon: Icons.block,
              title: tr.declinedTitle,
              body: tr.declinedBody,
              children: [_backButton(tr)],
            )),
          'withdrawn' || 'replaced' => _outcome(TutorStatusCard(
              icon: Icons.info_outline,
              title: tr.closedTitle,
              body: proposal.status == 'withdrawn'
                  ? tr.states.withdrawn
                  : tr.states.replaced,
              children: [_backButton(tr)],
            )),
          _ => _filled(proposal),
        },
      ),
    );
  }

  Widget _outcome(Widget card) =>
      ListView(padding: spacePagePadding(context), children: [card]);

  Widget _backButton(TranslationsTutorSpaceProposalFr tr) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SoeButton(
            label: tr.back,
            variant: SoeButtonVariant.secondary,
            size: SoeButtonSize.md,
            onPressed: _back),
      );

  Widget _filled(TutorProposal proposal) {
    final tr = Translations.of(context).tutorSpace.proposal;
    final pupil = [proposal.pupil, proposal.schoolClass]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');
    final rhythm = [
      if (proposal.sessionsPerWeek != null)
        tr.perWeek(n: proposal.sessionsPerWeek!),
      if (proposal.sessionMinutes != null)
        TutorFormat.duration(context, proposal.sessionMinutes!),
    ].join(' · ');
    final rows = <(String, String)>[
      if (proposal.subject != null) (tr.subject, proposal.subject!),
      if (proposal.neighborhood != null)
        (tr.neighborhood, proposal.neighborhood!),
      if (rhythm.isNotEmpty) (tr.rhythm, rhythm),
      if (proposal.moments.isNotEmpty)
        (tr.moments, proposal.moments.join(', ')),
      if (proposal.startDate != null)
        (tr.start, TutorFormat.dayLong(context, proposal.startDate!)),
    ];
    // The answer bar clears the navigation itself.
    final padding = spacePagePadding(context, insets: !proposal.canAnswer);
    return Column(children: [
      Expanded(
        child: ListView(padding: padding, children: [
          Text(tr.heading,
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 6),
          Text(
              proposal.respondBy == null
                  ? tr.introNoDate
                  : tr.intro(
                      date: TutorFormat.dateTime(context, proposal.respondBy!)),
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 16),
          SoeCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.pupil.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 2),
              Text(pupil,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 6),
              Text(
                  Translations.of(context)
                      .tutorSpace
                      .session
                      .contactAfterContract,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 4),
              for (var i = 0; i < rows.length; i++)
                TutorInfoRow(
                    label: rows[i].$1,
                    value: rows[i].$2,
                    last: i == rows.length - 1),
            ]),
          ),
          if (proposal.canAnswer && proposal.respondBy != null) ...[
            const SizedBox(height: 12),
            _Countdown(respondBy: proposal.respondBy!),
          ],
          const SizedBox(height: 12),
          SoeCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.pay,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 6),
              Text(TutorFormat.amount(context, proposal.sessionRate),
                  style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
              Text(tr.perSession,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
        ]),
      ),
      if (proposal.canAnswer)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SoeButton(
                label: tr.decline,
                variant: SoeButtonVariant.tertiary,
                fullWidth: true,
                onPressed:
                    _busy ? null : () => unawaited(_answer(accept: false)),
              ),
              const SizedBox(height: 8),
              SoeButton(
                label: tr.accept,
                fullWidth: true,
                loading: _busy,
                onPressed:
                    _busy ? null : () => unawaited(_answer(accept: true)),
              ),
            ]),
          ),
        ),
    ]);
  }
}

class _Accepted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    final steps = [
      tr.acceptedSteps.profile,
      tr.acceptedSteps.contract,
      tr.acceptedSteps.times
    ];
    return TutorStatusCard(
      icon: Icons.check,
      tone: SoeBadgeTone.success,
      title: tr.acceptedTitle,
      body: tr.acceptedBody,
      children: [
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: i == 0
                  ? Border.all(color: AppPalette.teal800, width: 1.5)
                  : null,
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 13,
                backgroundColor:
                    i == 0 ? AppPalette.teal800 : AppPalette.surfaceSoft,
                child: Text('${i + 1}',
                    style: AppTypography.labelSm.copyWith(
                        color: i == 0 ? AppPalette.white : AppPalette.text2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(steps[i],
                    style: i == 0
                        ? AppTypography.label
                        : AppTypography.bodySm
                            .copyWith(color: AppPalette.text2)),
              ),
            ]),
          ),
      ],
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.respondBy});

  final DateTime respondBy;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    final left = respondBy.difference(DateTime.now());
    final hours = left.isNegative ? 0 : left.inHours;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.toAnswer,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(tr.hours(hours: hours),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        Text(tr.left(date: TutorFormat.dateTime(context, respondBy)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}

/// The reason of a decline: a reason chip and an optional detail. Pops the reason sent.
class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet();

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  static const int _precisionMax = 300;
  final _precision = TextEditingController();
  String? _reason;

  @override
  void dispose() {
    _precision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    final reasons = [
      tr.reasons.tooFar,
      tr.reasons.times,
      tr.reasons.level,
      tr.reasons.other
    ];
    return TutorSheet(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.declineTitle,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 4),
            Text(tr.declineHint,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ]),
        ),
        IconButton(
          tooltip: tr.cancel,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ]),
      const SizedBox(height: 16),
      Text(tr.reason, style: AppTypography.label),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final reason in reasons)
          SoeChip(
            label: reason,
            selected: _reason == reason,
            onTap: () => setState(() => _reason = reason),
          ),
      ]),
      const SizedBox(height: 16),
      SoeTextField(
        controller: _precision,
        label: tr.precision,
        hint: tr.precisionHint,
        maxLines: 3,
        maxLength: _precisionMax,
      ),
      const SizedBox(height: 12),
      SoeButton(
        label: tr.confirmDecline,
        variant: SoeButtonVariant.dangerOutline,
        fullWidth: true,
        onPressed: _reason == null
            ? null
            : () {
                final detail = _precision.text.trim();
                Navigator.of(context)
                    .pop(detail.isEmpty ? _reason : '$_reason : $detail');
              },
      ),
      const SizedBox(height: 4),
      SoeButton(
        label: tr.cancel,
        variant: SoeButtonVariant.tertiary,
        fullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ]);
  }
}
