/// Paths of the API v2 (relative to `Env.apiV2BaseUrl`). Contract: soe/docs/api/v2/openapi.yml.
abstract final class ApiEndpointsV2 {
  /// The signed-in account: identity, language, roles, active role.
  static const String me = '/me';

  // Authentication (AUT-02 to AUT-11).
  static const String session = '/auth/session';
  static const String signUpValidate = '/auth/registrations/validate';
  static const String signUp = '/auth/registrations';
  static const String confirmation = '/auth/confirmations';
  static const String confirmationResend = '/auth/confirmations/resend';
  static const String passwordReset = '/auth/password_resets';
  static const String passwordResetVerify = '/auth/password_resets/verify';
  static const String passwordResetResend = '/auth/password_resets/resend';

  // Parent space (lot 3, PAR-01 to PAR-17).
  static const String parentHome = '/parent/home';
  static const String parentChildren = '/parent/children';
  static String parentChild(int id) => '/parent/children/$id';
  static const String parentSessions = '/parent/sessions';
  static String parentSession(int id) => '/parent/sessions/$id';
  static String parentSessionCancel(int id) => '/parent/sessions/$id/cancel';
  static String parentReport(int sessionId) =>
      '/parent/sessions/$sessionId/report';
  static String parentReportAnswer(int sessionId) =>
      '/parent/sessions/$sessionId/report/answer';
  static const String parentInvoices = '/parent/invoices';
  static String parentInvoicePay(int id) => '/parent/invoices/$id/pay';
  static const String parentPayments = '/parent/payments';
  static String parentPayment(int id) => '/parent/payments/$id';
  static const String parentRequests = '/parent/requests';
  static String parentRequest(int id) => '/parent/requests/$id';
  static String parentQuote(int requestId) =>
      '/parent/requests/$requestId/quote';
  static String parentQuoteAnswer(int requestId) =>
      '/parent/requests/$requestId/quote/answer';
  static String parentPlanning(int requestId) =>
      '/parent/requests/$requestId/planning';
  static String parentPlanningAnswer(int requestId) =>
      '/parent/requests/$requestId/planning/answer';
  static String parentContract(int id) => '/parent/contracts/$id';
  static String parentContractSign(int id) => '/parent/contracts/$id/sign';

  // Tutor space (lot 4, REP-01 to REP-21).
  static const String tutorHome = '/tutor/home';
  static const String tutorSessions = '/tutor/sessions';
  static String tutorSession(int id) => '/tutor/sessions/$id';
  static String tutorCheckIn(int id) => '/tutor/sessions/$id/check_in';
  static String tutorCheckOut(int id) => '/tutor/sessions/$id/check_out';
  static String tutorProblem(int id) => '/tutor/sessions/$id/problem';
  static String tutorReport(int sessionId) =>
      '/tutor/sessions/$sessionId/report';
  static String tutorProposal(int id) => '/tutor/proposals/$id';
  static String tutorProposalAnswer(int id) => '/tutor/proposals/$id/answer';
  static String tutorPlanning(int slotId) => '/tutor/slots/$slotId/planning';
  static const String tutorEarnings = '/tutor/earnings';
  static const String tutorContracts = '/tutor/contracts';
  static String tutorContract(int id) => '/tutor/contracts/$id';
  static String tutorContractSign(int id) => '/tutor/contracts/$id/sign';
}
