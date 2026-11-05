import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/avatar_picker_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// The largest photo the API takes (5 MB).
const int _maxPhotoBytes = 5 * 1024 * 1024;

/// A short-lived link to the profile photo (never stored), when the account has one.
final profilePhotoUrlProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || !user.hasPhoto) return null;
  return ref.watch(accountApiProvider).photoUrl();
});

/// The 9 digits of a Cameroonian number, without 237.
String _phoneDigits(String? phone) {
  final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('237') && digits.length == 12
      ? digits.substring(3)
      : digits;
}

/// COM-02 — photo, civility, language, first and last name; the phone and e-mail change once
/// the 6-digit code is entered (the current password is asked for them).
class AccountPersonalInfoPage extends ConsumerWidget {
  const AccountPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.personal;
    final user = ref.watch(currentUserProvider);
    final loaded = user.valueOrNull;
    if (loaded != null) return _PersonalForm(user: loaded);
    return AccountScaffold(title: tr.title, crumb: tr.crumb, children: [
      AccountAsync<User?>(
        value: user,
        onRetry: () => ref.invalidate(currentUserProvider),
        builder: (_) => const SizedBox.shrink(),
      ),
    ]);
  }
}

class _PersonalForm extends ConsumerStatefulWidget {
  const _PersonalForm({required this.user});

  final User user;

  @override
  ConsumerState<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends ConsumerState<_PersonalForm> {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone =
      TextEditingController(text: _phoneDigits(widget.user.phone));
  late final _email = TextEditingController(text: widget.user.email);
  final _password = TextEditingController();
  late String? _civility = widget.user.civility;
  late String _lang = widget.user.lang == 'en' ? 'en' : 'fr';
  File? _photo;
  bool _saving = false;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _phone.addListener(_refresh);
    _email.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _phone,
      _email,
      _password
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// The contact change typed, e-mail first (one change at a time): `(field, value)` or null.
  (String, String)? get _contactChange {
    final email = _email.text.trim();
    if (email.isNotEmpty &&
        email.toLowerCase() != widget.user.email.toLowerCase()) {
      return ('email', email);
    }
    final phone = _phoneDigits(_phone.text);
    if (phone.isNotEmpty && phone != _phoneDigits(widget.user.phone)) {
      return ('phone', phone);
    }
    return null;
  }

  bool get _profileChanged =>
      _photo != null ||
      _civility != widget.user.civility ||
      _lang != (widget.user.lang == 'en' ? 'en' : 'fr') ||
      _firstName.text.trim() != widget.user.firstName ||
      _lastName.text.trim() != widget.user.lastName;

  Future<void> _pickPhoto() async {
    final file = await AvatarPickerService.pick(context);
    if (file == null || !mounted) return;
    if (await file.length() > _maxPhotoBytes) {
      if (!mounted) return;
      SoeToast.show(context,
          message: Translations.of(context).accountSpace.personal.photoTooBig,
          tone: SoeToastTone.danger);
      return;
    }
    setState(() => _photo = file);
  }

  Future<void> _save() async {
    final tr = Translations.of(context).accountSpace.personal;
    final contact = _contactChange;
    setState(() {
      _saving = true;
      _error = null;
    });
    final api = ref.read(accountApiProvider);
    try {
      if (_profileChanged) {
        final json = await api.updateProfile(
          civility: _civility,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          lang: _lang,
          photo: _photo,
        );
        await _storeUser(json);
        if (_lang != ref.read(localeProvider).languageCode) {
          await ref
              .read(localeProvider.notifier)
              .set(_lang == 'en' ? AppLocale.en : AppLocale.fr);
        }
        _photo = null;
      }
      if (contact == null) {
        if (mounted) {
          SoeToast.show(context, message: tr.saved);
        }
        return;
      }
      final change = await api.requestContactChange(
          field: contact.$1,
          value: contact.$2,
          currentPassword: _password.text);
      _password.clear();
      if (mounted) await _askCode(change);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure);
      SoeToast.show(context,
          message: accountFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _storeUser(Map<String, dynamic> json) async {
    await cacheCurrentUser(
        ref.read(secureStorageProvider), AuthRepositoryImpl.userFromApi(json));
    ref.invalidate(currentUserProvider);
  }

  Future<void> _askCode(ContactChange change) async {
    final tr = Translations.of(context).accountSpace.personal;
    final confirmed = await showAccountSheet<bool>(
      context,
      title: change.isPhone ? tr.codeTitlePhone : tr.codeTitleEmail,
      builder: (sheetContext) => _CodeSheet(change: change),
    );
    if (confirmed == true && mounted) {
      SoeToast.show(context,
          message: change.isPhone ? tr.phoneChanged : tr.emailChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.personal;
    final photoUrl = ref.watch(profilePhotoUrlProvider).valueOrNull;
    final asksPassword = _contactChange != null;
    return AccountScaffold(
      title: tr.title,
      crumb: tr.crumb,
      bottom: SoeButton(
        label: tr.save,
        fullWidth: true,
        loading: _saving,
        onPressed: _saving ? null : () => unawaited(_save()),
      ),
      children: [
        AccountPageTitle(tr.title),
        AccountCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AccountFieldLabel(tr.photo, hint: tr.optional),
            InkWell(
              onTap: () => unawaited(_pickPhoto()),
              child: Row(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppPalette.surfaceSoft,
                  backgroundImage: _photo != null
                      ? FileImage(_photo!)
                      : photoUrl != null
                          ? NetworkImage(photoUrl) as ImageProvider
                          : null,
                  child: _photo == null && photoUrl == null
                      ? const Icon(Icons.photo_camera_outlined,
                          color: AppPalette.text2)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _photo != null || widget.user.hasPhoto
                                ? tr.changePhoto
                                : tr.addPhoto,
                            style: AppTypography.label
                                .copyWith(color: AppPalette.teal500)),
                        Text(tr.photoHint,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      ]),
                ),
              ]),
            ),
            AccountFieldLabel(tr.civility),
            AccountSegmented<String>(
              options: [
                (value: 'mr', label: tr.mr),
                (value: 'mrs', label: tr.mrs),
              ],
              selected: _civility,
              onChanged: (value) => setState(() => _civility = value),
            ),
            AccountFieldLabel(tr.language),
            DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppPalette.border, width: 1.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: DropdownButton<String>(
                  value: _lang,
                  items: [
                    DropdownMenuItem(
                        value: 'fr',
                        child: Text(Translations.of(context).languages.fr)),
                    DropdownMenuItem(
                        value: 'en',
                        child: Text(Translations.of(context).languages.en)),
                  ],
                  onChanged: (value) => setState(() => _lang = value ?? _lang),
                ),
              ),
            ),
            AccountFieldLabel(tr.firstName),
            SoeTextField(
                controller: _firstName,
                maxLength: 60,
                errorText: fieldError(_error, 'first_name')),
            AccountFieldLabel(tr.lastName),
            SoeTextField(
                controller: _lastName,
                maxLength: 60,
                errorText: fieldError(_error, 'last_name')),
            AccountFieldLabel(tr.phone),
            SoeTextField(
              controller: _phone,
              leadingIcon: Icons.phone_outlined,
              hint: tr.phoneHint,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))
              ],
              errorText: _contactChange?.$1 == 'phone'
                  ? fieldError(_error, 'contact_value')
                  : null,
            ),
            _Hint(tr.codeHint),
            AccountFieldLabel(tr.email),
            SoeTextField(
              controller: _email,
              leadingIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              errorText: _contactChange?.$1 == 'email'
                  ? fieldError(_error, 'contact_value')
                  : null,
            ),
            _Hint(tr.codeHint),
            if (asksPassword) ...[
              AccountFieldLabel(tr.currentPassword),
              SoePasswordField(
                controller: _password,
                label: '',
                hint: tr.currentPassword,
                errorText: fieldError(_error, 'current_password'),
              ),
              _Hint(tr.currentPasswordHint),
            ],
          ]),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      );
}

/// The 6-digit code of a phone or e-mail change, with « Renvoyer » after its delay.
class _CodeSheet extends ConsumerStatefulWidget {
  const _CodeSheet({required this.change});

  final ContactChange change;

  @override
  ConsumerState<_CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends ConsumerState<_CodeSheet> {
  late ContactChange _change = widget.change;
  late int _wait = widget.change.resendIn;
  Timer? _timer;
  String _code = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_wait <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _wait--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final json =
          await ref.read(accountApiProvider).confirmContactChange(_code);
      await cacheCurrentUser(ref.read(secureStorageProvider),
          AuthRepositoryImpl.userFromApi(json));
      ref.invalidate(currentUserProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (failure) {
      if (mounted) {
        setState(() => _error = accountFailureMessage(context, failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      final change = await ref.read(accountApiProvider).resendContactChange();
      setState(() {
        _change = change;
        _wait = change.resendIn;
        _error = null;
      });
      _startTimer();
    } on Failure catch (failure) {
      if (mounted) {
        setState(() => _error = accountFailureMessage(context, failure));
      }
    }
  }

  Future<void> _cancel() async {
    final navigator = Navigator.of(context);
    try {
      await ref.read(accountApiProvider).cancelContactChange();
    } on Failure catch (_) {
      // The pending change expires on its own.
    }
    navigator.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.personal;
    final minutes = _change.expiresAt == null
        ? 15
        : _change.expiresAt!.difference(DateTime.now()).inMinutes.clamp(1, 60);
    final wait = '${_wait ~/ 60}:${(_wait % 60).toString().padLeft(2, '0')}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(tr.codeSent(to: _change.codeSentTo, minutes: minutes),
          style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      AccountFieldLabel(tr.code),
      SoeOtpField(
        errorText: _error,
        onChanged: (code) => setState(() => _code = code),
        onCompleted: (code) {
          _code = code;
          unawaited(_confirm());
        },
      ),
      const SizedBox(height: 8),
      if (_wait > 0)
        Text(tr.resendIn(time: wait),
            style: AppTypography.caption.copyWith(color: AppPalette.text2))
      else
        Align(
          alignment: Alignment.centerLeft,
          child: SoeButton(
            label: tr.resend,
            variant: SoeButtonVariant.tertiary,
            size: SoeButtonSize.sm,
            onPressed: () => unawaited(_resend()),
          ),
        ),
      const SizedBox(height: 16),
      SoeButton(
        label: tr.confirm,
        variant: SoeButtonVariant.secondary,
        fullWidth: true,
        loading: _busy,
        onPressed:
            _code.length == 6 && !_busy ? () => unawaited(_confirm()) : null,
      ),
      const SizedBox(height: 8),
      SoeButton(
        label: tr.cancel,
        variant: SoeButtonVariant.tertiary,
        fullWidth: true,
        onPressed: () => unawaited(_cancel()),
      ),
    ]);
  }
}
