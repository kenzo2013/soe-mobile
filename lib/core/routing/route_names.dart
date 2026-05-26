/// Toutes les routes nommées SOE — pas de magic strings ailleurs.
abstract final class RouteNames {
  // Public — flow auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleChoice = '/role';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerStep1 = '/register/identity';
  static const String registerStep2 = '/register/contact';
  static const String registerStep3 = '/register/password';
  static const String registerStep4 = '/register/address';
  static const String emailSent = '/register/email-sent';
  static const String passwordForgot = '/password/forgot';
  static const String passwordForgotSent = '/password/forgot-sent';
  static const String passwordReset = '/password/reset';

  // Parent shell
  static const String parentDashboard = '/parent';
  static const String parentStudents = '/parent/students';
  static const String parentStudentNew = '/parent/students/new';
  static String parentStudentDetail(String id) => '/parent/students/$id';
  static String parentStudentEdit(String id) => '/parent/students/$id/edit';
  static String parentTutorProfile({
    required String studentId,
    required String tutorId,
  }) =>
      '/parent/students/$studentId/tutors/$tutorId';
  static const String parentReservations = '/parent/reservations';
  static const String parentSessions = '/parent/sessions';
  static const String parentPayments = '/parent/payments';

  // Tutor shell
  static const String tutorDashboard = '/tutor';
  static const String tutorJobs = '/tutor/jobs';
  static const String tutorSessions = '/tutor/sessions';
  static const String tutorProfile = '/tutor/profile';

  // Common
  static const String account = '/account';
  static const String notifications = '/notifications';
}
