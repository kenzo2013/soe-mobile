/// Toutes les routes nommées SOE — pas de magic strings ailleurs.
abstract final class RouteNames {
  // Public
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordForgot = '/password/forgot';
  static const String emailConfirmation = '/email/confirm';

  // Parent shell
  static const String parentDashboard = '/parent';
  static const String parentStudents = '/parent/students';
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
