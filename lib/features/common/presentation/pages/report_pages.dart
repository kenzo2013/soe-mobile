import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// The largest photo the API takes (5 MB).
const int _maxPhotoBytes = 5 * 1024 * 1024;

/// Picks a photo for a report (replaced in tests).
final reportPhotoPickerProvider =
    Provider<Future<File?> Function()>((ref) => () async {
          final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
              maxWidth: 2000,
              maxHeight: 2000);
          return picked == null ? null : File(picked.path);
        });

SoeBadgeTone _statusTone(String status) => switch (status) {
      'resolved' => SoeBadgeTone.success,
      'dismissed' => SoeBadgeTone.neutral,
      _ => SoeBadgeTone.info,
    };

/// COM-09 — report a problem to SOE (never to the other party): the emergency way first, the
/// session (prefilled when opened from it), a reason of the active role, a description and up
/// to the photos the API allows.
class ReportProblemPage extends ConsumerStatefulWidget {
  const ReportProblemPage({super.key, this.sessionId, this.serious = false});

  /// The session the screen was opened from, if any.
  final int? sessionId;

  /// Opened by « Signaler une urgence » (COM-10): the serious reason is chosen.
  final bool serious;

  @override
  ConsumerState<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends ConsumerState<ReportProblemPage> {
  final _description = TextEditingController();
  late int? _sessionId = widget.sessionId;
  String? _reason;
  late bool _serious = widget.serious;
  final List<File> _photos = [];
  bool _sending = false;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _description.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final file = await ref.read(reportPhotoPickerProvider)();
    if (file == null || !mounted) return;
    if (await file.length() > _maxPhotoBytes) {
      if (!mounted) return;
      SoeToast.show(context,
          message: Translations.of(context).accountSpace.report.photoTooBig,
          tone: SoeToastTone.danger);
      return;
    }
    setState(() => _photos.add(file));
  }

  Future<void> _send() async {
    final tr = Translations.of(context).accountSpace.report;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final report = await ref.read(accountApiProvider).createReport(
            sessionId: _sessionId!,
            description: _description.text.trim(),
            reportType: _reason,
            serious: _serious,
            photos: _photos,
          );
      ref.invalidate(reportsProvider);
      if (!mounted) return;
      SoeToast.show(context, message: tr.sent);
      context.pushReplacement(RouteNames.reportDetail(report.id));
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = failure;
      });
      SoeToast.show(context,
          message: accountFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.report;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    final reasons = ref.watch(reportReasonsProvider);
    final sessions = ref.watch(reportSessionsProvider);
    final ready = _sessionId != null &&
        (_serious || _reason != null) &&
        _description.text.trim().isNotEmpty &&
        !_sending;
    return AccountScaffold(
      title: tr.title,
      crumb: tr.crumb,
      bottom: SoeButton(
        label: tr.submit,
        fullWidth: true,
        loading: _sending,
        onPressed: ready ? () => unawaited(_send()) : null,
      ),
      children: [
        AccountPageTitle(
            _serious
                ? (tutor ? tr.seriousTitleTutor : tr.seriousTitleParent)
                : tr.title,
            subtitle: tutor ? tr.introTutor : tr.introParent),
        AccountAsync<ReportReasons>(
          value: reasons,
          onRetry: () => ref.invalidate(reportReasonsProvider),
          builder: (reasons) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Emergency(
                tutor: tutor,
                phone: reasons.emergencyPhone,
                serious: _serious,
                onSerious: () => setState(() {
                  _serious = true;
                  _reason = null;
                }),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SoeButton(
                  label: tr.myReports,
                  variant: SoeButtonVariant.tertiary,
                  size: SoeButtonSize.sm,
                  onPressed: () => unawaited(context.push(RouteNames.reports)),
                ),
              ),
              const SizedBox(height: 8),
              AccountAsync<List<ReportSession>>(
                value: sessions,
                onRetry: () => ref.invalidate(reportSessionsProvider),
                builder: (sessions) => _SessionCard(
                  sessions: sessions,
                  recentDays: reasons.recentDays,
                  selected: _sessionId,
                  onSelected: (id) => setState(() => _sessionId = id),
                ),
              ),
              AccountCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountFieldLabel(tr.reason),
                      if (_serious)
                        _Choice(
                          label: reasons.seriousReason.label,
                          selected: true,
                          onTap: () => setState(() => _serious = false),
                        )
                      else
                        for (final reason in reasons.reasons)
                          _Choice(
                            label: reason.label,
                            selected: _reason == reason.key,
                            onTap: () => setState(() => _reason = reason.key),
                          ),
                      AccountFieldLabel(tr.description),
                      SoeTextField(
                        controller: _description,
                        maxLines: 5,
                        maxLength: reasons.descriptionMax,
                        errorText: fieldError(_error, 'description'),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '${_description.text.length} / ${reasons.descriptionMax}',
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      ),
                      AccountFieldLabel(tr.photos,
                          hint: tr.photosHelp(max: reasons.photosMax)),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        for (final photo in _photos)
                          Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(photo,
                                  width: 72, height: 72, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _photos.remove(photo)),
                                child: const CircleAvatar(
                                  radius: 11,
                                  backgroundColor: AppPalette.ink,
                                  child: Icon(Icons.close,
                                      size: 14, color: AppPalette.white),
                                ),
                              ),
                            ),
                          ]),
                      ]),
                      if (_photos.length < reasons.photosMax)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: InkWell(
                            onTap: () => unawaited(_addPhoto()),
                            child: Row(children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundColor: AppPalette.surfaceSoft,
                                child: Icon(Icons.photo_camera_outlined,
                                    color: AppPalette.text2),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tr.addPhoto,
                                          style: AppTypography.label.copyWith(
                                              color: AppPalette.teal500)),
                                      Text(tr.photoFormat,
                                          style: AppTypography.caption.copyWith(
                                              color: AppPalette.text2)),
                                    ]),
                              ),
                            ]),
                          ),
                        ),
                    ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The emergency way, first on the screen: call SOE, or the serious reason.
class _Emergency extends StatelessWidget {
  const _Emergency({
    required this.tutor,
    required this.phone,
    required this.serious,
    required this.onSerious,
  });

  final bool tutor;
  final String phone;
  final bool serious;
  final VoidCallback onSerious;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.report;
    return AccountCard(
      color: AppPalette.dangerBg,
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.shield_outlined, color: AppPalette.dangerText),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tutor ? tr.emergencyTutor : tr.emergencyParent,
                style: AppTypography.labelSm
                    .copyWith(color: AppPalette.dangerText)),
            const SizedBox(height: 4),
            Text(tr.emergencyText(phone: phone),
                style: AppTypography.bodySm.copyWith(color: AppPalette.text)),
            if (!serious)
              SoeButton(
                label: tutor ? tr.emergencyLinkTutor : tr.emergencyLinkParent,
                variant: SoeButtonVariant.tertiary,
                size: SoeButtonSize.sm,
                onPressed: onSerious,
              ),
          ]),
        ),
      ]),
    );
  }
}

/// The session reported: its context when opened from it, else the recent sessions to choose.
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.sessions,
    required this.recentDays,
    required this.selected,
    required this.onSelected,
  });

  final List<ReportSession> sessions;
  final int recentDays;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.report;
    if (sessions.isEmpty) {
      return AccountCard(
        soft: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AccountCardTitle(tr.choose),
          Text(tr.noSession,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 12),
          SoeButton(
            label: tr.contactSoe,
            variant: SoeButtonVariant.outline,
            size: SoeButtonSize.md,
            onPressed: () => unawaited(context.push(RouteNames.help)),
          ),
        ]),
      );
    }
    final prefilled =
        sessions.where((session) => session.id == selected).firstOrNull;
    return AccountCard(
      soft: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AccountCardTitle(prefilled != null ? tr.context : tr.choose),
        Text(
            prefilled != null
                ? tr.contextHelp
                : tr.chooseHelp(days: recentDays),
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 8),
        for (final session in sessions)
          _Choice(
            label: session.label,
            selected: session.id == selected,
            onTap: () => onSelected(session.id),
          ),
      ]),
    );
  }
}

/// A single-choice tile (reason, session).
class _Choice extends StatelessWidget {
  const _Choice(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? AppPalette.white : AppPalette.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? AppPalette.teal500 : Colors.transparent,
                    width: 1.5),
              ),
              child: Row(children: [
                Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 22,
                    color: selected ? AppPalette.teal500 : AppPalette.text3),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        style: AppTypography.labelSm
                            .copyWith(color: AppPalette.text))),
              ]),
            ),
          ),
        ),
      );
}

/// COM-09 « Mes signalements »: the account's reports and where each stands.
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.report;
    return AccountScaffold(
      title: tr.myReports,
      crumb: tr.crumb,
      onRefresh: () => ref.refresh(reportsProvider.future),
      bottom: SoeButton(
        label: tr.title,
        fullWidth: true,
        onPressed: () => unawaited(context.push(RouteNames.reportNew)),
      ),
      children: [
        AccountPageTitle(tr.myReports),
        AccountAsync<List<ProblemReport>>(
          value: ref.watch(reportsProvider),
          onRetry: () => ref.invalidate(reportsProvider),
          builder: (reports) => reports.isEmpty
              ? SoeEmptyState(
                  icon: Icons.outlined_flag,
                  title: tr.empty,
                  message: tr.emptyMessage)
              : AccountRowsCard(rows: [
                  for (final report in reports)
                    AccountRow(
                      icon: Icons.outlined_flag,
                      title: report.reference,
                      subtitle: [
                        report.typeLabel,
                        if (report.sessionDate != null)
                          AccountFormat.day(context, report.sessionDate!),
                      ].join(' · '),
                      divider: report != reports.last,
                      trailing: SoeBadge(
                          label: report.statusLabel,
                          tone: _statusTone(report.status)),
                      onTap: () => unawaited(
                          context.push(RouteNames.reportDetail(report.id))),
                    ),
                ]),
        ),
      ],
    );
  }
}

/// COM-09 « Suivi »: received, in progress, resolved; the message sent, SOE's answer, and the
/// reminder that the other party never sees it.
class ReportDetailPage extends ConsumerWidget {
  const ReportDetailPage({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.report;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    return AccountScaffold(
      title: tr.title,
      crumb: tr.crumb,
      onRefresh: () => ref.refresh(reportProvider(reportId).future),
      children: [
        AccountAsync<ProblemReport>(
          value: ref.watch(reportProvider(reportId)),
          onRetry: () => ref.invalidate(reportProvider(reportId)),
          builder: (report) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AccountPageTitle(
              tr.reference(reference: report.reference),
              overline: [
                report.typeLabel,
                if (report.sessionDate != null)
                  tr.sessionOf(
                      date: AccountFormat.day(context, report.sessionDate!)),
              ].join(' · '),
            ),
            SoeBadge(
                label: report.statusLabel, tone: _statusTone(report.status)),
            const SizedBox(height: 16),
            AccountCard(
              soft: true,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccountCardTitle(tr.followUp),
                    for (final (index, step) in report.steps.reversed.indexed)
                      _Step(step: step, last: index == report.steps.length - 1),
                  ]),
            ),
            if ((report.description ?? '').isNotEmpty)
              AccountCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountCardTitle(tr.yourMessage),
                      Text(report.description!,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.text)),
                      if (report.photosCount > 0) ...[
                        const SizedBox(height: 8),
                        Text(tr.photosCount(n: report.photosCount),
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      ],
                    ]),
              ),
            if ((report.answer ?? '').isNotEmpty)
              AccountCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountCardTitle(tr.answer),
                      Text(report.answer!,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.text)),
                    ]),
              ),
            AccountCard(
              soft: true,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccountCardTitle(tr.confidential),
                    Text(tutor ? tr.confidentialTutor : tr.confidentialParent,
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
                  ]),
            ),
          ]),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.last});

  final ReportStep step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.report;
    final color = !step.reached
        ? AppPalette.white
        : step.key == 'in_progress'
            ? AppPalette.gold400
            : AppPalette.teal500;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                  color: step.reached ? color : AppPalette.border, width: 1.5),
            ),
          ),
          if (!last)
            Expanded(child: Container(width: 1.5, color: AppPalette.border)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.label,
                  style: AppTypography.labelSm.copyWith(
                      color:
                          step.reached ? AppPalette.text : AppPalette.text2)),
              Text(
                  step.at != null
                      ? AccountFormat.dateTime(context, step.at!)
                      : tr.toCome,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
        ),
      ]),
    );
  }
}
