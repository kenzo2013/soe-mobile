import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_avatar.dart';
import '../../domain/entities/student_summary.dart';

class ChildAvatarsRow extends StatelessWidget {
  const ChildAvatarsRow({
    super.key,
    required this.students,
    this.onAdd,
    this.onTapChild,
  });

  final List<StudentSummary> students;
  final VoidCallback? onAdd;
  final void Function(StudentSummary student)? onTapChild;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: students.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == 0) return _AddTile(onTap: onAdd);
          final s = students[i - 1];
          return _ChildTile(
            student: s,
            onTap: onTapChild == null ? null : () => onTapChild!(s),
          );
        },
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppPalette.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPalette.n500,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppPalette.teal,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajouter',
            style: TextStyle(
              fontSize: 10,
              color: AppPalette.n700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.student, this.onTap});
  final StudentSummary student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoeAvatar(
              name: student.fullName,
              imageUrl: student.avatarUrl,
              size: SoeAvatarSize.list,
            ),
            const SizedBox(height: 6),
            Text(
              student.firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppPalette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (student.classe.isNotEmpty)
              Text(
                student.classe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppPalette.n700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
