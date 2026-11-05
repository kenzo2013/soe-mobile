import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';

/// REP-18 — the report: written one question per screen and signed with the finger, or, once
/// sent, read with its state (sent, approved, disputed and the parent's reason).
class TutorReportPage extends ConsumerWidget {
  const TutorReportPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.report;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: TutorAsyncBody<TutorReport?>(
        value: ref.watch(tutorReportProvider(sessionId)),
        onRetry: () => ref.invalidate(tutorReportProvider(sessionId)),
        builder: (report) => report != null
            ? _SentReport(report: report)
            : TutorAsyncBody<TutorSessionDetail>(
                value: ref.watch(tutorSessionProvider(sessionId)),
                onRetry: () => ref.invalidate(tutorSessionProvider(sessionId)),
                builder: (detail) {
                  if (detail.checkedInAt == null) {
                    return SoeEmptyState(
                        title: tr.title,
                        message: tr.checkInFirst,
                        icon: Icons.location_off_outlined);
                  }
                  ref.watch(tutorClockProvider);
                  if (DateTime.now().isBefore(detail.reportAvailableAt)) {
                    return SoeEmptyState(
                        title: tr.title,
                        message: tr.notYet(
                            date: TutorFormat.dateTime(
                                context, detail.reportAvailableAt)),
                        icon: Icons.schedule_outlined);
                  }
                  return _ReportForm(detail: detail);
                },
              ),
      ),
    );
  }
}

class _SentReport extends StatelessWidget {
  const _SentReport({required this.report});

  final TutorReport report;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final (label, body, tone) = switch (report.state) {
      'approved' => (
          tr.stateLabels.approved,
          tr.states.approved,
          SoeAlertTone.success
        ),
      'disputed' => (
          tr.stateLabels.disputed,
          tr.states.disputed,
          SoeAlertTone.danger
        ),
      _ => (tr.stateLabels.waiting, tr.states.waiting, SoeAlertTone.info),
    };
    final times =
        [report.startAt, report.endAt].whereType<String>().join(' – ');
    return ListView(padding: const EdgeInsets.all(16), children: [
      SoeAlert(tone: tone, title: label, body: body),
      if (report.disputeReason != null) ...[
        const SizedBox(height: 8),
        Text(tr.disputeReason(reason: report.disputeReason!),
            style: AppTypography.body.copyWith(color: AppPalette.dangerText)),
      ],
      const SizedBox(height: 12),
      SoeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (times.isNotEmpty) TutorField(label: tr.times, value: times),
          if (report.topics.isNotEmpty)
            TutorField(label: tr.topics, value: report.topics.join(', ')),
          if (report.homework?.isNotEmpty == true)
            TutorField(label: tr.homework, value: report.homework!),
          if (report.observations?.isNotEmpty == true)
            TutorField(label: tr.observations, value: report.observations!),
        ]),
      ),
      const SizedBox(height: 12),
      if (report.submittedAt != null)
        Text(
            '${tr.sentAt(date: TutorFormat.dateTime(context, report.submittedAt!))}'
            '${report.late ? ' · ${tr.late}' : ''}',
            style: AppTypography.caption.copyWith(
                color: report.late ? AppPalette.dangerText : AppPalette.text2)),
      if (report.validated == null && report.autoValidatesAt != null)
        Text(
            tr.autoOn(
                date: TutorFormat.dateTime(context, report.autoValidatesAt!)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
    ]);
  }
}

/// The six screens of the report: times, topics, homework, scales, word, signature.
class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm({required this.detail});

  final TutorSessionDetail detail;

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  static const int _steps = 6;
  static const double _padHeight = 160;

  final _pages = PageController();
  final _topic = TextEditingController();
  final _homework = TextEditingController();
  final _message = TextEditingController();
  final _reason = TextEditingController();
  final _signature = SoeSignatureController();

  late TimeOfDay _start;
  late TimeOfDay _end;
  final List<String> _topics = [];
  int _step = 0;
  bool _corrected = false;
  String? _behavior;
  String? _progress;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final detail = widget.detail;
    final session = detail.session;
    _start = TimeOfDay.fromDateTime(detail.checkedInAt ?? session.startsAt);
    _end = TimeOfDay.fromDateTime(
        detail.checkedOutAt ?? session.endsAt ?? session.startsAt);
    for (final controller in [_topic, _reason]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _topic.dispose();
    _homework.dispose();
    _message.dispose();
    _reason.dispose();
    _signature.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _clock(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  bool get _timesValid =>
      !_corrected ||
      (_reason.text.trim().isNotEmpty && _minutes(_end) > _minutes(_start));

  bool get _canContinue => switch (_step) {
        0 => _timesValid,
        1 => _topics.isNotEmpty,
        _ => true,
      };

  void _addTopics() {
    final added = _topic.text
        .split(',')
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty && !_topics.contains(topic));
    setState(() => _topics.addAll(added
        .map((topic) => topic.length > 80 ? topic.substring(0, 80) : topic)));
    _topic.clear();
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    unawaited(_pages.animateToPage(step,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
        context: context, initialTime: start ? _start : _end);
    if (picked == null || !mounted) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  /// « Comportement : Très bien », « Progrès : Nets », then the word to the parents (as the web).
  String _observations(TranslationsTutorSpaceReportFr tr) {
    final behavior = switch (_behavior) {
      'to_improve' => tr.toImprove,
      'fair' => tr.fair,
      'very_good' => tr.veryGood,
      _ => null,
    };
    final progress = switch (_progress) {
      'to_watch' => tr.toWatch,
      'steady' => tr.steady,
      'clear' => tr.clear,
      _ => null,
    };
    return [
      if (behavior != null) '${tr.behavior} : $behavior',
      if (progress != null) '${tr.progress} : $progress',
      if (_message.text.trim().isNotEmpty) _message.text.trim(),
    ].join('\n');
  }

  Future<void> _send() async {
    final tr = Translations.of(context).tutorSpace.report;
    final sessionId = widget.detail.session.id;
    setState(() => _busy = true);
    try {
      final png = await _signature
          .toPng(Size(MediaQuery.sizeOf(context).width - 32, _padHeight));
      if (png == null) return;
      await ref.read(tutorApiProvider).sendReport(
            sessionId,
            topics: _topics,
            homework: _homework.text.trim(),
            observations: _observations(tr),
            signature: png,
            startAt: _corrected ? _clock(_start) : null,
            endAt: _corrected ? _clock(_end) : null,
            correctionReason: _corrected ? _reason.text.trim() : null,
          );
      if (!mounted) return;
      refreshTutorSession(ref, sessionId);
      SoeToast.show(context, message: tr.sent);
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
    final tr = Translations.of(context).tutorSpace.report;
    final last = _step == _steps - 1;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              '${widget.detail.session.title} · ${TutorFormat.day(context, widget.detail.session.date)}',
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 4),
          Text(tr.stepOf(step: _step + 1, total: _steps).toUpperCase(),
              style:
                  AppTypography.overline.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_step + 1) / _steps,
              minHeight: 6,
              color: AppPalette.teal500,
              backgroundColor: AppPalette.n300,
            ),
          ),
        ]),
      ),
      Expanded(
        child: PageView(
          controller: _pages,
          // Buttons only: a swipe would fight with the signature pad.
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _page(tr.timesTitle, _timesStep(tr)),
            _page(tr.topicsTitle, _topicsStep(tr)),
            _page(tr.homeworkTitle, [
              Text(tr.homeworkHint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 12),
              SoeTextField(controller: _homework, maxLines: 4, maxLength: 300),
            ]),
            _page(tr.scalesTitle, _scalesStep(tr)),
            _page(tr.messageTitle, [
              Text(tr.messageHint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 12),
              SoeTextField(controller: _message, maxLines: 5, maxLength: 900),
            ]),
            _page(tr.signatureTitle, [
              Text(tr.signatureHint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 12),
              SoeSignaturePad(
                  controller: _signature,
                  clearLabel: tr.clearSignature,
                  height: _padHeight),
            ]),
          ],
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(
                child: SoeButton(
                  label: tr.back,
                  variant: SoeButtonVariant.outline,
                  onPressed: _busy ? null : () => _go(_step - 1),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: last
                  ? ListenableBuilder(
                      listenable: _signature,
                      builder: (context, _) => SoeButton(
                        label: tr.send,
                        fullWidth: true,
                        loading: _busy,
                        onPressed: _busy || _signature.isEmpty
                            ? null
                            : () => unawaited(_send()),
                      ),
                    )
                  : SoeButton(
                      label: tr.next,
                      variant: SoeButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: _canContinue ? () => _go(_step + 1) : null,
                    ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _page(String title, List<Widget> children) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 8),
          ...children,
        ],
      );

  List<Widget> _timesStep(TranslationsTutorSpaceReportFr tr) {
    Widget time(String label, TimeOfDay value, {required bool start}) =>
        Expanded(
          child: SoeCard(
            onTap: _corrected ? () => unawaited(_pickTime(start: start)) : null,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label.toUpperCase(),
                  style:
                      AppTypography.overline.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 4),
              Text(_clock(value),
                  style: AppTypography.h2.copyWith(
                      color:
                          _corrected ? AppPalette.teal500 : AppPalette.text)),
            ]),
          ),
        );
    return [
      Text(tr.fromCheckIn,
          style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 12),
      Row(children: [
        time(tr.arrival, _start, start: true),
        const SizedBox(width: 12),
        time(tr.departure, _end, start: false),
      ]),
      const SizedBox(height: 12),
      Text(tr.timesHint,
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 8),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(tr.correct, style: AppTypography.label),
        value: _corrected,
        onChanged: (value) => setState(() => _corrected = value),
      ),
      if (_corrected) ...[
        SoeTextField(
          controller: _reason,
          label: tr.correctionReason,
          maxLines: 2,
          maxLength: 200,
          errorText: _minutes(_end) > _minutes(_start) ? null : tr.timesInvalid,
        ),
      ],
    ];
  }

  List<Widget> _topicsStep(TranslationsTutorSpaceReportFr tr) => [
        Text(tr.topicsHint,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: SoeTextField(
              controller: _topic,
              label: tr.topic,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _addTopics(),
            ),
          ),
          const SizedBox(width: 8),
          SoeButton(
            label: tr.add,
            size: SoeButtonSize.md,
            variant: SoeButtonVariant.outline,
            onPressed: _topic.text.trim().isEmpty ? null : _addTopics,
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final topic in _topics)
            InputChip(
              label: Text(topic),
              onDeleted: () => setState(() => _topics.remove(topic)),
            ),
        ]),
        if (_topics.isEmpty) ...[
          const SizedBox(height: 8),
          Text(tr.topicsMissing,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
      ];

  List<Widget> _scalesStep(TranslationsTutorSpaceReportFr tr) {
    Widget scale(String label, Map<String, String> values, String? selected,
            ValueChanged<String?> onSelect) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Text(label, style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final entry in values.entries)
              SoeChip(
                label: entry.value,
                selected: selected == entry.key,
                onTap: () => onSelect(selected == entry.key ? null : entry.key),
              ),
          ]),
        ]);
    return [
      scale(
          tr.behavior,
          {
            'to_improve': tr.toImprove,
            'fair': tr.fair,
            'very_good': tr.veryGood
          },
          _behavior,
          (value) => setState(() => _behavior = value)),
      scale(
          tr.progress,
          {'to_watch': tr.toWatch, 'steady': tr.steady, 'clear': tr.clear},
          _progress,
          (value) => setState(() => _progress = value)),
    ];
  }
}
