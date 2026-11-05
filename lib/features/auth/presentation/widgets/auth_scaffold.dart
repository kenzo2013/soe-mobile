import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../i18n/translations.g.dart';

/// Frame of the authentication screens (colourful direction, Login): a navy top with the way
/// back, the white logo, the sign-up step and its progress, then the screen's [AuthHeading]
/// (lifted from [children]) in white; below, a white sheet with 32 px top corners
/// holding the rest of [children], the main action pinned at the bottom.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold(
      {super.key, required this.children, this.bottom, this.step});

  final List<Widget> children;
  final Widget? bottom;

  /// Sign-up step (1 to 4): label and progress bar.
  final int? step;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final headingIndex = children.indexWhere((child) => child is AuthHeading);
    final heading =
        headingIndex < 0 ? null : children[headingIndex] as AuthHeading;
    final body = [
      for (final (i, child) in children.indexed)
        if (i != headingIndex) child,
    ];
    final media = MediaQuery.of(context);
    final canPop = context.canPop();
    final compact = canPop || step != null;
    final top = Padding(
      padding: EdgeInsets.fromLTRB(
          compact ? 12 : 24, media.padding.top + (compact ? 8 : 32), 24, 28),
      child: _Narrow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (canPop) ...[
                IconButton(
                  onPressed: context.pop,
                  style: IconButton.styleFrom(
                      backgroundColor: AppPalette.onBandSoft,
                      fixedSize: const Size(40, 40)),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppPalette.white, size: 22),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                const SizedBox(width: 12),
              ] else if (compact)
                const SizedBox(width: 12),
              SoeBrandLogo(width: compact ? 57 : 80, onDark: true),
              const Spacer(),
              if (step != null)
                Text(
                  tr.auth.step(current: step!, total: 4),
                  style: AppTypography.labelSm
                      .copyWith(color: AppPalette.navInactive),
                ),
            ]),
            Padding(
              padding: EdgeInsets.only(left: compact ? 12 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step != null) _Progress(step: step!),
                  if (heading != null) ...[
                    SizedBox(height: compact ? 20 : 22),
                    Semantics(
                      header: true,
                      child: Text(heading.title,
                          style: AppTypography.display.copyWith(
                              fontSize: compact ? 28 : 32,
                              height: compact ? 36 / 28 : 40 / 32,
                              color: AppPalette.white)),
                    ),
                    if (heading.lead != null) ...[
                      const SizedBox(height: 8),
                      Text(heading.lead!,
                          style: AppTypography.body
                              .copyWith(color: AppPalette.navInactive)),
                    ],
                  ],
                  if (step == null) ...[
                    const SizedBox(height: 22),
                    const _BrandBars(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppPalette.navy,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(child: top),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.band)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: _Narrow(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: body),
                    ),
                  ),
                ),
                // The sheet runs down to the bottom of the screen.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ColoredBox(
                    color: AppPalette.white,
                    child: SizedBox(
                        height: bottom == null ? media.padding.bottom : 0),
                  ),
                ),
              ]),
            ),
            if (bottom != null)
              ColoredBox(
                color: AppPalette.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: _Narrow(child: bottom!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The three bars of the brand under the heading (gold, green, teal).
class _BrandBars extends StatelessWidget {
  const _BrandBars();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Row(children: [
          for (final (width, color) in const [
            (32.0, AppPalette.gold400),
            (12.0, AppPalette.success),
            (12.0, AppPalette.teal400),
          ])
            Container(
              width: width,
              height: 6,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3)),
            ),
        ]),
      );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            for (var i = 1; i <= 4; i++)
              Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: i < step
                        ? AppPalette.success
                        : i == step
                            ? AppPalette.gold400
                            : const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Title and lead of a screen.
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, this.lead});
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
          if (lead != null) ...[
            const SizedBox(height: 8),
            Text(lead!,
                style: AppTypography.body.copyWith(color: AppPalette.ink700)),
          ],
        ],
      ),
    );
  }
}

/// Main button + the hint saying what is missing (Studio rule of the AUT screens).
class AuthSubmit extends StatelessWidget {
  const AuthSubmit({
    super.key,
    required this.button,
    this.hint,
  });

  final Widget button;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(hint!,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppPalette.ink700)),
        ],
      ],
    );
  }
}

/// Segmented choice (Studio SoeSegmented): one value among a few, with its error.
class ChoiceSegmented extends StatelessWidget {
  const ChoiceSegmented({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final Map<String, String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.label.copyWith(color: AppPalette.ink900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppPalette.teal50,
              borderRadius: BorderRadius.circular(999),
              border: errorText != null
                  ? Border.all(color: AppPalette.danger, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                for (final entry in options.entries)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: entry.key == value,
                      child: GestureDetector(
                        onTap: () => onChanged(entry.key),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: entry.key == value
                                ? AppPalette.teal500
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSm.copyWith(
                              color: entry.key == value
                                  ? AppPalette.white
                                  : AppPalette.ink700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(errorText!,
                style: AppTypography.caption
                    .copyWith(color: AppPalette.dangerText)),
          ],
        ],
      ),
    );
  }
}

/// The 4 password rules of the Studio, ticked as the user types.
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.password});
  final String password;

  static final Map<String, RegExp> rules = {
    'length': RegExp('.{8,}'),
    'uppercase': RegExp('[A-Z]'),
    'digit': RegExp(r'\d'),
    'special': RegExp(r'[^A-Za-z0-9\s]'),
  };

  static bool allMet(String password) =>
      rules.values.every((rule) => rule.hasMatch(password));

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).auth.password;
    final labels = {
      'length': tr.ruleLength,
      'uppercase': tr.ruleUppercase,
      'digit': tr.ruleDigit,
      'special': tr.ruleSpecial,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          for (final rule in rules.entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  rule.value.hasMatch(password)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: rule.value.hasMatch(password)
                      ? AppPalette.success
                      : AppPalette.ink400,
                ),
                const SizedBox(width: 6),
                Text(labels[rule.key]!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.ink900)),
              ],
            ),
        ],
      ),
    );
  }
}

/// The content of an authentication screen, at most 560 wide (tablet), centred.
class _Narrow extends StatelessWidget {
  const _Narrow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      );
}
