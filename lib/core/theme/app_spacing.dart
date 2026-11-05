import 'package:flutter/widgets.dart';

/// Échelle d'espacement 4px-grid SOE.
///
/// Usage : `padding: const EdgeInsets.all(AppSpacing.md)`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double huge = 48;
  static const double mega = 64;
}

/// The padding of a screen's scrolling list: 16 on a phone; on a wide screen (tablet in
/// landscape) the sides grow so that the content keeps a readable width, centred.
///
/// The bottom also clears the bottom inset of [context]: the safe area plus, inside a
/// signed-in space, the floating navigation (the shell adds its room to
/// `MediaQuery.padding.bottom`), so the last card scrolls above the pill. A list that ends on
/// a sticky bar (which clears the inset itself) passes [insets] false.
EdgeInsets spacePagePadding(BuildContext context,
    {double top = 16, double bottom = 16, bool insets = true}) {
  final width = MediaQuery.sizeOf(context).width;
  final side = width > 852 ? (width - 820) / 2 : 16.0;
  final inset = insets ? MediaQuery.paddingOf(context).bottom : 0.0;
  return EdgeInsets.fromLTRB(side, top, side, bottom + inset);
}
