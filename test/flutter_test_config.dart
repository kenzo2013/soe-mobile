import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Every test runs on a phone set to French (the app follows the phone's language); a test
/// in English sets `platformDispatcher.localesTestValue` itself.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized()
      .platformDispatcher
      .localesTestValue = const [Locale('fr', 'CM')];
  await testMain();
}
