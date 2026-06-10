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
  static const String emailConfirmed = '/register/email-confirmed';
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
  static const String parentReservationNew = '/parent/reservations/new';
  static const String parentSessions = '/parent/sessions';
  static const String parentPayments = '/parent/payments';

  // Tutor shell
  static const String tutorDashboard = '/tutor';

  // Tutor · Mon profil
  static const String tutorProfile = '/tutor/profile';
  static const String tutorProfileBio = '/tutor/profile/bio';
  static const String tutorProfileTrainings = '/tutor/profile/trainings';
  static const String tutorProfileWorks = '/tutor/profile/works';
  static const String tutorProfileIdentities = '/tutor/profile/identities';
  static const String tutorProfileCourses = '/tutor/profile/courses';
  static const String tutorProfileAvailabilities =
      '/tutor/profile/availabilities';

  // Tutor · Offres d'emploi
  static const String tutorJobs = '/tutor/jobs';
  static String tutorJobDetail(String id) => '/tutor/jobs/$id';
  static String tutorJobApply(String id) => '/tutor/jobs/$id/apply';

  // Tutor · Mes cours
  static const String tutorCourses = '/tutor/courses';
  static String tutorCourseDetail(String id) => '/tutor/courses/$id';
  static String tutorCourseSchedules(String id) =>
      '/tutor/courses/$id/schedules';

  // Tutor · Séances
  static const String tutorSessions = '/tutor/sessions';
  static String tutorSessionDetail(String id) => '/tutor/sessions/$id';
  static String tutorSessionEdit(String id) => '/tutor/sessions/$id/edit';
  static String tutorSessionReport(String id) => '/tutor/sessions/$id/report';

  // Tutor · Rémunérations
  static const String tutorRemunerations = '/tutor/remunerations';

  // Tutor · Infos de paiement
  static const String tutorPayment = '/tutor/payment';
  static const String tutorPaymentAddBank = '/tutor/payment/bank';
  static const String tutorPaymentDetail = '/tutor/payment/detail';

  // Tutor · Contrats
  static const String tutorContracts = '/tutor/contracts';

  // Common · Mon compte
  static const String account = '/account';
  static const String accountProfile = '/account/profile';
  static const String accountPassword = '/account/password';
  static const String accountAddress = '/account/address';
  static const String accountRole = '/account/role';
  static const String accountNotificationPrefs =
      '/account/notification-preferences';

  // Common · Notifications
  static const String notifications = '/notifications';
  static String notificationDetail(String id) => '/notifications/$id';
}
