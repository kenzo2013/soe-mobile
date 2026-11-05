import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// REP-15 — the weekly times of a signed slot: one start time per session of the week, among
/// the offered ones (a day, then an hour); then « En attente de la famille » until the parent
/// approves them or asks for others.
class TutorTimesPage extends ConsumerStatefulWidget {
  const TutorTimesPage({super.key, required this.slotId});

  final int slotId;

  @override
  ConsumerState<TutorTimesPage> createState() => _TutorTimesPageState();
}

class _TutorTimesPageState extends ConsumerState<TutorTimesPage> {
  /// The chosen option (« monday 16:00 ») of each session.
  final Map<int, String> _choices = {};

  /// The day shown for each session before an hour is chosen.
  final Map<int, String> _days = {};
  bool _busy = false;

  Future<void> _send(int count) async {
    final tr = Translations.of(context).tutorSpace.times;
    setState(() => _busy = true);
    try {
      await ref.read(tutorApiProvider).proposeTimes(
          widget.slotId, [for (var i = 0; i < count; i++) _choices[i]!]);
      if (!mounted) return;
      _choices.clear();
      _days.clear();
      ref
        ..invalidate(tutorPlanningProvider(widget.slotId))
        ..invalidate(tutorHomeProvider);
      SoeToast.show(context, message: tr.sent);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.times;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.tutor.today, title: tr.title),
      body: TutorAsyncBody<TutorPlanning>(
        value: ref.watch(tutorPlanningProvider(widget.slotId)),
        onRetry: () => ref.invalidate(tutorPlanningProvider(widget.slotId)),
        builder: (planning) {
          final times = planning.times;
          final changeRequested =
              times.any((time) => time.status == 'change_requested');
          if (times.isNotEmpty && times.every((t) => t.status == 'approved')) {
            return _summary(planning,
                icon: Icons.check,
                tone: SoeBadgeTone.success,
                title: tr.approvedTitle,
                body: tr.approvedBody);
          }
          if (times.isNotEmpty && !changeRequested) {
            return _summary(planning,
                icon: Icons.schedule,
                title: tr.waitingTitle,
                body: tr.waitingBody(pupil: planning.pupil));
          }
          return _form(planning, changeRequested: changeRequested);
        },
      ),
    );
  }

  Widget _summary(TutorPlanning planning,
      {required IconData icon,
      required String title,
      required String body,
      SoeBadgeTone tone = SoeBadgeTone.info}) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      TutorStatusCard(
        icon: icon,
        tone: tone,
        title: title,
        body: body,
        children: [
          for (final time in planning.times) ...[
            const SizedBox(height: 20),
            Text('${TutorFormat.weekday(context, time.day)} ${time.from ?? ''}',
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
            if (planning.sessionMinutes != null)
              Text(TutorFormat.duration(context, planning.sessionMinutes!),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
          ],
        ],
      ),
    ]);
  }

  Widget _form(TutorPlanning planning, {required bool changeRequested}) {
    final tr = Translations.of(context).tutorSpace.times;
    final count = planning.sessionsPerWeek ?? 0;
    final chosen = [for (var i = 0; i < count; i++) _choices[i]];
    final complete = count > 0 && chosen.every((c) => c != null);
    final distinct = chosen.whereType<String>().toSet().length ==
        chosen.whereType<String>().length;
    final subtitle = [
      planning.pupil,
      if (count > 0 && planning.sessionMinutes != null)
        tr.rhythm(
            n: count,
            duration: TutorFormat.duration(context, planning.sessionMinutes!)),
    ].where((s) => s.isNotEmpty).join(' · ');
    final canSend =
        planning.canPropose && count > 0 && planning.options.isNotEmpty;
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(tr.heading,
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          if (changeRequested) ...[
            const SizedBox(height: 12),
            SoeAlert(
                tone: SoeAlertTone.warning,
                title: tr.changeRequested,
                body: tr.changeRequestedBody),
          ],
          const SizedBox(height: 16),
          if (count == 0)
            SoeAlert(
                tone: SoeAlertTone.warning, title: tr.title, body: tr.noLine)
          else if (planning.options.isEmpty || !planning.canPropose)
            SoeAlert(
                tone: SoeAlertTone.info, title: tr.title, body: tr.noOptions)
          else
            SoeCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < count; i++) _sessionPicker(planning, i),
                    if (!distinct)
                      Text(tr.distinct,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.dangerText)),
                    const SizedBox(height: 4),
                    Text(
                        planning.fromAvailabilities
                            ? tr.withinAvailabilities
                            : tr.noAvailabilities,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]),
            ),
        ]),
      ),
      if (canSend)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SoeButton(
              label: tr.send,
              fullWidth: true,
              loading: _busy,
              onPressed: _busy || !complete || !distinct
                  ? null
                  : () => unawaited(_send(count)),
            ),
          ),
        ),
    ]);
  }

  /// A session: the days offered, then the hours of the chosen day.
  Widget _sessionPicker(TutorPlanning planning, int index) {
    final tr = Translations.of(context).tutorSpace.times;
    final days = <String>[];
    for (final option in planning.options) {
      final day = option.split(' ').first;
      if (!days.contains(day)) days.add(day);
    }
    final choice = _choices[index];
    final day = _days[index] ?? choice?.split(' ').first;
    final hours = day == null
        ? const <String>[]
        : planning.options.where((o) => o.split(' ').first == day).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(tr.session(number: index + 1),
                  style: AppTypography.label)),
          if (choice != null)
            Text(TutorFormat.option(context, choice),
                style:
                    AppTypography.labelSm.copyWith(color: AppPalette.teal800)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final d in days)
            SoeChip(
              label: TutorFormat.weekday(context, d),
              selected: day == d,
              onTap: _busy ? null : () => setState(() => _days[index] = d),
            ),
        ]),
        if (hours.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final option in hours)
              SoeChip(
                label: option.split(' ').last,
                selected: choice == option,
                onTap: _busy
                    ? null
                    : () => setState(() => _choices[index] = option),
              ),
          ]),
        ],
      ]),
    );
  }
}
