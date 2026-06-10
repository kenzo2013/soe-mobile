import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
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
  final category = TextEditingController(
      text: existing?.category.isNotEmpty == true
          ? existing!.category
          : 'Universitaire');
  final key = 'training:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? 'Nouvelle formation' : 'Modifier la formation',
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SoeTextField(controller: level, label: 'Niveau (ex: Master)'),
        const SizedBox(height: 10),
        SoeTextField(controller: domain, label: 'Domaine'),
        const SizedBox(height: 10),
        SoeTextField(controller: specialty, label: 'Spécialité'),
        const SizedBox(height: 10),
        SoeTextField(controller: date, label: "Année d'obtention"),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, r, _) => SoeButton(
            label: 'Enregistrer',
            fullWidth: true,
            loading: r.watch(tutorActionViewModelProvider(key))
                is TutorActionSubmitting,
            onPressed: () => runTutorAction(
              ctx,
              r,
              actionKey: key,
              successMessage:
                  existing == null ? 'Formation ajoutée' : 'Formation modifiée',
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
  final key = 'work:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? 'Nouvelle expérience' : "Modifier l'expérience",
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoeTextField(controller: title, label: 'Poste occupé'),
          const SizedBox(height: 10),
          SoeTextField(controller: company, label: 'Entreprise'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoeTextField(controller: since, label: 'Depuis'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoeTextField(
                  controller: until,
                  label: "Jusqu'à",
                  enabled: !current,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppPalette.teal,
            title: const Text('Poste actuel',
                style: TextStyle(fontSize: 13, color: AppPalette.ink)),
            value: current,
            onChanged: (v) => setState(() => current = v),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: 'Enregistrer',
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: key,
                successMessage: existing == null
                    ? 'Expérience ajoutée'
                    : 'Expérience modifiée',
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
  const days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche'
  ];
  var weekday = 1;
  final from = TextEditingController(text: '14:00');
  final to = TextEditingController(text: '18:00');
  return _showSheet(
    context,
    title: 'Nouveau créneau',
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: weekday,
            decoration: const InputDecoration(
              labelText: 'Jour',
              border: OutlineInputBorder(),
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
              Expanded(child: SoeTextField(controller: from, label: 'Début')),
              const SizedBox(width: 10),
              Expanded(child: SoeTextField(controller: to, label: 'Fin')),
            ],
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: 'Ajouter',
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider('availability'))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: 'availability',
                successMessage: 'Créneau ajouté',
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
  final key = 'pay_mobile:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? 'Ajouter Mobile Money' : 'Modifier Mobile Money',
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
            label: 'Numéro de téléphone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: 'Enregistrer',
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () => runTutorAction(
                ctx,
                r,
                actionKey: key,
                successMessage:
                    existing == null ? 'Méthode ajoutée' : 'Méthode modifiée',
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
  final key = 'identity:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? 'Ajouter un document' : 'Modifier le document',
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoeTextField(controller: type, label: 'Type (CNI, Passeport…)'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoeTextField(
                    controller: birthday, label: 'Naissance (AAAA-MM-JJ)'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child:
                    SoeTextField(controller: expiration, label: 'Expiration'),
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
                      ? 'Choisir des photos'
                      : 'Remplacer les photos')
                  : '${images.length} photo(s)',
            ),
          ),
          if (existing != null && images.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Laissez vide pour conserver les photos actuelles.',
                style: TextStyle(fontSize: 11, color: AppPalette.n500),
              ),
            ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: 'Enregistrer',
              fullWidth: true,
              loading: r.watch(tutorActionViewModelProvider(key))
                  is TutorActionSubmitting,
              onPressed: () {
                // Photos obligatoires uniquement à la création.
                if (existing == null && images.isEmpty) {
                  SoeToast.show(ctx,
                      message: 'Ajoutez au moins une photo',
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
                  successMessage:
                      existing == null ? 'Document ajouté' : 'Document modifié',
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
  final key = 'course:${existing?.id ?? 'new'}';
  return _showSheet(
    context,
    title: existing == null ? 'Nouvelle classe' : 'Modifier la classe',
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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Impossible de charger les classes / matières. Réessayez.',
              style: TextStyle(fontSize: 13, color: AppPalette.danger),
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
                decoration: const InputDecoration(
                  labelText: 'Classe / niveau',
                  border: OutlineInputBorder(),
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
              const Text(
                'Matières enseignées',
                style: TextStyle(
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
                label: 'Enregistrer',
                fullWidth: true,
                loading: r.watch(tutorActionViewModelProvider(key))
                    is TutorActionSubmitting,
                onPressed: () {
                  if (classId == null) {
                    SoeToast.show(ctx,
                        message: 'Choisissez une classe',
                        tone: SoeToastTone.warning);
                    return;
                  }
                  if (subjectIds.isEmpty) {
                    SoeToast.show(ctx,
                        message: 'Choisissez au moins une matière',
                        tone: SoeToastTone.warning);
                    return;
                  }
                  runTutorAction(
                    ctx,
                    r,
                    actionKey: key,
                    successMessage:
                        existing == null ? 'Classe ajoutée' : 'Classe modifiée',
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
  return _showSheet(
    context,
    title: 'Signer le contrat',
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Signez dans le cadre puis validez.',
            style: TextStyle(fontSize: 12, color: AppPalette.n700),
          ),
        ),
        const SizedBox(height: 10),
        TutorSignaturePad(controller: sig),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, r, _) => SoeButton(
            label: 'Signer le contrat',
            fullWidth: true,
            loading: r.watch(tutorActionViewModelProvider('sign:$contractId'))
                is TutorActionSubmitting,
            onPressed: () async {
              final file = await sig.toTempFile(const Size(320, 160));
              if (!ctx.mounted) return;
              if (file == null) {
                SoeToast.show(ctx,
                    message: 'Veuillez signer', tone: SoeToastTone.warning);
                return;
              }
              await runTutorAction(
                ctx,
                r,
                actionKey: 'sign:$contractId',
                successMessage: 'Contrat signé',
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
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer ?'),
      content: Text('Voulez-vous supprimer $label ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppPalette.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return r ?? false;
}
