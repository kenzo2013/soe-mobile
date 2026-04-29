import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/lang_pill.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _ctrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final slides = [
      _Slide(title: tr.onboarding.slide1.title, body: tr.onboarding.slide1.body),
      _Slide(title: tr.onboarding.slide2.title, body: tr.onboarding.slide2.body),
      _Slide(title: tr.onboarding.slide3.title, body: tr.onboarding.slide3.body),
    ];

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      const SoeBrandLogo(width: 64),
                      const Spacer(),
                      const LangPill(),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          tr.common.skip,
                          style: AppTypography.bodySm
                              .copyWith(color: AppPalette.n700),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _ctrl,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      for (final s in slides) _SlideView(slide: s),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Column(
                children: [
                  _Dots(index: _index, total: slides.length),
                  const SizedBox(height: 18),
                  SoeButton(
                    label: _index == slides.length - 1
                        ? tr.role.signIn
                        : tr.common.next,
                    icon: Icons.chevron_right,
                    iconRight: true,
                    size: SoeButtonSize.lg,
                    fullWidth: true,
                    onPressed: () {
                      if (_index == slides.length - 1) {
                        _finish();
                      } else {
                        _ctrl.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    ref
        .read(preferencesStorageProvider)
        .writeBool(StorageKeys.onboardingDoneFlag, value: true);
    context.go(RouteNames.roleChoice);
  }
}

class _Slide {
  const _Slide({required this.title, required this.body});
  final String title;
  final String body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const SoeBrandLogo(width: 140),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: AppTypography.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            style: AppTypography.body.copyWith(color: AppPalette.n700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: i == index ? 22 : 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: i == index ? AppPalette.yellow : AppPalette.n300,
            ),
          ),
      ],
    );
  }
}
