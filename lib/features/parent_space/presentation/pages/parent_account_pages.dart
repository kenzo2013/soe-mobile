import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_dialog.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_rating_stars.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_advisor_card.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

String _longDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
        .format(date);

/// PAR-18 — reviews: to give (after the required validated sessions), soon, given.
class ParentReviewsPage extends ConsumerWidget {
  const ParentReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.reviews;
    final reviews =
        ref.watch(parentReviewsProvider).valueOrNull ?? const <ParentReview>[];
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: ParentAsyncBody<List<ParentReviewTutor>>(
        value: ref.watch(parentReviewTutorsProvider),
        onRetry: () => ref
          ..invalidate(parentReviewTutorsProvider)
          ..invalidate(parentReviewsProvider),
        builder: (tutors) {
          final required = tutors.isEmpty ? 4 : tutors.first.sessionsRequired;
          final toGive = tutors
              .where((tutor) => tutor.eligible && tutor.activeReviewId == null)
              .toList();
          final soon = tutors.where((tutor) => !tutor.eligible).toList();
          final given =
              reviews.where((review) => review.status == 'active').toList();
          return ListView(
            padding: spacePagePadding(context),
            children: [
              ParentHeading(
                  title: tr.title, subtitle: tr.subtitle(count: required)),
              if (tutors.isEmpty && reviews.isEmpty) ...[
                const SizedBox(height: 16),
                SoeEmptyState(
                    title: tr.empty,
                    message: tr.emptyText(count: required),
                    icon: Icons.star_border),
              ],
              if (toGive.isNotEmpty) ParentSectionTitle(tr.toGive),
              for (final tutor in toGive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoeCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tutor.courses != null)
                            Row(children: [
                              const Icon(Icons.star_border,
                                  size: 16, color: AppPalette.teal700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(tutor.courses!,
                                    style: AppTypography.labelSm
                                        .copyWith(color: AppPalette.teal700)),
                              ),
                            ]),
                          const SizedBox(height: 6),
                          Text(tutor.name, style: AppTypography.label),
                          Text(
                              tutor.since == null
                                  ? tr.validated(count: tutor.approvedSessions)
                                  : tr.validatedSince(
                                      count: tutor.approvedSessions,
                                      date: _longDate(context, tutor.since!)),
                              style: AppTypography.bodySm
                                  .copyWith(color: AppPalette.text2)),
                          const SizedBox(height: 12),
                          SoeButton(
                            label: tr.give,
                            fullWidth: true,
                            onPressed: () => unawaited(context
                                .push(ParentSpaceRoutes.reviewForm(tutor.id))),
                          ),
                        ]),
                  ),
                ),
              if (soon.isNotEmpty)
                ParentPanel(soft: true, title: tr.soon, children: [
                  for (final tutor in soon)
                    ParentInfoRow(
                        [tutor.name, tutor.courses]
                            .whereType<String>()
                            .join(' · '),
                        tr.soonValue(
                            count: tutor.approvedSessions,
                            required: tutor.sessionsRequired),
                        last: tutor == soon.last),
                ]),
              ParentPanel(soft: true, title: tr.given, children: [
                if (given.isEmpty)
                  Text(tr.noneGiven,
                      style:
                          AppTypography.body.copyWith(color: AppPalette.text2)),
                for (final review in given)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(review.tutorName,
                                    style: AppTypography.label)),
                            SoeRatingStars(rating: review.rating),
                          ]),
                          if (review.comment != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('« ${review.comment!} »',
                                  style: AppTypography.bodySm),
                            ),
                          if (review.editable)
                            TextButton(
                              onPressed: () => unawaited(context.push(
                                  ParentSpaceRoutes.reviewForm(
                                      review.tutorId))),
                              child: Text(tr.edit),
                            ),
                        ]),
                  ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

/// PAR-18 « Saisie » — rate 1 to 5, an optional comment (500 characters), the subjects.
class ParentReviewFormPage extends ConsumerStatefulWidget {
  const ParentReviewFormPage({super.key, required this.tutorId});

  final int tutorId;

  @override
  ConsumerState<ParentReviewFormPage> createState() =>
      _ParentReviewFormPageState();
}

class _ParentReviewFormPageState extends ConsumerState<ParentReviewFormPage> {
  final _comment = TextEditingController();
  int _rating = 0;
  Set<int> _subjects = {};
  bool _initialized = false;
  bool _ratingMissing = false;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _init(ParentReviewTutor tutor, ParentReview? review) {
    if (_initialized) return;
    _initialized = true;
    _subjects = {
      ...(review?.subjects ?? tutor.subjects).map((subject) => subject.id)
    };
    if (review != null) {
      _rating = review.rating;
      _comment.text = review.comment ?? '';
    }
  }

  Future<void> _send(ParentReview? review) async {
    final tr = Translations.of(context).parentSpace.reviews;
    if (_rating < 1) {
      setState(() => _ratingMissing = true);
      return;
    }
    setState(() => _busy = true);
    final saved = await runParentAction(
        context,
        () => ref.read(parentApiProvider).saveReview(
            reviewId: review?.id,
            tutorId: widget.tutorId,
            rating: _rating,
            comment: _comment.text.trim(),
            subjectIds: _subjects.toList()));
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved == null) return;
    ref
      ..invalidate(parentReviewsProvider)
      ..invalidate(parentReviewTutorsProvider)
      ..invalidate(parentHomeProvider);
    SoeToast.show(context, message: tr.sent, tone: SoeToastTone.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.reviews;
    final tutors = ref.watch(parentReviewTutorsProvider);
    final reviews = ref.watch(parentReviewsProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab,
          title: tr.title,
          close: true),
      body: ParentAsyncBody<List<ParentReviewTutor>>(
        value: tutors,
        onRetry: () => ref.invalidate(parentReviewTutorsProvider),
        builder: (list) {
          final tutor =
              list.where((item) => item.id == widget.tutorId).firstOrNull;
          if (tutor == null) {
            return SoeEmptyState(
                title: tr.empty,
                message: tr.emptyText(count: 4),
                icon: Icons.star_border);
          }
          final review = reviews
              ?.where((item) =>
                  item.id == tutor.activeReviewId && item.status == 'active')
              .firstOrNull;
          _init(tutor, review);
          final ratingLabels = [tr.r1, tr.r2, tr.r3, tr.r4, tr.r5];
          return Column(children: [
            Expanded(
              child: ListView(
                padding: spacePagePadding(context, insets: false),
                children: [
                  ParentHeading(
                    title: tr.formTitle(name: tutor.name),
                    subtitle: [
                      tutor.courses,
                      tutor.since == null
                          ? null
                          : tr.validatedSince(
                              count: tutor.approvedSessions,
                              date: _longDate(context, tutor.since!)),
                    ].whereType<String>().join(' · '),
                  ),
                  const SizedBox(height: 16),
                  ParentPanel(children: [
                    Text(tr.rating, style: AppTypography.label),
                    const SizedBox(height: 10),
                    Row(children: [
                      SoeRatingStars(
                        rating: _rating,
                        size: 32,
                        onChanged: (value) => setState(() {
                          _rating = value;
                          _ratingMissing = false;
                        }),
                      ),
                      const SizedBox(width: 10),
                      if (_rating > 0)
                        Text(ratingLabels[_rating - 1],
                            style: AppTypography.labelSm
                                .copyWith(color: AppPalette.text2)),
                    ]),
                    if (_ratingMissing) ParentErrorText(tr.ratingMissing),
                    if (tutor.subjects.length > 1) ...[
                      ParentFieldLabel(tr.subjectsLabel),
                      ParentChoiceChips<int>(
                        options: [
                          for (final subject in tutor.subjects)
                            (subject.id, subject.name)
                        ],
                        selected: _subjects,
                        onToggle: (id) => setState(() => _subjects.contains(id)
                            ? _subjects.remove(id)
                            : _subjects.add(id)),
                      ),
                    ],
                    ParentFieldLabel(tr.comment, optional: true),
                    ParentCountedField(controller: _comment),
                  ]),
                  ParentPanel(
                    soft: true,
                    title: tr.whoTitle,
                    children: [
                      Text(tr.whoText(name: tutor.name),
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2)),
                    ],
                  ),
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
                  onPressed: _busy ? null : () => unawaited(_send(review)),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

/// PAR-19 — co-parents and invitations: invite (link valid 7 days), rights (read only
/// or report approval), resend, remove. Only the holder manages them.
class ParentCoParentsPage extends ConsumerWidget {
  const ParentCoParentsPage({super.key});

  void _refresh(WidgetRef ref) => ref
    ..invalidate(parentCoParentsProvider)
    ..invalidate(parentInvitationsProvider);

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final tr = Translations.of(context).parentSpace.coParents;
    final children =
        (ref.read(parentChildrenProvider).valueOrNull ?? const <ParentChild>[])
            .where((child) => child.editable)
            .map((child) => child.firstName)
            .toList();
    final sent = await showParentSheet<bool>(context,
        title: tr.invite,
        text: tr.inviteText,
        builder: (sheet) => _InviteForm(children: children));
    if (sent == true && context.mounted) {
      _refresh(ref);
      SoeToast.show(context, message: tr.sent, tone: SoeToastTone.success);
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, String name,
      Future<void> Function() action) async {
    final tr = Translations.of(context).parentSpace.coParents;
    final confirmed = await SoeConfirmDialog.show(context,
            title: tr.removeTitle(name: name),
            message: tr.removeText,
            confirmLabel: tr.remove,
            destructive: true) ??
        false;
    if (!confirmed || !context.mounted) return;
    final done = await runParentAction(context, () async {
      await action();
      return true;
    });
    if (done == true && context.mounted) {
      _refresh(ref);
      SoeToast.show(context, message: tr.removed, tone: SoeToastTone.success);
    }
  }

  Future<void> _editRights(
      BuildContext context, WidgetRef ref, ParentCoParent coParent) async {
    final tr = Translations.of(context).parentSpace.coParents;
    final reports = await showParentSheet<bool>(context,
        title: tr.editRights,
        text: coParent.name,
        builder: (sheet) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(!coParent.canAnswerReports
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked),
                title: Text(tr.readOnly),
                subtitle: Text(tr.rule1),
                onTap: () => Navigator.pop(sheet, false),
              ),
              ListTile(
                leading: Icon(coParent.canAnswerReports
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked),
                title: Text(tr.reports),
                subtitle: Text(tr.rule2),
                onTap: () => Navigator.pop(sheet, true),
              ),
            ]));
    if (reports == null ||
        reports == coParent.canAnswerReports ||
        !context.mounted) {
      return;
    }
    final updated = await runParentAction(
        context,
        () => ref
            .read(parentApiProvider)
            .updateCoParent(coParent.id, canAnswerReports: reports));
    if (updated != null && context.mounted) {
      _refresh(ref);
      SoeToast.show(context,
          message: tr.rightsSaved, tone: SoeToastTone.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.coParents;
    final invitations = ref.watch(parentInvitationsProvider).valueOrNull ??
        const <ParentInvitation>[];
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: ParentAsyncBody<List<ParentCoParent>>(
        value: ref.watch(parentCoParentsProvider),
        onRetry: () => _refresh(ref),
        builder: (coParents) => ListView(
          padding: spacePagePadding(context),
          children: [
            ParentHeading(title: tr.title, subtitle: tr.subtitle),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: SoeButton(
                label: tr.invite,
                size: SoeButtonSize.md,
                onPressed: () => unawaited(_invite(context, ref)),
              ),
            ),
            const SizedBox(height: 16),
            if (coParents.isEmpty && invitations.isEmpty)
              SoeEmptyState(
                  title: tr.empty,
                  message: tr.emptyText,
                  icon: Icons.group_outlined),
            for (final coParent in coParents)
              _PersonCard(
                header: tr.accepted,
                badge: SoeBadge(label: tr.accepted, tone: SoeBadgeTone.success),
                name: coParent.name,
                detail: [
                  coParent.canAnswerReports ? tr.reports : tr.readOnly,
                  if (coParent.children.isNotEmpty)
                    coParent.children.join(', '),
                  if (coParent.email != null) coParent.email!,
                ].join(' · '),
                actions: [
                  SoeButton(
                    label: tr.editRights,
                    variant: SoeButtonVariant.outline,
                    fullWidth: true,
                    onPressed: () =>
                        unawaited(_editRights(context, ref, coParent)),
                  ),
                  SoeButton(
                    label: tr.remove,
                    variant: SoeButtonVariant.dangerOutline,
                    fullWidth: true,
                    onPressed: () => unawaited(_remove(
                        context,
                        ref,
                        coParent.name,
                        () => ref
                            .read(parentApiProvider)
                            .removeCoParent(coParent.id))),
                  ),
                ],
              ),
            for (final invitation in invitations)
              _PersonCard(
                header: invitation.sentAt == null
                    ? ''
                    : tr.sentOn(
                        date: ParentFormat.day(context, invitation.sentAt!)),
                badge: invitation.expired
                    ? SoeBadge(label: tr.expired, tone: SoeBadgeTone.neutral)
                    : SoeBadge(
                        label: tr.pendingBadge(
                            days: invitation.expiresAt == null
                                ? 7
                                : invitation.expiresAt!
                                        .difference(DateTime.now())
                                        .inDays +
                                    1),
                        tone: SoeBadgeTone.info),
                name: invitation.name,
                detail: [
                  invitation.canAnswerReports ? tr.reports : tr.readOnly,
                  invitation.phone ?? invitation.email ?? '',
                  if (invitation.expired && invitation.expiresAt != null)
                    tr.expiredOn(
                        date: ParentFormat.day(context, invitation.expiresAt!)),
                ].where((part) => part.isNotEmpty).join(' · '),
                actions: [
                  SoeButton(
                    label: tr.resend,
                    variant: SoeButtonVariant.outline,
                    fullWidth: true,
                    onPressed: () async {
                      final resent = await runParentAction(
                          context,
                          () => ref
                              .read(parentApiProvider)
                              .resendInvitation(invitation.id));
                      if (resent != null && context.mounted) {
                        _refresh(ref);
                        SoeToast.show(context,
                            message: tr.resent, tone: SoeToastTone.success);
                      }
                    },
                  ),
                  if (!invitation.expired)
                    SoeButton(
                      label: tr.remove,
                      variant: SoeButtonVariant.dangerOutline,
                      fullWidth: true,
                      onPressed: () => unawaited(_remove(
                          context,
                          ref,
                          invitation.name,
                          () => ref
                              .read(parentApiProvider)
                              .removeInvitation(invitation.id))),
                    ),
                ],
              ),
            ParentPanel(soft: true, title: tr.rulesTitle, children: [
              for (final rule in [tr.rule1, tr.rule2, tr.rule3])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 8),
                          child: Icon(Icons.info_outline,
                              size: 16, color: AppPalette.teal600),
                        ),
                        Expanded(
                            child: Text(rule, style: AppTypography.bodySm)),
                      ]),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.header,
    required this.badge,
    required this.name,
    required this.detail,
    required this.actions,
  });

  final String header;
  final Widget badge;
  final String name;
  final String detail;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SoeCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // A long badge (« Envoyée · expire dans 5 j ») wraps under the date.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppPalette.text2),
                  const SizedBox(width: 6),
                  Text(header,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.text2)),
                ]),
                badge,
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: AppTypography.label),
            Text(detail,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            for (final action in actions) ...[
              const SizedBox(height: 8),
              action,
            ],
          ]),
        ),
      );
}

class _InviteForm extends ConsumerStatefulWidget {
  const _InviteForm({required this.children});

  final List<String> children;

  @override
  ConsumerState<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends ConsumerState<_InviteForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _civility = 'Mme';
  bool _reports = false;
  Map<String, List<String>> _errors = const {};
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _email, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _error(String field) => _errors[field]?.firstOrNull;

  Future<void> _send() async {
    final required = Translations.of(context).parentSpace.common.required;
    final missing = <String, List<String>>{
      for (final (field, controller) in [
        ('first_name', _firstName),
        ('last_name', _lastName),
        ('email', _email),
        ('phone', _phone),
      ])
        if (controller.text.trim().isEmpty) field: [required],
    };
    if (missing.isNotEmpty) {
      setState(() => _errors = missing);
      return;
    }
    setState(() {
      _busy = true;
      _errors = const {};
    });
    try {
      await ref.read(parentApiProvider).invite({
        'civility': _civility,
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'can_answer_reports': _reports,
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationFailure catch (failure) {
      if (mounted) setState(() => _errors = failure.errors);
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
    final tr = Translations.of(context).parentSpace.coParents;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ParentFieldLabel(tr.civility),
      ParentChoiceChips<String>(
        options: [('Mme', tr.mrs), ('Mr', tr.mr)],
        selected: {_civility},
        onToggle: (value) => setState(() => _civility = value),
      ),
      ParentFieldLabel(tr.firstName),
      SoeTextField(controller: _firstName, errorText: _error('first_name')),
      ParentFieldLabel(tr.lastName),
      SoeTextField(controller: _lastName, errorText: _error('last_name')),
      ParentFieldLabel(tr.email),
      SoeTextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          hint: tr.emailHint,
          errorText: _error('email')),
      ParentFieldLabel(tr.phone),
      SoeTextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          hint: '+237',
          errorText: _error('phone')),
      ParentFieldLabel(tr.rights),
      ParentChoiceChips<bool>(
        options: [(false, tr.readOnly), (true, tr.reports)],
        selected: {_reports},
        onToggle: (value) => setState(() => _reports = value),
      ),
      if (widget.children.isNotEmpty) ...[
        ParentFieldLabel(tr.childrenLabel),
        Text(tr.childrenAll(names: widget.children.join(', ')),
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      ],
      const SizedBox(height: 16),
      SoeButton(
        label: tr.send,
        variant: SoeButtonVariant.secondary,
        loading: _busy,
        onPressed: _busy ? null : () => unawaited(_send()),
      ),
      SoeButton(
        label: Translations.of(context).parentSpace.common.cancel,
        variant: SoeButtonVariant.tertiary,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ]);
  }
}

/// « Mon conseiller SOE » (More menu): who follows the family's requests.
class ParentAdvisorPage extends ConsumerWidget {
  const ParentAdvisorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.advisor;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: ParentAsyncBody<ParentHome>(
        value: ref.watch(parentHomeProvider),
        onRetry: () => ref.invalidate(parentHomeProvider),
        builder: (home) => ListView(
          padding: spacePagePadding(context),
          children: [
            ParentHeading(title: tr.title, subtitle: tr.text),
            const SizedBox(height: 16),
            if (home.advisorName == null)
              SoeEmptyState(
                  title: tr.title,
                  message: tr.none,
                  icon: Icons.support_agent_outlined)
            else
              const ParentAdvisorCard(),
          ],
        ),
      ),
    );
  }
}
