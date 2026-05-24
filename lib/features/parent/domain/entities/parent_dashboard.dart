import 'reservation_summary.dart';
import 'session_summary.dart';
import 'student_summary.dart';

class ParentDashboard {
  const ParentDashboard({
    required this.students,
    required this.todaySessions,
    required this.recentReservations,
  });

  final List<StudentSummary> students;
  final List<SessionSummary> todaySessions;
  final List<ReservationSummary> recentReservations;

  bool get isEmpty => students.isEmpty;
}
