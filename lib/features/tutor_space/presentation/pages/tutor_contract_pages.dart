import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_ui.dart';

/// REP-21 — the mission letters: to sign first, then the signed ones.
class TutorContractsPage extends ConsumerWidget {
  const TutorContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.contracts;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(tutorContractsProvider.future),
          child: TutorAsyncBody<List<TutorContract>>(
            value: ref.watch(tutorContractsProvider),
            onRetry: () => ref.invalidate(tutorContractsProvider),
            builder: (contracts) {
              final toSign = contracts.where((c) => c.canSign).toList();
              final others = contracts.where((c) => !c.canSign).toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(tr.title,
                      style:
                          AppTypography.h1.copyWith(color: AppPalette.teal800)),
                  if (contracts.isEmpty)
                    SoeEmptyState(
                        title: tr.empty,
                        message: tr.emptyText,
                        icon: Icons.description_outlined),
                  if (toSign.isNotEmpty) ...[
                    TutorSectionTitle(tr.toSign),
                    ...toSign.map((c) => _ContractTile(contract: c)),
                  ],
                  if (others.isNotEmpty) ...[
                    TutorSectionTitle(tr.signed),
                    ...others.map((c) => _ContractTile(contract: c)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({required this.contract});

  final TutorContract contract;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.contracts;
    final date = contract.signedAt != null
        ? tr.signedOn(date: TutorFormat.day(context, contract.signedAt!))
        : contract.receivedAt != null
            ? tr.received(date: TutorFormat.day(context, contract.receivedAt!))
            : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoeCard(
        onTap: () => context.push(TutorSpaceRoutes.contract(contract.id)),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.letter(pupil: contract.pupil),
                  style: AppTypography.label),
              Text(
                  [contract.subject, contract.reference, date]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
          const SizedBox(width: 8),
          TutorStateBadge(state: contract.status, label: contract.statusLabel),
        ]),
      ),
    );
  }
}

/// REP-21 — a mission letter: read to the end, then signed with the finger.
class TutorContractPage extends ConsumerStatefulWidget {
  const TutorContractPage({super.key, required this.contractId});

  final int contractId;

  @override
  ConsumerState<TutorContractPage> createState() => _TutorContractPageState();
}

class _TutorContractPageState extends ConsumerState<TutorContractPage> {
  static const double _padHeight = 130;

  final _signature = SoeSignatureController();
  final _scroll = ScrollController();
  bool _readToEnd = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_check);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _signature.dispose();
    super.dispose();
  }

  // Read once the end of the text was reached, or at once when it fits on the screen.
  void _check() {
    if (_readToEnd || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 40) setState(() => _readToEnd = true);
  }

  Future<void> _sign() async {
    final tr = Translations.of(context).tutorSpace.contracts;
    setState(() => _busy = true);
    try {
      final png = await _signature
          .toPng(Size(MediaQuery.sizeOf(context).width - 32, _padHeight));
      if (png == null) return;
      await ref.read(tutorApiProvider).signContract(widget.contractId, png);
      if (!mounted) return;
      ref
        ..invalidate(tutorContractProvider(widget.contractId))
        ..invalidate(tutorContractsProvider)
        ..invalidate(tutorHomeProvider);
      SoeToast.show(context,
          message: tr.signedToast, tone: SoeToastTone.success);
    } on Failure catch (failure) {
      // Only a failure frees the button: after a success the screen refreshes, never a 2nd send.
      if (mounted) setState(() => _busy = false);
      if (mounted) {
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.contracts;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.contractTitle)),
      body: TutorAsyncBody<TutorContract>(
        value: ref.watch(tutorContractProvider(widget.contractId)),
        onRetry: () => ref.invalidate(tutorContractProvider(widget.contractId)),
        builder: (contract) => Column(children: [
          Expanded(
            child: Builder(builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _check();
              });
              return ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(
                            [contract.reference, contract.title]
                                .whereType<String>()
                                .where((s) => s.isNotEmpty)
                                .join(' · '),
                            style: AppTypography.overline
                                .copyWith(color: AppPalette.text2))),
                    TutorStateBadge(
                        state: contract.status, label: contract.statusLabel),
                  ]),
                  const SizedBox(height: 12),
                  SoeCard(
                      child: Text(contract.text,
                          style: AppTypography.body.copyWith(height: 1.5))),
                  if (contract.signedAt != null) ...[
                    const SizedBox(height: 12),
                    Text(
                        tr.signedOn(
                            date: TutorFormat.dayLong(
                                context, contract.signedAt!)),
                        style: AppTypography.label
                            .copyWith(color: AppPalette.successText)),
                  ],
                ],
              );
            }),
          ),
          if (contract.canSign)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _readToEnd
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(tr.signHere, style: AppTypography.label),
                        const SizedBox(height: 8),
                        SoeSignaturePad(
                            controller: _signature,
                            clearLabel: tr.clear,
                            height: _padHeight),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: _signature,
                          builder: (context, _) => SoeButton(
                            label: tr.sign,
                            fullWidth: true,
                            loading: _busy,
                            onPressed: _busy || _signature.isEmpty
                                ? null
                                : () => unawaited(_sign()),
                          ),
                        ),
                      ])
                    : Text(tr.readFirst,
                        textAlign: TextAlign.center,
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// COM-08 — an amendment, its text and its signature (placeholder, being built).
class TutorAmendmentPage extends StatelessWidget {
  const TutorAmendmentPage(
      {super.key, required this.contractId, required this.amendmentId});

  final int contractId;
  final int amendmentId;

  @override
  Widget build(BuildContext context) => const Scaffold();
}
