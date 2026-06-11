import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/routing/route_names.dart';

void main() {
  group('RouteNames · constantes statiques', () {
    test('flow auth public', () {
      expect(RouteNames.splash, '/');
      expect(RouteNames.onboarding, '/onboarding');
      expect(RouteNames.roleChoice, '/role');
      expect(RouteNames.login, '/login');
      expect(RouteNames.register, '/register');
      expect(RouteNames.registerStep1, '/register/identity');
      expect(RouteNames.registerStep2, '/register/contact');
      expect(RouteNames.registerStep3, '/register/password');
      expect(RouteNames.registerStep4, '/register/address');
      expect(RouteNames.emailSent, '/register/email-sent');
      expect(RouteNames.emailConfirmed, '/register/email-confirmed');
      expect(RouteNames.passwordForgot, '/password/forgot');
      expect(RouteNames.passwordForgotSent, '/password/forgot-sent');
      expect(RouteNames.passwordReset, '/password/reset');
    });

    test('parent shell (constantes)', () {
      expect(RouteNames.parentDashboard, '/parent');
      expect(RouteNames.parentStudents, '/parent/students');
      expect(RouteNames.parentStudentNew, '/parent/students/new');
      expect(RouteNames.parentReservations, '/parent/reservations');
      expect(RouteNames.parentReservationNew, '/parent/reservations/new');
      expect(RouteNames.parentSessions, '/parent/sessions');
      expect(RouteNames.parentPayments, '/parent/payments');
    });

    test('tutor shell + profil (constantes)', () {
      expect(RouteNames.tutorDashboard, '/tutor');
      expect(RouteNames.tutorProfile, '/tutor/profile');
      expect(RouteNames.tutorProfileBio, '/tutor/profile/bio');
      expect(RouteNames.tutorProfileTrainings, '/tutor/profile/trainings');
      expect(RouteNames.tutorProfileWorks, '/tutor/profile/works');
      expect(RouteNames.tutorProfileIdentities, '/tutor/profile/identities');
      expect(RouteNames.tutorProfileCourses, '/tutor/profile/courses');
      expect(
        RouteNames.tutorProfileAvailabilities,
        '/tutor/profile/availabilities',
      );
    });

    test('tutor jobs / courses / sessions / remunerations / payment / contrats',
        () {
      expect(RouteNames.tutorJobs, '/tutor/jobs');
      expect(RouteNames.tutorCourses, '/tutor/courses');
      expect(RouteNames.tutorSessions, '/tutor/sessions');
      expect(RouteNames.tutorRemunerations, '/tutor/remunerations');
      expect(RouteNames.tutorPayment, '/tutor/payment');
      expect(RouteNames.tutorPaymentAddBank, '/tutor/payment/bank');
      expect(RouteNames.tutorPaymentDetail, '/tutor/payment/detail');
      expect(RouteNames.tutorContracts, '/tutor/contracts');
    });

    test('common (constantes)', () {
      expect(RouteNames.account, '/account');
      expect(RouteNames.accountProfile, '/account/profile');
      expect(RouteNames.accountPassword, '/account/password');
      expect(RouteNames.accountAddress, '/account/address');
      expect(RouteNames.accountRole, '/account/role');
      expect(
        RouteNames.accountNotificationPrefs,
        '/account/notification-preferences',
      );
      expect(RouteNames.notifications, '/notifications');
      expect(RouteNames.contractDetail, '/contracts/detail');
    });
  });

  group('RouteNames · builders paramétrés', () {
    test('parent students détail / edit', () {
      expect(RouteNames.parentStudentDetail('42'), '/parent/students/42');
      expect(RouteNames.parentStudentEdit('42'), '/parent/students/42/edit');
    });

    test('parentTutorProfile combine studentId + tutorId', () {
      expect(
        RouteNames.parentTutorProfile(studentId: '7', tutorId: '99'),
        '/parent/students/7/tutors/99',
      );
    });

    test('tutor jobs builders', () {
      expect(RouteNames.tutorJobDetail('j1'), '/tutor/jobs/j1');
      expect(RouteNames.tutorJobApply('j1'), '/tutor/jobs/j1/apply');
    });

    test('tutor courses builders', () {
      expect(RouteNames.tutorCourseDetail('c1'), '/tutor/courses/c1');
      expect(
        RouteNames.tutorCourseSchedules('c1'),
        '/tutor/courses/c1/schedules',
      );
    });

    test('tutor sessions builders', () {
      expect(RouteNames.tutorSessionDetail('s1'), '/tutor/sessions/s1');
      expect(RouteNames.tutorSessionEdit('s1'), '/tutor/sessions/s1/edit');
      expect(RouteNames.tutorSessionReport('s1'), '/tutor/sessions/s1/report');
    });

    test('notificationDetail', () {
      expect(RouteNames.notificationDetail('n9'), '/notifications/n9');
    });

    test('builders supportent les ids vides ou spéciaux sans planter', () {
      expect(RouteNames.parentStudentDetail(''), '/parent/students/');
      expect(
        RouteNames.tutorJobDetail('a b'),
        '/tutor/jobs/a b',
      );
    });
  });
}
