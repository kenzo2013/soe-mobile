import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// COM-03 — the password (AUT-05 rules; the new token returned is kept, the other devices must
/// sign in again), this device, and the way to the account deletion.
class AccountSecurityPage extends ConsumerStatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  ConsumerState<AccountSecurityPage> createState() =>
      _AccountSecurityPageState();
}

class _AccountSecurityPageState extends ConsumerState<AccountSecurityPage> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  Failure? _error;
  String? _mismatch;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    final tr = Translations.of(context).accountSpace.security;
    if (_password.text != _confirmation.text) {
      setState(() => _mismatch = tr.mismatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _mismatch = null;
    });
    try {
      final session = await ref.read(accountApiProvider).changePassword(
          currentPassword: _current.text,
          password: _password.text,
          confirmation: _confirmation.text);
      await _keepSession(session);
      _current.clear();
      _password.clear();
      _confirmation.clear();
      if (mounted) SoeToast.show(context, message: tr.changed);
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

  /// Every earlier token is revoked: this device goes on with the new one.
  Future<void> _keepSession(Map<String, dynamic> session) async {
    final token = session['token'] as String?;
    if (token == null || token.isEmpty) return;
    final storage = ref.read(secureStorageProvider);
    await storage.write(StorageKeys.authToken, token);
    final user = session['user'];
    if (user is Map<String, dynamic>) {
      await cacheCurrentUser(storage, AuthRepositoryImpl.userFromApi(user));
    }
    ref.read(authTokenProvider.notifier).state = token;
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.security;
    return AccountScaffold(
      title: tr.title,
      crumb: tr.crumb,
      children: [
        AccountPageTitle(tr.title),
        AccountCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AccountCardTitle(tr.password),
            SoePasswordField(
              controller: _current,
              label: tr.currentPassword,
              hint: tr.currentPassword,
              errorText: fieldError(_error, 'current_password'),
            ),
            const SizedBox(height: 16),
            SoePasswordField(
              controller: _password,
              label: tr.newPassword,
              hint: tr.newPassword,
              errorText: fieldError(_error, 'password'),
            ),
            const SizedBox(height: 6),
            Text(tr.rules,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 16),
            SoePasswordField(
              controller: _confirmation,
              label: tr.confirmation,
              hint: tr.confirmation,
              errorText:
                  _mismatch ?? fieldError(_error, 'password_confirmation'),
            ),
          ]),
        ),
        AccountCard(
          soft: true,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.change,
              variant: SoeButtonVariant.secondary,
              size: SoeButtonSize.md,
              loading: _saving,
              onPressed: _saving ? null : () => unawaited(_change()),
            ),
          ),
        ),
        AccountCard(
          padding: EdgeInsets.zero,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AccountCardTitle(tr.devices),
            ),
            AccountRow(
              icon: Icons.phone_android,
              title: tr.thisDevice,
              subtitle: tr.application,
              trailing: SoeBadge(label: tr.current, tone: SoeBadgeTone.success),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Text(tr.devicesHelp,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ),
          ]),
        ),
        AccountCard(
          soft: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AccountCardTitle(tr.deleteTitle),
            Text(tr.deleteText,
                style: AppTypography.body.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 16),
            SoeButton(
              label: tr.deleteTitle,
              variant: SoeButtonVariant.dangerOutline,
              size: SoeButtonSize.md,
              onPressed: () =>
                  unawaited(context.push(RouteNames.accountDeletion)),
            ),
          ]),
        ),
      ],
    );
  }
}

/// COM-03 « Supprimer mon compte »: what goes, what stays (legal), then the password and « Je
/// comprends que la suppression est définitive »; or why it is not possible yet and how to
/// clear it.
class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() =>
      _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final _password = TextEditingController();
  bool _understood = false;
  bool _deleting = false;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final tr = Translations.of(context).accountSpace.deletion;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await ref.read(accountApiProvider).deleteAccount(_password.text);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = failure;
      });
      if (failure is ConflictFailure) ref.invalidate(deletionCheckProvider);
      SoeToast.show(context,
          message: accountFailureMessage(context, failure),
          tone: SoeToastTone.danger);
      return;
    }
    // The token no longer works: nothing of the account stays on the phone.
    final storage = ref.read(secureStorageProvider);
    for (final key in [
      StorageKeys.authToken,
      StorageKeys.currentUser,
      StorageKeys.currentRole,
    ]) {
      await storage.delete(key);
    }
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentRoleProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
    router.go(RouteNames.login);
    messenger.showSnackBar(SnackBar(content: Text(tr.deleted)));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.deletion;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    final check = ref.watch(deletionCheckProvider);
    final allowed = check.valueOrNull?.allowed ?? false;
    return AccountScaffold(
      title: Translations.of(context).accountSpace.security.title,
      crumb: Translations.of(context).accountSpace.security.crumb,
      bottom: allowed
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              SoeButton(
                label: tr.cancel,
                variant: SoeButtonVariant.tertiary,
                fullWidth: true,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 8),
              SoeButton(
                label: tr.submit,
                variant: SoeButtonVariant.dangerOutline,
                fullWidth: true,
                loading: _deleting,
                onPressed:
                    _understood && _password.text.isNotEmpty && !_deleting
                        ? () => unawaited(_delete())
                        : null,
              ),
            ])
          : null,
      children: [
        AccountAsync(
          value: check,
          onRetry: () => ref.invalidate(deletionCheckProvider),
          builder: (check) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: check.allowed
                ? _allowed(context, tutor)
                : _blocked(context, check.blockers.map((b) => b.label),
                    check.blockers.map((b) => b.step)),
          ),
        ),
      ],
    );
  }

  List<Widget> _allowed(BuildContext context, bool tutor) {
    final tr = Translations.of(context).accountSpace.deletion;
    final removed = tutor ? tr.removedTutor : tr.removedParent;
    final kept = tutor ? tr.keptTutor : tr.keptParent;
    return [
      AccountPageTitle(tr.title, subtitle: tr.definitive),
      AccountCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AccountCardTitle(tr.removed),
          for (final line in removed)
            _Line(
                icon: Icons.delete_outline,
                color: AppPalette.danger,
                text: line),
        ]),
      ),
      AccountCard(
        soft: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AccountCardTitle(tr.kept),
          Text(tr.keptIntro,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 8),
          for (final line in kept)
            _Line(
                icon: Icons.lock_outline,
                color: AppPalette.teal500,
                text: line),
        ]),
      ),
      AccountCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AccountCardTitle(tr.confirm),
          SoePasswordField(
            controller: _password,
            label: tr.password,
            hint: tr.password,
            errorText: fieldError(_error, 'password'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _understood ? AppPalette.teal500 : AppPalette.border,
                  width: 1.5),
            ),
            child: _UnderstandBox(
              value: _understood,
              label: tr.understand,
              onChanged: (value) => setState(() => _understood = value),
            ),
          ),
        ]),
      ),
    ];
  }

  List<Widget> _blocked(
      BuildContext context, Iterable<String> labels, Iterable<String> steps) {
    final tr = Translations.of(context).accountSpace.deletion;
    final list = labels.toList();
    final details = list.length <= 1
        ? list.join()
        : '${list.sublist(0, list.length - 1).join(', ')} ${tr.and} ${list.last}';
    return [
      AccountPageTitle(tr.title),
      AccountCard(
        color: AppPalette.dangerBg,
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_rounded, color: AppPalette.dangerText),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.blockedTitle,
                  style: AppTypography.labelSm
                      .copyWith(color: AppPalette.dangerText)),
              const SizedBox(height: 4),
              Text(tr.blockedBody(details: details),
                  style: AppTypography.bodySm.copyWith(color: AppPalette.text)),
            ]),
          ),
        ]),
      ),
      AccountCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AccountCardTitle(tr.toDelete),
          for (final step in steps)
            _Line(
                icon: Icons.arrow_forward,
                color: AppPalette.teal500,
                text: step),
          const SizedBox(height: 16),
          SoeButton(
            label: tr.contactSoe,
            size: SoeButtonSize.md,
            onPressed: () => unawaited(context.push(RouteNames.help)),
          ),
        ]),
      ),
    ];
  }
}

/// The checkbox of the deletion: the whole row toggles it.
class _UnderstandBox extends StatelessWidget {
  const _UnderstandBox(
      {required this.value, required this.label, required this.onChanged});

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        value: value,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppPalette.teal500,
        title: Text(label,
            style: AppTypography.labelSm.copyWith(color: AppPalette.text)),
        onChanged: (value) => onChanged(value ?? false),
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text))),
        ]),
      );
}
