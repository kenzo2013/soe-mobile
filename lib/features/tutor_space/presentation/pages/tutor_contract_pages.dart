import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../../data/tutor_money_models.dart';
import '../providers.dart';
import '../tutor_money_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_download.dart';
import '../widgets/tutor_panel.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// REP-21 — the mission letters (to sign first, then the signed ones) and the v1 contracts
/// (« Anciens contrats »); opened full screen from « Plus » and the home.
class TutorContractsPage extends ConsumerWidget {
  const TutorContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.contracts;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorContractsProvider.future),
        child: TutorAsyncBody<List<TutorContract>>(
          value: ref.watch(tutorContractsProvider),
          onRetry: () => ref.invalidate(tutorContractsProvider),
          builder: (contracts) {
            final letters = contracts.where((c) => !c.legacy);
            final toSign = letters.where((c) => c.status == 'sent').toList();
            final signed = letters.where((c) => c.status != 'sent').toList();
            final legacy = contracts.where((c) => c.legacy).toList();
            return ListView(
              padding: spacePagePadding(context, top: 8, bottom: 32),
              children: [
                Text(tr.title, style: AppTypography.h1),
                const SizedBox(height: 16),
                if (contracts.isEmpty)
                  SoeEmptyState(
                      title: tr.empty,
                      message: tr.emptyText,
                      icon: Icons.description_outlined),
                for (final (title, group) in [
                  (tr.toSign, toSign),
                  (tr.signed, signed),
                  (tr.legacy, legacy),
                ])
                  if (group.isNotEmpty)
                    TutorPanel(
                      title: title,
                      children:
                          group.map((c) => _ContractRow(contract: c)).toList(),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({required this.contract});

  final TutorContract contract;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.contracts;
    final date = contract.signedAt != null
        ? tr.signedOn(date: TutorFormat.day(context, contract.signedAt!))
        : contract.receivedAt != null
            ? tr.received(date: TutorFormat.day(context, contract.receivedAt!))
            : null;
    return TutorPanelRow(
      icon: contract.legacy
          ? Icons.history_edu_outlined
          : contract.status == 'sent'
              ? Icons.draw_outlined
              : Icons.description_outlined,
      title: contract.legacy
          ? tr.legacyContract(reference: contract.reference ?? '')
          : tr.letter(pupil: contract.pupil),
      subtitle: [
        if (contract.legacy && contract.pupil.isNotEmpty) contract.pupil,
        if (date != null) date,
        if (contract.amendmentsToSign > 0)
          tr.amendmentsToSign(n: contract.amendmentsToSign)
        else if (contract.amendmentsCount > 0)
          tr.amendments(n: contract.amendmentsCount),
      ].join(' · '),
      trailing:
          TutorStateBadge(state: contract.status, label: contract.statusLabel),
      onTap: () =>
          unawaited(context.push(TutorSpaceRoutes.contract(contract.id))),
    );
  }
}

String _appLang(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'fr';

/// REP-21 « Signer une lettre de mission » — the summary, the full text (FR/EN, PDF), read to the
/// end then signed with the finger; the amendments of the contract.
class TutorContractPage extends ConsumerStatefulWidget {
  const TutorContractPage({super.key, required this.contractId});

  final int contractId;

  @override
  ConsumerState<TutorContractPage> createState() => _TutorContractPageState();
}

class _TutorContractPageState extends ConsumerState<TutorContractPage> {
  String? _lang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lang ??= _appLang(context);
  }

  Future<void> _sign(TutorContract contract, Uint8List png) async {
    final tr = Translations.of(context).tutorSpace.contracts;
    await ref.read(tutorApiProvider).signContract(contract.id, png);
    if (!mounted) return;
    ref
      ..invalidate(tutorContractTextProvider)
      ..invalidate(tutorContractProvider(contract.id))
      ..invalidate(tutorContractsProvider)
      ..invalidate(tutorAmendmentsProvider(contract.id))
      ..invalidate(tutorHomeProvider);
    SoeToast.show(context,
        message: contract.legacy ? tr.legacySignedToast : tr.signedToast,
        tone: SoeToastTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.contracts;
    final key = (id: widget.contractId, lang: _lang!);
    final value = ref.watch(tutorContractTextProvider(key));
    final legacy = value.valueOrNull?.legacy ?? false;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab,
          title: legacy ? tr.legacyTitle : tr.contractTitle),
      body: TutorAsyncBody<TutorContract>(
        value: value,
        onRetry: () => ref.invalidate(tutorContractTextProvider(key)),
        builder: (contract) => TutorDocumentView(
          reference: contract.reference,
          title: contract.legacy
              ? tr.legacyContract(reference: contract.reference ?? '')
              : tr.letter(pupil: contract.pupil),
          badge: TutorStateBadge(
              state: contract.status, label: contract.statusLabel),
          summary: [
            if (contract.pupil.isNotEmpty) (tr.pupil, contract.pupil),
            if (contract.subject != null) (tr.subject, contract.subject!),
            if (contract.receivedAt != null)
              (tr.receivedAt, TutorFormat.day(context, contract.receivedAt!)),
            if (contract.signedAt != null)
              (tr.signedAt, TutorFormat.day(context, contract.signedAt!)),
          ],
          textTitle: contract.legacy ? tr.legacyFullText : tr.fullText,
          blocks: contract.textFormat == 'html'
              ? tutorHtmlBlocks(contract.text)
              : tutorPlainBlocks(contract.text),
          lang: _lang!,
          onLang: (lang) => setState(() => _lang = lang),
          pdf: () => ref
              .read(tutorMoneyApiProvider)
              .contractPdfLink(contract.id, _lang!),
          canSign: contract.canSign,
          readFirst: tr.readFirst,
          signLabel: contract.legacy ? tr.legacySign : tr.sign,
          onSign: (png) => _sign(contract, png),
          note: contract.signedAt != null
              ? Text(
                  tr.signedNote(
                      date: TutorFormat.dayLong(context, contract.signedAt!)),
                  style: AppTypography.label
                      .copyWith(color: AppPalette.successText))
              : null,
          footer: contract.amendmentsCount > 0
              ? _AmendmentsPanel(contractId: contract.id)
              : null,
        ),
      ),
    );
  }
}

class _AmendmentsPanel extends ConsumerWidget {
  const _AmendmentsPanel({required this.contractId});

  final int contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.contracts;
    final amendments = ref.watch(tutorAmendmentsProvider(contractId));
    return TutorPanel(
      title: tr.amendmentsTitle,
      children: amendments.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        ],
        error: (error, _) => [
          ListTile(
            title: Text(tutorFailureMessage(context, asFailure(error)),
                style: AppTypography.bodySm),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.invalidate(tutorAmendmentsProvider(contractId)),
            ),
          ),
        ],
        data: (list) => list
            .map((amendment) => TutorPanelRow(
                  icon: Icons.post_add_outlined,
                  title: amendment.reference ??
                      Translations.of(context).tutorSpace.amendments.title,
                  subtitle: amendment.createdAt == null
                      ? null
                      : tr.dated(
                          date: TutorFormat.day(context, amendment.createdAt!)),
                  trailing: TutorAmendmentBadge(amendment: amendment),
                  onTap: () => unawaited(context.push(
                      TutorSpaceRoutes.amendment(contractId, amendment.id))),
                ))
            .toList(),
      ),
    );
  }
}

/// The state of an amendment: signed, to sign, or waiting for the contract's signature.
class TutorAmendmentBadge extends StatelessWidget {
  const TutorAmendmentBadge({super.key, required this.amendment});

  final TutorAmendment amendment;

  @override
  Widget build(BuildContext context) => SoeBadge(
        label: amendment.statusLabel,
        tone: switch (amendment.status) {
          'signed' => SoeBadgeTone.success,
          'to_sign' => SoeBadgeTone.warning,
          _ => SoeBadgeTone.neutral,
        },
      );
}

/// COM-08 — an amendment: its text (FR/EN, PDF), read to the end then signed with the finger,
/// once the contract itself is signed.
class TutorAmendmentPage extends ConsumerStatefulWidget {
  const TutorAmendmentPage(
      {super.key, required this.contractId, required this.amendmentId});

  final int contractId;
  final int amendmentId;

  @override
  ConsumerState<TutorAmendmentPage> createState() => _TutorAmendmentPageState();
}

class _TutorAmendmentPageState extends ConsumerState<TutorAmendmentPage> {
  String? _lang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lang ??= _appLang(context);
  }

  Future<void> _sign(Uint8List png) async {
    final tr = Translations.of(context).tutorSpace.amendments;
    await ref
        .read(tutorMoneyApiProvider)
        .signAmendment(widget.contractId, widget.amendmentId, png);
    if (!mounted) return;
    ref
      ..invalidate(tutorAmendmentProvider)
      ..invalidate(tutorAmendmentsProvider(widget.contractId))
      ..invalidate(tutorContractTextProvider)
      ..invalidate(tutorContractsProvider)
      ..invalidate(tutorHomeProvider);
    SoeToast.show(context, message: tr.signedToast, tone: SoeToastTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.amendments;
    final key =
        (contractId: widget.contractId, id: widget.amendmentId, lang: _lang!);
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: TutorAsyncBody<TutorAmendment>(
        value: ref.watch(tutorAmendmentProvider(key)),
        onRetry: () => ref.invalidate(tutorAmendmentProvider(key)),
        builder: (amendment) => TutorDocumentView(
          reference: amendment.createdAt == null
              ? null
              : tr.createdAt(
                  date: TutorFormat.day(context, amendment.createdAt!)),
          title: amendment.reference == null
              ? tr.title
              : tr.reference(reference: amendment.reference!),
          badge: TutorAmendmentBadge(amendment: amendment),
          summary: const [],
          textTitle: tr.fullText,
          blocks: tutorHtmlBlocks(amendment.text),
          lang: _lang!,
          onLang: (lang) => setState(() => _lang = lang),
          pdf: () => ref
              .read(tutorMoneyApiProvider)
              .amendmentPdfLink(widget.contractId, widget.amendmentId, _lang!),
          canSign: amendment.canSign,
          readFirst: tr.readFirst,
          signLabel: tr.sign,
          onSign: _sign,
          note: amendment.status == 'pending'
              ? SoeAlert(
                  title: tr.title,
                  body: tr.contractFirst,
                  tone: SoeAlertTone.info)
              : amendment.signedAt != null
                  ? Text(
                      tr.signedNote(
                          date: TutorFormat.dayLong(
                              context, amendment.signedAt!)),
                      style: AppTypography.label
                          .copyWith(color: AppPalette.successText))
                  : null,
        ),
      ),
    );
  }
}

/// A document to read and sign (mission letter, v1 contract, amendment): heading, summary, the
/// full text in a box scrolled to the end (FR/EN, PDF), the signature pad and the sign button.
class TutorDocumentView extends StatefulWidget {
  const TutorDocumentView({
    super.key,
    required this.reference,
    required this.title,
    required this.badge,
    required this.summary,
    required this.textTitle,
    required this.blocks,
    required this.lang,
    required this.onLang,
    required this.pdf,
    required this.canSign,
    required this.readFirst,
    required this.signLabel,
    required this.onSign,
    this.note,
    this.footer,
  });

  final String? reference;
  final String title;
  final Widget badge;
  final List<(String, String)> summary;
  final String textTitle;
  final List<TutorTextBlock> blocks;
  final String lang;
  final ValueChanged<String> onLang;
  final Future<TutorDownloadLink> Function() pdf;
  final bool canSign;
  final String readFirst;
  final String signLabel;

  /// Sends the PNG; throws a Failure when refused.
  final Future<void> Function(Uint8List png) onSign;
  final Widget? note;
  final Widget? footer;

  @override
  State<TutorDocumentView> createState() => _TutorDocumentViewState();
}

class _TutorDocumentViewState extends State<TutorDocumentView> {
  static const double _padHeight = 150;
  static const double _textHeight = 360;

  final _signature = SoeSignatureController();
  final _text = ScrollController();
  double _progress = 0;
  bool _readToEnd = false;
  bool _busy = false;
  double _padWidth = 300;

  @override
  void initState() {
    super.initState();
    _text.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(TutorDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another language: a text that fits needs no scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _text.dispose();
    _signature.dispose();
    super.dispose();
  }

  // Read once the end of the text was reached, or at once when it fits in the box.
  void _check() {
    if (!mounted || !_text.hasClients) return;
    final position = _text.position;
    final progress = position.maxScrollExtent <= 0
        ? 1.0
        : (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
    final read = _readToEnd || position.extentAfter < 24;
    if (progress != _progress || read != _readToEnd) {
      setState(() {
        _progress = _readToEnd ? 1 : progress;
        _readToEnd = read;
        if (read) _progress = 1;
      });
    }
  }

  Future<void> _sign() async {
    setState(() => _busy = true);
    try {
      final png = await _signature.toPng(Size(_padWidth, _padHeight));
      if (png == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      await widget.onSign(png);
    } on Failure catch (failure) {
      // Only a failure frees the button: after a success the screen refreshes, never a 2nd send.
      if (!mounted) return;
      setState(() => _busy = false);
      SoeToast.show(context,
          message: tutorFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.contracts;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: spacePagePadding(context,
              top: 8, bottom: 24, insets: !widget.canSign),
          children: [
            if (widget.reference != null)
              Text(widget.reference!.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal500)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(widget.title, style: AppTypography.h2)),
              const SizedBox(width: 8),
              Padding(
                  padding: const EdgeInsets.only(top: 6), child: widget.badge),
            ]),
            const SizedBox(height: 16),
            if (widget.summary.isNotEmpty) _summary(tr),
            if (widget.note != null) ...[
              widget.note!,
              const SizedBox(height: 16),
            ],
            _textCard(tr),
            if (widget.canSign) _signatureCard(tr),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
      if (widget.canSign)
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppPalette.white,
              border: Border(top: BorderSide(color: AppPalette.n100)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (!_readToEnd) ...[
                Text(widget.readFirst,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
                const SizedBox(height: 8),
              ],
              ListenableBuilder(
                listenable: _signature,
                builder: (context, _) => SoeButton(
                  label: widget.signLabel,
                  fullWidth: true,
                  loading: _busy,
                  onPressed: _busy || !_readToEnd || _signature.isEmpty
                      ? null
                      : () => unawaited(_sign()),
                ),
              ),
            ]),
          ),
        ),
    ]);
  }

  Widget _summary(TranslationsTutorSpaceContractsFr tr) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        decoration: const BoxDecoration(
            color: AppPalette.n50, borderRadius: AppRadius.rMd),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr.summary, style: AppTypography.h3),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.summary.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppPalette.n100),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Text(widget.summary[i].$1,
                    style:
                        AppTypography.bodySm.copyWith(color: AppPalette.text2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.summary[i].$2,
                      textAlign: TextAlign.end,
                      style: AppTypography.labelSm
                          .copyWith(color: AppPalette.text)),
                ),
              ]),
            ),
          ],
        ]),
      );

  Widget _textCard(TranslationsTutorSpaceContractsFr tr) => TutorPanel(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.textTitle, style: AppTypography.label),
              const SizedBox(height: 8),
              Row(children: [
                _LangSwitch(lang: widget.lang, onLang: widget.onLang),
                const SizedBox(width: 8),
                TutorDownloadButton(label: tr.pdf, fetch: widget.pdf),
              ]),
            ]),
          ),
          SizedBox(
            height: _textHeight,
            child: Scrollbar(
              controller: _text,
              child: ListView(
                controller: _text,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  for (final block in widget.blocks)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: block.heading ? 4 : 12,
                          top: block.heading ? 4 : 0),
                      child: Text(
                        block.item ? '•  ${block.text}' : block.text,
                        style: block.heading
                            ? AppTypography.label
                                .copyWith(color: AppPalette.text)
                            : AppTypography.bodySm
                                .copyWith(color: AppPalette.text2, height: 1.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    color: AppPalette.teal500,
                    backgroundColor: AppPalette.n100,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(_readToEnd ? tr.readToEnd : tr.scrollToEnd,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
        ],
      );

  Widget _signatureCard(TranslationsTutorSpaceContractsFr tr) => TutorPanel(
        title: tr.yourSignature,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: LayoutBuilder(builder: (context, constraints) {
              _padWidth = constraints.maxWidth;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoeSignaturePad(
                        controller: _signature,
                        clearLabel: tr.clear,
                        height: _padHeight),
                    const SizedBox(height: 8),
                    Text(tr.signHint,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]);
            }),
          ),
        ],
      );
}

/// FR | EN of a document's text (not the app's language).
class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.lang, required this.onLang});

  final String lang;
  final ValueChanged<String> onLang;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: AppPalette.n50, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final code in const ['fr', 'en'])
            Semantics(
              button: true,
              selected: code == lang,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: code == lang ? null : () => onLang(code),
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 36),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: code == lang ? AppPalette.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(code.toUpperCase(),
                      style: AppTypography.labelSm.copyWith(
                          color: code == lang
                              ? AppPalette.text
                              : AppPalette.text2)),
                ),
              ),
            ),
        ]),
      );
}
