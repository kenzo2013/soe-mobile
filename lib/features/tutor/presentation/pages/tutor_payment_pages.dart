import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/tutor_form_params.dart';
import '../../domain/entities/tutor_payment_method.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';
import '../widgets/tutor_action.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_form_sheets.dart';
import '../widgets/tutor_ui.dart';

// ════════════════════════════════════════════════════════════
// Mes méthodes de paiement
// ════════════════════════════════════════════════════════════
class TutorPaymentMethodsPage extends ConsumerWidget {
  const TutorPaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorPaymentMethodsViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorPayment),
      appBar: const TutorAppBar(
        title: 'Infos de paiement',
        subtitle: 'Mobile Money et compte bancaire',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorPaymentMethodsViewModelProvider.notifier).refresh(),
        ),
        loaded: (methods) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${methods.length} méthode${methods.length > 1 ? "s" : ""} '
              'enregistrée${methods.length > 1 ? "s" : ""} · '
              '${methods.where((m) => m.isDefault).length} par défaut',
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
            const SizedBox(height: 12),
            for (final m in methods)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MethodCard(
                  method: m,
                  onSetDefault: () => runTutorAction(
                    context,
                    ref,
                    actionKey: 'pay_default:${m.id}',
                    successMessage: 'Méthode par défaut mise à jour',
                    popOnSuccess: false,
                    op: () => ref.read(markTutorPaymentDefaultProvider)(m.id),
                    onSuccess: () => ref
                        .read(tutorPaymentMethodsViewModelProvider.notifier)
                        .refresh(),
                  ),
                  onDelete: () async {
                    if (await confirmDelete(context, 'cette méthode') &&
                        context.mounted) {
                      await runTutorAction(
                        context,
                        ref,
                        actionKey: 'pay_del:${m.id}',
                        successMessage: 'Méthode supprimée',
                        popOnSuccess: false,
                        op: () =>
                            ref.read(deleteTutorPaymentMethodProvider)(m.id),
                        onSuccess: () => ref
                            .read(tutorPaymentMethodsViewModelProvider.notifier)
                            .refresh(),
                      );
                    }
                  },
                  onEdit: () {
                    if (m.kind == TutorPaymentKind.bank) {
                      context.push(RouteNames.tutorPaymentAddBank, extra: m);
                    } else {
                      showMobilePaymentSheet(context, ref, existing: m);
                    }
                  },
                  onTap: () =>
                      context.push(RouteNames.tutorPaymentDetail, extra: m),
                ),
              ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                'Ajouter une méthode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _AddMethod(
                    icon: Icons.smartphone_outlined,
                    title: 'Mobile Money',
                    sub: 'MTN · Orange',
                    onTap: () => showMobilePaymentSheet(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AddMethod(
                    icon: Icons.account_balance_outlined,
                    title: 'Compte bancaire',
                    sub: 'IBAN · BIC',
                    onTap: () => context.push(RouteNames.tutorPaymentAddBank),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });
  final TutorPaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = method.kind == TutorPaymentKind.mobile;
    final isMtn = (method.operator ?? '').startsWith('MTN');
    return SoeCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: method.isDefault ? AppPalette.yellow : AppPalette.n300,
              width: method.isDefault ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isMobile
                            ? (isMtn
                                ? const Color(0xFFFFCC00)
                                : const Color(0xFFFF7900))
                            : AppPalette.teal.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: isMobile
                          ? Text(
                              isMtn ? 'MTN' : 'OM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isMtn ? AppPalette.ink : Colors.white,
                              ),
                            )
                          : const Icon(Icons.credit_card,
                              size: 20, color: AppPalette.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isMobile
                                      ? (method.operator ?? '')
                                      : (method.bank ?? ''),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.ink,
                                  ),
                                ),
                              ),
                              if (method.isDefault) ...[
                                const SizedBox(width: 6),
                                const TutorPillBadge(
                                  label: 'Par défaut',
                                  bg: AppPalette.successBg,
                                  fg: AppPalette.success,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isMobile
                                ? (method.phone ?? '')
                                : '…${_last4(method.iban ?? '')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppPalette.n700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.tune,
                          size: 16, color: AppPalette.n700),
                      tooltip: 'Options',
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'default') onSetDefault();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        if (!method.isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text('Définir par défaut'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!method.isDefault)
                InkWell(
                  onTap: onSetDefault,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppPalette.n50,
                      border: Border(top: BorderSide(color: AppPalette.n300)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Définir par défaut',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.teal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _last4(String iban) {
  final clean = iban.replaceAll(' ', '');
  return clean.length <= 4 ? clean : clean.substring(clean.length - 4);
}

class _AddMethod extends StatelessWidget {
  const _AddMethod({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppPalette.teal),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(fontSize: 10, color: AppPalette.n700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Ajouter un compte bancaire
// ════════════════════════════════════════════════════════════
class TutorAddBankPage extends ConsumerStatefulWidget {
  const TutorAddBankPage({super.key, this.existing});

  /// Méthode bancaire à éditer (`null` = création).
  final TutorPaymentMethod? existing;

  @override
  ConsumerState<TutorAddBankPage> createState() => _TutorAddBankPageState();
}

class _TutorAddBankPageState extends ConsumerState<TutorAddBankPage> {
  final _holder = TextEditingController();
  final _bank = TextEditingController();
  final _bankCode = TextEditingController();
  final _agencyCode = TextEditingController();
  final _account = TextEditingController();
  final _key = TextEditingController();
  final _bic = TextEditingController();
  final _iban = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _holder.text = e.holder ?? '';
      _bank.text = e.bank ?? '';
      _bankCode.text = e.bankCode ?? '';
      _agencyCode.text = e.branchCode ?? '';
      _account.text = e.accountNumber ?? '';
      _key.text = e.key ?? '';
      _bic.text = e.bic ?? '';
      _iban.text = e.iban ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _holder,
      _bank,
      _bankCode,
      _agencyCode,
      _account,
      _key,
      _bic,
      _iban,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final actionKey = isEdit ? 'bank_edit:${widget.existing!.id}' : 'add_bank';
    final submitting = ref.watch(tutorActionViewModelProvider(actionKey))
        is TutorActionSubmitting;
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: isEdit
            ? 'Modifier le compte bancaire'
            : 'Ajouter un compte bancaire',
        subtitle: 'Coordonnées de versement',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.infoBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: AppPalette.info),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos coordonnées bancaires sont chiffrées et ne sont '
                    'utilisées que pour les versements de rémunération.',
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
          _title('Titulaire'),
          SoeCard(
            child: _BankField(
              label: 'Titulaire du compte',
              hint: 'Paul Mbarga',
              icon: Icons.person_outline,
              controller: _holder,
            ),
          ),
          const SizedBox(height: 14),
          _title('Banque'),
          SoeCard(
            child: Column(
              children: [
                _BankField(
                  label: 'Nom de la banque',
                  hint: 'Afriland First Bank',
                  icon: Icons.account_balance_outlined,
                  controller: _bank,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _BankField(
                          label: 'Code banque',
                          hint: '10004',
                          controller: _bankCode),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BankField(
                          label: 'Code agence',
                          hint: '00100',
                          controller: _agencyCode),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _title('Compte'),
          SoeCard(
            child: Column(
              children: [
                _BankField(
                  label: 'Numéro de compte',
                  hint: '11234567890',
                  icon: Icons.credit_card,
                  controller: _account,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _BankField(
                          label: 'Clé', hint: '45', controller: _key),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BankField(
                          label: 'BIC', hint: 'CCEICMCX', controller: _bic),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _BankField(
                  label: 'IBAN',
                  hint: 'CM21 1000 4001 1234 5678 9012 345',
                  icon: Icons.public,
                  controller: _iban,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SoeButton(
            label: isEdit
                ? 'Enregistrer les modifications'
                : 'Enregistrer le compte',
            fullWidth: true,
            loading: submitting,
            onPressed: () => runTutorAction(
              context,
              ref,
              actionKey: actionKey,
              successMessage: isEdit ? 'Compte modifié' : 'Compte enregistré',
              op: () => ref.read(addTutorBankPaymentProvider)(
                TutorBankPaymentParams(
                  accountHolder: _holder.text.trim(),
                  bankName: _bank.text.trim(),
                  iban: _iban.text.trim(),
                  bic: _bic.text.trim(),
                  accountNumber: _account.text.trim(),
                  key: _key.text.trim(),
                  bankCode: _bankCode.text.trim(),
                  agencyCode: _agencyCode.text.trim(),
                ),
                id: widget.existing?.id,
              ),
              onSuccess: () => ref
                  .read(tutorPaymentMethodsViewModelProvider.notifier)
                  .refresh(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
      );
}

class _BankField extends StatelessWidget {
  const _BankField({
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
  });
  final TextEditingController? controller;
  final String label;
  final String hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppPalette.n700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppPalette.n50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppPalette.n300),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppPalette.teal),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration.collapsed(hintText: hint),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// Détail d'un moyen de paiement
// ════════════════════════════════════════════════════════════
class TutorPaymentDetailPage extends ConsumerWidget {
  const TutorPaymentDetailPage({super.key, required this.method});
  final TutorPaymentMethod method;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Résout la version à jour depuis la liste (reflète une édition / passage
    // par défaut sans recharger), avec repli sur le snapshot reçu.
    final state = ref.watch(tutorPaymentMethodsViewModelProvider);
    var m = method;
    if (state is AsyncListLoaded<TutorPaymentMethod>) {
      for (final e in state.items) {
        if (e.id == method.id) m = e;
      }
    }
    final isMobile = m.kind == TutorPaymentKind.mobile;
    final isMtn = (m.operator ?? '').startsWith('MTN');

    final rows = <(String, String?)>[
      if (isMobile) ...[
        ('Opérateur', m.operator),
        ('Numéro', m.phone),
      ] else ...[
        ('Titulaire', m.holder),
        ('Banque', m.bank),
        ('Code banque', m.bankCode),
        ('Code agence', m.branchCode),
        ('Numéro de compte', m.accountNumber),
        ('Clé', m.key),
        ('BIC', m.bic),
        ('IBAN', m.iban),
      ],
    ].where((r) => (r.$2 ?? '').isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: TutorAppBar(
        title: isMobile ? 'Détail Mobile Money' : 'Détail compte bancaire',
        subtitle: 'Moyen de versement',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête
          SoeCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isMobile
                        ? (isMtn
                            ? const Color(0xFFFFCC00)
                            : const Color(0xFFFF7900))
                        : AppPalette.teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: isMobile
                      ? Text(
                          isMtn ? 'MTN' : 'OM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isMtn ? AppPalette.ink : Colors.white,
                          ),
                        )
                      : const Icon(Icons.account_balance_outlined,
                          size: 22, color: AppPalette.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMobile
                            ? (m.operator ?? 'Mobile Money')
                            : (m.bank ?? 'Compte bancaire'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (m.isDefault)
                        const TutorPillBadge(
                          label: 'Par défaut',
                          bg: AppPalette.warningBg,
                          fg: AppPalette.warning,
                        )
                      else
                        Text(
                          isMobile ? 'Mobile Money' : 'Compte bancaire',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.n700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Détails
          SoeCard(
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 18, color: AppPalette.n100),
                  _DetailRow(label: rows[i].$1, value: rows[i].$2!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!m.isDefault) ...[
            SoeButton(
              label: 'Définir par défaut',
              variant: SoeButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => runTutorAction(
                context,
                ref,
                actionKey: 'pay_default:${m.id}',
                successMessage: 'Méthode par défaut mise à jour',
                popOnSuccess: false,
                op: () => ref.read(markTutorPaymentDefaultProvider)(m.id),
                onSuccess: () => ref
                    .read(tutorPaymentMethodsViewModelProvider.notifier)
                    .refresh(),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SoeButton(
            label: 'Modifier',
            fullWidth: true,
            onPressed: () {
              if (m.kind == TutorPaymentKind.bank) {
                context.push(RouteNames.tutorPaymentAddBank, extra: m);
              } else {
                showMobilePaymentSheet(context, ref, existing: m);
              }
            },
          ),
          const SizedBox(height: 10),
          SoeButton(
            label: 'Supprimer',
            variant: SoeButtonVariant.danger,
            fullWidth: true,
            onPressed: () async {
              if (await confirmDelete(context, 'cette méthode') &&
                  context.mounted) {
                await runTutorAction(
                  context,
                  ref,
                  actionKey: 'pay_del:${m.id}',
                  successMessage: 'Méthode supprimée',
                  op: () => ref.read(deleteTutorPaymentMethodProvider)(m.id),
                  onSuccess: () => ref
                      .read(tutorPaymentMethodsViewModelProvider.notifier)
                      .refresh(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppPalette.n700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.ink,
              ),
            ),
          ),
        ],
      );
}
