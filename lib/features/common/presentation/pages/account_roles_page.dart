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
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers.dart' show authRepositoryProvider;
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// COM-05 — the roles of the account: the active one, a switch to the other, « Devenir
/// répétiteur » (then the recruitment file) or « Ajouter un profil parent », and the space
/// opened after sign-in.
class AccountRolesPage extends ConsumerStatefulWidget {
  const AccountRolesPage({super.key});

  @override
  ConsumerState<AccountRolesPage> createState() => _AccountRolesPageState();
}

class _AccountRolesPageState extends ConsumerState<AccountRolesPage> {
  bool _busy = false;

  /// Runs a role change; when the active role changed, the app opens that space.
  Future<void> _run(Future<AccountRoles> Function() call,
      {String? message}) async {
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final previous = ref.read(currentRoleProvider);
    try {
      final roles = await call();
      ref.invalidate(accountRolesProvider);
      if (roles.currentRole != previous) {
        await _enterRole(roles.currentRole);
        router.go(roles.currentRole == 'tutor'
            ? RouteNames.tutorDashboard
            : RouteNames.parentDashboard);
      }
      if (mounted && message != null) SoeToast.show(context, message: message);
    } on Failure catch (failure) {
      if (mounted) {
        SoeToast.show(context,
            message: accountFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enterRole(String role) async {
    await ref.read(secureStorageProvider).write(StorageKeys.currentRole, role);
    ref.read(currentRoleProvider.notifier).state = role;
    await ref.read(authRepositoryProvider).fetchCurrentUser();
    ref.invalidate(currentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.roles;
    final value = ref.watch(accountRolesProvider);
    final api = ref.read(accountApiProvider);
    return AccountScaffold(
      title: tr.crumbTitle,
      crumb: tr.crumb,
      onRefresh: () => ref.refresh(accountRolesProvider.future),
      children: [
        AccountPageTitle(tr.title, subtitle: tr.intro),
        AccountAsync(
          value: value,
          onRetry: () => ref.invalidate(accountRolesProvider),
          builder: (roles) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final role in roles.roles)
              AccountCard(
                padding: EdgeInsets.zero,
                child: AccountRow(
                  icon: role.role == 'tutor'
                      ? Icons.school_outlined
                      : Icons.person_outline,
                  title: role.label,
                  divider: false,
                  trailing: role.role == roles.currentRole
                      ? SoeBadge(label: tr.active, tone: SoeBadgeTone.success)
                      : SoeButton(
                          label: tr.switchTo,
                          variant: SoeButtonVariant.outline,
                          size: SoeButtonSize.sm,
                          onPressed: _busy
                              ? null
                              : () => unawaited(
                                  _run(() => api.switchRole(role.role))),
                        ),
                ),
              ),
            if (roles.addableRole != null)
              AccountCard(
                soft: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountCardTitle(roles.addableRole == 'tutor'
                          ? tr.becomeTutor
                          : tr.addParent),
                      Text(
                          roles.addableRole == 'tutor'
                              ? tr.becomeTutorText
                              : tr.addParentText,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.text2)),
                      const SizedBox(height: 16),
                      SoeButton(
                        label: roles.addableRole == 'tutor'
                            ? tr.becomeTutor
                            : tr.addParent,
                        size: SoeButtonSize.md,
                        loading: _busy,
                        onPressed: _busy
                            ? null
                            : () => unawaited(_run(
                                () => api.addRole(roles.addableRole!),
                                message: roles.addableRole == 'tutor'
                                    ? tr.addedTutor
                                    : tr.addedParent)),
                      ),
                    ]),
              ),
            if (roles.multiRole)
              AccountCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountCardTitle(tr.defaultTitle),
                      Text(tr.defaultText,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.text2)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final option in <({String? value, String label})>[
                          (value: null, label: tr.defaultLast),
                          for (final role in roles.roles)
                            (value: role.role, label: role.label),
                        ])
                          SoeChip(
                            label: option.label,
                            selected: option.value == roles.preferredRole,
                            onTap: _busy
                                ? null
                                : () => unawaited(_run(
                                    () => api.setDefaultRole(option.value),
                                    message: tr.defaultSaved)),
                          ),
                      ]),
                    ]),
              ),
          ]),
        ),
      ],
    );
  }
}
