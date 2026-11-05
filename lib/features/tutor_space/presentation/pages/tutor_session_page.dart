import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_location.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-17 — a session: when and what, « J'arrive » by GPS (else the parent's code), « Je pars »,
/// the place and the parent once the contract is signed, the pay, the report, a problem.
class TutorSessionPage extends ConsumerStatefulWidget {
  const TutorSessionPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TutorSessionPage> createState() => _TutorSessionPageState();
}

class _TutorSessionPageState extends ConsumerState<TutorSessionPage> {
  bool _locating = false;
  bool _busy = false;

  void _toast(String message, {SoeToastTone tone = SoeToastTone.success}) =>
      SoeToast.show(context, message: message, tone: tone);

  Future<void> _arrive() async {
    final tr = Translations.of(context).tutorSpace.session.check;
    setState(() => _locating = true);
    final position = await tutorCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _locating = false);
      await _askCode(notice: tr.noPosition);
      return;
    }
    String? retryWithCode;
    try {
      await ref
          .read(tutorApiProvider)
          .checkIn(widget.sessionId, position: position);
      if (!mounted) return;
      refreshTutorSession(ref, widget.sessionId);
      _toast(tr.checkedIn);
    } on Failure catch (failure) {
      if (!mounted) return;
      final message = tutorFailureMessage(context, failure);
      // Too far, or no position for the server: the parent's code is the fallback.
      if (failure is ValidationFailure &&
          failure.errors.containsKey('latitude')) {
        retryWithCode = message;
      } else {
        _toast(message, tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
    if (retryWithCode != null && mounted) {
      await _askCode(notice: retryWithCode);
    }
  }

  Future<void> _askCode({String? notice}) async {
    final checkedIn = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CodeSheet(sessionId: widget.sessionId, notice: notice),
    );
    if (checkedIn != true || !mounted) return;
    refreshTutorSession(ref, widget.sessionId);
    _toast(Translations.of(context).tutorSpace.session.check.checkedIn);
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
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(tutorSessionProvider(widget.sessionId).future),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(TutorFormat.dayLong(context, session.date).toUpperCase(),
                  style:
                      AppTypography.overline.copyWith(color: AppPalette.text2)),
              Text(session.title,
                  style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 6),
              Align(
                  alignment: Alignment.centerLeft,
                  child: TutorStateBadge(
                      state: session.state, label: session.stateLabel)),
              const SizedBox(height: 16),
              _checkCard(detail),
              const SizedBox(height: 10),
              _reportCard(detail),
              const SizedBox(height: 10),
              SoeCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TutorField(
                          label: tr.time, value: TutorFormat.hours(session)),
                      TutorField(
                          label: tr.pupil,
                          value: [session.pupil, session.schoolClass]
                              .whereType<String>()
                              .join(' · ')),
                      if (detail.rate != null)
                        TutorField(
                            label: tr.pay,
                            value: tr.ifApproved(
                                amount:
                                    TutorFormat.amount(context, detail.rate!))),
                    ]),
              ),
              const SizedBox(height: 10),
              _placeCard(detail),
              TutorSectionTitle(tr.problem.title),
              Text(tr.problem.hint,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 8),
              SoeButton(
                label: tr.problem.open,
                variant: SoeButtonVariant.dangerOutline,
                size: SoeButtonSize.md,
                fullWidth: true,
                onPressed: () => unawaited(_reportProblem()),
              ),
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }

  Widget _checkCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session.check;
    final session = detail.session;
    final now = DateTime.now();
    final open = !now.isBefore(detail.checkInOpensAt);
    final method =
        detail.checkInMethod == 'code' ? tr.methodCode : tr.methodGps;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(tr.title, style: AppTypography.title),
        const SizedBox(height: 6),
        if (detail.checkedInAt == null) ...[
          if (session.closed)
            Text(session.stateLabel,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2))
          else ...[
            Text(
                open
                    ? tr.hint
                    : tr.opens(
                        date: TutorFormat.dateTime(
                            context, detail.checkInOpensAt)),
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 12),
            SoeButton(
              label: tr.arrive,
              icon: Icons.location_on_outlined,
              fullWidth: true,
              loading: _locating,
              loadingLabel: tr.locating,
              onPressed: !open || _locating ? null : () => unawaited(_arrive()),
            ),
            if (open) ...[
              const SizedBox(height: 4),
              SoeButton(
                label: tr.useCode,
                variant: SoeButtonVariant.tertiary,
                size: SoeButtonSize.md,
                fullWidth: true,
                onPressed: _locating ? null : () => unawaited(_askCode()),
              ),
            ],
          ],
        ] else ...[
          Text(
              tr.arrived(
                  time: TutorFormat.time(detail.checkedInAt!), method: method),
              style: AppTypography.body),
          if (detail.checkedOutAt != null)
            Text(tr.left(time: TutorFormat.time(detail.checkedOutAt!)),
                style: AppTypography.body)
          else ...[
            const SizedBox(height: 12),
            SoeButton(
              label: tr.leave,
              variant: SoeButtonVariant.secondary,
              icon: Icons.logout,
              fullWidth: true,
              loading: _busy,
              onPressed: _busy ? null : () => unawaited(_leave()),
            ),
          ],
        ],
      ]),
    );
  }

  Widget _reportCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session.report;
    final session = detail.session;
    final available = !DateTime.now().isBefore(detail.reportAvailableAt);
    final canWrite = detail.checkedInAt != null && !session.hasReport;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(tr.title, style: AppTypography.title),
        if (canWrite && detail.reportDueAt != null) ...[
          const SizedBox(height: 4),
          Text(
              tr.dueOn(
                  date: TutorFormat.dateTime(context, detail.reportDueAt!)),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
        if (canWrite && !available) ...[
          const SizedBox(height: 4),
          Text(
              tr.opensOn(
                  date:
                      TutorFormat.dateTime(context, detail.reportAvailableAt)),
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
        if (session.hasReport || (canWrite && available)) ...[
          const SizedBox(height: 10),
          SoeButton(
            label: session.hasReport ? tr.see : tr.write,
            size: SoeButtonSize.md,
            variant: session.hasReport
                ? SoeButtonVariant.outline
                : SoeButtonVariant.primary,
            fullWidth: true,
            onPressed: () => context.push(TutorSpaceRoutes.report(session.id)),
          ),
        ],
      ]),
    );
  }

  Widget _placeCard(TutorSessionDetail detail) {
    final tr = Translations.of(context).tutorSpace.session;
    return SoeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.place, style: AppTypography.title),
        if (detail.neighborhood != null)
          TutorField(label: tr.neighborhood, value: detail.neighborhood!),
        if (detail.address != null)
          TutorField(label: tr.address, value: detail.address!),
        if (detail.landmark != null)
          TutorField(label: tr.landmark, value: detail.landmark!),
        if (detail.parentName != null)
          TutorField(label: tr.parent, value: detail.parentName!),
        if (detail.parentPhone != null)
          TutorField(label: tr.phone, value: detail.parentPhone!),
        if (!detail.hasContact) ...[
          const SizedBox(height: 8),
          Text(tr.contactAfterContract,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
      ]),
    );
  }
}

/// The parent's 4-digit code, when the GPS cannot check in. Pops `true` once checked in.
class _CodeSheet extends ConsumerStatefulWidget {
  const _CodeSheet({required this.sessionId, this.notice});

  final int sessionId;
  final String? notice;

  @override
  ConsumerState<_CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends ConsumerState<_CodeSheet> {
  final _code = TextEditingController();
  String? _error;
  bool _locked = false;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(tutorApiProvider)
          .checkIn(widget.sessionId, code: _code.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = tutorFailureMessage(context, failure);
        _locked =
            failure is CodeFailure && failure.problem == CodeProblem.locked;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.session.check;
    return TutorSheet(children: [
      Text(tr.codeTitle, style: AppTypography.title),
      if (widget.notice != null) ...[
        const SizedBox(height: 8),
        SoeAlert(
            tone: SoeAlertTone.warning, title: tr.title, body: widget.notice!),
      ],
      const SizedBox(height: 8),
      Text(tr.codeHint,
          style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 12),
      SoeTextField(
        controller: _code,
        label: tr.code,
        enabled: !_locked,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        errorText: _error,
      ),
      const SizedBox(height: 12),
      ListenableBuilder(
        listenable: _code,
        builder: (context, _) => SoeButton(
          label: tr.validate,
          fullWidth: true,
          loading: _busy,
          onPressed: _busy || _locked || _code.text.trim().length != 4
              ? null
              : () => unawaited(_submit()),
        ),
      ),
    ]);
  }
}

/// The report types a tutor may send about a family (the API's enum).
const tutorProblemTypes = [
  'student_absence',
  'parent_not_home',
  'unsafe_environment',
  'inappropriate_behavior_parent',
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

String _problemLabel(TranslationsTutorSpaceProblemTypesFr tr, String type) =>
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

/// « Signaler un problème »: a type and a description, sent to SOE. Pops `true` once sent.
class _ProblemSheet extends ConsumerStatefulWidget {
  const _ProblemSheet({required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<_ProblemSheet> createState() => _ProblemSheetState();
}

class _ProblemSheetState extends ConsumerState<_ProblemSheet> {
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
      if (mounted)
        setState(() => _error = tutorFailureMessage(context, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: TutorSheet(children: [
        Text(tr.session.problem.open, style: AppTypography.title),
        const SizedBox(height: 12),
        Text(tr.session.problem.type, style: AppTypography.label),
        const SizedBox(height: 4),
        ...tutorProblemTypes.map((type) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_problemLabel(tr.problemTypes, type),
                  style: AppTypography.bodySm),
              trailing: Icon(
                  _type == type
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _type == type ? AppPalette.teal500 : AppPalette.n300),
              onTap: () => setState(() => _type = type),
            )),
        const SizedBox(height: 12),
        SoeTextField(
          controller: _description,
          label: tr.session.problem.description,
          maxLines: 4,
          maxLength: 2000,
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
            fullWidth: true,
            loading: _busy,
            onPressed:
                _busy || _type == null || _description.text.trim().isEmpty
                    ? null
                    : () => unawaited(_send()),
          ),
        ),
      ]),
    );
  }
}
