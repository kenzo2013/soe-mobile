import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_signature.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_file_models.dart';
import '../tutor_file_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_file_ui.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';
import '../tutor_navigation.dart';

/// REP-24 — the charter and code of conduct: read to the end, then signed with the finger (a PNG
/// sent to the API); the condition of the account's activation.
class TutorCharterPage extends ConsumerStatefulWidget {
  const TutorCharterPage({super.key});

  @override
  ConsumerState<TutorCharterPage> createState() => _TutorCharterPageState();
}

class _TutorCharterPageState extends ConsumerState<TutorCharterPage> {
  static const double _padHeight = 150;

  final _signature = SoeSignatureController();
  final _scroll = ScrollController();
  final _articlesKey = GlobalKey();
  final _listKey = GlobalKey();
  double _read = 0;
  bool _busy = false;
  bool _justSigned = false;
  // The list stops scrolling while a finger is on the pad: the stroke never fights the scroll.
  bool _drawing = false;
  double _padWidth = 300;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_track);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _signature.dispose();
    super.dispose();
  }

  bool get _readToEnd => _read >= 1;

  // The share of the articles seen: the bottom of the list against the bottom of the articles;
  // 100 % at once when they fit on the screen.
  void _track() {
    if (_readToEnd || !_scroll.hasClients) return;
    final articles =
        _articlesKey.currentContext?.findRenderObject() as RenderBox?;
    final list = _listKey.currentContext?.findRenderObject() as RenderBox?;
    var read = _scroll.position.extentAfter < 40 ? 1.0 : 0.0;
    if (read < 1 &&
        articles != null &&
        list != null &&
        articles.hasSize &&
        list.hasSize &&
        articles.size.height > 0) {
      final top = articles.localToGlobal(Offset.zero).dy;
      final bottom = list.localToGlobal(Offset(0, list.size.height)).dy;
      read = ((bottom - top) / articles.size.height).clamp(0, 1).toDouble();
    }
    if ((read - _read).abs() > 0.01) setState(() => _read = read);
  }

  Future<void> _sign() async {
    final tr = Translations.of(context).tutorSpace.charter;
    setState(() => _busy = true);
    try {
      final png = await _signature.toPng(Size(_padWidth, _padHeight));
      if (png == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      await ref.read(tutorFileApiProvider).signCharter(png);
      if (!mounted) return;
      setState(() => _justSigned = true);
      ref
        ..invalidate(tutorCharterProvider)
        ..invalidate(tutorInterviewProvider);
      refreshTutorFile(ref);
      SoeToast.show(context,
          message: tr.successTitle, tone: SoeToastTone.success);
    } on Failure catch (failure) {
      // Only a failure frees the button: after a success the screen shows it, never a 2nd send.
      if (mounted) {
        setState(() => _busy = false);
        SoeToast.show(context,
            message: tutorFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.charter;
    final value = ref.watch(tutorCharterProvider);
    final charter = value.valueOrNull;
    final signing = charter != null && charter.canSign && !_justSigned;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(section: tutorMoreSection(context), title: tr.short),
      bottomNavigationBar: signing
          ? TutorBottomBar(
              hint: _readToEnd ? null : tr.readFirst,
              child: ListenableBuilder(
                listenable: _signature,
                builder: (context, _) => SoeButton(
                  label: tr.sign,
                  fullWidth: true,
                  loading: _busy,
                  onPressed: _busy || !_readToEnd || _signature.isEmpty
                      ? null
                      : () => unawaited(_sign()),
                ),
              ),
            )
          : null,
      body: _justSigned
          ? _Success(
              onOffers: () => goTutorScreen(context, TutorSpaceRoutes.offers))
          : TutorAsyncBody<TutorCharter>(
              value: value,
              onRetry: () => ref.invalidate(tutorCharterProvider),
              builder: (charter) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _track();
                });
                return ListView(
                  key: _listKey,
                  controller: _scroll,
                  physics:
                      _drawing ? const NeverScrollableScrollPhysics() : null,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(tr.title,
                                style: AppTypography.h1
                                    .copyWith(color: AppPalette.teal800)),
                          ),
                          const SizedBox(width: 8),
                          if (charter.signedAt != null)
                            SoeBadge(
                                label: tr.signed, tone: SoeBadgeTone.success)
                          else if (charter.canSign)
                            SoeBadge(
                                label: tr.toSign, tone: SoeBadgeTone.warning),
                        ]),
                    const SizedBox(height: 6),
                    Text(tr.intro,
                        style: AppTypography.body
                            .copyWith(color: AppPalette.text2)),
                    const SizedBox(height: 16),
                    SoeCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(tr.cardTitle,
                                  style: AppTypography.label),
                            ),
                            const Divider(height: 1, color: AppPalette.n100),
                            Padding(
                              key: _articlesKey,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0;
                                        i < charter.articles.length;
                                        i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${i + 1}. ${charter.articles[i].title}',
                                                  style: AppTypography.label),
                                              const SizedBox(height: 4),
                                              Text(charter.articles[i].body,
                                                  style: AppTypography.bodySm
                                                      .copyWith(
                                                          color:
                                                              AppPalette.text2,
                                                          height: 1.5)),
                                            ]),
                                      ),
                                  ]),
                            ),
                            if (charter.canSign) _ReadProgress(read: _read),
                          ]),
                    ),
                    const SizedBox(height: 16),
                    if (charter.signedAt != null)
                      Text(
                          charter.stage == 'active'
                              ? tr.active
                              : tr.signedOn(
                                  date: TutorFormat.dayLong(
                                      context, charter.signedAt!)),
                          style: AppTypography.label
                              .copyWith(color: AppPalette.successText))
                    else if (!charter.canSign)
                      Text(tr.later,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.text2))
                    else if (_readToEnd)
                      SoeCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr.signature,
                                  style: AppTypography.h3
                                      .copyWith(color: AppPalette.teal800)),
                              const SizedBox(height: 10),
                              LayoutBuilder(builder: (context, constraints) {
                                _padWidth = constraints.maxWidth;
                                return Listener(
                                  onPointerDown: (_) =>
                                      setState(() => _drawing = true),
                                  onPointerUp: (_) =>
                                      setState(() => _drawing = false),
                                  onPointerCancel: (_) =>
                                      setState(() => _drawing = false),
                                  child: SoeSignaturePad(
                                      controller: _signature,
                                      clearLabel: tr.clear,
                                      height: _padHeight),
                                );
                              }),
                            ]),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _ReadProgress extends StatelessWidget {
  const _ReadProgress({required this.read});

  final double read;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.charter;
    return Container(
      color: AppPalette.surfaceSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: read,
              minHeight: 4,
              color: AppPalette.teal600,
              backgroundColor: AppPalette.n300,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(read >= 1 ? tr.readAll : tr.readPercent(n: (read * 100).round()),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ]),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.onOffers});

  final VoidCallback onOffers;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.charter;
    return ListView(padding: const EdgeInsets.all(16), children: [
      SoeCard(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppPalette.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check,
                color: AppPalette.successText, size: 32),
          ),
          const SizedBox(height: 12),
          Text(tr.successTitle,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 8),
          Text(tr.successText,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 16),
          SoeButton(
            label: tr.seeOffers,
            variant: SoeButtonVariant.outline,
            size: SoeButtonSize.md,
            onPressed: onOffers,
          ),
        ]),
      ),
    ]);
  }
}
