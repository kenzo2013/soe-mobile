import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../widgets/launch_view.dart';

/// AUT-01 — welcome, shown once on the first launch (Opening of the colourful direction):
/// the navy launch screen for [LaunchView.duration], then 4 slides, each on its own ground
/// (navy, deep green, deep orange, SOE teal) with its accent: the photo with a rounded bottom
/// and a slight zoom, its tag, the progress dots in the accent, the title, text and button
/// fading up. « Passer » goes to the last slide: « Créer mon compte » (gold) and « J’ai déjà
/// un compte ». On a tablet the photo sits on the left, the text on the right.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.launch = true});

  /// The launch screen before the slides (off in the tests of the slides).
  final bool launch;

  /// From this width the photo and the text sit side by side.
  static const double tabletMinWidth = 700;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

/// A slide: its key, ground and accent.
typedef _Slide = ({String key, Color ground, Color accent, Color accentText});

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const List<_Slide> _slides = [
    (
      key: 'tutor',
      ground: AppPalette.navy,
      accent: AppPalette.gold400,
      accentText: AppPalette.ink900
    ),
    (
      key: 'report',
      ground: AppPalette.greenDeep,
      accent: AppPalette.success,
      accentText: AppPalette.white
    ),
    (
      key: 'contract',
      ground: AppPalette.orangeDeep,
      accent: AppPalette.orange,
      accentText: AppPalette.ink900
    ),
    (
      key: 'payment',
      ground: AppPalette.teal500,
      accent: AppPalette.gold400,
      accentText: AppPalette.ink900
    ),
  ];

  final _controller = PageController();
  int _index = 0;
  late bool _launching = widget.launch;
  Timer? _launchTimer;

  @override
  void initState() {
    super.initState();
    if (_launching) {
      _launchTimer = Timer(LaunchView.duration, () {
        if (mounted) setState(() => _launching = false);
      });
    }
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(index);
      return;
    }
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish(String route) async {
    await ref
        .read(preferencesStorageProvider)
        .writeBool(StorageKeys.onboardingDoneFlag, value: true);
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final slide = _slides[_index];
    final Widget body = _launching
        ? const LaunchView(key: ValueKey('launch'))
        : AnnotatedRegion<SystemUiOverlayStyle>(
            key: const ValueKey('slides'),
            value: SystemUiOverlayStyle.light,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              color: slide.ground,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _SlideView(
                  slide: _slides[index],
                  index: index,
                  total: _slides.length,
                  active: index == _index,
                  label: tr.onboarding
                      .slideLabel(current: index + 1, total: _slides.length),
                  onSkip: () => _goTo(_slides.length - 1),
                  actions: _actions(tr, _slides[index], index),
                ),
              ),
            ),
          );
    return Scaffold(
      backgroundColor: AppPalette.navy,
      body: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 400),
        child: body,
      ),
    );
  }

  Widget _actions(Translations tr, _Slide slide, int index) {
    final last = index == _slides.length - 1;
    if (!last) {
      return SoeButton(
        label: tr.onboarding.next,
        size: SoeButtonSize.xl,
        fullWidth: true,
        onPressed: () => _goTo(index + 1),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoeButton(
          label: tr.onboarding.createAccount,
          size: SoeButtonSize.xl,
          fullWidth: true,
          onPressed: () => _finish(RouteNames.roleChoice),
        ),
        const SizedBox(height: 10),
        SoeButton(
          label: tr.onboarding.haveAccount,
          size: SoeButtonSize.md,
          variant: SoeButtonVariant.onBrand,
          fullWidth: true,
          onPressed: () => _finish(RouteNames.login),
        ),
      ],
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.total,
    required this.active,
    required this.label,
    required this.onSkip,
    required this.actions,
  });

  final _Slide slide;
  final int index;
  final int total;
  final bool active;
  final String label;
  final VoidCallback onSkip;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final texts = _texts(tr);
    final last = index == total - 1;
    final media = MediaQuery.of(context);
    final tablet = media.size.width >= OnboardingPage.tabletMinWidth;
    // Side by side on a wide landscape screen; stacked otherwise (a tablet in portrait too).
    final wide = media.size.width >= OnboardingPage.tabletMinWidth &&
        media.size.width > media.size.height;
    // With a large system font the photo shrinks so the text keeps its room.
    final large = media.textScaler.scale(1) > 1.3;

    final photo = _Photo(
      asset: 'assets/images/onboarding/${slide.key}.webp',
      alt: texts.alt,
      tag: texts.tag,
      accent: slide.accent,
      accentText: slide.accentText,
      replayKey: active,
      radius: wide
          ? const BorderRadius.all(Radius.circular(40))
          : const BorderRadius.vertical(bottom: Radius.circular(40)),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Dots(index: index, total: total, accent: slide.accent, label: label),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeUp(
                  replayKey: active,
                  child: Text(texts.title,
                      style: AppTypography.h1.copyWith(
                          fontSize: tablet ? 34 : 28,
                          height: tablet ? 42 / 34 : 36 / 28,
                          color: AppPalette.white)),
                ),
                const SizedBox(height: 12),
                FadeUp(
                  replayKey: active,
                  delay: const Duration(milliseconds: 120),
                  child: Text(texts.body,
                      style: AppTypography.body
                          .copyWith(color: AppPalette.teal100)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeUp(
          replayKey: active,
          delay: const Duration(milliseconds: 240),
          child: actions,
        ),
      ],
    );

    final skip = last
        ? const SizedBox(height: 40)
        : Semantics(
            button: true,
            child: Material(
              color: const Color(0x8C01202F),
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: onSkip,
                customBorder: const StadiumBorder(),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(tr.onboarding.skip,
                      style: AppTypography.label
                          .copyWith(color: AppPalette.white)),
                ),
              ),
            ),
          );
    final topBar = Row(children: [
      const DecoratedBox(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Color(0x40000000), blurRadius: 8),
        ]),
        child: SoeBrandLogo(width: 50, onDark: true),
      ),
      const Spacer(),
      skip,
    ]);

    if (wide) {
      return Semantics(
        container: true,
        label: label,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24, media.padding.top + 24, 40, media.padding.bottom + 32),
          child: Row(children: [
            Expanded(child: photo),
            const SizedBox(width: 48),
            Expanded(
              child: Column(children: [
                topBar,
                const SizedBox(height: 48),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 440, maxHeight: 560),
                      child: text,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    }
    return Semantics(
      container: true,
      label: label,
      child: Column(children: [
        Expanded(
          flex: large ? 4 : 11,
          child: Stack(fit: StackFit.expand, children: [
            photo,
            Positioned(
              top: media.padding.top + 8,
              left: 20,
              right: 20,
              child: topBar,
            ),
          ]),
        ),
        Expanded(
          flex: large ? 6 : 9,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, media.padding.bottom + 16),
            child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: text),
            ),
          ),
        ),
      ]),
    );
  }

  ({String title, String body, String alt, String tag}) _texts(
      Translations tr) {
    final slides = tr.onboarding.slides;
    return switch (slide.key) {
      'tutor' => (
          title: slides.tutor.title,
          body: slides.tutor.body,
          alt: slides.tutor.alt,
          tag: slides.tutor.tag,
        ),
      'report' => (
          title: slides.report.title,
          body: slides.report.body,
          alt: slides.report.alt,
          tag: slides.report.tag,
        ),
      'contract' => (
          title: slides.contract.title,
          body: slides.contract.body,
          alt: slides.contract.alt,
          tag: slides.contract.tag,
        ),
      _ => (
          title: slides.payment.title,
          body: slides.payment.body,
          alt: slides.payment.alt,
          tag: slides.payment.tag,
        ),
    };
  }
}

/// The photo of a slide: rounded, zooming from 1.08 to 1 as it fades in (soePhoto), its tag
/// at the bottom left in the slide's accent.
class _Photo extends StatefulWidget {
  const _Photo({
    required this.asset,
    required this.alt,
    required this.tag,
    required this.accent,
    required this.accentText,
    required this.replayKey,
    required this.radius,
  });

  final String asset;
  final String alt;
  final String tag;
  final Color accent;
  final Color accentText;
  final Object replayKey;
  final BorderRadius radius;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(_Photo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey && widget.replayKey == true) {
      _play();
    }
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return ClipRRect(
      borderRadius: widget.radius,
      child: Stack(fit: StackFit.expand, children: [
        AnimatedBuilder(
          animation: curve,
          builder: (context, child) => Opacity(
            opacity: 0.3 + 0.7 * curve.value,
            child:
                Transform.scale(scale: 1.08 - 0.08 * curve.value, child: child),
          ),
          child: Image.asset(widget.asset,
              fit: BoxFit.cover, semanticLabel: widget.alt),
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: widget.accent, borderRadius: BorderRadius.circular(999)),
            child: Text(widget.tag,
                style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700, color: widget.accentText)),
          ),
        ),
      ]),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots(
      {required this.index,
      required this.total,
      required this.accent,
      required this.label});

  final int index;
  final int total;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < total; i++)
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: i == index ? 28 : 10,
                height: 6,
                decoration: BoxDecoration(
                  color: i == index ? accent : const Color(0x59FFFFFF),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
