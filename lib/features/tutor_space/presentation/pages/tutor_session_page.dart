import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_location.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-17 — a session: « J'arrive » by GPS (out of zone: a clear message and « Réessayer »; no
/// GPS or network: the parent's 4-digit backup code), « Je pars », the address and the parent
/// once the contract is signed, the session and its pay, « Reporter » (move it in the month),
/// « Signaler un problème » to SOE.
class TutorSessionPage extends ConsumerStatefulWidget {
  const TutorSessionPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TutorSessionPage> createState() => _TutorSessionPageState();
}

class _TutorSessionPageState extends ConsumerState<TutorSessionPage> {
  final _code = TextEditingController();
  bool _locating = false;
  bool _busy = false;

  /// The server's « too far » message after a GPS check-in.
  String? _tooFar;

  /// The backup code panel is open, with why (null: the generic GPS / network text).
  bool _codeMode = false;
  String? _codeNotice;
  TutorLocationIssue? _settings;
  String? _codeError;
  bool _codeLocked = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _toast(String message, {SoeToastTone tone = SoeToastTone.success}) =>
      SoeToast.show(context, message: message, tone: tone);

  void _openCode({String? notice, TutorLocationIssue? settings}) =>
      setState(() {
        _codeMode = true;
        _codeNotice = notice;
        _settings = settings;
        _tooFar = null;
      });

  void _checkedIn() {
    setState(() {
      _codeMode = false;
      _tooFar = null;
      _code.clear();
    });
    refreshTutorSession(ref, widget.sessionId);
    _toast(Translations.of(context).tutorSpace.session.check.checkedIn);
  }

  Future<void> _arrive() async {
    final tr = Translations.of(context).tutorSpace.session.check;
    setState(() {
      _locating = true;
      _tooFar = null;
    });
    final located = await tutorLocate();
    final position = located.position;
    if (!mounted) return;
    if (position == null) {
      setState(() => _locating = false);
      final issue = located.issue ?? TutorLocationIssue.notFound;
      _openCode(
          notice: switch (issue) {
            TutorLocationIssue.off => tr.locationOff,
            TutorLocationIssue.denied => tr.locationDenied,
            TutorLocationIssue.deniedForever => tr.locationDenied,
            TutorLocationIssue.approximate => tr.locationApproximate,
            TutorLocationIssue.notFound => tr.noPosition,
          },
          settings: issue == TutorLocationIssue.notFound ? null : issue);
      return;
    }
    try {
      await ref
          .read(tutorApiProvider)
          .checkIn(widget.sessionId, position: position);
      if (mounted) _checkedIn();
    } on Failure catch (failure) {
      if (!mounted) return;
      final message = tutorFailureMessage(context, failure);
      if (failure is ValidationFailure &&
          failure.errors.containsKey('latitude')) {
        // Too far (or no position for the server): a clear message, retry or the code.
        setState(() => _tooFar = message);
      } else if (failure is NetworkFailure || failure is TimeoutFailure) {
        _openCode();
      } else {
        _toast(message, tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submitCode() async {
    setState(() {
      _busy = true;
      _codeError = null;
    });
    try {
      await ref
          .read(tutorApiProvider)
          .checkIn(widget.sessionId, code: _code.text.trim());
      if (mounted) _checkedIn();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _codeError = tutorFailureMessage(context, failure);
        _codeLocked =
            failure is CodeFailure && failure.problem == CodeProblem.locked;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    final tr = Translations.of(context).tutorSpace.session.check;
    setState(() => _busy = true);
    try {
      final position = await tutorCurrentPosition();
      await ref
          .read(tutorApiProvider)
          .checkOut(widget.sessionId, position: position);
      if (!mounted) return;
      refreshTutorSession(ref, widget.sessionId);
      _toast(tr.checkedOut);
    } on Failure catch (failure) {
      if (mounted) {
        _toast(tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _move(TutorSessionDetail detail) async {
    final moved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TutorMoveSheet(detail: detail),
    );
    if (moved != true || !mounted) return;
    refreshTutorSession(ref, widget.sessionId);
    _toast(Translations.of(context).tutorSpace.session.move.moved);
  }

  Future<void> _reportProblem() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProblemSheet(sessionId: widget.sessionId),
    );
    if (sent == true && mounted) {
      _toast(Translations.of(context).tutorSpace.session.problem.sent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.session;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: TutorAsyncBody<TutorSessionDetail>(
        value: ref.watch(tutorSessionProvider(widget.sessionId)),
        onRetry: () => ref.invalidate(tutorSessionProvider(widget.sessionId)),
        builder: (detail) {
          final session = detail.session;
          final pupil = [session.pupil, session.schoolClass]
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .join(', ');
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(tutorSessionProvider(widget.sessionId).future),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(
                  tr
                      .when(
                          date: TutorFormat.dayLong(context, session.date),
                          hours: TutorFormat.hours(session))
                      .toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                      [session.subject, pupil]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style:
                          AppTypography.h1.copyWith(color: AppPalette.teal800)),
                ),
                const SizedBox(width: 8),
                TutorStateBadge(
                    state: session.state, label: session.stateLabel),
              ]),
              if (_tooFar != null) ...[
                const SizedBox(height: 16),
                SoeAlert(
                    tone: SoeAlertTone.danger,
                    title: tr.check.tooFarTitle,
                    body: _tooFar!),
              ],
              const SizedBox(height: 16),
              if (_codeMode && detail.checkedInAt == null)
                ..._codePanel()
              else
                _checkCard(detail),
              const SizedBox(height: 12),
              _addressCard(detail),
              const SizedBox(height: 12),
              _sessionCard(detail),
              const SizedBox(height: 12),
              _problemCard(),
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }

  List<Widget> _codePanel() {
    final tr = Translations.of(context).tutorSpace.session.check;
    return [
      SoeAlert(
          tone: SoeAlertTone.warning,
          title: tr.gpsTitle,
          body: _codeNotice ?? tr.gpsBody),
      if (_settings != null)
        Align(
          alignment: Alignment.centerLeft,
          child: SoeButton(
            label: tr.openSettings,
            variant: SoeButtonVariant.tertiary,
            size: SoeButtonSize.sm,
            onPressed: () => unawaited(tutorOpenLocationSettings(_settings!)),
          ),
        ),
      const SizedBox(height: 12),
      SoeCard(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr.codeTitle,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 12),
          SoeTextField(
            controller: _code,
            label: tr.code,
            enabled: !_codeLocked,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _codeError,
          ),
          const SizedBox(height: 4),
          Text(tr.codeHint,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: _code,
            builder: (context, _) => Align(
              alignment: Alignment.centerLeft,
              child: SoeButton(
                label: tr.validate,
                size: SoeButtonSize.md,
                loading: _busy,
                onPressed: _busy || _codeLocked || _code.text.trim().length != 4
                    ? null
                    : () => unawaited(_submitCode()),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.arrive,
              variant: SoeButtonVariant.tertiary,
              size: SoeButtonSize.sm,
              onPressed: _locating ? null : () => unawaited(_arrive()),
            ),
          ),
        ]),
      ),
    ];
  }

  Widget _checkCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session;
    final session = detail.session;
    ref.watch(tutorClockProvider);
    final now = DateTime.now();
    final open = !now.isBefore(detail.checkInOpensAt);
    final checkedIn = detail.checkedInAt;
    final children = <Widget>[];
    if (checkedIn == null && session.state == 'planned' && !session.closed) {
      children.addAll([
        Text(
            open
                ? tr.check.hint
                : tr.check.opens(
                    date: TutorFormat.dateTime(context, detail.checkInOpensAt)),
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: SoeButton(
            label: _tooFar != null ? tr.check.retry : tr.check.arrive,
            size: SoeButtonSize.md,
            loading: _locating,
            loadingLabel: tr.check.locating,
            onPressed: !open || _locating ? null : () => unawaited(_arrive()),
          ),
        ),
        if (open)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _locating ? null : _openCode,
              child: Text(tr.check.useCode),
            ),
          ),
      ]);
    } else if (checkedIn != null) {
      final method = detail.checkInMethod == 'code'
          ? tr.check.methodCode
          : tr.check.methodGps;
      children.addAll([
        Text(TutorFormat.time(checkedIn),
            style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
        Text(tr.check.arrivedCaption(method: method),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 10),
        if (detail.checkedOutAt == null) ...[
          Text(
              tr.check
                  .leaveHint(time: TutorFormat.time(detail.reportAvailableAt)),
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.check.leave,
              size: SoeButtonSize.md,
              loading: _busy,
              onPressed: _busy ? null : () => unawaited(_leave()),
            ),
          ),
        ] else
          Text(tr.check.left(time: TutorFormat.time(detail.checkedOutAt!)),
              style: AppTypography.body),
      ]);
    } else {
      children.add(Text(_stateText(tr.check.states, session.state),
          style: AppTypography.body.copyWith(color: AppPalette.text2)));
    }
    children.addAll(_reportPart(detail));
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(tr.check.title,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
          if (checkedIn != null)
            SoeBadge(label: tr.check.verified, tone: SoeBadgeTone.success),
        ]),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }

  String _stateText(
          TranslationsTutorSpaceSessionCheckStatesFr tr, String state) =>
      switch (state) {
        'to_report' => tr.toReport,
        'report_sent' => tr.reportSent,
        'approved' => tr.approved,
        'disputed' => tr.disputed,
        'suspended' => tr.suspended,
        'cancelled' => tr.cancelled,
        _ => tr.planned,
      };

  /// The report: due date and « Rédiger le PV » once checked out (or checked in and open),
  /// « Voir le PV » once sent.
  List<Widget> _reportPart(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session.report;
    final session = detail.session;
    final available = !DateTime.now().isBefore(detail.reportAvailableAt);
    final canWrite = detail.checkedInAt != null &&
        !session.hasReport &&
        (detail.checkedOutAt != null || available);
    if (!session.hasReport && !canWrite) return const [];
    return [
      const SizedBox(height: 14),
      if (canWrite && detail.reportDueAt != null) ...[
        Text(tr.dueOn(date: TutorFormat.dateTime(context, detail.reportDueAt!)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
      ],
      if (canWrite && !available) ...[
        Text(
            tr.opensOn(
                date: TutorFormat.dateTime(context, detail.reportAvailableAt)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
      ],
      Align(
        alignment: Alignment.centerLeft,
        child: SoeButton(
          label: session.hasReport ? tr.see : tr.write,
          size: SoeButtonSize.md,
          variant: session.hasReport
              ? SoeButtonVariant.outline
              : SoeButtonVariant.primary,
          onPressed: () => context.push(TutorSpaceRoutes.report(session.id)),
        ),
      ),
    ];
  }

  Widget _addressCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session;
    final address = detail.hasContact
        ? [detail.address, detail.neighborhood].whereType<String>().join(', ')
        : (detail.neighborhood ?? '—');
    final parent =
        [detail.parentName, detail.parentPhone].whereType<String>().join(' · ');
    final rows = <(String, String)>[
      (detail.hasContact ? tr.address : tr.neighborhood, address),
      if (detail.landmark != null) (tr.landmark, detail.landmark!),
      if (parent.isNotEmpty) (tr.parent, parent),
    ];
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.addressTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        for (var i = 0; i < rows.length; i++)
          TutorInfoRow(
              label: rows[i].$1, value: rows[i].$2, last: i == rows.length - 1),
        const SizedBox(height: 12),
        if (detail.hasContact)
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (detail.address != null)
              SoeButton(
                label: tr.directions,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.outline,
                onPressed: () => unawaited(tutorDirections(address)),
              ),
            if (detail.parentPhone != null)
              SoeButton(
                label: tr.call,
                size: SoeButtonSize.md,
                variant: SoeButtonVariant.tertiary,
                onPressed: () => unawaited(tutorCall(detail.parentPhone!)),
              ),
          ])
        else
          Text(tr.contactAfterContract,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }

  Widget _sessionCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session;
    final session = detail.session;
    final rows = <(String, String)>[
      (tr.time, TutorFormat.hours(session)),
      (
        tr.pupil,
        [session.pupil, session.schoolClass]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join(' · ')
      ),
      if (session.subject != null) (tr.subject, session.subject!),
      if (detail.rate != null)
        (
          tr.pay,
          tr.ifApproved(amount: TutorFormat.amount(context, detail.rate!))
        ),
    ];
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.sessionTitle,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 4),
        for (var i = 0; i < rows.length; i++)
          TutorInfoRow(
              label: rows[i].$1, value: rows[i].$2, last: i == rows.length - 1),
        if (detail.canMove) ...[
          const SizedBox(height: 12),
          SoeButton(
            label: tr.move.open,
            size: SoeButtonSize.md,
            variant: SoeButtonVariant.outline,
            onPressed: () => unawaited(_move(detail)),
          ),
        ],
      ]),
    );
  }

  Widget _problemCard() {
    final tr = Translations.of(context).tutorSpace.session.problem;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppPalette.surfaceSoft,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.title,
            style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 6),
        Text(tr.hint,
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        SoeButton(
          label: tr.open,
          variant: SoeButtonVariant.tertiary,
          size: SoeButtonSize.md,
          onPressed: () => unawaited(_reportProblem()),
        ),
      ]),
    );
  }
}

/// « Reporter la séance »: a new date in the same month, a new start, the length kept, a word
/// for the family. Pops `true` once moved; a refusal shows the server's message under its field.
class TutorMoveSheet extends ConsumerStatefulWidget {
  const TutorMoveSheet({super.key, required this.detail});

  final TutorSessionDetail detail;

  @override
  ConsumerState<TutorMoveSheet> createState() => _TutorMoveSheetState();
}

class _TutorMoveSheetState extends ConsumerState<TutorMoveSheet> {
  static const int _commentMax = 500;
  final _comment = TextEditingController();
  late DateTime _date = widget.detail.session.date;
  late TimeOfDay _start =
      TimeOfDay.fromDateTime(widget.detail.session.startsAt);
  String? _dateError;
  String? _startError;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String get _clock =>
      '${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final current = widget.detail.session.date;
    final today = DateTime.now();
    final monthStart = DateTime(current.year, current.month);
    final first = today.isAfter(monthStart)
        ? DateTime(today.year, today.month, today.day)
        : monthStart;
    final last = DateTime(current.year, current.month + 1, 0);
    if (first.isAfter(last)) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(first) || _date.isAfter(last) ? first : _date,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null && mounted) {
      setState(() {
        _start = picked;
        _startError = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _dateError = null;
      _startError = null;
      _error = null;
    });
    try {
      await ref.read(tutorApiProvider).moveSession(widget.detail.session.id,
          date: _date, startAt: _clock, comment: _comment.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (failure) {
      if (!mounted) return;
      final message = tutorFailureMessage(context, failure);
      setState(() {
        if (failure is ValidationFailure &&
            failure.errors.containsKey('start_at')) {
          _startError = failure.errors['start_at']!.first;
        } else if (failure is ValidationFailure &&
            failure.errors.containsKey('date')) {
          _dateError = failure.errors['date']!.first;
        } else {
          _error = message;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _picker(String label, String value, String? error, VoidCallback onTap,
          IconData icon) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        InkWell(
          onTap: _busy ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppPalette.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: error == null ? AppPalette.n300 : AppPalette.danger),
            ),
            child: Row(children: [
              Icon(icon, size: 18, color: AppPalette.text2),
              const SizedBox(width: 10),
              Expanded(child: Text(value, style: AppTypography.body)),
            ]),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error,
              style:
                  AppTypography.caption.copyWith(color: AppPalette.dangerText)),
        ],
        const SizedBox(height: 14),
      ]);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.session.move;
    final minutes = widget.detail.minutes;
    return TutorSheet(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr.title,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 4),
            Text(tr.hint,
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
      _picker(tr.date, TutorFormat.dayLong(context, _date), _dateError,
          () => unawaited(_pickDate()), Icons.calendar_today_outlined),
      _picker(tr.startAt, _clock, _startError, () => unawaited(_pickTime()),
          Icons.schedule),
      if (minutes != null) ...[
        Text(tr.length(duration: TutorFormat.duration(context, minutes)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 14),
      ],
      SoeTextField(
        controller: _comment,
        label: tr.comment,
        hint: tr.commentHint,
        maxLines: 3,
        maxLength: _commentMax,
      ),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!,
            style: AppTypography.bodySm.copyWith(color: AppPalette.dangerText)),
      ],
      const SizedBox(height: 12),
      SoeButton(
        label: tr.submit,
        variant: SoeButtonVariant.secondary,
        fullWidth: true,
        loading: _busy,
        onPressed: _busy ? null : () => unawaited(_submit()),
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

/// The report types a tutor may send about a family (the API's enum).
const tutorProblemTypes = [
  'student_absence',
  'parent_not_home',
  'inappropriate_behavior_parent',
  'unsafe_environment',
  'harassment',
  'boundaries_violation',
  'unsuitable_workspace',
  'constant_interruptions',
  'lack_of_materials',
  'poor_communication_parent',
  'last_minute_changes',
  'scheduling_issues',
  'lack_of_involvement',
  'unrealistic_expectations',
  'other',
];

String _problemLabel(
        TranslationsTutorSpaceProblemTypesShortFr tr, String type) =>
    switch (type) {
      'student_absence' => tr.studentAbsence,
      'parent_not_home' => tr.parentNotHome,
      'unsafe_environment' => tr.unsafeEnvironment,
      'inappropriate_behavior_parent' => tr.inappropriateBehaviorParent,
      'harassment' => tr.harassment,
      'boundaries_violation' => tr.boundariesViolation,
      'unsuitable_workspace' => tr.unsuitableWorkspace,
      'constant_interruptions' => tr.constantInterruptions,
      'lack_of_materials' => tr.lackOfMaterials,
      'poor_communication_parent' => tr.poorCommunicationParent,
      'last_minute_changes' => tr.lastMinuteChanges,
      'scheduling_issues' => tr.schedulingIssues,
      'lack_of_involvement' => tr.lackOfInvolvement,
      'unrealistic_expectations' => tr.unrealisticExpectations,
      _ => tr.other,
    };

/// « Signaler un problème »: a subject and a message, sent to SOE. Pops `true` once sent.
class _ProblemSheet extends ConsumerStatefulWidget {
  const _ProblemSheet({required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<_ProblemSheet> createState() => _ProblemSheetState();
}

class _ProblemSheetState extends ConsumerState<_ProblemSheet> {
  static const int _descriptionMax = 500;
  final _description = TextEditingController();
  String? _type;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(tutorApiProvider).reportProblem(widget.sessionId,
          type: _type!, description: _description.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (failure) {
      if (mounted) {
        setState(() => _error = tutorFailureMessage(context, failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: TutorSheet(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.session.problem.open,
                  style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 4),
              Text(tr.session.problem.sheetHint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ]),
          ),
          IconButton(
            tooltip: tr.session.problem.cancel,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ]),
        const SizedBox(height: 16),
        Text(tr.session.problem.type, style: AppTypography.label),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final type in tutorProblemTypes)
            SoeChip(
              label: _problemLabel(tr.problemTypes.short, type),
              selected: _type == type,
              onTap: () => setState(() => _type = type),
            ),
        ]),
        const SizedBox(height: 16),
        SoeTextField(
          controller: _description,
          label: tr.session.problem.description,
          hint: tr.session.problem.placeholder,
          maxLines: 4,
          maxLength: _descriptionMax,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style:
                  AppTypography.bodySm.copyWith(color: AppPalette.dangerText)),
        ],
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: _description,
          builder: (context, _) => SoeButton(
            label: tr.session.problem.send,
            variant: SoeButtonVariant.secondary,
            fullWidth: true,
            loading: _busy,
            onPressed:
                _busy || _type == null || _description.text.trim().isEmpty
                    ? null
                    : () => unawaited(_send()),
          ),
        ),
        const SizedBox(height: 4),
        SoeButton(
          label: tr.session.problem.cancel,
          variant: SoeButtonVariant.tertiary,
          fullWidth: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ]),
    );
  }
}
