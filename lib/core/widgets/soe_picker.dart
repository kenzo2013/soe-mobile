import 'package:flutter/material.dart';

import '../data/search_key.dart';
import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'soe_text_field.dart';

export '../data/search_key.dart' show soeSearchKey;

/// One choice of [showSoePickerSheet]: the [value] returned, its [label], an optional
/// [leading] (a flag) and [trailing] text (a region, a calling code). Items sharing a
/// [section] are listed under that heading, in the order given. [searchKey] is what the
/// search compares, already folded with [soeSearchKey]; it defaults to the folded label.
class SoePickerItem<T> {
  SoePickerItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.section,
    String? searchKey,
  }) : searchKey = searchKey ?? soeSearchKey(label);

  final T value;
  final String label;
  final Widget? leading;
  final String? trailing;
  final String? section;
  final String searchKey;
}

/// A field that looks like an input and opens a picker sheet: [valueText] once chosen, else
/// the [placeholder] (grey). [loading] shows a spinner and ignores taps; [errorText] rings it
/// red with the message below, like [SoeTextField]. [semanticLabel] names the field for screen
/// readers when its visible label is drawn by the page (an [label] does both).
class SoePickerField extends StatelessWidget {
  const SoePickerField({
    super.key,
    required this.placeholder,
    required this.onTap,
    this.valueText,
    this.label,
    this.semanticLabel,
    this.leading,
    this.errorText,
    this.loading = false,
    this.trailingIcon = Icons.keyboard_arrow_down,
  });

  final String placeholder;
  final String? valueText;
  final String? label;
  final String? semanticLabel;
  final Widget? leading;
  final String? errorText;
  final bool loading;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final chosen = valueText != null && valueText!.isNotEmpty;
    final shown = chosen ? valueText! : placeholder;
    final name = (label != null && label!.isNotEmpty) ? label : semanticLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExcludeSemantics(
              child: Text(label!,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.teal800)),
            ),
          ),
        Semantics(
          button: true,
          enabled: !loading,
          label: [if (name != null && name.isNotEmpty) name, shown].join(', '),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: AppRadius.rField,
            onTap: loading ? null : onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: SoeFieldFill.of(context),
                borderRadius: AppRadius.rField,
                border: hasError
                    ? Border.all(color: AppPalette.dangerText, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Text(
                      shown,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                          color: chosen ? AppPalette.ink : AppPalette.ink600),
                    ),
                  ),
                  if (loading)
                    const SizedBox.square(
                      dimension: AppSpacing.lg,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(trailingIcon, size: 20, color: AppPalette.ink600),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding:
                const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: AppPalette.dangerText),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(errorText!,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.dangerText)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Bottom sheet listing [items] (sections in their first-seen order, the [selected] value
/// checked). With [searchHint], a search field filters them with [soeSearchKey] (and shows
/// [emptyText] when nothing matches). Returns the value chosen, or null when closed.
Future<T?> showSoePickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<SoePickerItem<T>> items,
  T? selected,
  String? searchHint,
  String? emptyText,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.band)),
      ),
      builder: (_) => _SoePickerSheet<T>(
        title: title,
        items: items,
        selected: selected,
        searchHint: searchHint,
        emptyText: emptyText,
      ),
    );

/// A row of the sheet: a section heading or an item.
typedef _Row<T> = ({String? heading, SoePickerItem<T>? item});

class _SoePickerSheet<T> extends StatefulWidget {
  const _SoePickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.searchHint,
    required this.emptyText,
  });

  final String title;
  final List<SoePickerItem<T>> items;
  final T? selected;
  final String? searchHint;
  final String? emptyText;

  @override
  State<_SoePickerSheet<T>> createState() => _SoePickerSheetState<T>();
}

class _SoePickerSheetState<T> extends State<_SoePickerSheet<T>> {
  final _query = TextEditingController();
  String _key = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<_Row<T>> _rows() {
    final found = _key.isEmpty
        ? widget.items
        : widget.items.where((item) => item.searchKey.contains(_key));
    final sections = <String?>[];
    final bySection = <String?, List<SoePickerItem<T>>>{};
    for (final item in found) {
      if (!bySection.containsKey(item.section)) sections.add(item.section);
      bySection.putIfAbsent(item.section, () => []).add(item);
    }
    return [
      for (final section in sections) ...[
        if (section != null) (heading: section, item: null),
        for (final item in bySection[section]!) (heading: null, item: item),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    final searchable = widget.searchHint != null;
    final list = rows.isEmpty
        ? Center(
            child: Text(widget.emptyText ?? '',
                style: AppTypography.body.copyWith(color: AppPalette.ink700)))
        : ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return row.heading != null
                  ? _heading(row.heading!)
                  : _item(row.item!);
            },
          );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: searchable ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: AppSpacing.xxxxl,
            height: AppSpacing.xs,
            decoration: const BoxDecoration(
                color: AppPalette.n300, borderRadius: AppRadius.rPill),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(widget.title, style: AppTypography.h4),
        const SizedBox(height: AppSpacing.md),
        if (searchable) ...[
          SoeTextField(
            controller: _query,
            hint: widget.searchHint,
            leadingIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: (text) => setState(() => _key = soeSearchKey(text)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: list),
        ] else
          Flexible(child: list),
      ],
    );
    final padded = Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: content,
    );
    return searchable
        ? FractionallySizedBox(heightFactor: 0.88, child: padded)
        : padded;
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.xs),
        child: Semantics(
          header: true,
          child: Text(text.toUpperCase(),
              style: AppTypography.overline.copyWith(color: AppPalette.ink600)),
        ),
      );

  Widget _item(SoePickerItem<T> item) {
    final isSelected = item.value == widget.selected;
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: AppRadius.rSm,
        onTap: () => Navigator.of(context).pop(item.value),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.huge),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              if (item.leading != null) ...[
                item.leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(item.label,
                    style: AppTypography.body.copyWith(
                      color: isSelected ? AppPalette.teal800 : AppPalette.ink,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    )),
              ),
              if (item.trailing != null)
                Text(item.trailing!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.ink600)),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.check,
                  size: 18,
                  color: isSelected ? AppPalette.teal500 : Colors.transparent),
            ],
          ),
        ),
      ),
    );
  }
}
