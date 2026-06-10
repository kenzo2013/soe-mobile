import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/avatar_picker_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../domain/repositories/common_repository.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// 2 · Informations personnelles (design `CommonPersonalInfo`).
class AccountPersonalInfoPage extends ConsumerWidget {
  const AccountPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final async = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.account.personalInfo.title,
        subtitle: tr.account.personalInfo.subtitle,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (user) => user == null
            ? Center(child: Text(tr.account.personalInfo.unavailable))
            : _ProfileForm(user: user),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});
  final User user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late String _civility;
  late String _lang;
  File? _photo;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstName = TextEditingController(text: u.firstName);
    _lastName = TextEditingController(text: u.lastName);
    _phone = TextEditingController(text: u.phone ?? '');
    _civility = (u.civility == 'Mme') ? 'Mme' : 'Mr';
    _lang = (u.lang ?? 'fr').toLowerCase().startsWith('en') ? 'en' : 'fr';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await AvatarPickerService.pick(context);
    if (file != null && mounted) setState(() => _photo = file);
  }

  Future<void> _save() async {
    final tr = Translations.of(context);
    final params = UpdateProfileParams(
      civility: _civility,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      lang: _lang,
      photo: _photo,
    );
    await runCommonAction(
      context,
      ref,
      actionKey: 'profile',
      successMessage: tr.account.personalInfo.saved,
      op: () async {
        final r = await ref.read(commonRepositoryProvider).updateProfile(params);
        return switch (r) {
          Ok() => const Ok<void, Failure>(null),
          Err(:final failure) => Err<void, Failure>(failure),
        };
      },
      onSuccess: () => ref.invalidate(currentUserProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final submitting =
        ref.watch(commonActionViewModelProvider('profile')) is CommonActionSubmitting;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _photo != null
                        ? CircleAvatar(
                            radius: 46,
                            backgroundImage: FileImage(_photo!),
                          )
                        : SoeAvatar(
                            name: widget.user.fullName,
                            imageUrl: widget.user.photoUrl,
                            size: SoeAvatarSize.profile,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppPalette.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppPalette.n100, width: 3),
                        ),
                        child: const Icon(Icons.add,
                            size: 16, color: AppPalette.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickPhoto,
                child: Text(
                  tr.account.personalInfo.photoHint,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SoeCard(
          child: Column(
            children: [
              _CivilitySelector(
                value: _civility,
                onChanged: (v) => setState(() => _civility = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SoeTextField(
                      controller: _firstName,
                      label: tr.account.personalInfo.firstName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SoeTextField(
                      controller: _lastName,
                      label: tr.account.personalInfo.lastName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoeTextField(
                controller: _phone,
                label: tr.account.personalInfo.phone,
                leadingIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              SoeTextField(
                controller: TextEditingController(text: widget.user.email),
                label: tr.account.personalInfo.email,
                leadingIcon: Icons.mail_outline,
                enabled: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          tr.account.personalInfo.preferredLanguage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LangCard(
                flag: '🇫🇷',
                label: 'Français',
                selected: _lang == 'fr',
                onTap: () => setState(() => _lang = 'fr'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LangCard(
                flag: '🇬🇧',
                label: 'English',
                selected: _lang == 'en',
                onTap: () => setState(() => _lang = 'en'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SoeButton(
          label: tr.account.personalInfo.save,
          fullWidth: true,
          loading: submitting,
          onPressed: submitting ? null : _save,
        ),
      ],
    );
  }
}

class _CivilitySelector extends StatelessWidget {
  const _CivilitySelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            tr.account.personalInfo.civility,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppPalette.n700,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _CivilityChip(
                label: tr.account.personalInfo.mr,
                selected: value == 'Mr',
                onTap: () => onChanged('Mr'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CivilityChip(
                label: tr.account.personalInfo.mrs,
                selected: value == 'Mme',
                onTap: () => onChanged('Mme'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CivilityChip extends StatelessWidget {
  const _CivilityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.teal : AppPalette.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppPalette.teal : AppPalette.n300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppPalette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.yellow.withValues(alpha: 0.08)
              : AppPalette.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppPalette.yellow : AppPalette.n300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Opacity(
              opacity: selected ? 1 : 0.4,
              child: Text(flag, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppPalette.ink : AppPalette.n700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
