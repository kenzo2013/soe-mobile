/// Paths of the tutor space v2 screens opened full screen (from the tabs, the home actions and
/// the « Plus » links).
abstract final class TutorSpaceRoutes {
  // Sessions (REP-13 to REP-18).
  static String session(int id) => '/tutor/space/sessions/$id';
  static String report(int sessionId) =>
      '/tutor/space/sessions/$sessionId/report';
  static String proposal(int id) => '/tutor/space/proposals/$id';
  static String times(int slotId) => '/tutor/space/slots/$slotId/times';

  // Contracts and amendments (REP-21, COM-08).
  static const String contracts = '/tutor/space/contracts';
  static String contract(int id) => '/tutor/space/contracts/$id';
  static String amendment(int contractId, int id) =>
      '/tutor/space/contracts/$contractId/amendments/$id';

  // Recruitment (REP-02 to REP-09, REP-23, REP-24).
  static const String file = '/tutor/space/file';

  /// A section of the file: identity, address, subjects, availability, diplomas, experiences,
  /// presentation.
  static String fileSection(String section) => '/tutor/space/file/$section';
  static const String interview = '/tutor/space/interview';
  static const String charter = '/tutor/space/charter';

  // Offers and applications (REP-10 to REP-12).
  static const String offers = '/tutor/space/offers';
  static String offer(int id) => '/tutor/space/offers/$id';
  static const String applications = '/tutor/space/applications';

  // Pupils (REP-14): the list is a tab, the pupil's file is full screen.
  static String student(int id) => '/tutor/space/students/$id';

  // Money (REP-19, REP-20).
  static const String earningsHistory = '/tutor/space/earnings/history';
  static const String payoutMethods = '/tutor/space/payout-methods';
}
