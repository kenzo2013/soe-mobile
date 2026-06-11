import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../domain/entities/service_contract.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// Détail d'un contrat : contenu, signature, avenants (CDC §6).
class ContractDetailPage extends ConsumerWidget {
  const ContractDetailPage({super.key, required this.contract});

  final ServiceContract contract;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final lang = ref.watch(currentUserProvider).asData?.value?.lang ?? 'fr';
    // Reprend la version à jour depuis le provider (après signature).
    final c = ref.watch(contractsProvider).maybeWhen(
          data: (list) => list.firstWhere(
            (x) => x.id == contract.id,
            orElse: () => contract,
          ),
          orElse: () => contract,
        );

    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: c.reference,
        subtitle: c.signed ? tr.contracts.signed : tr.contracts.toSign,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statut
          _StatusBadge(signed: c.signed),
          const SizedBox(height: 14),
          // Contenu
          SoeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.contracts.contentTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  c.content(lang),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppPalette.n700,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          if (!c.signed) ...[
            const SizedBox(height: 16),
            SoeButton(
              label: tr.contracts.sign,
              icon: Icons.draw_outlined,
              fullWidth: true,
              onPressed: () => _signContract(context, ref, c),
            ),
          ],
          // Avenants
          if (c.amendments.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              tr.contracts.amendmentsTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(height: 12),
            for (final a in c.amendments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AmendmentCard(
                  amendment: a,
                  lang: lang,
                  onSign: () => _signAmendment(context, ref, c.id, a),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _signContract(
    BuildContext context,
    WidgetRef ref,
    ServiceContract c,
  ) {
    return _showSignSheet(
      context,
      ref,
      actionKey: 'sign_contract:${c.id}',
      successMessage: Translations.of(context).contracts.signSuccess,
      op: (file) => ref.read(commonRepositoryProvider).signContract(c.id, file),
    );
  }

  Future<void> _signAmendment(
    BuildContext context,
    WidgetRef ref,
    String contractId,
    ContractAmendment a,
  ) {
    return _showSignSheet(
      context,
      ref,
      actionKey: 'sign_amendment:${a.id}',
      successMessage: Translations.of(context).contracts.amendmentSigned,
      op: (file) => ref
          .read(commonRepositoryProvider)
          .signAmendment(contractId, a.id, file),
    );
  }
}

/// Bottom-sheet de capture de signature → upload → refresh.
Future<void> _showSignSheet(
  BuildContext context,
  WidgetRef ref, {
  required String actionKey,
  required String successMessage,
  required Future<Result<void, Failure>> Function(File file) op,
}) {
  final sig = SoeSignatureController();
  final tr = Translations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPalette.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(sheetCtx).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.n300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr.contracts.signInFrame,
            style: const TextStyle(fontSize: 12, color: AppPalette.n700),
          ),
          const SizedBox(height: 10),
          SoeSignaturePad(controller: sig, clearLabel: tr.contracts.clear),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, r, _) => SoeButton(
              label: tr.contracts.sign,
              fullWidth: true,
              loading: r.watch(commonActionViewModelProvider(actionKey))
                  is CommonActionSubmitting,
              onPressed: () async {
                final file = await sig.toTempFile(const Size(320, 160));
                if (!sheetCtx.mounted) return;
                if (file == null) {
                  SoeToast.show(
                    sheetCtx,
                    message: tr.contracts.pleaseSign,
                    tone: SoeToastTone.warning,
                  );
                  return;
                }
                await runCommonAction(
                  sheetCtx,
                  r,
                  actionKey: actionKey,
                  successMessage: successMessage,
                  op: () => op(file),
                  onSuccess: () => r.invalidate(contractsProvider),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.signed});
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final color = signed ? AppPalette.success : AppPalette.warning;
    final bg = signed ? AppPalette.successBg : AppPalette.warningBg;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(signed ? Icons.check_circle : Icons.draw_outlined,
                size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              signed ? tr.contracts.badgeSigned : tr.contracts.badgeToSign,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmendmentCard extends StatelessWidget {
  const _AmendmentCard({
    required this.amendment,
    required this.lang,
    required this.onSign,
  });
  final ContractAmendment amendment;
  final String lang;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final a = amendment;
    return SoeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${tr.contracts.amendment} · ${a.reference}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
              ),
              _StatusBadge(signed: a.signed),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            a.content(lang),
            style: const TextStyle(
              fontSize: 12,
              color: AppPalette.n700,
              height: 1.5,
            ),
          ),
          if (!a.signed) ...[
            const SizedBox(height: 12),
            SoeButton(
              label: tr.contracts.signAmendment,
              icon: Icons.draw_outlined,
              size: SoeButtonSize.sm,
              onPressed: onSign,
            ),
          ],
        ],
      ),
    );
  }
}
