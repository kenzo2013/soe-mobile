import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/features/shell/presentation/routes.dart';

void main() {
  test('RouteNames.tabRoots lists exactly the first screens of the tabs', () {
    final paths = {
      for (final shell in shellRoutes().cast<StatefulShellRoute>())
        for (final branch in shell.branches)
          for (final route in branch.routes.cast<GoRoute>()) route.path,
    };

    expect(paths, RouteNames.tabRoots);
  });
}
