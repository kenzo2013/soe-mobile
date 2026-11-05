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
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_file_ui.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// REP-23 — the interview with SOE's recruitment team (its date is set by SOE, what to bring)
/// and the level test with its result; then the way to the charter.
class TutorInterviewPage extends ConsumerWidget {
  const TutorInterviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.interview;
    final value = ref.watch(tutorInterviewProvider);
    final charterNext = value.valueOrNull?.stage == 'charter';
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      bottomNavigationBar: charterNext
          ? TutorBottomBar(
              child: SoeButton(
                label: tr.readCharter,
                fullWidth: true,
                onPressed: () => context.push(TutorSpaceRoutes.charter),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorInterviewProvider.future),
        child: TutorAsyncBody<TutorInterview>(
          value: value,
          onRetry: () => ref.invalidate(tutorInterviewProvider),
          builder: (interview) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(tr.title,
                  style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 16),
              if (interview.stage == 'refused') ...[
                SoeAlert(
                    title: tr.title,
                    body: tr.refused,
                    tone: SoeAlertTone.danger),
                const SizedBox(height: 16),
              ],
              _InterviewCard(interview: interview),
              if (!interview.interviewPassed && interview.bring.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Bring(items: interview.bring),
              ],
              const SizedBox(height: 16),
              _TestCard(interview: interview),
              if (charterNext) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.next,
                            style: AppTypography.h3
                                .copyWith(color: AppPalette.teal800)),
                        const SizedBox(height: 6),
                        Text(tr.nextCharter,
                            style: AppTypography.body
                                .copyWith(color: AppPalette.text2)),
                      ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard({required this.interview});

  final TutorInterview interview;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.interview;
    final at = interview.interviewAt;
    final Widget body;
    if (at != null) {
      body = Column(children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
              color: AppPalette.successBg, shape: BoxShape.circle),
          child: const Icon(Icons.event_available,
              color: AppPalette.successText, size: 30),
        ),
        const SizedBox(height: 12),
        Text(interview.interviewPassed ? tr.interview : tr.planned,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        Text(TutorFormat.day(context, at),
            style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
        Text(
            tr.at(
                date: TutorFormat.dayLong(context, at),
                time: TutorFormat.time(at)),
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 6),
        Text(tr.withTeam,
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      ]);
    } else {
      final reached = TutorJourney.reached(interview.stage, 'interview');
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.interview, style: AppTypography.title),
        const SizedBox(height: 6),
        Text(
            interview.interviewPassed
                ? tr.withTeam
                : reached
                    ? tr.soon
                    : tr.before,
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
      ]);
    }
    return SoeCard(
      child: Stack(children: [
        SizedBox(width: double.infinity, child: body),
        if (interview.interviewPassed)
          Positioned(
              top: 0,
              right: 0,
              child: SoeBadge(label: tr.passed, tone: SoeBadgeTone.success)),
      ]),
    );
  }
}

class _Bring extends StatelessWidget {
  const _Bring({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.gold50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Translations.of(context).tutorSpace.interview.bring,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check, size: 18, color: AppPalette.success),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: AppTypography.bodySm)),
              ]),
            ),
        ]),
      );
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.interview});

  final TutorInterview interview;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.interview;
    final score = interview.testScore;
    final String text;
    if (score != null) {
      text = tr.score(score: score);
    } else if (interview.testPassed) {
      text = tr.passed;
    } else if (TutorJourney.reached(interview.stage, 'test')) {
      text = tr.testPending;
    } else {
      text = tr.testAfter;
    }
    return SoeCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TutorFileIcon(Icons.menu_book_outlined),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.test, style: AppTypography.title),
            const SizedBox(height: 4),
            Text(text,
                style: AppTypography.body.copyWith(
                    color: score != null ? AppPalette.text : AppPalette.text2)),
          ]),
        ),
        if (interview.testPassed)
          SoeBadge(label: tr.passed, tone: SoeBadgeTone.success),
      ]),
    );
  }
}
