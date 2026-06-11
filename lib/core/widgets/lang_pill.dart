import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../providers/locale_provider.dart';
import '../theme/app_palette.dart';

/// Pill langue (FR ↔ EN) — affichée sur les écrans auth.
///
/// `dark: true` → version surface marque (texte blanc).
class LangPill extends ConsumerWidget {
  const LangPill({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final bg = dark ? const Color(0x24FFFFFF) : AppPalette.n100;
    final border = dark ? const Color(0x2EFFFFFF) : AppPalette.n300;
    final fg = dark ? AppPalette.white : AppPalette.n700;

    const flagFr = _Flag(colors: [
      Color(0xFF00267F),
      AppPalette.white,
      Color(0xFFF31830),
    ]);
    const flagEn = _Flag(colors: [
      Color(0xFF012169),
      AppPalette.white,
      Color(0xFFC8102E),
    ]);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(localeProvider.notifier).toggle(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locale == AppLocale.fr) flagFr else flagEn,
              const SizedBox(width: 6),
              Text(
                locale.languageCode.toUpperCase(),
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 14, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.colors});
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 12,
      child: Row(
        children: [
          for (final c in colors) Expanded(child: Container(color: c)),
        ],
      ),
    );
  }
}
