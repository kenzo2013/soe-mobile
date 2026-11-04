import 'package:flutter/material.dart';

/// Elevations — design system v2: cards stay flat; `e1` / `e2` only for floating layers
/// (menus, popovers, sheets, dialogs, toasts). `sm`, `md`, `lg`, `brand`, `cta` are v1.
abstract final class AppShadows {
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x0D010814), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F010814), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x1A010814), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x1F010814), blurRadius: 64, offset: Offset(0, 24)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F041527), // rgba(4,21,39,.06)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A041527),
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14041527), // rgba(4,21,39,.08)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A041527),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F041527), // rgba(4,21,39,.12)
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0F041527),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> brand = [
    BoxShadow(
      color: Color(0x470A5F77), // rgba(10,95,119,.28)
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> cta = [
    BoxShadow(
      color: Color(0x59FFB400), // rgba(255,180,0,.35)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
