import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/parent_home_placeholder.dart';

List<RouteBase> parentRoutes() => [
      GoRoute(
        path: RouteNames.parentDashboard,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
    ];
