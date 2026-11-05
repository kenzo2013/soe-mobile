import '../../../core/routing/route_names.dart';
import '../../parent_space/presentation/parent_space_routes.dart';
import '../../tutor_space/presentation/tutor_space_routes.dart';
import '../data/account_models.dart';

/// The screen a notification opens in the active [role] (`parent` or `tutor`); the space home
/// when it has no target or the target has no screen in this role. A tab root is opened with
/// `go`, any other screen with `push` (see [RouteNames.tabRoots]).
String notificationRoute(NotificationTarget? target, String? role) {
  final tutor = role == 'tutor';
  final home = tutor ? RouteNames.tutorDashboard : RouteNames.parentDashboard;
  if (target == null) return home;
  final id = target.id;
  if (tutor) {
    return switch (target.kind) {
      'session' => TutorSpaceRoutes.session(id),
      'session_report' => TutorSpaceRoutes.report(id),
      'contract' => TutorSpaceRoutes.contract(id),
      'proposal' => TutorSpaceRoutes.proposal(id),
      'earnings' || 'payment' => RouteNames.tutorRemunerations,
      _ => home,
    };
  }
  return switch (target.kind) {
    'session' => ParentSpaceRoutes.session(id),
    'session_report' => ParentSpaceRoutes.report(id),
    'contract' => ParentSpaceRoutes.contract(id),
    'payment' => ParentSpaceRoutes.payment(id),
    'invoice' => RouteNames.parentPayments,
    'request' => ParentSpaceRoutes.requests,
    'child' => ParentSpaceRoutes.child(id),
    _ => home,
  };
}
