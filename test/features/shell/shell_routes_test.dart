import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/features/parent_space/presentation/parent_space_router.dart';
import 'package:soe/features/shell/presentation/routes.dart';
import 'package:soe/features/tutor_space/presentation/tutor_space_router.dart';

void main() {
  final branches = [
    for (final shell in shellRoutes().cast<StatefulShellRoute>())
      ...shell.branches
  ];

  test('RouteNames.tabRoots lists exactly the first screens of the tabs', () {
    final roots = {
      for (final branch in branches) (branch.routes.first as GoRoute).path,
    };

    expect(roots, RouteNames.tabRoots);
  });

  test(
      'the detail screens of a tab sit in its branch, the others stay full screen',
      () {
    final tabbed = {
      for (final branch in branches)
        for (final route in branch.routes.skip(1).cast<GoRoute>()) route.path,
    };
    final fullScreen = {
      for (final route in [...parentSpaceRoutes(), ...tutorSpaceRoutes()])
        (route as GoRoute).path,
    };

    expect(tabbed, {...parentTabScreens.keys, ...tutorTabScreens.keys});
    expect(tabbed.intersection(fullScreen), isEmpty);
    expect(fullScreen, contains('/parent/space/children/new'));
    expect(fullScreen, contains('/parent/space/requests/new'));
  });
}
