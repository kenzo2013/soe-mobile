/// Paths of the screens that open from the parent tabs, full screen.
abstract final class ParentSpaceRoutes {
  static String session(int id) => '/parent/space/sessions/$id';

  /// The session with the serious behaviour sheet open (PAR-03 « Sécurité »).
  static String sessionSerious(int id) => '/parent/space/sessions/$id?serious=1';
  static String report(int sessionId) =>
      '/parent/space/sessions/$sessionId/report';
  static String child(int id) => '/parent/space/children/$id';
  static const String newChild = '/parent/space/children/new';
  static String editChild(int id) => '/parent/space/children/$id/edit';
  static String pay(int invoiceId) => '/parent/space/invoices/$invoiceId/pay';
  static const String paymentsHistory = '/parent/space/payments';
  static String payment(int id) => '/parent/space/payments/$id';
  static const String requests = '/parent/space/requests';
  static const String newRequest = '/parent/space/requests/new';
  static String request(int id) => '/parent/space/requests/$id';
  static String quote(int requestId) =>
      '/parent/space/requests/$requestId/quote';
  static String planning(int requestId) =>
      '/parent/space/requests/$requestId/planning';
  static String tutors(int requestId) =>
      '/parent/space/requests/$requestId/tutors';
  static String newReplacement(int requestId, {int? slotId}) =>
      '/parent/space/requests/$requestId/replacement/new${slotId == null ? '' : '?slot=$slotId'}';
  static String replacement(int requestId) =>
      '/parent/space/requests/$requestId/replacement';
  static const String contracts = '/parent/space/contracts';
  static String contract(int id) => '/parent/space/contracts/$id';
  static String amendment(int contractId, int id) =>
      '/parent/space/contracts/$contractId/amendments/$id';
  static const String reviews = '/parent/space/reviews';
  static String reviewForm(int tutorId) =>
      '/parent/space/reviews/tutors/$tutorId';
  static const String coParents = '/parent/space/co-parents';
  static const String advisor = '/parent/space/advisor';
}
