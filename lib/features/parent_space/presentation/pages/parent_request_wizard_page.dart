import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_need_fields.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// PAR-05 — a new request in three steps: the children, each child's need, the summary.
/// The server keeps the draft at each step: leaving and coming back resumes it.
class ParentRequestWizardPage extends ConsumerWidget {
  const ParentRequestWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.wizard;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab,
          title: tr.title,
          close: true),
      body: ParentAsyncBody<ParentRequestDraft>(
        value: ref.watch(parentDraftProvider),
        onRetry: () => ref.invalidate(parentDraftProvider),
        builder: (draft) => ParentAsyncBody<ParentReferences>(
          value: ref.watch(parentReferencesProvider),
          onRetry: () => ref.invalidate(parentReferencesProvider),
          builder: (references) =>
              ParentRequestWizard(draft: draft, references: references),
        ),
      ),
    );
  }
}

/// The wizard itself, built on a loaded draft (separate for the tests).
class ParentRequestWizard extends ConsumerStatefulWidget {
  const ParentRequestWizard(
      {super.key, required this.draft, required this.references});

  final ParentRequestDraft draft;
  final ParentReferences references;

  @override
  ConsumerState<ParentRequestWizard> createState() =>
      _ParentRequestWizardState();
}

class _ParentRequestWizardState extends ConsumerState<ParentRequestWizard> {
  late ParentRequestDraft _draft = widget.draft;
  late final Set<int> _selected = {..._draft.childIds};

  /// 0: children, 1: need of [_childIndex], 2: summary, 3: sent.
  int _step = 0;
  int _childIndex = 0;
  ParentNeed? _need;
  List<String> _missing = const [];
  bool _busy = false;
  bool _resumed = false;
  ParentRequestDetail? _sent;

  @override
  void initState() {
    super.initState();
    if (_draft.started) {
      _resumed = true;
      final firstIncomplete =
          _draft.childIds.indexWhere((id) => !_draft.needOf(id).complete);
      if (_draft.complete || firstIncomplete < 0) {
        _step = 2;
      } else {
        _openNeed(firstIncomplete);
      }
    }
  }

  void _openNeed(int index) {
    _step = 1;
    _childIndex = index;
    _need = _draft.needOf(_draft.childIds[index]);
    _missing = const [];
  }

  Future<T?> _call<T>(Future<T> Function() action) async {
    setState(() => _busy = true);
    try {
      return await action();
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() => _missing = failure.errors.keys.toList());
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
      return null;
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveChildren() async {
    final draft = await _call(() =>
        ref.read(parentApiProvider).draftChildren(_selected.toList()..sort()));
    if (draft == null || !mounted) return;
    setState(() {
      _draft = draft;
      _resumed = false;
      _openNeed(0);
    });
  }

  Future<void> _saveNeed() async {
    final draft =
        await _call(() => ref.read(parentApiProvider).draftNeed(_need!));
    if (draft == null || !mounted) return;
    setState(() {
      _draft = draft;
      _resumed = false;
      if (_childIndex + 1 < _draft.childIds.length) {
        _openNeed(_childIndex + 1);
      } else {
        _step = 2;
      }
    });
  }

  /// Back without loss: the need typed so far is saved, even incomplete.
  Future<void> _previous() async {
    if (_step == 1 && _need != null) {
      try {
        _draft = await ref.read(parentApiProvider).draftNeed(_need!);
      } on Failure catch (_) {
        // Incomplete needs are kept by the server too; nothing to show.
      }
    }
    if (!mounted) return;
    setState(() {
      _resumed = false;
      if (_step == 2) {
        _openNeed(_draft.childIds.length - 1);
      } else if (_step == 1 && _childIndex > 0) {
        _openNeed(_childIndex - 1);
      } else {
        _step = 0;
      }
    });
  }

  Future<void> _submit() async {
    final summary =
        await _call(() => ref.read(parentApiProvider).draftSummary());
    if (summary == null || !mounted) return;
    final sent = await _call(() => ref.read(parentApiProvider).submitDraft());
    if (sent == null || !mounted) return;
    ref
      ..invalidate(parentRequestsProvider)
      ..invalidate(parentHomeProvider)
      ..invalidate(parentDraftProvider);
    setState(() {
      _sent = sent;
      _step = 3;
    });
  }

  String _childName(int id) =>
      _draft.children.where((child) => child.id == id).firstOrNull?.firstName ??
      '';

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.wizard;
    if (_step == 3) return _success(context);
    final (title, body, action, onAction) = switch (_step) {
      0 => (
          tr.childrenTitle,
          _childrenStep(context),
          Translations.of(context).parentSpace.common.next,
          _selected.isEmpty ? null : _saveChildren,
        ),
      1 => (
          tr.needTitle(name: _childName(_need!.childId)),
          _needStep(context),
          Translations.of(context).parentSpace.common.next,
          _saveNeed,
        ),
      _ => (tr.summaryTitle, _summaryStep(context), tr.submit, _submit),
    };
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context, insets: false),
          children: [
            _Progress(
                step: _step,
                childName: _step == 1 ? _childName(_need!.childId) : null),
            const SizedBox(height: 16),
            if (_resumed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoeAlert(
                    tone: SoeAlertTone.info,
                    title: tr.resumedTitle,
                    body: tr.resumedText),
              ),
            Text(title,
                style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
      SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppPalette.n300))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_step == 2 ? tr.free : tr.autosaved,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            if (_step > 0)
              SoeButton(
                label: Translations.of(context).parentSpace.common.previous,
                variant: SoeButtonVariant.tertiary,
                onPressed: _busy ? null : () => unawaited(_previous()),
              ),
            const SizedBox(height: 4),
            SoeButton(
              label: action,
              fullWidth: true,
              loading: _busy,
              onPressed: _busy || onAction == null
                  ? null
                  : () => unawaited(onAction()),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _childrenStep(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    if (_draft.children.isEmpty) {
      return SoeEmptyState(
        title: tr.wizard.noChild,
        message: tr.children.emptyText,
        icon: Icons.family_restroom_outlined,
        actionLabel: tr.childFile.add,
        onAction: () => context.pushReplacement(ParentSpaceRoutes.newChild),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tr.wizard.childrenText,
          style: AppTypography.body.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 12),
      for (final child in _draft.children)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoeCard(
            onTap: () => setState(() => _selected.contains(child.id)
                ? _selected.remove(child.id)
                : _selected.add(child.id)),
            child: Row(children: [
              Checkbox(
                value: _selected.contains(child.id),
                onChanged: (checked) => setState(() => checked == true
                    ? _selected.add(child.id)
                    : _selected.remove(child.id)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.firstName, style: AppTypography.label),
                      if (child.schoolClass != null)
                        Text(child.schoolClass!,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                    ]),
              ),
            ]),
          ),
        ),
    ]);
  }

  Widget _needStep(BuildContext context) {
    final need = _need!;
    final child =
        _draft.children.where((item) => item.id == need.childId).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (child?.schoolClass != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(child!.schoolClass!,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
        ),
      ParentPanel(children: [
        ParentNeedFields(
          need: need,
          draft: _draft,
          subjects: widget.references.subjectsFor(
              ref.watch(parentChildClassIdProvider(need.childId)),
              Localizations.localeOf(context).languageCode,
              // A subject chosen earlier stays visible, to be unticked if the server refuses it.
              keep: need.subjectIds),
          missing: {..._missing, ...need.missing},
          onChanged: (next) => setState(() => _need = next),
        ),
      ]),
    ]);
  }

  Widget _summaryStep(BuildContext context) {
    final tr = Translations.of(context).parentSpace.wizard;
    return Column(children: [
      for (var i = 0; i < _draft.childIds.length; i++)
        _NeedSummary(
          draft: _draft,
          need: _draft.needOf(_draft.childIds[i]),
          childName: _childName(_draft.childIds[i]),
          onEdit: () => setState(() => _openNeed(i)),
        ),
      ParentPanel(soft: true, title: tr.nextTitle, children: [
        ParentArrowList([tr.next1, tr.next2, tr.next3]),
      ]),
    ]);
  }

  Widget _success(BuildContext context) {
    final tr = Translations.of(context).parentSpace.wizard;
    return SoeFullStatusView(
      title: tr.successTitle,
      message: tr.successText,
      icon: Icons.check_circle_outline,
      iconColor: AppPalette.successText,
      iconBgColor: AppPalette.successBg,
      primaryActionLabel: tr.seeRequest,
      onPrimaryAction: () =>
          context.pushReplacement(ParentSpaceRoutes.request(_sent!.request.id)),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, this.childName});

  final int step;
  final String? childName;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.wizard;
    final labels = [tr.stepChildren, tr.stepNeed, tr.stepSummary];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          [tr.step(n: step + 1), if (childName != null) childName!].join(' · '),
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 6),
      Row(children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < step
                      ? AppPalette.teal800
                      : i == step
                          ? AppPalette.teal400
                          : AppPalette.teal100,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Text(labels[i],
                  style: AppTypography.caption.copyWith(
                      color: i <= step ? AppPalette.text : AppPalette.text2)),
            ]),
          ),
          if (i < 2) const SizedBox(width: 6),
        ],
      ]),
    ]);
  }
}

class _NeedSummary extends StatelessWidget {
  const _NeedSummary({
    required this.draft,
    required this.need,
    required this.childName,
    required this.onEdit,
  });

  final ParentRequestDraft draft;
  final ParentNeed need;
  final String childName;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace;
    final duration = draft.labelOf(draft.sessionMinutes, need.sessionMinutes);
    final schoolClass = draft.children
        .where((child) => child.id == need.childId)
        .firstOrNull
        ?.schoolClass;
    return ParentPanel(
      title: [childName, schoolClass].whereType<String>().join(' · '),
      trailing: TextButton(onPressed: onEdit, child: Text(tr.common.edit)),
      children: [
        ParentInfoRow(tr.wizard.subjects, need.subjects.join(', ')),
        ParentInfoRow(tr.wizard.objective,
            draft.labelOf(draft.objectives, need.objective)),
        if (need.startOn != null)
          ParentInfoRow(
              tr.wizard.start, ParentFormat.dayLong(context, need.startOn!)),
        ParentInfoRow(
            tr.wizard.rhythm,
            tr.wizard.rhythmValue(
                count: need.sessionsPerWeek ?? 0, duration: duration)),
        if (need.moments.isNotEmpty)
          ParentInfoRow(
              tr.wizard.moments,
              need.moments
                  .map((moment) => draft.labelOf(draft.moments, moment))
                  .join(', ')),
        ParentInfoRow(
            tr.wizard.preference, draft.labelOf(draft.genders, need.gender),
            last: true),
      ],
    );
  }
}
