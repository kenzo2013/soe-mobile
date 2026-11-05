import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';

/// AUT-01 — welcome, shown once on the first launch: 4 slides (photo, title,
/// sentence), FR / EN switch preselected from the phone language, « Passer »
/// to the last slide. On a tablet, the teal brand panel sits on the right.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  /// The tablet layout (with the brand panel) needs a tablet (shortest side) and room.
  static const double tabletShortestSide = 600;
  static const double tabletMinWidth = 700;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _slides = ['tutor', 'report', 'contract', 'payment'];

  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
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
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const SoeBrandLogo(width: 56),
                const SizedBox(width: 8),
                // Large system fonts: the switch and « Passer » go on two lines
                // instead of pushing « Passer » off screen.
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (!_isLast)
                        TextButton(
                          onPressed: () => _goTo(_slides.length - 1),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            foregroundColor: AppPalette.teal500,
                          ),
                          child: Text(
                            tr.onboarding.skip,
                            style: AppTypography.label
                                .copyWith(color: AppPalette.teal500),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _SlideView(
                  slide: _slides[index],
                  label: tr.onboarding.slideLabel(
                    current: index + 1,
                    total: _slides.length,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Dots(index: _index, total: _slides.length),
            const SizedBox(height: 20),
            if (_isLast) ...[
              SoeButton(
                label: tr.onboarding.createAccount,
                onPressed: () => _finish(RouteNames.roleChoice),
                fullWidth: true,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _finish(RouteNames.login),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: AppPalette.teal500,
                ),
                child: Text(tr.onboarding.haveAccount,
                    style: AppTypography.label
                        .copyWith(color: AppPalette.teal500)),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: SoeButton(
                  label: tr.onboarding.next,
                  onPressed: () => _goTo(_index + 1),
                  variant: SoeButtonVariant.secondary,
                  icon: Icons.arrow_forward,
                  iconRight: true,
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // A tablet, not a phone turned sideways: decided on the shortest side.
          final shortestSide = MediaQuery.sizeOf(context).shortestSide;
          if (shortestSide < OnboardingPage.tabletShortestSide ||
              constraints.maxWidth < OnboardingPage.tabletMinWidth) {
            return content;
          }
          return Row(
            children: [
              Expanded(flex: 16, child: content),
              const Expanded(flex: 9, child: _BrandPanel()),
            ],
          );
        },
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.label});

  final String slide;
  final String label;

  @override
  Widget build(BuildContext context) {
    final texts = _texts(Translations.of(context));
    // With a large system font the photo shrinks so the text keeps its room.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: textScale > 1.3 ? 4 : 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/onboarding/$slide.webp',
                width: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: texts.alt,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            flex: 4,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texts.title,
                    style: AppTypography.h2.copyWith(color: AppPalette.teal800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    texts.body,
                    style:
                        AppTypography.body.copyWith(color: AppPalette.ink700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String title, String body, String alt}) _texts(Translations tr) {
    final slides = tr.onboarding.slides;
    return switch (slide) {
      'tutor' => (
          title: slides.tutor.title,
          body: slides.tutor.body,
          alt: slides.tutor.alt
        ),
      'report' => (
          title: slides.report.title,
          body: slides.report.body,
          alt: slides.report.alt
        ),
      'contract' => (
          title: slides.contract.title,
          body: slides.contract.body,
          alt: slides.contract.alt
        ),
      _ => (
          title: slides.payment.title,
          body: slides.payment.body,
          alt: slides.payment.alt
        ),
    };
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppPalette.teal500 : AppPalette.teal100,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tablet only: the teal panel of the Studio (welcome, 3 promises, languages).
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final panel = Translations.of(context).onboarding.panel;
    final items = [
      (
        Icons.verified_user_outlined,
        panel.items.vetted.title,
        panel.items.vetted.body
      ),
      (
        Icons.description_outlined,
        panel.items.sessions.title,
        panel.items.sessions.body
      ),
      (
        Icons.account_balance_wallet_outlined,
        panel.items.payment.title,
        panel.items.payment.body
      ),
    ];
    return ColoredBox(
      color: AppPalette.teal800,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -20,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0.08,
                child: SvgPicture.asset(
                  'assets/logo/bulb.svg',
                  width: 220,
                  colorFilter:
                      const ColorFilter.mode(AppPalette.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SafeArea(
            // Scrolls when the panel is narrow or the system font is large.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    panel.overline.toUpperCase(),
                    style: AppTypography.overline
                        .copyWith(color: AppPalette.ink400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    panel.title,
                    style: AppTypography.h1.copyWith(color: AppPalette.white),
                  ),
                  const SizedBox(height: 24),
                  for (final (icon, title, body) in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0x1FFFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child:
                                Icon(icon, size: 18, color: AppPalette.ink400),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: AppTypography.label
                                        .copyWith(color: AppPalette.white)),
                                Text(body,
                                    style: AppTypography.bodySm
                                        .copyWith(color: AppPalette.ink400)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(panel.footer,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.ink400)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
