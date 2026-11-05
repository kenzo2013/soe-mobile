import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../i18n/translations.g.dart';

/// Frame of the authentication screens (Studio AUT, mobile): back arrow, logo, step and
/// FR | EN on top, the content scrolling, the main action pinned at the bottom.
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
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: context.pop,
                      icon: const Icon(Icons.chevron_left),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    )
                  else
                    const SizedBox(width: 12),
                  const SoeBrandLogo(width: 48),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        if (step != null)
                          Text(
                            tr.auth.step(current: step!, total: 4),
                            style: AppTypography.labelSm
                                .copyWith(color: AppPalette.ink700),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (step != null) _Progress(step: step!),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children),
              ),
            ),
            if (bottom != null)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: bottom),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            for (var i = 1; i <= 4; i++)
              Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < step
                        ? AppPalette.teal800
                        : i == step
                            ? AppPalette.teal300
                            : AppPalette.teal50,
                    borderRadius: BorderRadius.circular(999),
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
              color: AppPalette.n50,
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
