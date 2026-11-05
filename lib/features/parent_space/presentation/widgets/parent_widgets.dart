import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';
import 'parent_ui.dart';

/// Runs an API action of a parent screen: on a failure, the server's message as a toast.
/// Returns the result, or null when it failed.
Future<T?> runParentAction<T>(
    BuildContext context, Future<T> Function() action) async {
  try {
    return await action();
  } on Failure catch (failure) {
    if (context.mounted) {
      SoeToast.show(context,
          message: parentFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
    return null;
  }
}

/// Downloads a PDF with the token and opens it in the system viewer.
Future<void> openParentPdf(BuildContext context, WidgetRef ref,
    Future<List<int>> Function() download, String name) async {
  final tr = Translations.of(context).parentSpace.common;
  final bytes = await runParentAction(context, download);
  if (bytes == null || !context.mounted) return;
  final opened = await ref.read(parentFilesProvider).openPdf(bytes, name);
  if (!opened && context.mounted) {
    SoeToast.show(context, message: tr.pdfError, tone: SoeToastTone.danger);
  }
}

/// The title block of a parent screen: overline, serif title, subtitle.
class ParentHeading extends StatelessWidget {
  const ParentHeading(
      {super.key, this.overline, required this.title, this.subtitle});

  final String? overline;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overline != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(overline!.toUpperCase(),
                  style: AppTypography.overline
                      .copyWith(color: AppPalette.teal700)),
            ),
          Text(title,
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle!,
                  style: AppTypography.body.copyWith(color: AppPalette.text2)),
            ),
        ],
      );
}

/// A white card with a serif title (and an optional link on the right).
class ParentPanel extends StatelessWidget {
  const ParentPanel({
    super.key,
    this.title,
    this.trailing,
    required this.children,
    this.soft = false,
  });

  final String? title;
  final Widget? trailing;
  final List<Widget> children;

  /// The tinted variant (« Et ensuite ? », rules).
  final bool soft;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: soft ? AppPalette.surfaceSoft : AppPalette.white,
          borderRadius: BorderRadius.circular(20),
          border: soft ? null : Border.all(color: AppPalette.n300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Expanded(
                      child: Text(title!,
                          style: AppTypography.h3
                              .copyWith(color: AppPalette.teal800))),
                  if (trailing != null) trailing!,
                ]),
              ),
            ...children,
          ],
        ),
      );
}

/// A label on the left, a value on the right, separated by a thin line.
class ParentInfoRow extends StatelessWidget {
  const ParentInfoRow(this.label, this.value,
      {super.key, this.last = false, this.valueColor});

  final String label;
  final String value;
  final bool last;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppPalette.n300)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(label,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.text2))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppTypography.labelSm
                    .copyWith(color: valueColor ?? AppPalette.text)),
          ),
        ]),
      );
}

/// A field label with « Facultatif » on the right when optional.
class ParentFieldLabel extends StatelessWidget {
  const ParentFieldLabel(this.label, {super.key, this.optional = false});

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Row(children: [
          Expanded(child: Text(label, style: AppTypography.label)),
          if (optional)
            Text(Translations.of(context).parentSpace.common.optional,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
      );
}

/// Pills to pick one value or several (subjects, moments, reasons).
class ParentChoiceChips<T> extends StatelessWidget {
  const ParentChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<(T, String)> options;
  final Set<T> selected;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (value, label) in options)
            _Pill(
              label: label,
              selected: selected.contains(value),
              onTap: () => onToggle(value),
            ),
        ],
      );
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? AppPalette.teal800 : AppPalette.white,
          shape: StadiumBorder(
              side: BorderSide(
                  color: selected ? AppPalette.teal800 : AppPalette.n300,
                  width: 1.5)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(label,
                  style: AppTypography.labelSm.copyWith(
                      color: selected ? AppPalette.white : AppPalette.text)),
            ),
          ),
        ),
      );
}

/// A segmented control: one value among a few (gender, section, rhythm).
class ParentSegmented<T> extends StatelessWidget {
  const ParentSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppPalette.surfaceSoft,
            borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final (option, label) in options)
            Expanded(
              child: Semantics(
                selected: option == value,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: option == value
                          ? AppPalette.teal600
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSm.copyWith(
                            color: option == value
                                ? AppPalette.white
                                : AppPalette.text2)),
                  ),
                ),
              ),
            ),
        ]),
      );
}

/// A bottom sheet of the parent space: serif title, text, close button, content.
Future<T?> showParentSheet<T>(
  BuildContext context, {
  required String title,
  String? text,
  required Widget Function(BuildContext sheet) builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 20 + MediaQuery.viewInsetsOf(sheet).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppPalette.teal100,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Text(title,
                        style: AppTypography.h2
                            .copyWith(color: AppPalette.teal800))),
                IconButton(
                  tooltip: MaterialLocalizations.of(sheet).closeButtonTooltip,
                  style: IconButton.styleFrom(
                      backgroundColor: AppPalette.surfaceSoft),
                  onPressed: () => Navigator.of(sheet).pop(),
                  icon: const Icon(Icons.close, color: AppPalette.text2),
                ),
              ]),
              if (text != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(text,
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.text2)),
                ),
              builder(sheet),
            ],
          ),
        ),
      ),
    );

/// A list of arrows (« Et ensuite ? »).
class ParentArrowList extends StatelessWidget {
  const ParentArrowList(this.items, {super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 10),
                child: Icon(Icons.arrow_forward,
                    size: 16, color: AppPalette.teal600),
              ),
              Expanded(child: Text(item, style: AppTypography.bodySm)),
            ]),
          ),
      ]);
}

/// A vertical timeline (request history, replacement follow-up).
class ParentTimeline extends StatelessWidget {
  const ParentTimeline({super.key, required this.items});

  /// title, subtitle, state: done, current or upcoming.
  final List<({String title, String subtitle, String state})> items;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 20,
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (items[i].state) {
                        'current' => AppPalette.gold400,
                        'done' => AppPalette.teal600,
                        _ => AppPalette.white,
                      },
                      border: Border.all(
                          color: items[i].state == 'upcoming'
                              ? AppPalette.teal100
                              : Colors.transparent,
                          width: 2),
                    ),
                  ),
                  if (i < items.length - 1)
                    Expanded(
                        child: Container(width: 2, color: AppPalette.teal100)),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title,
                            style: AppTypography.labelSm.copyWith(
                                color: items[i].state == 'upcoming'
                                    ? AppPalette.text2
                                    : AppPalette.text)),
                        Text(items[i].subtitle,
                            style: AppTypography.caption
                                .copyWith(color: AppPalette.text2)),
                      ]),
                ),
              ),
            ]),
          ),
      ]);
}

/// A counted multi-line field (« 72 / 500 »).
class ParentCountedField extends StatelessWidget {
  const ParentCountedField({
    super.key,
    required this.controller,
    this.hint,
    this.max = 500,
    this.minLines = 3,
    this.errorText,
  });

  final TextEditingController controller;
  final String? hint;
  final int max;
  final int minLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 3,
        maxLength: max,
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          filled: true,
          fillColor: AppPalette.surfaceSoft,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      );
}

/// A tappable field that opens a picker (date).
class ParentPickerField extends StatelessWidget {
  const ParentPickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.errorText,
  });

  final IconData icon;
  final String label;
  final bool placeholder;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppPalette.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: errorText == null
                    ? null
                    : Border.all(color: AppPalette.danger),
              ),
              child: Row(children: [
                Icon(icon, size: 18, color: AppPalette.text2),
                const SizedBox(width: 10),
                Text(label,
                    style: AppTypography.body.copyWith(
                        color:
                            placeholder ? AppPalette.text3 : AppPalette.text)),
              ]),
            ),
          ),
          if (errorText != null) ParentErrorText(errorText!),
        ],
      );
}

/// A field error under a custom control.
class ParentErrorText extends StatelessWidget {
  const ParentErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text,
            style:
                AppTypography.caption.copyWith(color: AppPalette.dangerText)),
      );
}
