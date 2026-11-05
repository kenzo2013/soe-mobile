import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/parent_space/data/parent_files.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('soe/pdf_preview_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('on iOS, the PDF opens in the app preview with its close label',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });

    final opened = await const ParentFiles(preview: channel)
        .openPdf([37, 80, 68, 70], 'receipt PAY/1.pdf', closeLabel: 'Fermer');

    expect(opened, isTrue);
    expect(calls.single.method, 'open');
    final args = calls.single.arguments as Map;
    expect(args['close'], 'Fermer');
    expect(args['path'], endsWith('receipt_PAY_1.pdf'));
  });
}
