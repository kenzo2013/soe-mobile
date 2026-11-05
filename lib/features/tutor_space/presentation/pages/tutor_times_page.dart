import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';

/// REP-15 — the weekly times of a signed slot: one start time per session of the week, among
/// the offered ones; the parent approves them.
class TutorTimesPage extends ConsumerStatefulWidget {
  const TutorTimesPage({super.key, required this.slotId});

  final int slotId;

  @override
  ConsumerState<TutorTimesPage> createState() => _TutorTimesPageState();
}

class _TutorTimesPageState extends ConsumerState<TutorTimesPage> {
  final Map<int, String> _choices = {};
  bool _busy = false;

  Future<void> _send(int count) async {
    final tr = Translations.of(context).tutorSpace.times;
    setState(() => _busy = true);
    try {
      await ref.read(tutorApiProvider).proposeTimes(
          widget.slotId, [for (var i = 0; i < count; i++) _choices[i]!]);
      if (!mounted) return;
      _choices.clear();
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
      appBar: AppBar(title: Text(tr.title)),
      body: TutorAsyncBody<TutorPlanning>(
        value: ref.watch(tutorPlanningProvider(widget.slotId)),
        onRetry: () => ref.invalidate(tutorPlanningProvider(widget.slotId)),
        builder: (planning) {
          final count = planning.sessionsPerWeek ?? 0;
          final chosen = [for (var i = 0; i < count; i++) _choices[i]];
          final complete = count > 0 && chosen.every((c) => c != null);
          final distinct = chosen.whereType<String>().toSet().length ==
              chosen.whereType<String>().length;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Text(planning.title,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            if (count > 0 && planning.sessionMinutes != null)
              Text(tr.rhythm(count: count, minutes: planning.sessionMinutes!),
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            if (planning.times.isNotEmpty) ...[
              TutorSectionTitle(tr.current),
              SoeCard(
                child: Column(
                  children: [
                    for (final time in planning.times)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                                '${TutorFormat.weekday(context, time.day)} · ${time.from ?? ''} – ${time.to ?? ''}',
                                style: AppTypography.body),
                          ),
                          TutorStateBadge(
                              state: time.status, label: time.statusLabel),
                        ]),
                      ),
                  ],
                ),
              ),
            ],
            if (planning.canPropose) ...[
              const SizedBox(height: 16),
              if (count == 0)
                SoeAlert(
                    tone: SoeAlertTone.warning,
                    title: tr.title,
                    body: tr.noLine)
              else if (planning.options.isEmpty)
                SoeAlert(
                    tone: SoeAlertTone.info,
                    title: tr.title,
                    body: tr.noOptions)
              else ...[
                Text(
                    planning.fromAvailabilities
                        ? tr.withinAvailabilities
                        : tr.noAvailabilities,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
                for (var i = 0; i < count; i++) ...[
                  const SizedBox(height: 12),
                  Text(tr.session(number: i + 1), style: AppTypography.label),
                  const SizedBox(height: 4),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalette.n300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _choices[i],
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: Text(tr.choose),
                        items: [
                          for (final option in planning.options)
                            DropdownMenuItem(
                                value: option,
                                child:
                                    Text(TutorFormat.option(context, option))),
                        ],
                        onChanged: _busy
                            ? null
                            : (value) => setState(() {
                                  if (value == null) {
                                    _choices.remove(i);
                                  } else {
                                    _choices[i] = value;
                                  }
                                }),
                      ),
                    ),
                  ),
                ],
                if (!distinct) ...[
                  const SizedBox(height: 8),
                  Text(tr.distinct,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.dangerText)),
                ],
                const SizedBox(height: 20),
                SoeButton(
                  label: tr.send,
                  fullWidth: true,
                  loading: _busy,
                  onPressed: _busy || !complete || !distinct
                      ? null
                      : () => unawaited(_send(count)),
                ),
              ],
            ],
          ]);
        },
      ),
    );
  }
}
