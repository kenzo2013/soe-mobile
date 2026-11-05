import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';

/// REP-13 — a family proposed to the tutor: the need, the time left to answer, the pay;
/// accept, or decline with a reason.
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
      if (mounted) setState(() => _busy = false);
      if (mounted) {
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: TutorAsyncBody<TutorProposal>(
        value: ref.watch(tutorProposalProvider(widget.proposalId)),
        onRetry: () => ref.invalidate(tutorProposalProvider(widget.proposalId)),
        builder: (proposal) {
          final stateText = switch (proposal.status) {
            'accepted' => tr.states.accepted,
            'declined' => tr.states.declined,
            'expired' => tr.states.expired,
            'withdrawn' => tr.states.withdrawn,
            'replaced' => tr.states.replaced,
            _ => null,
          };
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(tr.heading,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 6),
            Align(
                alignment: Alignment.centerLeft,
                child: TutorStateBadge(
                    state: proposal.status, label: proposal.statusLabel)),
            if (stateText != null) ...[
              const SizedBox(height: 12),
              SoeAlert(
                  tone: proposal.status == 'accepted'
                      ? SoeAlertTone.success
                      : SoeAlertTone.info,
                  title: proposal.statusLabel,
                  body: stateText),
            ],
            if (proposal.canAnswer && proposal.respondBy != null) ...[
              const SizedBox(height: 12),
              _Countdown(respondBy: proposal.respondBy!),
            ],
            const SizedBox(height: 12),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TutorField(label: tr.pupil, value: proposal.pupil),
                    if (proposal.schoolClass != null)
                      TutorField(
                          label: tr.schoolClass, value: proposal.schoolClass!),
                    if (proposal.subject != null)
                      TutorField(label: tr.subject, value: proposal.subject!),
                    if (proposal.neighborhood != null)
                      TutorField(
                          label: tr.neighborhood,
                          value: proposal.neighborhood!),
                    if (proposal.sessionsPerWeek != null &&
                        proposal.sessionMinutes != null)
                      TutorField(
                          label: tr.rhythm,
                          value: tr.rhythmValue(
                              sessions: proposal.sessionsPerWeek!,
                              minutes: proposal.sessionMinutes!)),
                    if (proposal.moments.isNotEmpty)
                      TutorField(
                          label: tr.moments,
                          value: proposal.moments.join(', ')),
                    if (proposal.startDate != null)
                      TutorField(
                          label: tr.start,
                          value: TutorFormat.dayLong(
                              context, proposal.startDate!)),
                  ]),
            ),
            const SizedBox(height: 10),
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.pay.toUpperCase(),
                        style: AppTypography.overline
                            .copyWith(color: AppPalette.text2)),
                    const SizedBox(height: 4),
                    Text(TutorFormat.amount(context, proposal.sessionRate),
                        style: AppTypography.h2
                            .copyWith(color: AppPalette.teal800)),
                    Text(tr.perSession,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]),
            ),
            const SizedBox(height: 10),
            Text(
                Translations.of(context)
                    .tutorSpace
                    .session
                    .contactAfterContract,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            if (proposal.canAnswer) ...[
              const SizedBox(height: 20),
              SoeButton(
                label: tr.accept,
                fullWidth: true,
                loading: _busy,
                onPressed:
                    _busy ? null : () => unawaited(_answer(accept: true)),
              ),
              const SizedBox(height: 8),
              SoeButton(
                label: tr.decline,
                variant: SoeButtonVariant.dangerOutline,
                fullWidth: true,
                onPressed:
                    _busy ? null : () => unawaited(_answer(accept: false)),
              ),
            ],
          ]);
        },
      ),
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
    final minutes = left.isNegative ? 0 : left.inMinutes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppPalette.gold50, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.toAnswer.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 4),
        Text(tr.left(hours: minutes ~/ 60, minutes: minutes % 60),
            style: AppTypography.h3.copyWith(color: AppPalette.ink900)),
        Text(tr.until(date: TutorFormat.dateTime(context, respondBy)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}

/// The reason of a decline; « Décliner la mission » stays disabled until it is written.
class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet();

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.proposal;
    return TutorSheet(children: [
      Text(tr.decline, style: AppTypography.title),
      const SizedBox(height: 12),
      SoeTextField(
          controller: _reason, label: tr.reason, maxLines: 4, maxLength: 500),
      const SizedBox(height: 12),
      ListenableBuilder(
        listenable: _reason,
        builder: (context, _) => SoeButton(
          label: tr.confirmDecline,
          variant: SoeButtonVariant.danger,
          fullWidth: true,
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
        ),
      ),
    ]);
  }
}
