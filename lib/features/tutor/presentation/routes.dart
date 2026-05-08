import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/tutor_home_placeholder.dart';

List<RouteBase> tutorRoutes() => [
      GoRoute(
        path: RouteNames.tutorDashboard,
        builder: (context, state) => const TutorHomePlaceholderPage(),
      ),
    ];
