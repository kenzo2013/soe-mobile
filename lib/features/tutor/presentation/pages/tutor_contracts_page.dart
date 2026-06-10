import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../domain/entities/tutor_contract.dart';
import '../providers.dart';
import '../widgets/tutor_app_bar.dart';
import '../widgets/tutor_drawer.dart';
import '../widgets/tutor_form_sheets.dart';
import '../widgets/tutor_ui.dart';
import 'tutor_profile_pages.dart' show stubAction;

class TutorContractsPage extends ConsumerWidget {
  const TutorContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorContractsViewModelProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      drawer: const TutorDrawer(activeRoute: RouteNames.tutorContracts),
      appBar: const TutorAppBar(
        title: 'Mes contrats',
        subtitle: 'Conventions et avenants',
      ),
      body: state.when(
        initial: () => const TutorLoading(),
        loading: () => const TutorLoading(),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(tutorContractsViewModelProvider.notifier).refresh(),
        ),
        loaded: (items) {
          final unsigned = items.where((c) => !c.signed).toList();
          final signed = items.where((c) => c.signed).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unsigned.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPalette.warningBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppPalette.warning.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.draw_outlined,
                          size: 18, color: AppPalette.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${unsigned.length} contrat'
                          '${unsigned.length > 1 ? "s" : ""} à signer',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.warning,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 14, color: AppPalette.warning),
                    ],
                  ),
                ),
              if (unsigned.isNotEmpty) ...[
                const SizedBox(height: 14),
                _sectionTitle('À signer'),
                for (final c in unsigned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UnsignedCard(
                      contract: c,
                      onSign: () => showContractSignSheet(
                        context,
                        ref,
                        c.id,
                        onSuccess: () => ref
                            .read(tutorContractsViewModelProvider.notifier)
                            .refresh(),
                      ),
                      onView: () => stubAction(context),
                    ),
                  ),
              ],
              const SizedBox(height: 4),
              _sectionTitle('Signés'),
              for (final c in signed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SignedCard(
                      contract: c, onDownload: () => stubAction(context)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
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

class _UnsignedCard extends StatelessWidget {
  const _UnsignedCard({
    required this.contract,
    required this.onSign,
    required this.onView,
  });
  final TutorContract contract;
  final VoidCallback onSign;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.warning, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppPalette.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined,
                      size: 18, color: AppPalette.warning),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Convention de tutorat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                      Text(
                        contract.reference,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.n700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const TutorPillBadge(
                  label: 'À signer',
                  bg: AppPalette.warningBg,
                  fg: AppPalette.warning,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppPalette.n300),
            const SizedBox(height: 8),
            Text(
              'Parent : ${contract.parent} · Élève : ${contract.student} · '
              'Mensuel : ${fcfa(contract.monthlyAmount)}',
              style: const TextStyle(fontSize: 11, color: AppPalette.n700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSign,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppPalette.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.draw_outlined,
                              size: 14, color: AppPalette.ink),
                          SizedBox(width: 6),
                          Text('Signer',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.ink,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppPalette.n300),
                    ),
                    child: const Icon(Icons.visibility_outlined,
                        size: 14, color: AppPalette.teal),
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

class _SignedCard extends StatelessWidget {
  const _SignedCard({required this.contract, required this.onDownload});
  final TutorContract contract;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SoeCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.successBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, size: 18, color: AppPalette.success),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contract.parent,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                    ),
                    if (contract.amendment) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppPalette.info.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'AVENANT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${contract.student} · ${contract.dateLine}',
                  style: const TextStyle(fontSize: 11, color: AppPalette.n700),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDownload,
            child: const Icon(Icons.download_outlined,
                size: 16, color: AppPalette.teal),
          ),
        ],
      ),
    );
  }
}
