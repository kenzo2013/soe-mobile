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

  // Parent space tabs (PAR-01, Q5): Accueil, Planning, Enfants, Paiements, Plus.
  static const String parentHome = '/parent';
  static const String parentPlanning = '/parent/planning';
  static const String parentChildren = '/parent/children';
  static const String parentPayments = '/parent/payments';
  static const String parentMore = '/parent/more';

  // Tutor space tabs (REP-01, Q5): Aujourd’hui, Planning, Élèves, Revenus, Plus.
  static const String tutorHome = '/tutor';
  static const String tutorPlanning = '/tutor/planning';
  static const String tutorStudents = '/tutor/students';
  static const String tutorEarnings = '/tutor/earnings';
  static const String tutorMore = '/tutor/more';

  // Common · account (COM-01 to COM-10)
  static const String account = '/account';
  static const String accountProfile = '/account/profile';
  static const String accountSecurity = '/account/security';
  static const String accountDeletion = '/account/security/deletion';
  static const String accountAddress = '/account/address';
  static const String accountRoles = '/account/roles';
  static const String accountNotificationPrefs =
      '/account/notification-preferences';
  static const String help = '/account/help';
  static const String reports = '/account/reports';
  static const String reportNew = '/account/reports/new';
  static String reportDetail(int id) => '/account/reports/$id';

  // Common · notification centre (COM-07)
  static const String notifications = '/notifications';

  /// First screens of the tabs (Q5): reached with `go` (switches tab). Any other
  /// screen opens with `push`, over the tabs, which keep their history.
  static const Set<String> tabRoots = {
    parentHome,
    parentPlanning,
    parentChildren,
    parentPayments,
    parentMore,
    tutorHome,
    tutorPlanning,
    tutorStudents,
    tutorEarnings,
    tutorMore,
  };
}
