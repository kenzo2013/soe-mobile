import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../references/presentation/providers.dart';
import '../../domain/entities/tutor_form_params.dart';
import '../../domain/entities/tutor_payment_method.dart';
import '../../domain/entities/tutor_profile.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import 'tutor_action.dart';
import 'tutor_signature.dart';

/// Coquille commune des sheets de formulaire tuteur.
Future<void> _showSheet(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext) builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Évite la fermeture accidentelle par glissement pendant la saisie.
    enableDrag: false,
    backgroundColor: AppPalette.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppPalette.n300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 16),
          builder(ctx),
        ],
      ),
    ),
  );
}

// ── Formation (création + édition) ───────────────────────────
Future<void> showTrainingSheet(
  BuildContext context,
  WidgetRef ref, {
  TutorTraining? existing,
}) {
  final level = TextEditingController(text: existing?.level ?? '');
  final domain = TextEditingController(text: existing?.domain ?? '');
  final specialty = TextEditingController(
    text: (existing?.specialty == '—' ? '' : existing?.specialty) ?? '',
  );
  final date = TextEditingController(text: existing?.date ?? '');
  final tr = Translations.of(context);
  final category = TextEditingController(
      text: existing?.category.isNotEmpty == true
          ? existing!.category
          : 'Universitaire');
  final key = 'training:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null
        ? tr.tutor.forms.newTraining
        : tr.tutor.forms.editTraining,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SoeTextField(controller: level, label: tr.tutor.forms.levelLabel),
        const SizedBox(height: 10),
        SoeTextField(controller: domain, label: tr.tutor.forms.domain),
        const SizedBox(height: 10),
        SoeTextField(controller: specialty, label: tr.tutor.forms.specialty),
        const SizedBox(height: 10),
        SoeTextField(controller: date, label: tr.tutor.forms.obtentionYear),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, r, _) => SoeButton(
            label: tr.common.save,
            fullWidth: true,
            loading: r.watch(tutorActionViewModelProvider(key))
                is TutorActionSubmitting,
            onPressed: () => runTutorAction(
              ctx,
              r,
              actionKey: key,
              successMessage: existing == null
                  ? tr.tutor.forms.trainingAdded
                  : tr.tutor.forms.trainingUpdated,
              op: () => r.read(saveTutorTrainingProvider)(
                TutorTrainingParams(
                  category: category.text.trim(),
                  level: level.text.trim(),
                  domain: domain.text.trim(),
                  specialty: specialty.text.trim(),
                  date: date.text.trim(),
                ),
                id: existing?.id,
              ),
              onSuccess: () =>
                  ref.read(tutorTrainingsViewModelProvider.notifier).refresh(),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Expérience (création + édition) ──────────────────────────
Future<void> showWorkSheet(
  BuildContext context,
  WidgetRef ref, {
  TutorWork? existing,
}) {
  final title = TextEditingController(text: existing?.title ?? '');
  final company = TextEditingController(text: existing?.company ?? '');
  final since = TextEditingController(text: existing?.since ?? '');
  final until = TextEditingController(text: existing?.until ?? '');
  var current = existing?.current ?? false;
  final tr = Translations.of(context);
  final key = 'work:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? tr.tutor.forms.newWork : tr.tutor.forms.editWork,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoeTextField(controller: title, label: tr.tutor.forms.position),
          const SizedBox(height: 10),
          SoeTextField(controller: company, label: tr.tutor.forms.company),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoeTextField(
                    controller: since, label: tr.tutor.forms.since),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoeTextField(
                  controller: until,
                  label: tr.tutor.forms.until,
                  enabled: !current,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppPalette.teal,
            title: Text(tr.tutor.forms.currentPosition,
                style: const TextStyle(fontSize: 13, color: AppPalette.ink)),
            value: current,
            onChanged: (v) => setState(() => current = v),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: tr.common.save,
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: key,
                successMessage: existing == null
                    ? tr.tutor.forms.workAdded
                    : tr.tutor.forms.workUpdated,
                op: () => r.read(saveTutorWorkProvider)(
                  TutorWorkParams(
                    title: title.text.trim(),
                    company: company.text.trim(),
                    current: current,
                    since: since.text.trim().isEmpty ? null : since.text.trim(),
                    until: current || until.text.trim().isEmpty
                        ? null
                        : until.text.trim(),
                  ),
                  id: existing?.id,
                ),
                onSuccess: () =>
                    ref.read(tutorWorksViewModelProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Disponibilité ────────────────────────────────────────────
Future<void> showAvailabilitySheet(BuildContext context, WidgetRef ref) {
  final tr = Translations.of(context);
  final days = [
    tr.tutor.days.monday,
    tr.tutor.days.tuesday,
    tr.tutor.days.wednesday,
    tr.tutor.days.thursday,
    tr.tutor.days.friday,
    tr.tutor.days.saturday,
    tr.tutor.days.sunday,
  ];
  var weekday = 1;
  final from = TextEditingController(text: '14:00');
  final to = TextEditingController(text: '18:00');
  return _showSheet(
    context,
    title: tr.tutor.forms.newSlot,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: weekday,
            decoration: InputDecoration(
              labelText: tr.tutor.forms.day,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (var i = 0; i < days.length; i++)
                DropdownMenuItem(value: i + 1, child: Text(days[i])),
            ],
            onChanged: (v) => setState(() => weekday = v ?? 1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: SoeTextField(
                      controller: from, label: tr.tutor.forms.start)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      SoeTextField(controller: to, label: tr.tutor.forms.end)),
            ],
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: tr.common.add,
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider('availability'))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: 'availability',
                successMessage: tr.tutor.forms.slotAdded,
                op: () => r.read(createTutorAvailabilityProvider)(
                  TutorAvailabilityParams(
                    weekday: weekday,
                    startTime: from.text.trim(),
                    endTime: to.text.trim(),
                  ),
                ),
                onSuccess: () => ref
                    .read(tutorAvailabilitiesViewModelProvider.notifier)
                    .refresh(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Mobile Money (création + édition) ────────────────────────
Future<void> showMobilePaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  TutorPaymentMethod? existing,
}) {
  final phone = TextEditingController(text: existing?.phone ?? '');
  var op = (existing?.operator ?? '').toLowerCase().contains('orange')
      ? TutorMobileOperator.orange
      : TutorMobileOperator.mtn;
  final tr = Translations.of(context);
  final key = 'pay_mobile:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null
        ? tr.tutor.forms.addMobileMoney
        : tr.tutor.forms.editMobileMoney,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<TutorMobileOperator>(
            segments: const [
              ButtonSegment(
                  value: TutorMobileOperator.mtn, label: Text('MTN MoMo')),
              ButtonSegment(
                  value: TutorMobileOperator.orange,
                  label: Text('Orange Money')),
            ],
            selected: {op},
            onSelectionChanged: (s) => setState(() => op = s.first),
          ),
          const SizedBox(height: 12),
          SoeTextField(
            controller: phone,
            label: tr.tutor.forms.phoneNumber,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: tr.common.save,
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: key,
                successMessage: existing == null
                    ? tr.tutor.forms.methodAdded
                    : tr.tutor.forms.methodUpdated,
                op: () => r.read(addTutorMobilePaymentProvider)(
                  TutorMobilePaymentParams(
                      phone: phone.text.trim(), operator: op),
                  id: existing?.id,
                ),
                onSuccess: () => ref
                    .read(tutorPaymentMethodsViewModelProvider.notifier)
                    .refresh(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Pièce d'identité (upload photos · création + édition) ────
Future<void> showIdentitySheet(
  BuildContext context,
  WidgetRef ref, {
  TutorIdentity? existing,
}) {
  final type = TextEditingController(text: existing?.type ?? 'CNI');
  final birthday = TextEditingController(text: existing?.dob ?? '');
  final expiration = TextEditingController(text: existing?.expires ?? '');
  final images = <File>[];
  final tr = Translations.of(context);
  final key = 'identity:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null
        ? tr.tutor.forms.addDocument
        : tr.tutor.forms.editDocument,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoeTextField(controller: type, label: tr.tutor.forms.documentType),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoeTextField(
                    controller: birthday, label: tr.tutor.forms.birthDate),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoeTextField(
                    controller: expiration, label: tr.tutor.forms.expiration),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await ImagePicker().pickMultiImage();
              setState(() {
                images
                  ..clear()
                  ..addAll(picked.map((x) => File(x.path)));
              });
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              images.isEmpty
                  ? (existing == null
                      ? tr.tutor.forms.choosePhotos
                      : tr.tutor.forms.replacePhotos)
                  : tr.tutor.forms.photosCount(count: images.length),
            ),
          ),
          if (existing != null && images.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                tr.tutor.forms.keepCurrentPhotos,
                style: const TextStyle(fontSize: 11, color: AppPalette.n500),
              ),
            ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: tr.common.save,
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () {
                // Photos obligatoires uniquement à la création.
                if (existing == null && images.isEmpty) {
                  SoeToast.show(ctx,
                      message: tr.tutor.forms.addAtLeastOnePhoto,
                      tone: SoeToastTone.warning);
                  return;
                }
                final params = TutorIdentityParams(
                  documentType: type.text.trim().toLowerCase(),
                  birthday: birthday.text.trim(),
                  expirationDate: expiration.text.trim(),
                  images: images,
                );
                runTutorAction(
                  ctx,
                  r,
                  actionKey: key,
                  successMessage: existing == null
                      ? tr.tutor.forms.documentAdded
                      : tr.tutor.forms.documentUpdated,
                  op: () => existing == null
                      ? r.read(createTutorIdentityProvider)(params)
                      : r.read(updateTutorIdentityProvider)(
                          existing.id, params),
                  onSuccess: () => ref
                      .read(tutorIdentitiesViewModelProvider.notifier)
                      .refresh(),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Matières enseignées (classe + matières · création + édition) ──
Future<void> showTeachingCourseSheet(
  BuildContext context,
  WidgetRef ref, {
  TutorTeachingCourse? existing,
}) {
  // Sélection courante (capturée dans la closure, mutée via setState).
  String? classId;
  final subjectIds = <String>{};
  var prefilled = false;
  final tr = Translations.of(context);
  final key = 'course:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title:
        existing == null ? tr.tutor.forms.newClass : tr.tutor.forms.editClass,
    builder: (ctx) => Consumer(
      builder: (ctx, r, _) {
        final classesAsync =
            r.watch(schoolClassesProvider((education: null, section: null)));
        final subjectsAsync = r.watch(subjectsProvider);
        // Tant que les deux catalogues ne sont pas chargés, on patiente.
        if (classesAsync.isLoading || subjectsAsync.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (classesAsync.hasError || subjectsAsync.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              tr.tutor.forms.loadClassesError,
              style: const TextStyle(fontSize: 13, color: AppPalette.danger),
            ),
          );
        }
        final classes = classesAsync.value!.classes;
        final subjects = subjectsAsync.value!;

        // Pré-remplissage (une fois) par correspondance de noms.
        if (!prefilled && existing != null) {
          prefilled = true;
          for (final c in classes) {
            if (c.name == existing.classe || c.abbr == existing.classe) {
              classId = c.id;
              break;
            }
          }
          for (final s in subjects) {
            if (existing.subjects.contains(s.name) ||
                (s.abbr != null && existing.subjects.contains(s.abbr))) {
              subjectIds.add(s.id);
            }
          }
        }

        return StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: classId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: tr.tutor.forms.classLevel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final c in classes)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.abbr == null ? c.name : '${c.name} (${c.abbr})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => classId = v),
              ),
              const SizedBox(height: 16),
              Text(
                tr.tutor.forms.taughtSubjects,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in subjects)
                        FilterChip(
                          label: Text(s.name),
                          selected: subjectIds.contains(s.id),
                          selectedColor:
                              AppPalette.teal.withValues(alpha: 0.18),
                          checkmarkColor: AppPalette.teal,
                          onSelected: (sel) => setState(() {
                            if (sel) {
                              subjectIds.add(s.id);
                            } else {
                              subjectIds.remove(s.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SoeButton(
                label: tr.common.save,
                fullWidth: true,
                loading: r.watch(tutorActionViewModelProvider(key))
                    is TutorActionSubmitting,
                onPressed: () {
                  if (classId == null) {
                    SoeToast.show(ctx,
                        message: tr.tutor.forms.chooseClass,
                        tone: SoeToastTone.warning);
                    return;
                  }
                  if (subjectIds.isEmpty) {
                    SoeToast.show(ctx,
                        message: tr.tutor.forms.chooseSubject,
                        tone: SoeToastTone.warning);
                    return;
                  }
                  runTutorAction(
                    ctx,
                    r,
                    actionKey: key,
                    successMessage: existing == null
                        ? tr.tutor.forms.classAdded
                        : tr.tutor.forms.classUpdated,
                    op: () => r.read(saveTutorTeachingCourseProvider)(
                      TutorTeachingCourseParams(
                        schoolClassId: classId!,
                        subjectIds: subjectIds.toList(),
                      ),
                      id: existing?.id,
                    ),
                    onSuccess: () => ref
                        .read(tutorTeachingCoursesViewModelProvider.notifier)
                        .refresh(),
                  );
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ── Signature de contrat ─────────────────────────────────────
Future<void> showContractSignSheet(
  BuildContext context,
  WidgetRef ref,
  String contractId, {
  VoidCallback? onSuccess,
}) {
  final sig = TutorSignatureController();
  final tr = Translations.of(context);
  return _showSheet(
    context,
    title: tr.tutor.forms.signContract,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            tr.tutor.forms.signInFrame,
            style: const TextStyle(fontSize: 12, color: AppPalette.n700),
          ),
        ),
        const SizedBox(height: 10),
        TutorSignaturePad(controller: sig),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, r, _) => SoeButton(
            label: tr.tutor.forms.signContract,
            fullWidth: true,
            loading: r.watch(tutorActionViewModelProvider('sign:$contractId'))
                is TutorActionSubmitting,
            onPressed: () async {
              final file = await sig.toTempFile(const Size(320, 160));
              if (!ctx.mounted) return;
              if (file == null) {
                SoeToast.show(ctx,
                    message: tr.tutor.forms.pleaseSign,
                    tone: SoeToastTone.warning);
                return;
              }
              await runTutorAction(
                ctx,
                r,
                actionKey: 'sign:$contractId',
                successMessage: tr.tutor.forms.contractSigned,
                op: () => r.read(signTutorContractProvider)(contractId, file),
                onSuccess: onSuccess,
              );
            },
          ),
        ),
      ],
    ),
  );
}

/// Confirmation de suppression générique.
Future<bool> confirmDelete(BuildContext context, String label) async {
  final tr = Translations.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.tutor.forms.deleteTitle),
      content: Text(tr.tutor.forms.deleteConfirm(label: label)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr.common.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppPalette.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr.common.delete),
        ),
      ],
    ),
  );
  return r ?? false;
}
