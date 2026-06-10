import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// 3 · Changer le mot de passe (design `CommonPassword`).
class AccountPasswordPage extends ConsumerStatefulWidget {
  const AccountPasswordPage({super.key});

  @override
  ConsumerState<AccountPasswordPage> createState() =>
      _AccountPasswordPageState();
}

class _AccountPasswordPageState extends ConsumerState<AccountPasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Rebuild la jauge de force à chaque frappe.
    _next.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Force du mot de passe sur 4 niveaux (longueur, chiffre, lettre, casse mixte).
  int get _strength {
    final p = _next.text;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[a-zA-Z]').hasMatch(p)) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    return s;
  }

  String get _strengthLabel => switch (_strength) {
        0 || 1 => 'Mot de passe faible',
        2 => 'Mot de passe moyen',
        3 => 'Mot de passe correct',
        _ => 'Mot de passe fort',
      };

  Color get _strengthColor => switch (_strength) {
        0 || 1 => AppPalette.danger,
        2 => AppPalette.warning,
        _ => AppPalette.success,
      };

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_current.text.isEmpty) {
      setState(() => _error = 'Saisissez votre mot de passe actuel.');
      return;
    }
    if (_next.text.length < 8) {
      setState(() => _error = 'Le nouveau mot de passe doit faire 8 caractères.');
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'La confirmation ne correspond pas.');
      return;
    }
    await runCommonAction(
      context,
      ref,
      actionKey: 'password',
      successMessage: 'Mot de passe mis à jour',
      op: () => ref.read(commonRepositoryProvider).updatePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
            confirmation: _confirm.text,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(commonActionViewModelProvider('password'))
        is CommonActionSubmitting;
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const CommonTopBar(
        title: 'Changer le mot de passe',
        subtitle: 'Sécurité du compte',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.infoBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lock_outline, size: 16, color: AppPalette.info),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Pour votre sécurité, choisissez un mot de passe d'au moins "
                    '8 caractères avec lettres et chiffres.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppPalette.info,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoeCard(
            child: SoePasswordField(
              controller: _current,
              label: 'Mot de passe actuel',
              hint: 'Votre mot de passe actuel',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nouveau mot de passe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 12),
          SoeCard(
            child: Column(
              children: [
                SoePasswordField(
                  controller: _next,
                  label: 'Nouveau',
                  hint: '8 caractères minimum',
                  onFieldSubmitted: (_) {},
                ),
                const SizedBox(height: 12),
                SoePasswordField(
                  controller: _confirm,
                  label: 'Confirmation',
                  hint: 'Répétez le mot de passe',
                ),
                if (_next.text.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _StrengthBar(level: _strength, color: _strengthColor),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _strengthLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _strengthColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: AppPalette.danger),
            ),
          ],
          const SizedBox(height: 24),
          SoeButton(
            label: 'Mettre à jour',
            fullWidth: true,
            loading: submitting,
            onPressed: submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.level, required this.color});
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < level ? color : AppPalette.n300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
