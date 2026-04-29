import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer makeContainer({List<Override> overrides = const []}) {
  final c = ProviderContainer(overrides: overrides);
  addTearDown(c.dispose);
  return c;
}
