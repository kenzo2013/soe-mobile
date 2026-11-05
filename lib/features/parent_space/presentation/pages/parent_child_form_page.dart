import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/avatar_picker_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_dialog.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_child_avatar.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// PAR-04 — add a child (childId null) or edit their profile; archive from the edit form.
/// Optional photo; the address is given to the tutor only once the contract is signed.
class ParentChildFormPage extends ConsumerWidget {
  const ParentChildFormPage({super.key, this.childId});

  final int? childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.childForm;
    final references = ref.watch(parentReferencesProvider);
    final child =
        childId == null ? null : ref.watch(parentChildProvider(childId!));
    final title = childId == null
        ? tr.titleNew
        : tr.titleEdit(name: child?.valueOrNull?.firstName ?? '');
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
        section: Translations.of(context).parentSpace.children.title,
        title: title,
        close: true,
        bell: false,
      ),
      body: ParentAsyncBody<ParentReferences>(
        value: references,
        onRetry: () => ref.invalidate(parentReferencesProvider),
        builder: (refs) => child == null
            ? _ChildForm(references: refs)
            : ParentAsyncBody<ParentChild>(
                value: child,
                onRetry: () => ref.invalidate(parentChildProvider(childId!)),
                builder: (value) => _ChildForm(references: refs, child: value),
              ),
      ),
    );
  }
}

class _ChildForm extends ConsumerStatefulWidget {
  const _ChildForm({required this.references, this.child});

  final ParentReferences references;
  final ParentChild? child;

  @override
  ConsumerState<_ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends ConsumerState<_ChildForm> {
  late final _firstName = TextEditingController(text: widget.child?.firstName);
  late final _lastName = TextEditingController(text: widget.child?.lastName);
  late final _schoolName =
      TextEditingController(text: widget.child?.schoolName);
  late final _address =
      TextEditingController(text: widget.child?.address?.address);
  late final _landmark =
      TextEditingController(text: widget.child?.address?.landmark);
  late final _specialNeeds =
      TextEditingController(text: widget.child?.specialNeeds);
  late DateTime? _birthdate = widget.child?.birthdate;
  late String? _gender = widget.child?.gender;
  late String _section = widget.child?.section ?? 'francophone';
  late String? _schoolType = widget.child?.schoolType;
  late int? _schoolClassId = widget.child?.schoolClassId;
  late String? _city = widget.child?.address?.city;
  late String? _neighborhood = widget.child?.address?.neighborhood;
  File? _photo;
  Map<String, List<String>> _errors = const {};
  bool _busy = false;

  bool get _editing => widget.child != null;

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _schoolName,
      _address,
      _landmark,
      _specialNeeds
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _error(String field) {
    final messages = _errors[field] ?? _errors['${field}_id'];
    return messages == null || messages.isEmpty ? null : messages.first;
  }

  String _iso(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(now.year - 30),
      lastDate: now.subtract(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _pickPhoto() async {
    final file = await AvatarPickerService.pick(context);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    final tr = Translations.of(context).parentSpace;
    final missing = <String, List<String>>{
      if (_firstName.text.trim().isEmpty) 'first_name': [tr.common.required],
      if (_lastName.text.trim().isEmpty) 'last_name': [tr.common.required],
      if (_gender == null) 'gender': [tr.common.required],
      if (_schoolClassId == null) 'school_class': [tr.common.required],
    };
    if (missing.isNotEmpty) {
      setState(() => _errors = missing);
      return;
    }
    setState(() {
      _busy = true;
      _errors = const {};
    });
    final body = <String, dynamic>{
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'birthdate': _birthdate == null ? null : _iso(_birthdate!),
      'gender': _gender,
      'section': _section,
      'school_type': _schoolType,
      'school_class_id': _schoolClassId,
      'school_name': _schoolName.text.trim(),
      'special_needs': _specialNeeds.text.trim(),
      if (_city != null || _address.text.trim().isNotEmpty)
        'address': {
          'address': _address.text.trim(),
          'neighborhood': _neighborhood,
          'city': _city,
          'landmark': _landmark.text.trim(),
        },
    };
    try {
      final saved = await ref
          .read(parentApiProvider)
          .saveChild(widget.child?.id, body, photo: _photo?.path);
      if (!mounted) return;
      ref
        ..invalidate(parentChildrenProvider)
        ..invalidate(parentHomeProvider)
        ..invalidate(parentChildProvider(saved.id))
        ..invalidate(parentChildPhotoProvider(saved.id));
      SoeToast.show(context,
          message: _editing
              ? tr.childForm.saved
              : tr.childForm.created(name: saved.firstName),
          tone: SoeToastTone.success);
      if (_editing) {
        context.pop();
      } else {
        context.pushReplacement(ParentSpaceRoutes.child(saved.id));
      }
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

  Future<void> _archive() async {
    final tr = Translations.of(context).parentSpace.childForm;
    final child = widget.child!;
    final confirmed = await SoeConfirmDialog.show(context,
            title: tr.archiveTitle(name: child.firstName),
            message: tr.archiveText,
            confirmLabel: tr.archive,
            destructive: true) ??
        false;
    if (!confirmed || !mounted) return;
    final archived = await runParentAction(
        context, () => ref.read(parentApiProvider).archiveChild(child.id));
    if (archived == null || !mounted) return;
    ref
      ..invalidate(parentChildrenProvider)
      ..invalidate(parentHomeProvider);
    SoeToast.show(context, message: tr.archived, tone: SoeToastTone.success);
    context.go(RouteNames.parentChildren);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.childForm;
    final refs = widget.references;
    final classes = refs.classesOf(_section);
    final cities = refs.cities;
    final neighborhoods =
        cities.where((city) => city.name == _city).firstOrNull?.neighborhoods ??
            const <String>[];
    final readOnly = _editing && !widget.child!.editable;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context),
          children: [
            ParentHeading(
                title: _editing
                    ? tr.titleEdit(name: widget.child!.firstName)
                    : tr.titleNew,
                subtitle: tr.subtitle),
            const SizedBox(height: 16),
            if (readOnly)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoeAlert(
                    tone: SoeAlertTone.info,
                    title: tr.titleEdit(name: widget.child!.firstName),
                    body: tr.readOnly),
              ),
            if (_errors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoeAlert(
                    tone: SoeAlertTone.danger,
                    title: tr.errorTitle,
                    body: tr.errorText),
              ),
            ParentPanel(title: tr.child, children: [
              ParentFieldLabel(tr.photo, optional: true),
              InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(12),
                child: Row(children: [
                  if (_photo != null)
                    CircleAvatar(
                        radius: 30, backgroundImage: FileImage(_photo!))
                  else if (widget.child != null && widget.child!.hasPhoto)
                    ParentChildAvatar(child: widget.child!, radius: 30)
                  else
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppPalette.surfaceSoft,
                      child: Icon(Icons.photo_camera_outlined,
                          color: AppPalette.text2),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _photo != null ||
                                      (widget.child?.hasPhoto ?? false)
                                  ? tr.changePhoto
                                  : tr.addPhoto,
                              style: AppTypography.labelSm
                                  .copyWith(color: AppPalette.teal700)),
                          Text(tr.photoHint,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
                        ]),
                  ),
                ]),
              ),
              ParentFieldLabel(tr.firstName),
              SoeTextField(
                  controller: _firstName, errorText: _error('first_name')),
              ParentFieldLabel(tr.lastName),
              SoeTextField(
                  controller: _lastName, errorText: _error('last_name')),
              ParentFieldLabel(tr.birthdate),
              ParentPickerField(
                icon: Icons.calendar_today_outlined,
                label: _birthdate == null
                    ? tr.chooseDate
                    : DateFormat('dd/MM/yyyy').format(_birthdate!),
                placeholder: _birthdate == null,
                errorText: _error('birthdate'),
                onTap: _pickBirthdate,
              ),
              ParentFieldLabel(tr.gender),
              ParentSegmented<String>(
                options: [('female', tr.girl), ('male', tr.boy)],
                value: _gender,
                onChanged: (value) => setState(() => _gender = value),
              ),
              if (_error('gender') != null) ParentErrorText(_error('gender')!),
            ]),
            ParentPanel(title: tr.schooling, children: [
              ParentFieldLabel(tr.section),
              ParentSegmented<String>(
                options: [
                  ('francophone', tr.francophone),
                  ('anglophone', tr.anglophone)
                ],
                value: _section,
                onChanged: (value) => setState(() {
                  _section = value;
                  if (!refs
                      .classesOf(value)
                      .any((item) => item.id == _schoolClassId)) {
                    _schoolClassId = null;
                  }
                }),
              ),
              ParentFieldLabel(tr.schoolType),
              ParentSegmented<String>(
                options: [
                  ('public', tr.public),
                  ('private_secular', tr.privateSecular),
                  ('religious', tr.religious),
                ],
                value: _schoolType,
                onChanged: (value) => setState(() => _schoolType = value),
              ),
              ParentFieldLabel(tr.schoolClass),
              DropdownButtonFormField<int>(
                key: ValueKey('class-$_section'),
                initialValue: classes.any((item) => item.id == _schoolClassId)
                    ? _schoolClassId
                    : null,
                isExpanded: true,
                hint: Text(tr.chooseClass),
                decoration: _decoration(_error('school_class')),
                items: [
                  for (final item in classes)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) => setState(() => _schoolClassId = value),
              ),
              ParentFieldLabel(tr.schoolName, optional: true),
              SoeTextField(
                  controller: _schoolName, errorText: _error('school_name')),
            ]),
            ParentPanel(title: tr.home, children: [
              ParentFieldLabel(tr.city),
              DropdownButtonFormField<String>(
                initialValue:
                    cities.any((city) => city.name == _city) ? _city : null,
                isExpanded: true,
                decoration: _decoration(null),
                items: [
                  for (final city in cities)
                    DropdownMenuItem(value: city.name, child: Text(city.name)),
                ],
                onChanged: (value) => setState(() {
                  _city = value;
                  _neighborhood = null;
                }),
              ),
              if (neighborhoods.isNotEmpty) ...[
                ParentFieldLabel(tr.neighborhood),
                DropdownButtonFormField<String>(
                  key: ValueKey('neighborhood-$_city'),
                  initialValue: neighborhoods.contains(_neighborhood)
                      ? _neighborhood
                      : null,
                  isExpanded: true,
                  decoration: _decoration(null),
                  items: [
                    for (final name in neighborhoods)
                      DropdownMenuItem(value: name, child: Text(name)),
                  ],
                  onChanged: (value) => setState(() => _neighborhood = value),
                ),
              ],
              ParentFieldLabel(tr.address),
              SoeTextField(
                  controller: _address,
                  leadingIcon: Icons.place_outlined,
                  errorText: _error('address')),
              ParentFieldLabel(tr.landmark, optional: true),
              SoeTextField(controller: _landmark),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(tr.addressHint,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              ),
              ParentFieldLabel(tr.specialNeeds, optional: true),
              ParentCountedField(
                  controller: _specialNeeds,
                  hint: tr.specialNeedsHint,
                  max: 300,
                  errorText: _error('special_needs')),
            ]),
            if (_editing && widget.child!.editable)
              SoeButton(
                label: tr.archive,
                variant: SoeButtonVariant.dangerOutline,
                fullWidth: true,
                onPressed: _busy ? null : () => unawaited(_archive()),
              ),
          ],
        ),
      ),
      if (!readOnly)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SoeButton(
              label: _editing ? tr.submitEdit : tr.submitNew,
              fullWidth: true,
              loading: _busy,
              onPressed: _busy ? null : () => unawaited(_submit()),
            ),
          ),
        )
    ]);
  }

  InputDecoration _decoration(String? error) => InputDecoration(
        errorText: error,
        filled: true,
        fillColor: AppPalette.surfaceSoft,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      );
}
