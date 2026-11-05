/// Paths of the API v2 parent endpoints added after lot 3 (children forms, request wizard,
/// tutors, contracts list, reviews, co-parents). Kept in the parent space so the shared
/// [ApiEndpointsV2] only holds the first lot.
abstract final class ParentEndpoints {
  static const String references = '/references';

  static String childArchive(int id) => '/parent/children/$id/archive';
  static String childPhoto(int id) => '/parent/children/$id/photo';

  static String sessionProblem(int id) => '/parent/sessions/$id/problem';
  static String paymentReceipt(int id) => '/parent/payments/$id/receipt';

  static const String draft = '/parent/request_draft';
  static const String draftChildren = '/parent/request_draft/children';
  static String draftNeed(int childId) =>
      '/parent/request_draft/needs/$childId';
  static const String draftSummary = '/parent/request_draft/summary';
  static const String draftSubmit = '/parent/request_draft/submit';

  static String requestCancel(int id) => '/parent/requests/$id/cancel';
  static String requestNeed(int requestId, int needId) =>
      '/parent/requests/$requestId/needs/$needId';
  static String tutors(int requestId) => '/parent/requests/$requestId/tutors';
  static String tutorReviews(int requestId, int tutorId) =>
      '/parent/requests/$requestId/tutors/$tutorId/reviews';
  static String replacement(int requestId) =>
      '/parent/requests/$requestId/tutors/replacement';

  static const String contracts = '/parent/contracts';
  static String contractPdf(int id) => '/parent/contracts/$id/pdf';
  static String amendments(int contractId) =>
      '/parent/contracts/$contractId/amendments';
  static String amendment(int contractId, int id) =>
      '/parent/contracts/$contractId/amendments/$id';
  static String amendmentSign(int contractId, int id) =>
      '/parent/contracts/$contractId/amendments/$id/sign';
  static String amendmentPdf(int contractId, int id) =>
      '/parent/contracts/$contractId/amendments/$id/pdf';

  static const String reviews = '/parent/reviews';
  static const String reviewTutors = '/parent/reviews/tutors';
  static String review(int id) => '/parent/reviews/$id';

  static const String coParents = '/parent/co_parents';
  static String coParent(int id) => '/parent/co_parents/$id';
  static const String invitations = '/parent/co_parents/invitations';
  static String invitation(int id) => '/parent/co_parents/invitations/$id';
  static String invitationResend(int id) =>
      '/parent/co_parents/invitations/$id/resend';
}
