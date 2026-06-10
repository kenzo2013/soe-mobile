import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../references/presentation/providers.dart';
import '../../domain/entities/child.dart';
import '../../domain/entities/reservation_detail.dart';
import '../providers.dart';

class ParentNewReservationPage extends ConsumerStatefulWidget {
  const ParentNewReservationPage({super.key});
  @override
  ConsumerState<ParentNewReservationPage> createState() =>
      _ParentNewReservationPageState();
}

class _ParentNewReservationPageState
    extends ConsumerState<ParentNewReservationPage> {
  int _step = 0;
  Child? _child;

  /// Identifiants (UUID) des matières sélectionnées — issus de
  /// `GET /common/subjects` (le backend attend des `subject_ids` réels).
  final Set<String> _subjects = {};
  int _frequency = 2;
  DateTime _start = DateTime.now().add(const Duration(days: 7));
  TutorGenderPref _genderPref = TutorGenderPref.noPreference;

  bool _canContinue() {
    switch (_step) {
      case 0:
        return _child != null && _subjects.isNotEmpty;
      case 1:
        return _frequency > 0;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _submit() {
    if (_child == null || _subjects.isEmpty) return;
    final params = NewReservationParams(
      childId: _child!.id,
      subjects: _subjects.toList(),
      frequency: _frequency,
      estimatedStartDate: _start,
      preferredTutorGender: _genderPref,
    );
    ref.read(newReservationViewModelProvider.notifier).submit(params);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    ref.listen(newReservationViewModelProvider, (_, next) {
      next.whenOrNull(
        submitted: (_) {
          SoeToast.show(context, message: tr.parent.reservation.requestSent);
          Navigator.of(context).pop();
        },
        error: (_) => SoeToast.show(
          context,
          message: tr.parent.reservation.requestError,
          tone: SoeToastTone.danger,
        ),
      );
    });

    final submitting = ref
        .watch(newReservationViewModelProvider)
        .maybeWhen(submitting: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr.parent.reservation.title,
              style: const TextStyle(
                color: AppPalette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr.parent.reservation.stepHeader(
                step: _step + 1,
                label: _stepLabel(tr, _step),
              ),
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppPalette.ink),
      ),
      body: Column(
        children: [
          _ProgressBar(step: _step + 1, total: 3, tr: tr),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (_step) {
                0 => _Step1(
                    key: const ValueKey(0),
                    selectedChild: _child,
                    selectedSubjects: _subjects,
                    onChildChanged: (c) => setState(() => _child = c),
                    onToggleSubject: (id) => setState(() {
                      if (_subjects.contains(id)) {
                        _subjects.remove(id);
                      } else {
                        _subjects.add(id);
                      }
                    }),
                  ),
                1 => _Step2(
                    key: const ValueKey(1),
                    frequency: _frequency,
                    start: _start,
                    genderPref: _genderPref,
                    onFrequency: (n) => setState(() => _frequency = n),
                    onPickStart: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _start = d);
                    },
                    onGender: (g) => setState(() => _genderPref = g),
                  ),
                _ => _Step3(
                    key: const ValueKey(2),
                    child: _child,
                    subjects: _subjects.toList(),
                    frequency: _frequency,
                    start: _start,
                    genderPref: _genderPref,
                  ),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SoeButton(
                label: _step == 2
                    ? tr.parent.reservation.submit
                    : tr.common.kContinue,
                icon: _step == 2 ? Icons.check : Icons.chevron_right,
                iconRight: _step < 2,
                fullWidth: true,
                loading: submitting,
                onPressed: submitting || !_canContinue()
                    ? null
                    : () {
                        if (_step == 2) {
                          _submit();
                        } else {
                          setState(() => _step++);
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stepLabel(Translations tr, int s) => switch (s) {
        0 => tr.parent.reservation.step1Label,
        1 => tr.parent.reservation.step2Label,
        _ => tr.parent.reservation.step3Label,
      };
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.step,
    required this.total,
    required this.tr,
  });
  final int step;
  final int total;
  final Translations tr;
  @override
  Widget build(BuildContext context) {
    final pct = step / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                tr.parent.reservation.stepOf(step: step, total: total),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.teal,
                ),
              ),
              const Spacer(),
              Text(
                tr.parent.reservation.percent(value: (pct * 100).round()),
                style: const TextStyle(fontSize: 11, color: AppPalette.n700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppPalette.n300,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: AppPalette.yellow,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends ConsumerWidget {
  const _Step1({
    super.key,
    required this.selectedChild,
    required this.selectedSubjects,
    required this.onChildChanged,
    required this.onToggleSubject,
  });
  final Child? selectedChild;
  final Set<String> selectedSubjects;
  final ValueChanged<Child> onChildChanged;
  final ValueChanged<String> onToggleSubject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final children = ref.watch(childrenListViewModelProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          tr.parent.reservation.step1Title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr.parent.reservation.step1Subtitle,
          style: const TextStyle(fontSize: 12, color: AppPalette.n700),
        ),
        const SizedBox(height: 16),
        children.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_) => Text(
            tr.parent.reservation.childrenLoadError,
            style: const TextStyle(color: AppPalette.danger, fontSize: 12),
          ),
          loaded: (list) => Column(
            children: [
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChildChanged(c),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedChild?.id == c.id
                            ? AppPalette.infoBg
                            : AppPalette.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedChild?.id == c.id
                              ? AppPalette.teal
                              : AppPalette.n300,
                          width: selectedChild?.id == c.id ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          SoeAvatar(
                            name: c.fullName,
                            imageUrl: c.avatarUrl,
                            size: SoeAvatarSize.list,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.fullName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (c.classe != null) c.classe!,
                                    '${c.age} ans',
                                  ].join(' · '),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppPalette.n700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedChild?.id == c.id
                                  ? AppPalette.teal
                                  : Colors.transparent,
                              border: Border.all(
                                color: selectedChild?.id == c.id
                                    ? AppPalette.teal
                                    : AppPalette.n500,
                                width: 2,
                              ),
                            ),
                            child: selectedChild?.id == c.id
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              tr.parent.reservation.subjectsLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              selectedSubjects.length > 1
                  ? tr.parent.reservation
                      .selectedMany(count: selectedSubjects.length)
                  : tr.parent.reservation
                      .selectedOne(count: selectedSubjects.length),
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.n700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ref.watch(subjectsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(
                tr.parent.reservation.subjectsLoadError,
                style: const TextStyle(color: AppPalette.danger, fontSize: 12),
              ),
              data: (subjects) => subjects.isEmpty
                  ? Text(
                      tr.parent.reservation.subjectsEmpty,
                      style: const TextStyle(
                          color: AppPalette.n700, fontSize: 12),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in subjects)
                          _SubjectChip(
                            label: s.name,
                            selected: selectedSubjects.contains(s.id),
                            onTap: () => onToggleSubject(s.id),
                          ),
                      ],
                    ),
            ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppPalette.teal : AppPalette.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppPalette.teal : AppPalette.n300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 12, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppPalette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2({
    super.key,
    required this.frequency,
    required this.start,
    required this.genderPref,
    required this.onFrequency,
    required this.onPickStart,
    required this.onGender,
  });
  final int frequency;
  final DateTime start;
  final TutorGenderPref genderPref;
  final ValueChanged<int> onFrequency;
  final VoidCallback onPickStart;
  final ValueChanged<TutorGenderPref> onGender;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          tr.parent.reservation.step2Title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr.parent.reservation.step2Subtitle,
          style: const TextStyle(fontSize: 12, color: AppPalette.n700),
        ),
        const SizedBox(height: 18),
        _sectionLabel(tr.parent.reservation.startDate),
        InkWell(
          onTap: onPickStart,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppPalette.n300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: AppPalette.n500,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DateFormat('EEEE d MMMM yyyy', 'fr').format(start),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppPalette.n500,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _sectionLabel(tr.parent.reservation.frequency),
        SoeCard(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    tr.parent.reservation.sessionsPerWeek,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.n700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.yellow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$frequency',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var n = 1; n <= 5; n++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => onFrequency(n),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: n == frequency
                                  ? AppPalette.teal
                                  : AppPalette.n100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: n == frequency
                                    ? Colors.white
                                    : AppPalette.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionLabel(tr.parent.reservation.preferredTutor),
        Row(
          children: [
            Expanded(
              child: _GenderTile(
                label: tr.parent.reservation.genderNoPreferenceShort,
                icon: Icons.groups_outlined,
                selected: genderPref == TutorGenderPref.noPreference,
                onTap: () => onGender(TutorGenderPref.noPreference),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderTile(
                label: tr.parent.reservation.genderMale,
                icon: Icons.person_outline,
                selected: genderPref == TutorGenderPref.male,
                onTap: () => onGender(TutorGenderPref.male),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderTile(
                label: tr.parent.reservation.genderFemale,
                icon: Icons.person_outline,
                selected: genderPref == TutorGenderPref.female,
                onTap: () => onGender(TutorGenderPref.female),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppPalette.teal,
          ),
        ),
      );
}

class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppPalette.infoBg : AppPalette.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppPalette.teal : AppPalette.n300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppPalette.teal : AppPalette.n700,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppPalette.teal : AppPalette.n700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step3 extends ConsumerWidget {
  const _Step3({
    super.key,
    required this.child,
    required this.subjects,
    required this.frequency,
    required this.start,
    required this.genderPref,
  });
  final Child? child;

  /// UUID des matières sélectionnées (résolus en noms pour l'affichage).
  final List<String> subjects;
  final int frequency;
  final DateTime start;
  final TutorGenderPref genderPref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final subjectNames = ref.watch(subjectsProvider).maybeWhen(
          data: (all) {
            final byId = {for (final s in all) s.id: s.name};
            return subjects.map((id) => byId[id] ?? id).toList();
          },
          orElse: () => subjects,
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          tr.parent.reservation.step3Title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr.parent.reservation.step3Subtitle,
          style: const TextStyle(fontSize: 12, color: AppPalette.n700),
        ),
        const SizedBox(height: 18),
        SoeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (child != null)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SoeAvatar(
                        name: child!.fullName,
                        imageUrl: child!.avatarUrl,
                        size: SoeAvatarSize.list,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child!.fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (child!.classe != null) child!.classe!,
                                '${child!.age} ans',
                              ].join(' · '),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppPalette.n700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Container(height: 1, color: AppPalette.n100),
              _row(tr.parent.reservation.summarySubjects,
                  subjectNames.join(' · ')),
              _row(
                tr.parent.reservation.summaryStart,
                DateFormat('d MMM yyyy', 'fr').format(start),
              ),
              _row(
                tr.parent.reservation.summaryFrequency,
                frequency > 1
                    ? tr.parent.reservation.frequencyValueMany(count: frequency)
                    : tr.parent.reservation.frequencyValueOne(count: frequency),
              ),
              _row(
                  tr.parent.reservation.summaryTutor,
                  switch (genderPref) {
                    TutorGenderPref.male => tr.parent.reservation.genderMale,
                    TutorGenderPref.female => tr.parent.reservation.genderFemale,
                    TutorGenderPref.noPreference =>
                      tr.parent.reservation.genderNoPreference,
                  },
                  last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String k, String v, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: AppPalette.n100, width: 1),
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppPalette.n700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.ink,
                ),
              ),
            ),
          ],
        ),
      );
}
