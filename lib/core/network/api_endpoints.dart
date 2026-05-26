/// Centralisation de tous les endpoints API SOE (cahier des charges §7.6).
abstract final class ApiEndpoints {
  // Auth
  static const String login = '/users/login';
  static const String logout = '/users/logout';
  static const String register = '/users/register';
  static const String confirmation = '/users/confirmation';
  static const String confirmationVerifyCode = '/users/confirmation/verify_code';
  static const String passwordReset = '/users/password';
  static const String passwordVerifyCode = '/users/password/verify_code';
  static const String passwordResetWithCode = '/users/password/reset_with_code';

  // Current user
  static const String currentUser = '/current_user';
  static const String updatePassword = '/current_user/update_password';
  static const String roleSwitch = '/role_switch';
  static const String roleAddition = '/role_addition';

  // Devices
  static const String userDevices = '/user_devices';
  static const String userDevicesActivity = '/user_devices/activity';

  // Parents
  static const String parentsDashboard = '/parents';
  static const String parentsStudents = '/parents/students';
  static const String parentsReservations = '/parents/reservations';
  static const String parentsSessions = '/parents/sessions';
  static const String parentsPayments = '/parents/payments';
  static const String parentsReviews = '/parents/reviews';

  // Tutors
  static const String tutorsDashboard = '/tutors';
  static const String tutorsJobs = '/tutors/jobs';
  static const String tutorsCandidacies = '/tutors/candidacies';
  static const String tutorsSessions = '/tutors/sessions';
  static const String tutorsTutoringCourses = '/tutors/tutoring_courses';
  static const String tutorsAvailabilities = '/tutors/availabilities';
  static const String tutorsRemunerations = '/tutors/remunerations';
  static const String tutorsDescriptions = '/tutors/descriptions';
  static const String tutorsTrainings = '/tutors/trainings';
  static const String tutorsWorks = '/tutors/works';
  static const String tutorsIdentities = '/tutors/identities';
  static const String tutorsTutorCourses = '/tutors/tutor_courses';
  static const String tutorsPaymentInformations =
      '/tutors/payment_informations';

  // Common
  static const String notifications = '/common/notifications';
  static const String notificationPreferences =
      '/common/notification_preferences';
  static const String contracts = '/common/contracts';
  static const String address = '/common/address';
}
