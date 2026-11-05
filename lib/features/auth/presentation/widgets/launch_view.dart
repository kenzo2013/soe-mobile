import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../i18n/translations.g.dart';

/// The launch screen of the colourful direction (Opening): navy, the white SOE logo scaling
/// in, a gold ring pulsing behind it, the promise fading up, three bouncing dots (gold, green,
/// orange) and a gold bar filling the bottom in [LaunchView.duration]. With reduced motion,
/// everything is still and the bar is full.
class LaunchView extends StatefulWidget {
  const LaunchView({super.key, this.showProgress = true});

  static const Duration duration = Duration(milliseconds: 2400);

  /// The gold bar at the bottom (the onboarding's launch); off for a plain start.
  final bool showProgress;

  @override
  State<LaunchView> createState() => _LaunchViewState();
}

class _LaunchViewState extends State<LaunchView> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  late final AnimationController _dots =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final AnimationController _bar =
      AnimationController(vsync: this, duration: LaunchView.duration);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      _bar.value = 1;
    } else {
      _intro.forward();
      _loop.repeat();
      _dots.repeat();
      _bar.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _dots.dispose();
    _bar.dispose();
    super.dispose();
  }

  /// soeLogoIn: 0 → .6 scale and 12 px low, 60 % → 1.06, 100 % → 1.
  static double _logoScale(double t) => t < 0.6
      ? 0.6 + 0.46 * Curves.easeOutCubic.transform(t / 0.6)
      : 1.06 - 0.06 * ((t - 0.6) / 0.4);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppPalette.navy,
        child: Stack(children: [
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 220,
                height: 160,
                child: Stack(alignment: Alignment.center, children: [
                  if (!still)
                    AnimatedBuilder(
                      animation: _loop,
                      builder: (context, _) {
                        // soeRing: starts .3 s late, scale .7 → 1.9, opacity 0 → .55 → 0.
                        final t = _loop.value;
                        final opacity = t < 0.3
                            ? t / 0.3 * 0.55
                            : 0.55 * (1 - (t - 0.3) / 0.7);
                        return Transform.scale(
                          scale: 0.7 + 1.2 * t,
                          child: Opacity(
                            opacity: opacity.clamp(0, 1),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppPalette.gold400, width: 3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  AnimatedBuilder(
                    animation: _intro,
                    builder: (context, child) {
                      final t = _intro.value;
                      return Opacity(
                        opacity: (t / 0.6).clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(
                              0, 12 * (1 - Curves.easeOutCubic.transform(t))),
                          child: Transform.scale(
                              scale: _logoScale(t), child: child),
                        ),
                      );
                    },
                    child: const SoeBrandLogo(width: 190, onDark: true),
                  ),
                ]),
              ),
              const SizedBox(height: 36),
              FadeUp(
                delay: const Duration(milliseconds: 120),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(tr.onboarding.panel.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                          fontSize: 15, color: AppPalette.navInactive)),
                ),
              ),
              const SizedBox(height: 36),
              Semantics(
                label: tr.splash.loading,
                child: ExcludeSemantics(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    for (final (i, color) in const [
                      AppPalette.gold400,
                      AppPalette.success,
                      AppPalette.orange,
                    ].indexed)
                      Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                        child: AnimatedBuilder(
                          animation: _dots,
                          builder: (context, child) {
                            if (still) return child!;
                            // soeDot: 1 s up-and-down, each dot .15 s after the previous.
                            final phase = (_dots.value - i * 0.15) % 1.0;
                            final wave =
                                (1 - math.cos(phase * 2 * math.pi)) / 2;
                            return Transform.translate(
                              offset: Offset(0, -8 * wave),
                              child: Opacity(
                                  opacity: 0.5 + 0.5 * wave, child: child),
                            );
                          },
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ]),
          ),
          if (widget.showProgress)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _bar,
                builder: (context, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _bar.value,
                    child: Container(height: 4, color: AppPalette.gold400),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Fades [child] in while it rises 24 px (soeFadeUp, .55 s), after [delay]. Replays when
/// [replayKey] changes (a new slide). Still with reduced motion.
class FadeUp extends StatefulWidget {
  const FadeUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.replayKey,
  });

  final Widget child;
  final Duration delay;
  final Object? replayKey;

  @override
  State<FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<FadeUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550) + widget.delay);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(FadeUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey) _play();
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
    final total = _controller.duration!.inMilliseconds;
    final start = widget.delay.inMilliseconds / total;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: const Cubic(0.2, 0.8, 0.2, 1)),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
            offset: Offset(0, 24 * (1 - curve.value)), child: child),
      ),
      child: widget.child,
    );
  }
}
