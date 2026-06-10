import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../i18n/translations.g.dart';

/// Contrôleur de signature : accumule le tracé et l'exporte en PNG transparent
/// (CDC §11.6 — signature → fichier PNG → upload multipart).
class TutorSignatureController extends ChangeNotifier {
  final List<Offset?> _points = [];

  List<Offset?> get points => List.unmodifiable(_points);
  bool get isEmpty => _points.whereType<Offset>().isEmpty;

  void add(Offset p) {
    _points.add(p);
    notifyListeners();
  }

  void endStroke() {
    _points.add(null);
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }

  /// Rend le tracé en PNG transparent à la taille fournie.
  Future<Uint8List?> toPng(Size size) async {
    if (isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = AppPalette.ink
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < _points.length - 1; i++) {
      final a = _points[i];
      final b = _points[i + 1];
      if (a != null && b != null) canvas.drawLine(a, b, paint);
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  /// Exporte la signature dans un fichier PNG temporaire (sans path_provider).
  Future<File?> toTempFile(Size size) async {
    final bytes = await toPng(size);
    if (bytes == null) return null;
    final dir = Directory.systemTemp.createTempSync('soe_sig');
    final file = File('${dir.path}/signature.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}

/// Zone de signature tactile reliée à un [TutorSignatureController].
class TutorSignaturePad extends StatelessWidget {
  const TutorSignaturePad({
    super.key,
    required this.controller,
    this.height = 160,
  });

  final TutorSignatureController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.teal, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (d) => controller.add(d.localPosition),
              onPanUpdate: (d) => controller.add(d.localPosition),
              onPanEnd: (_) => controller.endStroke(),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) =>
                    CustomPaint(painter: _SignaturePainter(controller.points)),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 10,
            child: InkWell(
              onTap: controller.clear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPalette.n100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Translations.of(context).tutor.forms.signatureClear,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.n700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.ink
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
