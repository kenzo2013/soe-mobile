/// Paths of the screens that open from the parent tabs (lot 3), full screen.
abstract final class ParentSpaceRoutes {
  static String session(int id) => '/parent/space/sessions/$id';
  static String report(int sessionId) =>
      '/parent/space/sessions/$sessionId/report';
  static String child(int id) => '/parent/space/children/$id';
  static String pay(int invoiceId) => '/parent/space/invoices/$invoiceId/pay';
  static String payment(int id) => '/parent/space/payments/$id';
}
