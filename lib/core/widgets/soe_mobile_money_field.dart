import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../i18n/translations.g.dart';
import '../data/mobile_money_operator.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'soe_button.dart';
import 'soe_text_field.dart';

/// The Mobile Money number that pays (+237 and 9 digits) and its operator, recognised from the
/// prefix as the parent types (MobileMoneyOperator.detect) and shown with its logo. « Ce n’est
/// pas le bon opérateur ? » opens the two operators to choose from; an unknown prefix shows them
/// straight away. Mirror of the web payment form.
class SoeMobileMoneyField extends StatefulWidget {
  const SoeMobileMoneyField({
    super.key,
    required this.controller,
    required this.operator,
    required this.onOperatorChanged,
    this.help,
    this.errorText,
  });

  final TextEditingController controller;

  /// The operator the payment will use; null while none is recognised or chosen.
  final MobileMoneyOperator? operator;
  final ValueChanged<MobileMoneyOperator?> onOperatorChanged;
  final String? help;
  final String? errorText;

  @override
  State<SoeMobileMoneyField> createState() => _SoeMobileMoneyFieldState();
}

class _SoeMobileMoneyFieldState extends State<SoeMobileMoneyField> {
  // A choice made by hand wins over the prefix until the number changes operator again.
  bool _chosenByHand = false;
  bool _choicesOpen = false;
  MobileMoneyOperator? _lastDetected;

  @override
  void initState() {
    super.initState();
    _lastDetected = MobileMoneyOperator.detect(widget.controller.text);
    if (widget.operator == null && _lastDetected != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onOperatorChanged(_lastDetected));
    }
  }

  void _typed(String value) {
    final detected = MobileMoneyOperator.detect(value);
    if (detected == _lastDetected) {
      setState(() {}); // the « not recognised » line follows the digits typed
      return;
    }
    _lastDetected = detected;
    setState(() {
      _chosenByHand = false;
      _choicesOpen = detected == null;
    });
    widget.onOperatorChanged(detected);
  }

  void _choose(MobileMoneyOperator operator) {
    setState(() {
      _chosenByHand = true;
      _choicesOpen = false;
    });
    widget.onOperatorChanged(operator);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).mobileMoney;
    final operator = widget.operator;
    final digits =
        MobileMoneyOperator.nationalDigits(widget.controller.text).length;
    final unknown = operator == null && digits >= 3;
    final showChoices = _choicesOpen || operator == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoeTextField(
          controller: widget.controller,
          label: tr.phone,
          hint: tr.phoneHint,
          prefixText: MobileMoneyOperator.countryCode,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]'))
          ],
          errorText: widget.errorText,
          onChanged: _typed,
        ),
        if (widget.help != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(widget.help!,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ],
        const SizedBox(height: AppSpacing.md),
        if (operator != null)
          Semantics(
            liveRegion: true,
            label: tr.detected(operator: _name(context, operator)),
            excludeSemantics: true,
            child: _OperatorBadge(
                operator: operator,
                label: _name(context, operator),
                byHand: _chosenByHand),
          )
        else if (unknown)
          Semantics(
            liveRegion: true,
            child: Text(tr.unknown,
                style: AppTypography.bodySm
                    .copyWith(color: AppPalette.warningText)),
          ),
        if (operator != null && !_choicesOpen)
          Align(
            alignment: Alignment.centerLeft,
            child: SoeButton(
              label: tr.notRight,
              variant: SoeButtonVariant.tertiary,
              size: SoeButtonSize.md,
              onPressed: () => setState(() => _choicesOpen = true),
            ),
          ),
        if (showChoices) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(tr.choose,
              style: AppTypography.labelSm.copyWith(color: AppPalette.text2)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final (index, choice)
                  in MobileMoneyOperator.values.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _OperatorChoice(
                    operator: choice,
                    label: _name(context, choice),
                    selected: choice == operator,
                    onTap: () => _choose(choice),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  static String _name(BuildContext context, MobileMoneyOperator operator) {
    final tr = Translations.of(context).mobileMoney;
    return switch (operator) {
      MobileMoneyOperator.mtn => tr.mtn,
      MobileMoneyOperator.orange => tr.orange,
    };
  }
}

class _OperatorLogo extends StatelessWidget {
  const _OperatorLogo({required this.operator});

  final MobileMoneyOperator operator;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.rSm,
        child: Image.asset(operator.logoAsset,
            width: AppSpacing.xxxxl - AppSpacing.xs,
            height: AppSpacing.xxxxl - AppSpacing.xs,
            fit: BoxFit.cover,
            excludeFromSemantics: true),
      );
}

/// The recognised (or chosen) operator: logo, name and a check.
class _OperatorBadge extends StatelessWidget {
  const _OperatorBadge(
      {required this.operator, required this.label, required this.byHand});

  final MobileMoneyOperator operator;
  final String label;
  final bool byHand;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: AppRadius.rPill,
          border: Border.all(color: AppPalette.successText, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OperatorLogo(operator: operator),
            const SizedBox(width: AppSpacing.md),
            Text(label,
                style: AppTypography.label.copyWith(color: AppPalette.ink900)),
            const SizedBox(width: AppSpacing.sm),
            Icon(byHand ? Icons.check_circle : Icons.check,
                size: AppSpacing.xl, color: AppPalette.successText),
          ],
        ),
      );
}

/// One operator to choose (« Ce n’est pas le bon opérateur ? » or an unknown prefix).
class _OperatorChoice extends StatelessWidget {
  const _OperatorChoice({
    required this.operator,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final MobileMoneyOperator operator;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: selected ? AppPalette.teal50 : AppPalette.white,
          borderRadius: AppRadius.rCard,
          child: InkWell(
            borderRadius: AppRadius.rCard,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpacing.huge),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.rCard,
                border: Border.all(
                    color: selected ? AppPalette.teal500 : AppPalette.n300,
                    width: selected ? 2 : 1.5),
              ),
              child: Row(
                children: [
                  _OperatorLogo(operator: operator),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(label,
                        style: AppTypography.labelSm
                            .copyWith(color: AppPalette.ink900)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
