import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/session_summary.dart';

class TodaySessionRow extends StatelessWidget {
  const TodaySessionRow({super.key, required this.session, this.onTap});

  final SessionSummary session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Live = la seance est dans la fenetre [start, start + duration] et
    // pas encore validee/refusee. Plus de SessionStatus.inProgress dans
    // l'API (CDC §11.5 : pending|completed|approved|rejected).
    final now = DateTime.now();
    final endAt = session.startAt.add(Duration(minutes: session.durationMinutes));
    final isLive = session.status == SessionStatus.pending &&
        now.isAfter(session.startAt) &&
        now.isBefore(endAt);
    final hh = session.startAt.hour.toString().padLeft(2, '0');
    final mm = session.startAt.minute.toString().padLeft(2, '0');
    final dur = _formatDuration(session.durationMinutes);
    final boxBg = isLive ? AppPalette.successBg : AppPalette.infoBg;
    final boxFg = isLive ? AppPalette.success : AppPalette.teal;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: boxFg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                      children: [
                        TextSpan(text: hh),
                        TextSpan(
                          text: ':$mm',
                          style: const TextStyle(
                            fontSize: 9,
                            color: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dur,
                    style: TextStyle(
                      color: boxFg.withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.ink,
                          ),
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppPalette.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${session.childName} · ${session.tutorName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.n700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppPalette.n500,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    if (h > 0) return '${h}h';
    return '${m}min';
  }
}
