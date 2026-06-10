import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/services/avatar_picker_service.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_back_button.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_places_autocomplete_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../references/domain/entities/school_class.dart';
import '../../../references/presentation/providers.dart';
import '../../domain/entities/child.dart';
import '../providers.dart';

class ParentChildFormPage extends ConsumerStatefulWidget {
  const ParentChildFormPage({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<ParentChildFormPage> createState() =>
      _ParentChildFormPageState();
}

class _ParentChildFormPageState extends ConsumerState<ParentChildFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _age;
  late final TextEditingController _neighborhood;
  late final TextEditingController _city;
  ChildGender _gender = ChildGender.male;

  /// Niveau d'éducation choisi — libellé brut tel que renvoyé par l'API
  /// dans `data.educations` (ex: "Primaire", "Secondaire", "Général").
  String? _education;

  /// Section choisie — libellé brut tel que renvoyé par l'API dans
  /// `data.sections` (ex: "Francophone", "Anglophone").
  String? _section;

  /// UUID de la SchoolClass selectionnee (pas le nom).
  String? _schoolClassId;
  String? _avatarUrl;
  File? _avatarFile;
  String _country = 'Cameroun';
  String _countryCode = 'CM';
  bool _prefilled = false;

  /// Filtre courant pour `schoolClassesProvider`.
  SchoolClassFilter get _classFilter => (
        education: _education,
        section: _section,
      );

  /// Filtre vide → fetch global utilisé pour récupérer `educations` et
  /// `sections` (les listes de choix des pickers Niveau/Section).
  static const SchoolClassFilter _emptyFilter =
      (education: null, section: null);

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _age = TextEditingController();
    _neighborhood = TextEditingController();
    _city = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _neighborhood.dispose();
    _city.dispose();
    super.dispose();
  }

  void _prefillFromExisting() {
    if (_prefilled || widget.editId == null) return;
    final list = ref.read(childrenListViewModelProvider);
    list.whenOrNull(
      loaded: (children) {
        final c = children.where((e) => e.id == widget.editId).firstOrNull;
        if (c != null) {
          _firstName.text = c.firstName;
          _lastName.text = c.lastName;
          _age.text = c.age.toString();
          _schoolClassId =
              (c.schoolClassId ?? '').isEmpty ? null : c.schoolClassId;
          // L'API renvoie l'adresse en string "neighborhood, city" — on
          // tente une separation simple sur la virgule.
          final addr = (c.address ?? '').split(',').map((s) => s.trim()).toList();
          if (addr.isNotEmpty) _neighborhood.text = addr.first;
          if (addr.length > 1) _city.text = addr[1];
          _gender = c.gender;
          _education = c.education;
          _avatarUrl = c.avatarUrl;
          if (c.section != null) _section = c.section!;
          _prefilled = true;
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    _prefillFromExisting();
    final state = ref.watch(childFormViewModelProvider);

    ref.listen(childFormViewModelProvider, (prev, next) {
      next.whenOrNull(
        saved: (c) {
          SoeToast.show(
            context,
            message: widget.editId == null
                ? tr.parent.childForm.addedToast(name: c.firstName)
                : tr.parent.childForm.updatedToast(name: c.firstName),
          );
          Navigator.of(context).pop(c);
        },
        error: (Failure f) => SoeToast.show(
          context,
          message: tr.parent.childForm.saveError,
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isEdit = widget.editId != null;
    final saving = state.maybeWhen(saving: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const SoeBackButton(),
        leadingWidth: 72,
        title: Text(
            isEdit ? tr.parent.childForm.editTitle : tr.parent.childForm.newTitle),
        titleTextStyle: const TextStyle(
          color: AppPalette.ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
            child: _SaveActionButton(
              loading: saving,
              onTap: saving ? null : _submit,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: _AvatarUploader(
                imageUrl: _avatarUrl,
                file: _avatarFile,
                onTap: _pickAvatar,
              ),
            ),
            const SizedBox(height: 22),
            _section_(tr.parent.childForm.identitySection, [
              Row(children: [
                Expanded(
                  child: SoeTextField(
                    label: tr.parent.childForm.firstName,
                    controller: _firstName,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SoeTextField(
                    label: tr.parent.childForm.lastName,
                    controller: _lastName,
                    validator: _required,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SoeTextField(
                    label: tr.parent.childForm.age,
                    controller: _age,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0 || n > 25) {
                        return tr.parent.childForm.invalid;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GenderPicker(
                    value: _gender,
                    onChanged: (g) => setState(() => _gender = g),
                  ),
                ),
              ]),
            ]),
            _section_(tr.parent.childForm.schoolingSection, [
              // Listes Niveau + Section viennent des keys API
              // `data.educations` et `data.sections` du fetch sans filtre.
              Consumer(
                builder: (context, ref, _) {
                  final globalAsync =
                      ref.watch(schoolClassesProvider(_emptyFilter));
                  return globalAsync.when(
                    loading: () => Row(children: [
                      Expanded(
                          child: _ClassPickerSkeleton(
                              label: tr.parent.childForm.level)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _ClassPickerSkeleton(
                              label: tr.parent.childForm.section)),
                    ]),
                    error: (_, __) => Row(children: [
                      Expanded(
                          child:
                              _ClassPickerError(label: tr.parent.childForm.level)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _ClassPickerError(
                              label: tr.parent.childForm.section)),
                    ]),
                    data: (refs) => Row(children: [
                      Expanded(
                        child: _DynamicPicker(
                          label: tr.parent.childForm.level,
                          value: _education,
                          options: refs.educations,
                          hint: tr.parent.childForm.choose,
                          onChanged: (v) => setState(() {
                            _education = v;
                            _schoolClassId = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DynamicPicker(
                          label: tr.parent.childForm.section,
                          value: _section,
                          options: refs.sections,
                          hint: tr.parent.childForm.choose,
                          onChanged: (v) => setState(() {
                            _section = v;
                            _schoolClassId = null;
                          }),
                        ),
                      ),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  final async = ref.watch(schoolClassesProvider(_classFilter));
                  return async.when(
                    loading: () =>
                        _ClassPickerSkeleton(label: tr.parent.childForm.schoolClass),
                    error: (_, __) =>
                        _ClassPickerError(label: tr.parent.childForm.schoolClass),
                    data: (refs) => _ClassPicker(
                      value: _schoolClassId,
                      options: refs.classes,
                      onChanged: (id) =>
                          setState(() => _schoolClassId = id),
                    ),
                  );
                },
              ),
            ]),
            _section_(tr.parent.childForm.addressSection, [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 5),
                child: Text(
                  tr.parent.childForm.neighborhood,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SoePlacesAutocompleteField(
                controller: _neighborhood,
                client: ref.watch(googlePlacesClientProvider),
                hint: tr.parent.childForm.neighborhoodHint,
                onPlaceSelected: (p) {
                  _neighborhood.text =
                      p.neighborhood ?? p.formattedAddress;
                  _city.text = p.city;
                  _country = p.country;
                  _countryCode = p.countryCode;
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              SoeTextField(
                label: tr.parent.childForm.city,
                controller: _city,
                hint: tr.parent.childForm.cityHint,
                leadingIcon: Icons.location_city_outlined,
                validator: _required,
              ),
            ]),
            const SizedBox(height: 22),
            SoeButton(
              label: isEdit
                  ? tr.parent.childForm.update
                  : tr.parent.childForm.saveChild,
              icon: Icons.check,
              fullWidth: true,
              loading: saving,
              onPressed: saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final file = await AvatarPickerService.pick(context);
    if (file == null || !mounted) return;
    setState(() => _avatarFile = file);
  }

  Widget _section_(String label, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: AppPalette.teal,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  String? _required(String? v) => (v ?? '').trim().isEmpty
      ? Translations.of(context).parent.childForm.required
      : null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final params = ChildFormParams(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      age: int.parse(_age.text),
      gender: _gender,
      schoolClassId: _schoolClassId,
      section: _section,
      education: _education,
      city: _city.text.trim(),
      neighborhood:
          _neighborhood.text.trim().isEmpty ? null : _neighborhood.text.trim(),
      country: _country,
      countryCode: _countryCode,
    );
    ref.read(childFormViewModelProvider.notifier).submit(
          id: widget.editId,
          params: params,
          photo: _avatarFile,
        );
  }
}

class _SaveActionButton extends StatelessWidget {
  const _SaveActionButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Material(
      color: AppPalette.yellow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPalette.ink,
                  ),
                )
              : Text(
                  tr.common.save,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AvatarUploader extends StatelessWidget {
  const _AvatarUploader({
    this.imageUrl,
    this.file,
    required this.onTap,
  });
  final String? imageUrl;
  final File? file;
  final VoidCallback onTap;

  bool get _hasImage => file != null || (imageUrl != null && imageUrl!.isNotEmpty);

  ImageProvider? get _imageProvider {
    if (file != null) return FileImage(file!);
    if (imageUrl != null && imageUrl!.isNotEmpty) return NetworkImage(imageUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: _hasImage
                ? null
                : _DashedCirclePainter(color: AppPalette.teal),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppPalette.infoBg,
                shape: BoxShape.circle,
                image: _imageProvider == null
                    ? null
                    : DecorationImage(
                        image: _imageProvider!,
                        fit: BoxFit.cover,
                      ),
                border: _hasImage
                    ? Border.all(color: AppPalette.teal, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: _hasImage
                  ? null
                  : const Icon(
                      Icons.person_outline,
                      size: 38,
                      color: AppPalette.teal,
                    ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: AppPalette.yellow,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 2),
              ),
              elevation: 4,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppPalette.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addOval(rect);
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});
  final ChildGender value;
  final ValueChanged<ChildGender> onChanged;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return _Dropdown<ChildGender>(
      label: tr.parent.childForm.gender,
      value: value,
      items: [
        DropdownMenuItem(
            value: ChildGender.male,
            child: Text(tr.parent.childForm.genderBoy)),
        DropdownMenuItem(
            value: ChildGender.feminine,
            child: Text(tr.parent.childForm.genderGirl)),
      ],
      onChanged: onChanged,
    );
  }
}

/// Picker générique alimenté par une liste de strings (libellés API).
/// Sert pour Niveau (`data.educations`) et Section (`data.sections`).
class _DynamicPicker extends StatelessWidget {
  const _DynamicPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    // Sécurité : si la valeur sélectionnée n'est plus dans les options
    // (cas rare lors d'un refresh API), on l'oublie.
    final safeValue = options.contains(value) ? value : null;
    return _Dropdown<String?>(
      label: label,
      value: safeValue,
      hint: hint ??
          (options.isEmpty
              ? tr.parent.childForm.noOption
              : tr.parent.childForm.choose),
      items: [
        for (final o in options)
          DropdownMenuItem<String?>(value: o, child: Text(o)),
      ],
      onChanged: onChanged,
    );
  }
}

class _ClassPicker extends StatelessWidget {
  const _ClassPicker({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String? value;
  final List<SchoolClass> options;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    // Sécurité : si l'id sélectionné n'est plus dans les options, on
    // l'oublie pour éviter un assert de DropdownButton.
    final safeValue =
        options.any((c) => c.id == value) ? value : null;
    return _Dropdown<String?>(
      label: tr.parent.childForm.schoolClass,
      value: safeValue,
      hint: options.isEmpty
          ? tr.parent.childForm.noClassAvailable
          : tr.parent.childForm.selectClass,
      items: [
        for (final c in options)
          DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _ClassPickerSkeleton extends StatelessWidget {
  const _ClassPickerSkeleton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.n700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.n300),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppPalette.teal,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tr.parent.childForm.loadingClasses,
                style: const TextStyle(fontSize: 13, color: AppPalette.n700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassPickerError extends StatelessWidget {
  const _ClassPickerError({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.n700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppPalette.warningBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.warning),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 16, color: AppPalette.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr.parent.childForm.loadClassesError,
                  style: const TextStyle(fontSize: 12, color: AppPalette.warning),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.n700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.n300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint == null
                  ? null
                  : Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.n500,
                      ),
                    ),
              items: items,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppPalette.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
