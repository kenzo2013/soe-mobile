import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
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
import '../../../common/presentation/widgets/space_app_bar.dart';

/// A report being written, kept while the app runs (leaving the screen or a network cut
/// never loses it).
class TutorReportDraft {
  const TutorReportDraft({
    this.step = 0,
    this.topics = const [],
    this.homework = '',
    this.message = '',
    this.behavior,
    this.progress,
    this.correctedStart,
    this.correctedEnd,
    this.correctionReason,
    this.signature = const [],
  });

  final int step;
  final List<String> topics;
  final String homework;
  final String message;
  final String? behavior;
  final String? progress;

  /// HH:MM, with a reason, when the check-in times are corrected.
  final String? correctedStart;
  final String? correctedEnd;
  final String? correctionReason;

  /// The strokes of the signature (null ends a stroke).
  final List<Offset?> signature;
}

/// The drafts by session id.
final tutorReportDraftsProvider =
    StateProvider<Map<int, TutorReportDraft>>((ref) => const {});

/// REP-18 — the report: written one question per screen under the check-in times (corrected
/// with a reason if needed) and signed with the finger; kept as a draft and sent again when
/// the network is back. Before it opens: when it will. Once sent: waiting, disputed (the
/// parent's reason, the times, the follow-up) or approved (the pay of the month).
class TutorReportPage extends ConsumerWidget {
  const TutorReportPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.report;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.tutor.planning,
          title: tr.title),
      body: TutorAsyncBody<TutorReport?>(
        value: ref.watch(tutorReportProvider(sessionId)),
        onRetry: () => ref.invalidate(tutorReportProvider(sessionId)),
        builder: (report) => TutorAsyncBody<TutorSessionDetail>(
          value: ref.watch(tutorSessionProvider(sessionId)),
          onRetry: () => ref.invalidate(tutorSessionProvider(sessionId)),
          builder: (detail) {
            if (report != null) {
              return report.state == 'approved'
                  ? _ApprovedReport(report: report, detail: detail)
                  : _SentReport(report: report, detail: detail);
            }
            if (detail.checkedInAt == null) {
              return SoeEmptyState(
                  title: tr.title,
                  message: tr.checkInFirst,
                  icon: Icons.location_off_outlined);
            }
            ref.watch(tutorClockProvider);
            if (DateTime.now().isBefore(detail.reportAvailableAt)) {
              return _NotYet(detail: detail);
            }
            return _ReportForm(detail: detail);
          },
        ),
      ),
    );
  }
}

class _NotYet extends StatelessWidget {
  const _NotYet({required this.detail});

  final TutorSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final opens = TutorFormat.time(detail.reportAvailableAt);
    Widget figure(String value, String caption) => Column(children: [
          Text(value,
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          Text(caption,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]);
    return ListView(padding: const EdgeInsets.all(16), children: [
      TutorStatusCard(
        icon: Icons.timer_outlined,
        title: tr.notYetTitle(time: opens),
        body: tr.notYetBody,
        children: [
          const SizedBox(height: 20),
          Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 12,
              children: [
                figure(opens, tr.opening),
                if (detail.reportDueAt != null)
                  figure(
                      '${TutorFormat.weekdayShort(context, detail.reportDueAt!).toLowerCase()} ${TutorFormat.time(detail.reportDueAt!)}',
                      tr.dueLatest),
              ]),
        ],
      ),
    ]);
  }
}

class _ApprovedReport extends StatelessWidget {
  const _ApprovedReport({required this.report, required this.detail});

  final TutorReport report;
  final TutorSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final date = report.date ?? detail.session.date;
    final month =
        TutorFormat.month(context, date).split(' ').first.toLowerCase();
    return ListView(padding: const EdgeInsets.all(16), children: [
      TutorStatusCard(
        icon: Icons.check,
        tone: SoeBadgeTone.success,
        title: tr.approvedTitle,
        body: tr.approvedBody(
            date: TutorFormat.dayLong(context, date).toLowerCase(),
            pupil: detail.session.pupil,
            month: month),
        children: [
          if (detail.rate != null) ...[
            const SizedBox(height: 16),
            Text(
                tr.plusAmount(
                    amount: TutorFormat.amount(context, detail.rate!)),
                style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
            Text(month,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          ],
          const SizedBox(height: 20),
          SoeButton(
            label: tr.seeEarnings,
            variant: SoeButtonVariant.secondary,
            size: SoeButtonSize.md,
            onPressed: () => context.go(RouteNames.tutorEarnings),
          ),
        ],
      ),
    ]);
  }
}

/// A sent report waiting for the parent, or disputed (SOE reviews).
class _SentReport extends StatelessWidget {
  const _SentReport({required this.report, required this.detail});

  final TutorReport report;
  final TutorSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final session = detail.session;
    final disputed = report.state == 'disputed';
    final date = report.date ?? session.date;
    final pupil = [session.pupil, session.schoolClass]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');
    final checkIn = detail.checkedInAt == null
        ? null
        : [
            '${TutorFormat.time(detail.checkedInAt!)}${detail.checkedOutAt == null ? '' : ' → ${TutorFormat.time(detail.checkedOutAt!)}'}',
            if (detail.checkInMethod == 'code')
              Translations.of(context).tutorSpace.session.check.methodCode
            else
              Translations.of(context).tutorSpace.session.check.methodGps,
          ].join(' · ');
    final reportTimes =
        [report.startAt, report.endAt].whereType<String>().join(' → ');
    final corrected = detail.checkedInAt != null &&
        report.startAt != null &&
        report.startAt != TutorFormat.time(detail.checkedInAt!);
    final content = <(String, String)>[
      if (report.topics.isNotEmpty) (tr.topics, report.topics.join(', ')),
      if (report.homework?.isNotEmpty == true) (tr.homework, report.homework!),
      if (report.observations?.isNotEmpty == true)
        (tr.observations, report.observations!),
    ];
    final times = <(String, String, Color?)>[
      if (checkIn != null) (tr.checkIn, checkIn, null),
      if (reportTimes.isNotEmpty)
        (
          corrected ? tr.correctedTimes : tr.reportTimesRow,
          reportTimes,
          corrected ? AppPalette.warningText : null
        ),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(pupil.toUpperCase(),
          style: AppTypography.overline.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 4),
      Text(tr.pvOf(date: TutorFormat.dayLong(context, date).toLowerCase()),
          style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: SoeBadge(
            label: disputed ? tr.stateLabels.disputed : tr.stateLabels.waiting,
            tone: disputed ? SoeBadgeTone.danger : SoeBadgeTone.info),
      ),
      const SizedBox(height: 12),
      if (disputed)
        SoeAlert(
            tone: SoeAlertTone.danger,
            title: report.disputeReason == null
                ? tr.stateLabels.disputed
                : tr.disputeReason(reason: report.disputeReason!),
            body: tr.states.disputed)
      else
        SoeAlert(
            tone: SoeAlertTone.info,
            title: tr.stateLabels.waiting,
            body: tr.states.waiting),
      if (times.isNotEmpty) ...[
        const SizedBox(height: 12),
        SoeCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(tr.reportTimes,
                      style: AppTypography.h3
                          .copyWith(color: AppPalette.teal800))),
              if (corrected)
                SoeBadge(label: tr.corrected, tone: SoeBadgeTone.warning),
            ]),
            if (corrected) ...[
              const SizedBox(height: 4),
              Text(tr.reportTimesHint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ],
            for (var i = 0; i < times.length; i++)
              TutorInfoRow(
                  label: times[i].$1,
                  value: times[i].$2,
                  valueColor: times[i].$3,
                  last: i == times.length - 1),
          ]),
        ),
      ],
      if (content.isNotEmpty) ...[
        const SizedBox(height: 12),
        SoeCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.yourReport,
                style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
            for (var i = 0; i < content.length; i++)
              TutorInfoRow(
                  label: content[i].$1,
                  value: content[i].$2,
                  last: i == content.length - 1),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      _Follow(report: report),
      if (disputed) ...[
        const SizedBox(height: 12),
        _SoftCard(title: tr.duringReview, body: tr.duringReviewBody),
      ],
    ]);
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppPalette.gold50,
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 6),
          Text(body,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
        ]),
      );
}

/// « Suivi »: newest first — the decision to come, the dispute, the sending.
class _Follow extends StatelessWidget {
  const _Follow({required this.report});

  final TutorReport report;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final disputed = report.state == 'disputed';
    final sent = report.submittedAt == null
        ? null
        : '${TutorFormat.dateTime(context, report.submittedAt!)}${report.late ? ' · ${tr.late}' : ''}';
    final steps = <(String, String?, Color?)>[
      if (disputed) ...[
        (tr.followDecision, tr.followPending, null),
        (tr.followDisputed, null, AppPalette.teal800),
      ] else if (report.autoValidatesAt != null)
        (
          tr.stateLabels.waiting,
          tr.followAuto(
              date: TutorFormat.dateTime(context, report.autoValidatesAt!)),
          AppPalette.gold400
        ),
      (tr.followSent, sent, AppPalette.teal800),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppPalette.gold50,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.follow,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        for (final (label, caption, color) in steps)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: color ?? AppPalette.white,
                  shape: BoxShape.circle,
                  border: color == null
                      ? Border.all(color: AppPalette.n300, width: 1.5)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTypography.labelSm.copyWith(
                              color: color == null
                                  ? AppPalette.text2
                                  : AppPalette.text)),
                      if (caption != null)
                        Text(caption,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                    ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// The five questions of the report under the times card; « Signer et envoyer » on the last.
class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm({required this.detail});

  final TutorSessionDetail detail;

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  static const int _steps = 5;
  static const double _padHeight = 160;
  static const Duration _retryEvery = Duration(seconds: 20);

  final _topic = TextEditingController();
  final _homework = TextEditingController();
  final _message = TextEditingController();
  final _signature = SoeSignatureController();

  int _step = 0;
  List<String> _topics = [];
  String? _behavior;
  String? _progress;
  String? _correctedStart;
  String? _correctedEnd;
  String? _correctionReason;
  bool _busy = false;
  bool _offline = false;
  Timer? _retry;

  int get _sessionId => widget.detail.session.id;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(tutorReportDraftsProvider)[_sessionId];
    if (draft != null) {
      _step = draft.step;
      _topics = [...draft.topics];
      _homework.text = draft.homework;
      _message.text = draft.message;
      _behavior = draft.behavior;
      _progress = draft.progress;
      _correctedStart = draft.correctedStart;
      _correctedEnd = draft.correctedEnd;
      _correctionReason = draft.correctionReason;
      for (final point in draft.signature) {
        point == null ? _signature.endStroke() : _signature.add(point);
      }
    }
    _homework.addListener(_saveDraft);
    _message.addListener(_saveDraft);
    _signature.addListener(_saveDraft);
    _topic.addListener(_refresh);
  }

  @override
  void dispose() {
    _retry?.cancel();
    _topic.dispose();
    _homework.dispose();
    _message.dispose();
    _signature.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _saveDraft() {
    final drafts = ref.read(tutorReportDraftsProvider.notifier);
    drafts.state = {
      ...drafts.state,
      _sessionId: TutorReportDraft(
        step: _step,
        topics: List.unmodifiable(_topics),
        homework: _homework.text,
        message: _message.text,
        behavior: _behavior,
        progress: _progress,
        correctedStart: _correctedStart,
        correctedEnd: _correctedEnd,
        correctionReason: _correctionReason,
        signature: _signature.points,
      ),
    };
  }

  void _update(VoidCallback change) {
    setState(change);
    _saveDraft();
  }

  void _clearDraft() {
    final drafts = ref.read(tutorReportDraftsProvider.notifier);
    drafts.state = {...drafts.state}..remove(_sessionId);
  }

  void _addTopics() {
    final added = _topic.text
        .split(',')
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty && !_topics.contains(topic))
        .map((topic) => topic.length > 80 ? topic.substring(0, 80) : topic);
    _update(() => _topics = [..._topics, ...added]);
    _topic.clear();
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    _update(() => _step = step);
  }

  bool get _canContinue => _step != 0 || _topics.isNotEmpty;

  Future<void> _correct() async {
    final detail = widget.detail;
    final corrected = await showModalBottomSheet<_Correction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CorrectionSheet(
        start: _correctedStart ??
            TutorFormat.time(detail.checkedInAt ?? detail.session.startsAt),
        end: _correctedEnd ??
            TutorFormat.time(detail.checkedOutAt ??
                detail.session.endsAt ??
                detail.session.startsAt),
        reason: _correctionReason ?? '',
      ),
    );
    if (corrected == null || !mounted) return;
    _update(() {
      _correctedStart = corrected.start;
      _correctedEnd = corrected.end;
      _correctionReason = corrected.reason;
    });
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
    if (_busy) return;
    final tr = Translations.of(context).tutorSpace.report;
    setState(() => _busy = true);
    try {
      final png = await _signature
          .toPng(Size(MediaQuery.sizeOf(context).width - 32, _padHeight));
      if (png == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final corrected = _correctedStart != null &&
          _correctedEnd != null &&
          _correctionReason != null;
      await ref.read(tutorApiProvider).sendReport(
            _sessionId,
            topics: _topics,
            homework: _homework.text.trim(),
            observations: _observations(tr),
            signature: png,
            startAt: corrected ? _correctedStart : null,
            endAt: corrected ? _correctedEnd : null,
            correctionReason: corrected ? _correctionReason : null,
          );
      _retry?.cancel();
      if (!mounted) return;
      _clearDraft();
      refreshTutorSession(ref, _sessionId);
      SoeToast.show(context, message: tr.sent);
    } on Failure catch (failure) {
      if (!mounted) return;
      // Only a failure frees the button: after a success the screen refreshes, never a 2nd send.
      setState(() => _busy = false);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        // The draft stays; it is sent again while the screen is open.
        setState(() => _offline = true);
        _retry ??= Timer.periodic(_retryEvery, (_) => unawaited(_send()));
        return;
      }
      SoeToast.show(context,
          message: tutorFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final session = widget.detail.session;
    final last = _step == _steps - 1;
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(
              [TutorFormat.dayLong(context, session.date), session.subject]
                  .whereType<String>()
                  .join(' · ')
                  .toUpperCase(),
              style:
                  AppTypography.overline.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 4),
          Text(
              tr.heading(
                  pupil: [session.pupil, session.schoolClass]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(', ')),
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          if (widget.detail.reportDueAt != null)
            Text(
                tr.dueBefore(
                    date: TutorFormat.dateTime(
                        context, widget.detail.reportDueAt!)),
                style: AppTypography.body.copyWith(color: AppPalette.text2)),
          if (_offline) ...[
            const SizedBox(height: 12),
            SoeAlert(
                tone: SoeAlertTone.warning,
                title: tr.offlineTitle,
                body: tr.offlineBody),
            Align(
              alignment: Alignment.centerLeft,
              child: SoeButton(
                label: tr.retryNow,
                variant: SoeButtonVariant.tertiary,
                size: SoeButtonSize.sm,
                onPressed: _busy ? null : () => unawaited(_send()),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _timesCard(tr),
          const SizedBox(height: 16),
          Text(tr.questionOf(step: _step + 1, total: _steps),
              style: AppTypography.labelSm),
          const SizedBox(height: 6),
          Row(children: [
            for (var i = 0; i < _steps; i++)
              Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == _steps - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i < _step
                        ? AppPalette.teal300
                        : (i == _step ? AppPalette.teal800 : AppPalette.n300),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          ..._question(tr),
        ]),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(tr.remaining(step: _step + 1, total: _steps),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 8),
            Row(children: [
              if (_step > 0) ...[
                SoeButton(
                  label: tr.back,
                  variant: SoeButtonVariant.tertiary,
                  onPressed: _busy ? null : () => _go(_step - 1),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
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
                        fullWidth: true,
                        onPressed: _canContinue ? () => _go(_step + 1) : null,
                      ),
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _timesCard(TranslationsTutorSpaceReportFr tr) {
    final detail = widget.detail;
    final session = detail.session;
    final start = detail.checkedInAt ?? session.startsAt;
    final end = detail.checkedOutAt ?? session.endsAt;
    final corrected = _correctedStart != null && _correctedEnd != null;
    int minutes(String clock) {
      final parts = clock.split(':');
      return int.parse(parts.first) * 60 + int.parse(parts.last);
    }

    final length = corrected
        ? minutes(_correctedEnd!) - minutes(_correctedStart!)
        : (end?.difference(start).inMinutes);
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(tr.timesOverline.toUpperCase(),
                style:
                    AppTypography.overline.copyWith(color: AppPalette.teal800)),
          ),
          if (corrected)
            SoeBadge(label: tr.corrected, tone: SoeBadgeTone.warning),
        ]),
        const SizedBox(height: 2),
        Text(tr.timesTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(tr.timesHint,
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
        TutorInfoRow(
            label: tr.arrival,
            value: corrected
                ? '${TutorFormat.time(start)} → $_correctedStart'
                : TutorFormat.time(start)),
        TutorInfoRow(
            label: tr.departure,
            value: corrected
                ? '${end == null ? '—' : TutorFormat.time(end)} → $_correctedEnd'
                : (end == null ? '—' : TutorFormat.time(end))),
        TutorInfoRow(
            label: tr.duration,
            last: true,
            value: length == null || length <= 0
                ? '—'
                : TutorFormat.duration(context, length)),
        if (corrected && _correctionReason != null)
          Text('« $_correctionReason »',
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          SoeButton(
            label: tr.correct,
            variant: SoeButtonVariant.tertiary,
            size: SoeButtonSize.md,
            onPressed: _busy ? null : () => unawaited(_correct()),
          ),
          if (corrected)
            SoeButton(
              label: tr.removeCorrection,
              variant: SoeButtonVariant.tertiary,
              size: SoeButtonSize.md,
              onPressed: _busy
                  ? null
                  : () => _update(() {
                        _correctedStart = null;
                        _correctedEnd = null;
                        _correctionReason = null;
                      }),
            ),
        ]),
      ]),
    );
  }

  List<Widget> _question(TranslationsTutorSpaceReportFr tr) {
    Widget title(String text, [String? hint]) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint,
                style: AppTypography.body.copyWith(color: AppPalette.text2)),
          ],
          const SizedBox(height: 12),
        ]);
    return switch (_step) {
      0 => [
          title(tr.topicsTitle, tr.topicsHint),
          SoeCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    onDeleted: () => _update(() =>
                        _topics = _topics.where((t) => t != topic).toList()),
                  ),
              ]),
              if (_topics.isEmpty)
                Text(tr.topicsMissing,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
            ]),
          ),
        ],
      1 => [
          title(tr.homeworkTitle, tr.homeworkHint),
          SoeTextField(controller: _homework, maxLines: 4, maxLength: 300),
        ],
      2 => [
          title(tr.scalesTitle),
          _scale(
              tr.behavior,
              {
                'to_improve': tr.toImprove,
                'fair': tr.fair,
                'very_good': tr.veryGood
              },
              _behavior,
              (value) => _update(() => _behavior = value)),
          _scale(
              tr.progress,
              {'to_watch': tr.toWatch, 'steady': tr.steady, 'clear': tr.clear},
              _progress,
              (value) => _update(() => _progress = value)),
        ],
      3 => [
          title(tr.messageTitle, tr.messageHint),
          SoeTextField(controller: _message, maxLines: 5, maxLength: 900),
        ],
      _ => [
          title(tr.signatureTitle, tr.signatureHint),
          SoeSignaturePad(
              controller: _signature,
              clearLabel: tr.clearSignature,
              height: _padHeight),
        ],
    };
  }

  Widget _scale(String label, Map<String, String> values, String? selected,
          ValueChanged<String?> onSelect) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ]),
      );
}

typedef _Correction = ({String start, String end, String reason});

/// « Corriger les horaires »: the corrected arrival and departure and a reason (required).
class _CorrectionSheet extends StatefulWidget {
  const _CorrectionSheet(
      {required this.start, required this.end, required this.reason});

  final String start;
  final String end;
  final String reason;

  @override
  State<_CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends State<_CorrectionSheet> {
  static const int _reasonMax = 200;
  late final _reason = TextEditingController(text: widget.reason);
  late String _start = widget.start;
  late String _end = widget.end;

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  static int _minutes(String clock) {
    final parts = clock.split(':');
    return int.parse(parts.first) * 60 + int.parse(parts.last);
  }

  static String _clock(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pick({required bool start}) async {
    final value = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _minutes(value) ~/ 60, minute: _minutes(value) % 60),
    );
    if (picked == null || !mounted) return;
    setState(() => start ? _start = _clock(picked) : _end = _clock(picked));
  }

  Widget _time(String label, String value, VoidCallback onTap) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppPalette.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppPalette.n300),
            ),
            child: Text(value, style: AppTypography.body),
          ),
        ),
        const SizedBox(height: 14),
      ]);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.report;
    final timesValid = _minutes(_end) > _minutes(_start);
    final reason = _reason.text.trim();
    return TutorSheet(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.correct,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 4),
            Text(tr.correctHint,
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
      _time(tr.correctedArrival, _start, () => unawaited(_pick(start: true))),
      _time(tr.correctedDeparture, _end, () => unawaited(_pick(start: false))),
      if (!timesValid) ...[
        Text(tr.timesInvalid,
            style:
                AppTypography.caption.copyWith(color: AppPalette.dangerText)),
        const SizedBox(height: 10),
      ],
      SoeTextField(
        controller: _reason,
        label: tr.reasonRequired,
        hint: tr.reasonPlaceholder,
        maxLines: 3,
        maxLength: _reasonMax,
        errorText: reason.isEmpty ? tr.reasonMissing : null,
      ),
      const SizedBox(height: 12),
      SoeButton(
        label: tr.saveCorrection,
        variant: SoeButtonVariant.secondary,
        fullWidth: true,
        onPressed: reason.isEmpty || !timesValid
            ? null
            : () => Navigator.of(context)
                .pop<_Correction>((start: _start, end: _end, reason: reason)),
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
