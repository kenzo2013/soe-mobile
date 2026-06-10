import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers.dart' show authRepositoryProvider;
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// Métadonnées d'affichage d'un rôle. Les libellés sont résolus via `tr` au
/// point d'usage (voir [_roleLabel] / [_roleDesc]).
class _RoleMeta {
  const _RoleMeta(this.key, this.icon);
  final String key;
  final IconData icon;
}

const _parentMeta = _RoleMeta('parent', Icons.group_outlined);
const _tutorMeta = _RoleMeta('tutor', Icons.school_outlined);

String _roleLabel(Translations tr, _RoleMeta meta) =>
    meta.key == 'tutor' ? tr.account.role.tutorLabel : tr.account.role.parentLabel;

String _roleDesc(Translations tr, _RoleMeta meta) =>
    meta.key == 'tutor' ? tr.account.role.tutorDesc : tr.account.role.parentDesc;

/// 5 · Mon rôle — switch / ajout (design `CommonRoleSwitch`).
class AccountRolePage extends ConsumerWidget {
  const AccountRolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final user = ref.watch(currentUserProvider).asData?.value;
    final currentKey =
        ref.watch(currentRoleProvider) ?? user?.role.apiValue ?? 'parent';
    final multiRole = user?.multiRole ?? false;

    final current = currentKey == 'tutor' ? _tutorMeta : _parentMeta;
    final other = currentKey == 'tutor' ? _parentMeta : _tutorMeta;
    final submitting = ref.watch(commonActionViewModelProvider('role'))
        is CommonActionSubmitting;

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.account.role.title,
        subtitle: tr.account.role.subtitle,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              tr.account.role.activeSectionLabel,
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
          ),
          _ActiveRoleCard(meta: current),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              tr.account.role.otherSectionLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
              ),
            ),
          ),
          if (multiRole)
            _OtherRoleCard(
              meta: other,
              actionLabel: tr.account.role.switchAction,
              loading: submitting,
              onTap: submitting
                  ? null
                  : () => _switch(context, ref, other.key),
            )
          else ...[
            _OtherRoleCard(
              meta: other,
              subtitle: tr.account.role.notActivated,
            ),
            const SizedBox(height: 12),
            _AddRoleButton(
              label: other.key == 'tutor'
                  ? tr.account.role.becomeTutor
                  : tr.account.role.becomeParent,
              loading: submitting,
              onTap:
                  submitting ? null : () => _add(context, ref, other.key),
            ),
            const SizedBox(height: 10),
            Text(
              other.key == 'tutor'
                  ? tr.account.role.addTutorHint
                  : tr.account.role.addParentHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppPalette.n700,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _switch(BuildContext context, WidgetRef ref, String role) async {
    final tr = Translations.of(context);
    final ok = await runCommonAction(
      context,
      ref,
      actionKey: 'role',
      successMessage: tr.account.role.switched,
      popOnSuccess: false,
      op: () => ref.read(commonRepositoryProvider).switchRole(role),
      onSuccess: () => ref.read(currentRoleProvider.notifier).state = role,
    );
    if (!ok) return;
    // Rafraîchit le user (rôle actif + multi_role) depuis le serveur.
    await ref.read(authRepositoryProvider).fetchCurrentUser();
    ref.invalidate(currentUserProvider);
    if (context.mounted) {
      context.go(role == 'tutor'
          ? RouteNames.tutorDashboard
          : RouteNames.parentDashboard);
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref, String role) async {
    final tr = Translations.of(context);
    final ok = await runCommonAction(
      context,
      ref,
      actionKey: 'role',
      successMessage: tr.account.role.added,
      popOnSuccess: false,
      op: () => ref.read(commonRepositoryProvider).addRole(role),
    );
    if (!ok) return;
    // Recharge le user pour refléter `multi_role` (sinon la bascule reste
    // masquée jusqu'à la prochaine connexion).
    await ref.read(authRepositoryProvider).fetchCurrentUser();
    ref.invalidate(currentUserProvider);
  }
}

class _ActiveRoleCard extends StatelessWidget {
  const _ActiveRoleCard({required this.meta});
  final _RoleMeta meta;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppPalette.brandGradient,
        border: Border.all(color: AppPalette.yellow, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, size: 22, color: AppPalette.yellow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _roleLabel(tr, meta),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roleDesc(tr, meta),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppPalette.success,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              tr.account.role.activeBadge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherRoleCard extends StatelessWidget {
  const _OtherRoleCard({
    required this.meta,
    this.subtitle,
    this.actionLabel,
    this.loading = false,
    this.onTap,
  });
  final _RoleMeta meta;
  final String? subtitle;
  final String? actionLabel;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.n300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, size: 18, color: AppPalette.n700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _roleLabel(tr, meta),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? _roleDesc(tr, meta),
                  style: const TextStyle(fontSize: 11, color: AppPalette.n700),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onTap,
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.teal,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _AddRoleButton extends StatelessWidget {
  const _AddRoleButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppPalette.n500,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              const Icon(Icons.add, size: 16, color: AppPalette.teal),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.teal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
