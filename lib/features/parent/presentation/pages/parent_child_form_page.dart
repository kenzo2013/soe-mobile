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
  ChildEducation _education = ChildEducation.general;
  String _section = 'francophone';
  /// UUID de la SchoolClass selectionnee (pas le nom).
  String? _schoolClassId;
  String? _avatarUrl;
  File? _avatarFile;
  String _country = 'Cameroun';
  String _countryCode = 'CM';
  bool _prefilled = false;

  /// Filtre les SchoolClasses du back selon le niveau d'education et la
  /// section choisis. Si l'API ne fournit pas ces metadonnes pour une
  /// classe, on la garde (mieux que de la cacher).
  List<SchoolClass> _filterClasses(List<SchoolClass> all) {
    final eduKey = switch (_education) {
      ChildEducation.primary => 'primary',
      ChildEducation.general => 'general',
      ChildEducation.technic => 'technic',
      ChildEducation.unknown => null,
    };
    return all.where((c) {
      final matchEdu = eduKey == null || c.education == null || c.education == eduKey;
      final matchSec = c.section == null || c.section == _section;
      return matchEdu && matchSec;
    }).toList()
      ..sort((a, b) {
        if (a.position != null && b.position != null) {
          return a.position!.compareTo(b.position!);
        }
        return a.name.compareTo(b.name);
      });
  }

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
    _prefillFromExisting();
    final state = ref.watch(childFormViewModelProvider);

    ref.listen(childFormViewModelProvider, (prev, next) {
      next.whenOrNull(
        saved: (c) {
          SoeToast.show(
            context,
            message: widget.editId == null
                ? '${c.firstName} ajouté(e)'
                : '${c.firstName} mis(e) à jour',
          );
          Navigator.of(context).pop(c);
        },
        error: (Failure f) => SoeToast.show(
          context,
          message: 'Erreur — réessayez.',
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
        title: Text(isEdit ? 'Modifier l\'enfant' : 'Nouvel enfant'),
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
            _section_('Identité', [
              Row(children: [
                Expanded(
                  child: SoeTextField(
                    label: 'Prénom',
                    controller: _firstName,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SoeTextField(
                    label: 'Nom',
                    controller: _lastName,
                    validator: _required,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SoeTextField(
                    label: 'Âge',
                    controller: _age,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0 || n > 25) return 'Invalide';
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
            _section_('Scolarité', [
              Row(children: [
                Expanded(
                  child: _EducationPicker(
                    value: _education,
                    onChanged: (e) => setState(() {
                      _education = e;
                      // Reset si la classe n'est plus valide pour le nouveau
                      // niveau — verifie via le provider async.
                      final all = ref.read(schoolClassesProvider).valueOrNull ??
                          const <SchoolClass>[];
                      final stillValid = _filterClasses(all)
                          .any((c) => c.id == _schoolClassId);
                      if (!stillValid) _schoolClassId = null;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SectionPicker(
                    value: _section,
                    onChanged: (s) => setState(() => _section = s),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  final async = ref.watch(schoolClassesProvider);
                  return async.when(
                    loading: () =>
                        const _ClassPickerSkeleton(label: 'Classe'),
                    error: (_, __) => const _ClassPickerError(label: 'Classe'),
                    data: (all) {
                      final options = _filterClasses(all);
                      return _ClassPicker(
                        value: _schoolClassId,
                        options: options,
                        onChanged: (id) =>
                            setState(() => _schoolClassId = id),
                      );
                    },
                  );
                },
              ),
            ]),
            _section_('Adresse', [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 5),
                child: const Text(
                  'Quartier',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppPalette.n700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SoePlacesAutocompleteField(
                controller: _neighborhood,
                client: ref.watch(googlePlacesClientProvider),
                hint: 'Ex. Bastos',
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
                label: 'Ville *',
                controller: _city,
                hint: 'Ex. Yaoundé',
                leadingIcon: Icons.location_city_outlined,
                validator: _required,
              ),
            ]),
            const SizedBox(height: 22),
            SoeButton(
              label: isEdit ? 'Mettre à jour' : 'Enregistrer cet enfant',
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

  String? _required(String? v) =>
      (v ?? '').trim().isEmpty ? 'Obligatoire' : null;

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
              : const Text(
                  'Enregistrer',
                  style: TextStyle(
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
    return _Dropdown<ChildGender>(
      label: 'Genre',
      value: value,
      items: const [
        DropdownMenuItem(value: ChildGender.male, child: Text('Garçon')),
        DropdownMenuItem(value: ChildGender.feminine, child: Text('Fille')),
      ],
      onChanged: onChanged,
    );
  }
}

class _EducationPicker extends StatelessWidget {
  const _EducationPicker({required this.value, required this.onChanged});
  final ChildEducation value;
  final ValueChanged<ChildEducation> onChanged;
  @override
  Widget build(BuildContext context) {
    return _Dropdown<ChildEducation>(
      label: 'Niveau',
      value: value,
      items: const [
        DropdownMenuItem(
          value: ChildEducation.primary,
          child: Text('Primaire'),
        ),
        DropdownMenuItem(
          value: ChildEducation.general,
          child: Text('Général'),
        ),
        DropdownMenuItem(
          value: ChildEducation.technic,
          child: Text('Technique'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return _Dropdown<String>(
      label: 'Section',
      value: value,
      items: const [
        DropdownMenuItem(value: 'francophone', child: Text('Francophone')),
        DropdownMenuItem(value: 'anglophone', child: Text('Anglophone')),
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
    // Sécurité : si l'id sélectionné n'est plus dans les options, on
    // l'oublie pour éviter un assert de DropdownButton.
    final safeValue =
        options.any((c) => c.id == value) ? value : null;
    return _Dropdown<String?>(
      label: 'Classe',
      value: safeValue,
      hint: options.isEmpty
          ? 'Aucune classe disponible'
          : 'Sélectionnez la classe',
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
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppPalette.teal,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Chargement des classes…',
                style: TextStyle(fontSize: 13, color: AppPalette.n700),
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
          child: const Row(
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 16, color: AppPalette.warning),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Impossible de charger les classes.',
                  style: TextStyle(fontSize: 12, color: AppPalette.warning),
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
