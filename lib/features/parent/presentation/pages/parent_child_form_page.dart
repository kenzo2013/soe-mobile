import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
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
  late final TextEditingController _classe;
  late final TextEditingController _address;
  ChildGender _gender = ChildGender.male;
  ChildEducation _education = ChildEducation.general;
  String _section = 'francophone';
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _age = TextEditingController();
    _classe = TextEditingController();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _classe.dispose();
    _address.dispose();
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
          _classe.text = c.classe ?? '';
          _address.text = c.address ?? '';
          _gender = c.gender;
          _education = c.education;
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
        title: Text(isEdit ? 'Modifier l\'enfant' : 'Nouvel enfant'),
        titleTextStyle: const TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppPalette.ink),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
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
                    onChanged: (e) => setState(() => _education = e),
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
              SoeTextField(label: 'Classe', controller: _classe),
            ]),
            _section_('Adresse', [
              SoeTextField(
                label: 'Quartier · Ville',
                controller: _address,
                hint: 'Ex. Bastos, Yaoundé',
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
                fontSize: 10,
                fontWeight: FontWeight.w700,
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
      classe: _classe.text.trim().isEmpty ? null : _classe.text.trim(),
      section: _section,
      education: _education,
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
    );
    ref
        .read(childFormViewModelProvider.notifier)
        .submit(id: widget.editId, params: params);
  }
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
          value: ChildEducation.secondary,
          child: Text('Secondaire'),
        ),
        DropdownMenuItem(
          value: ChildEducation.general,
          child: Text('Général'),
        ),
        DropdownMenuItem(
          value: ChildEducation.technical,
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

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

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
