import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_rating_stars.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_advisor_card.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';

/// Replacement reasons (ReplacementRequest::REASONS), in the prototype's order.
const parentReplacementReasons = [
  'incompatibility',
  'punctuality',
  'level',
  'behaviour',
  'other'
];

String parentReplacementReason(BuildContext context, String reason) {
  final tr = Translations.of(context).parentSpace.replacement;
  return switch (reason) {
    'incompatibility' => tr.incompatibility,
    'punctuality' => tr.punctuality,
    'level' => tr.level,
    'behaviour' => tr.behaviour,
    _ => tr.other,
  };
}

/// PAR-09 — the tutor(s) SOE presents: verified profile, other families' reviews, the
/// decision (sign the contract) or a replacement. The parent never picks the tutor.
class ParentTutorPage extends ConsumerWidget {
  const ParentTutorPage({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.tutor;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: ParentAsyncBody<List<ParentTutorProfile>>(
        value: ref.watch(parentTutorsProvider(requestId)),
        onRetry: () => ref.invalidate(parentTutorsProvider(requestId)),
        builder: (tutors) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (tutors.isEmpty)
              SoeEmptyState(
                  title: tr.title,
                  message: tr.empty,
                  icon: Icons.person_search_outlined),
            for (final tutor in tutors)
              _TutorProfile(requestId: requestId, tutor: tutor),
            const ParentAdvisorCard(),
          ],
        ),
      ),
    );
  }
}

class _TutorProfile extends ConsumerWidget {
  const _TutorProfile({required this.requestId, required this.tutor});

  final int requestId;
  final ParentTutorProfile tutor;

  Future<void> _showChecks(BuildContext context) {
    final tr = Translations.of(context).parentSpace.tutor;
    final checks = {
      'identity': tr.checkIdentity,
      'diplomas': tr.checkDiplomas,
      'interview': tr.checkInterview,
      'test': tr.checkTest,
    };
    return showParentSheet<void>(
      context,
      title: tr.checksTitle,
      builder: (sheet) => Column(children: [
        const SizedBox(height: 12),
        for (final entry in checks.entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
                tutor.checks.contains(entry.key)
                    ? Icons.verified_outlined
                    : Icons.hourglass_empty,
                color: tutor.checks.contains(entry.key)
                    ? AppPalette.successText
                    : AppPalette.text3),
            title: Text(entry.value, style: AppTypography.label),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.tutor;
    final firstName = tutor.name.split(' ').first;
    final children = {for (final slot in tutor.slots) slot.child}.join(', ');
    final detail =
        ref.watch(parentRequestDetailProvider(requestId)).valueOrNull;
    final contractId = detail?.request.contractId;
    final toSign = !tutor.contractSigned &&
        contractId != null &&
        detail?.request.contractStatus == 'sent';
    final reviews = ref.watch(
        parentTutorReviewsProvider((requestId: requestId, tutorId: tutor.id)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ParentHeading(
          title: tr.heading(name: firstName),
          subtitle: children.isEmpty ? null : tr.intro(children: children)),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppPalette.surfaceNav,
            borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppPalette.teal100,
            child: Text(tutor.initials,
                style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          ),
          const SizedBox(height: 14),
          Text(tr.proposedBy.toUpperCase(),
              style:
                  AppTypography.overline.copyWith(color: AppPalette.onDark2)),
          Text(tutor.name,
              style: AppTypography.h1.copyWith(color: AppPalette.onDark)),
          Text(
              [
                tutor.slots.map((slot) => slot.subject).toSet().join(', '),
                children
              ].where((part) => part.isNotEmpty).join(' · '),
              style: AppTypography.bodySm.copyWith(color: AppPalette.onDark2)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            ActionChip(
              avatar: const Icon(Icons.verified_user_outlined, size: 16),
              label: Text(tr.verified),
              onPressed: () => unawaited(_showChecks(context)),
            ),
            Chip(
              avatar: const Icon(Icons.star_border,
                  size: 16, color: AppPalette.gold500),
              label: Text(tutor.rating == null
                  ? tr.newTutor
                  : tr.rating(
                      rating: tutor.rating!.toStringAsFixed(1),
                      count: tutor.reviewsCount)),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      ParentPanel(children: [
        if (tutor.trainings.isNotEmpty) _Block(tr.training, tutor.trainings),
        if (tutor.experiences.isNotEmpty)
          _Block(tr.experience, tutor.experiences),
        if (tutor.subjects.isNotEmpty) _Block(tr.subjects, tutor.subjects),
        if (tutor.availabilities.isNotEmpty)
          _Block(tr.availabilities, [
            for (final day in tutor.availabilities)
              '${day.day} · ${day.ranges.join(', ')}'
          ]),
        if (tutor.presentation != null) ...[
          Text(tr.presentation.toUpperCase(),
              style:
                  AppTypography.overline.copyWith(color: AppPalette.teal700)),
          const SizedBox(height: 4),
          Text('« ${tutor.presentation!} »',
              style: AppTypography.body.copyWith(
                  fontStyle: FontStyle.italic, color: AppPalette.teal800)),
        ],
      ]),
      ParentSectionTitle(tr.reviewsTitle),
      Text(tr.reviewsHint,
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 8),
      ...switch (reviews) {
        AsyncData(:final value) when value.isEmpty => [
            Text(tr.noReviews,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2))
          ],
        AsyncData(:final value) => [
            for (final review in value)
              ParentPanel(soft: true, children: [
                SoeRatingStars(rating: review.rating),
                if (review.comment != null) ...[
                  const SizedBox(height: 6),
                  Text('« ${review.comment!} »', style: AppTypography.bodySm),
                ],
                const SizedBox(height: 6),
                Text(
                    [
                      review.subjects.join(', '),
                      if (review.createdAt != null)
                        DateFormat.yMMM(
                                Localizations.localeOf(context).languageCode)
                            .format(review.createdAt!),
                    ].where((part) => part.isNotEmpty).join(' · '),
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              ]),
          ],
        _ => [const LinearProgressIndicator()],
      },
      const SizedBox(height: 12),
      ParentPanel(title: tr.decisionTitle, children: [
        Text(tr.decisionText,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 12),
        if (toSign)
          SoeButton(
            label: tr.confirm(name: firstName),
            fullWidth: true,
            onPressed: () =>
                unawaited(context.push(ParentSpaceRoutes.contract(contractId))),
          ),
        SoeButton(
          label: tr.replace,
          fullWidth: true,
          variant: SoeButtonVariant.tertiary,
          onPressed: () => unawaited(context.push(
              ParentSpaceRoutes.newReplacement(
                  requestId,
                  slotId:
                      tutor.slots.length == 1 ? tutor.slots.first.id : null))),
        ),
      ]),
    ]);
  }
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.lines);

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(),
              style:
                  AppTypography.overline.copyWith(color: AppPalette.teal700)),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: AppTypography.bodySm),
            ),
        ]),
      );
}

/// PAR-20 — ask for a replacement: fixed reasons and a comment; the advisor calls back
/// with the timing, the parent never picks the replacement. Serious behaviour has its own
/// emergency path (session report).
class ParentReplacementPage extends ConsumerStatefulWidget {
  const ParentReplacementPage(
      {super.key, required this.requestId, this.slotId});

  final int requestId;
  final int? slotId;

  @override
  ConsumerState<ParentReplacementPage> createState() =>
      _ParentReplacementPageState();
}

class _ParentReplacementPageState extends ConsumerState<ParentReplacementPage> {
  final _comment = TextEditingController();
  late int? _slotId = widget.slotId;
  String? _reason;
  bool _reasonMissing = false;
  String? _commentError;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = Translations.of(context).parentSpace.replacement;
    if (_reason == null || _slotId == null) {
      setState(() => _reasonMissing = true);
      return;
    }
    setState(() {
      _busy = true;
      _commentError = null;
    });
    try {
      await ref.read(parentApiProvider).askReplacement(widget.requestId,
          slotId: _slotId!, reason: _reason!, comment: _comment.text.trim());
      if (!mounted) return;
      ref
        ..invalidate(parentRequestDetailProvider(widget.requestId))
        ..invalidate(parentRequestsProvider)
        ..invalidate(parentHomeProvider);
      SoeToast.show(context, message: tr.sent, tone: SoeToastTone.success);
      context.pushReplacement(ParentSpaceRoutes.replacement(widget.requestId));
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() => _commentError = failure.message);
      }
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.replacement;
    final tutors =
        ref.watch(parentTutorsProvider(widget.requestId)).valueOrNull ??
            const <ParentTutorProfile>[];
    final slots = [
      for (final tutor in tutors)
        for (final slot in tutor.slots)
          (
            id: slot.id,
            label: '${slot.subject} · ${slot.child} · ${tutor.name}'
          )
    ];
    final current = slots.where((slot) => slot.id == _slotId).firstOrNull;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(leading: const CloseButton(), title: Text(tr.title)),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ParentHeading(title: tr.heading, subtitle: current?.label),
              const SizedBox(height: 16),
              ParentPanel(children: [
                if (widget.slotId == null && slots.length > 1) ...[
                  ParentFieldLabel(tr.course),
                  ParentChoiceChips<int>(
                    options: [for (final slot in slots) (slot.id, slot.label)],
                    selected: {if (_slotId != null) _slotId!},
                    onToggle: (id) => setState(() => _slotId = id),
                  ),
                ],
                ParentFieldLabel(tr.reason),
                for (final reason in parentReplacementReasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReasonTile(
                      label: parentReplacementReason(context, reason),
                      selected: _reason == reason,
                      onTap: () => setState(() {
                        _reason = reason;
                        _reasonMissing = false;
                        _slotId ??= slots.length == 1 ? slots.first.id : null;
                      }),
                    ),
                  ),
                if (_reasonMissing) ParentErrorText(tr.reasonMissing),
                ParentFieldLabel(tr.comment, optional: true),
                ParentCountedField(
                    controller: _comment, errorText: _commentError),
              ]),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppPalette.dangerBg,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.shield_outlined,
                            color: AppPalette.dangerText, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(tr.seriousTitle,
                                style: AppTypography.labelSm
                                    .copyWith(color: AppPalette.dangerText))),
                      ]),
                      const SizedBox(height: 4),
                      Text(tr.seriousText, style: AppTypography.bodySm),
                      TextButton(
                        // The report is made from the session concerned (PAR-13).
                        onPressed: () => context.go(RouteNames.parentPlanning),
                        child: Text(tr.seriousAction),
                      ),
                    ]),
              ),
              ParentPanel(soft: true, title: tr.nextTitle, children: [
                ParentArrowList([tr.next1, tr.next2, tr.next3]),
              ]),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SoeButton(
              label: tr.submit,
              fullWidth: true,
              loading: _busy,
              onPressed: _busy ? null : () => unawaited(_submit()),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: selected ? AppPalette.white : AppPalette.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? AppPalette.teal700 : Colors.transparent,
                  width: 1.5),
            ),
            child: Row(children: [
              Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppPalette.teal700 : AppPalette.n500),
              const SizedBox(width: 12),
              Text(label, style: AppTypography.labelSm),
            ]),
          ),
        ),
      );
}

/// PAR-20 « Suivi » — where the replacement stands, from the request's history.
class ParentReplacementFollowUpPage extends ConsumerWidget {
  const ParentReplacementFollowUpPage({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final tutors = ref.watch(parentTutorsProvider(requestId)).valueOrNull;
    final name = tutors == null || tutors.isEmpty ? '' : tutors.first.name;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.replacement.title)),
      body: ParentAsyncBody<ParentRequestDetail>(
        value: ref.watch(parentRequestDetailProvider(requestId)),
        onRetry: () => ref.invalidate(parentRequestDetailProvider(requestId)),
        builder: (detail) {
          final events = detail.replacementEvents.reversed.toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ParentHeading(
                overline: detail.request.reference,
                title: tr.replacement.followTitle(name: name),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: SoeBadge(
                    label: tr.replacement.inProgress, tone: SoeBadgeTone.info),
              ),
              const SizedBox(height: 8),
              Text(tr.replacement.followText,
                  style: AppTypography.body.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 16),
              ParentPanel(soft: true, title: tr.replacement.follow, children: [
                if (events.isEmpty)
                  Text(tr.replacement.noneYet,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2))
                else
                  ParentTimeline(items: [
                    for (final (i, event) in events.indexed)
                      (
                        title: event.label,
                        subtitle: [
                          if (event.at != null)
                            ParentFormat.dateTime(context, event.at!),
                          event.actor == 'you' ? tr.common.you : tr.common.soe,
                        ].join(' · '),
                        state: i == events.length - 1 ? 'current' : 'done',
                      ),
                    (
                      title: tr.replacement.stepCall,
                      subtitle: tr.common.upcoming,
                      state: 'upcoming'
                    ),
                    (
                      title: tr.replacement.stepNew,
                      subtitle: tr.common.upcoming,
                      state: 'upcoming'
                    ),
                  ]),
              ]),
              ParentPanel(title: tr.replacement.nowTitle, children: [
                Text(tr.replacement.next2,
                    style:
                        AppTypography.body.copyWith(color: AppPalette.text2)),
              ]),
              const ParentAdvisorCard(),
            ],
          );
        },
      ),
    );
  }
}
