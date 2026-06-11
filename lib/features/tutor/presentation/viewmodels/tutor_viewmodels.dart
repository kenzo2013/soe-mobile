import '../../domain/entities/tutor_contract.dart';
import '../../domain/entities/tutor_course.dart';
import '../../domain/entities/tutor_dashboard.dart';
import '../../domain/entities/tutor_job.dart';
import '../../domain/entities/tutor_payment_method.dart';
import '../../domain/entities/tutor_profile.dart';
import '../../domain/entities/tutor_remuneration.dart';
import '../../domain/entities/tutor_session.dart';
import '../../domain/usecases/tutor_usecases.dart';
import 'tutor_async_state.dart';

/// ViewModels concrets. Chacun délègue à un usecase et hérite d'un VM
/// générique (`AsyncObjectViewModel` / `AsyncListViewModel` /
/// `AsyncItemViewModel`). Des types nommés distincts facilitent les overrides
/// de providers et les tests par écran.

// ── Dashboard ────────────────────────────────────────────────
class TutorDashboardViewModel extends AsyncObjectViewModel<TutorDashboard> {
  TutorDashboardViewModel(GetTutorDashboard uc) : super(uc.call);
}

// ── Profil ───────────────────────────────────────────────────
class TutorProfileViewModel extends AsyncObjectViewModel<TutorProfile> {
  TutorProfileViewModel(GetTutorProfile uc) : super(uc.call);
}

class TutorTrainingsViewModel extends AsyncListViewModel<TutorTraining> {
  TutorTrainingsViewModel(ListTutorTrainings uc) : super(uc.call);
}

class TutorWorksViewModel extends AsyncListViewModel<TutorWork> {
  TutorWorksViewModel(ListTutorWorks uc) : super(uc.call);
}

class TutorIdentitiesViewModel extends AsyncListViewModel<TutorIdentity> {
  TutorIdentitiesViewModel(ListTutorIdentities uc) : super(uc.call);
}

class TutorTeachingCoursesViewModel
    extends AsyncListViewModel<TutorTeachingCourse> {
  TutorTeachingCoursesViewModel(ListTutorTeachingCourses uc) : super(uc.call);
}

class TutorAvailabilitiesViewModel
    extends AsyncListViewModel<TutorDayAvailability> {
  TutorAvailabilitiesViewModel(ListTutorAvailabilities uc) : super(uc.call);
}

// ── Offres d'emploi ──────────────────────────────────────────
class TutorJobsListViewModel extends AsyncListViewModel<TutorJob> {
  TutorJobsListViewModel(ListTutorJobs uc) : super(uc.call);
}

class TutorJobDetailViewModel extends AsyncItemViewModel<TutorJob> {
  TutorJobDetailViewModel(GetTutorJob uc) : super(uc.call);
}

// ── Mes cours ────────────────────────────────────────────────
class TutorActiveCoursesViewModel
    extends AsyncListViewModel<TutorActiveCourse> {
  TutorActiveCoursesViewModel(ListTutorCourses uc) : super(uc.call);
}

class TutorCourseDetailViewModel extends AsyncItemViewModel<TutorCourseDetail> {
  TutorCourseDetailViewModel(GetTutorCourse uc, {String? reservationId})
      : super((id) => uc(studentId: id, reservationId: reservationId));
}

// ── Séances ──────────────────────────────────────────────────
class TutorSessionsListViewModel extends AsyncListViewModel<TutorSessionGroup> {
  TutorSessionsListViewModel(ListTutorSessionGroups uc) : super(uc.call);
}

class TutorSessionDetailViewModel
    extends AsyncItemViewModel<TutorSessionDetail> {
  TutorSessionDetailViewModel(GetTutorSession uc) : super(uc.call);
}

// ── Rémunérations ────────────────────────────────────────────
class TutorRemunerationsViewModel
    extends AsyncObjectViewModel<TutorRemunerations> {
  TutorRemunerationsViewModel(GetTutorRemunerations uc) : super(uc.call);
}

// ── Infos de paiement ────────────────────────────────────────
class TutorPaymentMethodsViewModel
    extends AsyncListViewModel<TutorPaymentMethod> {
  TutorPaymentMethodsViewModel(ListTutorPaymentMethods uc) : super(uc.call);
}

// ── Contrats ─────────────────────────────────────────────────
class TutorContractsViewModel extends AsyncListViewModel<TutorContract> {
  TutorContractsViewModel(ListTutorContracts uc) : super(uc.call);
}
