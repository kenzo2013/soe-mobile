/// Paths of the screens that open from the parent tabs (lot 3), full screen.
abstract final class ParentSpaceRoutes {
  static String session(int id) => '/parent/space/sessions/$id';
  static String report(int sessionId) =>
      '/parent/space/sessions/$sessionId/report';
  static String child(int id) => '/parent/space/children/$id';
  static String pay(int invoiceId) => '/parent/space/invoices/$invoiceId/pay';
  static String payment(int id) => '/parent/space/payments/$id';
  static const String requests = '/parent/space/requests';
  static String request(int id) => '/parent/space/requests/$id';
  static String quote(int requestId) =>
      '/parent/space/requests/$requestId/quote';
  static String planning(int requestId) =>
      '/parent/space/requests/$requestId/planning';
  static String contract(int id) => '/parent/space/contracts/$id';
}
