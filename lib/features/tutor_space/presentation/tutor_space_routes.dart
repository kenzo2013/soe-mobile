/// Paths of the screens that open from the tutor tabs (lot 4), full screen.
abstract final class TutorSpaceRoutes {
  static String session(int id) => '/tutor/space/sessions/$id';
  static String report(int sessionId) =>
      '/tutor/space/sessions/$sessionId/report';
  static String proposal(int id) => '/tutor/space/proposals/$id';
  static String times(int slotId) => '/tutor/space/slots/$slotId/times';
  static String contract(int id) => '/tutor/space/contracts/$id';
}
