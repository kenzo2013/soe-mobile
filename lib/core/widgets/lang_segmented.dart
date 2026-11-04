import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../providers/locale_provider.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// FR | EN switch of the opening screens (Studio AUT-01). Preselected from the
/// phone language; a tap is kept for the whole app (see [localeProvider]).
class LangSegmented extends ConsumerWidget {
  const LangSegmented({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppPalette.n50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in AppLocale.values)
            _Option(
              locale: locale,
              selected: locale == current,
              onTap: () => ref.read(localeProvider.notifier).set(locale),
            ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final code = locale.languageCode.toUpperCase();
    return Semantics(
      button: true,
      selected: selected,
      label: code,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppPalette.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x14010814),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                code,
                style: AppTypography.labelSm.copyWith(
                  color: selected ? AppPalette.ink900 : AppPalette.ink700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
