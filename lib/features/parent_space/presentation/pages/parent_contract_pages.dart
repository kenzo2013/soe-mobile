import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_flow_models.dart';
import '../../data/parent_models.dart';
import '../parent_space_routes.dart';
import '../providers.dart';
import '../widgets/parent_ui.dart';
import '../widgets/parent_widgets.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// PAR-10 / COM-08 — the family's contracts (including those of the former platform),
/// with their amendments to sign.
class ParentContractsPage extends ConsumerWidget {
  const ParentContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.contracts;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(parentContractsProvider.future),
        child: ParentAsyncBody<List<ParentContract>>(
          value: ref.watch(parentContractsProvider),
          onRetry: () => ref.invalidate(parentContractsProvider),
          builder: (contracts) => ListView(
            padding: spacePagePadding(context),
            children: [
              ParentHeading(title: tr.title, subtitle: tr.subtitle),
              const SizedBox(height: 16),
              if (contracts.isEmpty)
                SoeEmptyState(
                    title: tr.empty,
                    message: tr.emptyText,
                    icon: Icons.draw_outlined),
              for (final contract in contracts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ParentContractCard(contract: contract),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A contract in the list: reference, state, amendments to sign.
class ParentContractCard extends StatelessWidget {
  const ParentContractCard({super.key, required this.contract});

  final ParentContract contract;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.contracts;
    final toSign = contract.canSign || contract.amendmentsToSign > 0;
    return SoeCard(
      onTap: () =>
          unawaited(context.push(ParentSpaceRoutes.contract(contract.id))),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(contract.reference,
                style:
                    AppTypography.overline.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 4),
            Text(contract.statusLabel, style: AppTypography.label),
            if (contract.createdAt != null)
              Text(
                  tr.createdOn(
                      date: ParentFormat.dayLong(context, contract.createdAt!)),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (contract.legacy)
                SoeBadge(label: tr.legacy, tone: SoeBadgeTone.neutral),
              if (contract.amendmentsToSign > 0)
                SoeBadge(
                    label: tr.toSign(count: contract.amendmentsToSign),
                    icon: Icons.draw_outlined,
                    tone: SoeBadgeTone.warning),
            ]),
          ]),
        ),
        SoeBadge(
            label: contract.status == 'signed'
                ? tr.signedBadge
                : (toSign ? tr.toSignBadge : contract.statusLabel),
            tone: contract.status == 'signed'
                ? SoeBadgeTone.success
                : (toSign ? SoeBadgeTone.warning : SoeBadgeTone.neutral)),
        const Icon(Icons.chevron_right, color: AppPalette.text2),
      ]),
    );
  }
}

/// The amendments of a contract, shown under its text.
class ParentAmendmentsSection extends ConsumerWidget {
  const ParentAmendmentsSection({super.key, required this.contractId});

  final int contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace.contracts;
    final amendments =
        ref.watch(parentAmendmentsProvider(contractId)).valueOrNull ??
            const <ParentAmendment>[];
    if (amendments.isEmpty) return const SizedBox.shrink();
    return ParentPanel(title: tr.amendments, children: [
      for (final amendment in amendments)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr.amendment(reference: amendment.reference),
              style: AppTypography.labelSm),
          subtitle: amendment.createdAt == null
              ? null
              : Text(tr.createdOn(
                  date: ParentFormat.dayLong(context, amendment.createdAt!))),
          trailing: SoeBadge(
              label: amendment.signed ? tr.signedBadge : tr.toSignBadge,
              tone: amendment.signed
                  ? SoeBadgeTone.success
                  : SoeBadgeTone.warning),
          onTap: () => unawaited(context
              .push(ParentSpaceRoutes.amendment(contractId, amendment.id))),
        ),
    ]);
  }
}

/// COM-08 — an amendment: read to the end, signed with the finger, PDF.
class ParentAmendmentPage extends ConsumerWidget {
  const ParentAmendmentPage(
      {super.key, required this.contractId, required this.amendmentId});

  final int contractId;
  final int amendmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final key = (contractId: contractId, id: amendmentId);
    final value = ref.watch(parentAmendmentProvider(key));
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
        section: Translations.of(context).shell.more.tab,
        title: value.valueOrNull == null
            ? tr.contracts.amendments
            : tr.contracts.amendment(reference: value.valueOrNull!.reference),
        actions: [
          IconButton(
            tooltip: tr.common.pdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => unawaited(openParentPdf(
                context,
                ref,
                () => ref
                    .read(parentApiProvider)
                    .amendmentPdf(contractId, amendmentId),
                'amendment_$amendmentId.pdf')),
          ),
        ],
      ),
      body: ParentAsyncBody<ParentAmendment>(
        value: value,
        onRetry: () => ref.invalidate(parentAmendmentProvider(key)),
        builder: (amendment) => ParentSignableText(
          header: [
            Text(amendment.reference,
                style:
                    AppTypography.overline.copyWith(color: AppPalette.text2)),
          ],
          text: amendment.text,
          signedAt: amendment.signedAt,
          canSign: amendment.canSign,
          signLabel: tr.contracts.signAmendment,
          onSign: (png) async {
            final signed = await runParentAction(
                context,
                () => ref
                    .read(parentApiProvider)
                    .signAmendment(contractId, amendmentId, png));
            if (signed == null || !context.mounted) return;
            ref
              ..invalidate(parentAmendmentProvider(key))
              ..invalidate(parentAmendmentsProvider(contractId))
              ..invalidate(parentContractsProvider)
              ..invalidate(parentHomeProvider);
            SoeToast.show(context,
                message: tr.contracts.amendmentSigned,
                tone: SoeToastTone.success);
          },
        ),
      ),
    );
  }
}

/// A text to read to the end before the signature pad appears (contracts, amendments).
class ParentSignableText extends StatefulWidget {
  const ParentSignableText({
    super.key,
    required this.header,
    required this.text,
    required this.signedAt,
    required this.canSign,
    required this.signLabel,
    required this.onSign,
    this.footer = const [],
  });

  final List<Widget> header;
  final String text;
  final DateTime? signedAt;
  final bool canSign;
  final String signLabel;
  final Future<void> Function(List<int> png) onSign;
  final List<Widget> footer;

  @override
  State<ParentSignableText> createState() => _ParentSignableTextState();
}

class _ParentSignableTextState extends State<ParentSignableText> {
  static const double _padHeight = 130;

  final _signature = SoeSignatureController();
  final _scroll = ScrollController();
  bool _readToEnd = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _check();
    });
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
    setState(() => _busy = true);
    try {
      final png = await _signature
          .toPng(Size(MediaQuery.sizeOf(context).width - 32, _padHeight));
      if (png != null) await widget.onSign(png);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.requests;
    return Column(children: [
      Expanded(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: [
            ...widget.header,
            const SizedBox(height: 12),
            SoeCard(
                child: Text(widget.text,
                    style: AppTypography.body.copyWith(height: 1.5))),
            if (widget.signedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                  tr.signedOn(
                      date: ParentFormat.dayLong(context, widget.signedAt!)),
                  style: AppTypography.label
                      .copyWith(color: AppPalette.successText)),
            ],
            ...widget.footer,
          ],
        ),
      ),
      if (widget.canSign)
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
                        label: widget.signLabel,
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
                    style:
                        AppTypography.body.copyWith(color: AppPalette.text2)),
          ),
        ),
    ]);
  }
}
