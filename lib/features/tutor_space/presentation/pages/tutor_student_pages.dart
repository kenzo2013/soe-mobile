import 'package:flutter/material.dart';

/// REP-14 — the pupils, a tab (placeholder, being built).
class TutorStudentsPage extends StatelessWidget {
  const TutorStudentsPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold();
}

/// REP-14 — a pupil's file (placeholder, being built).
class TutorStudentPage extends StatelessWidget {
  const TutorStudentPage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) => const Scaffold();
}
