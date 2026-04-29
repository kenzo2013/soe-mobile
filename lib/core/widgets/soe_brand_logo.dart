import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

/// Logo SOE — fallback SVG-like vectoriel tant que l'asset PNG n'est pas
/// embedé. Reproduit l'esprit du design (livre + ampoule + lettrage).
///
/// `onDark: true` → posé directement sur surface marque.
/// `onDark: false` → encadré dans une pill teal pour rester lisible sur fond clair.
class SoeBrandLogo extends StatelessWidget {
  const SoeBrandLogo({super.key, this.width = 110, this.onDark = false});

  final double width;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 100 / 70,
        child: CustomPaint(painter: _SoeMarkPainter(onDark: onDark)),
      ),
    );

    if (onDark) return logo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppPalette.teal,
        borderRadius: AppRadius.rLg,
        boxShadow: [
          BoxShadow(
            color: Color(0x38035E7B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: logo,
    );
  }
}

class _SoeMarkPainter extends CustomPainter {
  _SoeMarkPainter({required this.onDark});
  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final unit = w / 100; // canevas conçu sur 100×70
    final letter = onDark ? AppPalette.white : AppPalette.white;
    final bulb = AppPalette.yellow;

    final pageL = Paint()..color = AppPalette.white.withValues(alpha: 0.95);
    final pageR = Paint()..color = AppPalette.white.withValues(alpha: 0.7);

    Path page(double x0) {
      return Path()
        ..moveTo(x0 * unit, 22 * unit)
        ..cubicTo(
          (x0 + 14) * unit, 16 * unit,
          (x0 + 28) * unit, 16 * unit,
          (x0 + 42) * unit, 22 * unit,
        )
        ..lineTo((x0 + 42) * unit, 58 * unit)
        ..cubicTo(
          (x0 + 28) * unit, 52 * unit,
          (x0 + 14) * unit, 52 * unit,
          x0 * unit, 58 * unit,
        )
        ..close();
    }

    canvas
      ..drawPath(page(4), pageL)
      ..drawPath(page(54), pageR);

    // Bulbe centrale
    final bulbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(44 * unit, 12 * unit, 14 * unit, 34 * unit),
      Radius.circular(7 * unit),
    );
    canvas.drawRRect(bulbRect, Paint()..color = bulb);

    // Lettres S et E
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp
      ..text = TextSpan(
        text: 'S',
        style: TextStyle(
          color: AppPalette.teal,
          fontWeight: FontWeight.w800,
          fontSize: 20 * unit,
          height: 1,
        ),
      )
      ..layout();
    tp.paint(canvas, Offset(25 * unit - tp.width / 2, 30 * unit));

    tp
      ..text = TextSpan(
        text: 'E',
        style: TextStyle(
          color: letter,
          fontWeight: FontWeight.w800,
          fontSize: 20 * unit,
          height: 1,
        ),
      )
      ..layout();
    tp.paint(canvas, Offset(78 * unit - tp.width / 2, 30 * unit));
  }

  @override
  bool shouldRepaint(_SoeMarkPainter old) => old.onDark != onDark;
}
