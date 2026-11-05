import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/parent_models.dart';
import 'parent_ui.dart';

/// A session row (PAR-12): the day, a bar in the colour of the status, subject and child, time
/// and tutor, the status below, a chevron. Rows sit in a card, separated by a line.
class ParentSessionTile extends StatelessWidget {
  const ParentSessionTile(
      {super.key, required this.session, this.onTap, this.divider = false});

  final ParentSession session;
  final VoidCallback? onTap;

  /// A line under the row (not after the last one of a card).
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final end = session.endsAt;
    return Material(
      color: AppPalette.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            border: divider
                ? const Border(bottom: BorderSide(color: AppPalette.n300))
                : null,
          ),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 40,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ParentFormat.weekday(context, session.startsAt),
                          style: AppTypography.caption
                              .copyWith(fontSize: 11, color: AppPalette.text2)),
                      Text('${session.startsAt.day}',
                          style: AppTypography.title
                              .copyWith(color: AppPalette.teal800)),
                    ]),
              ),
              Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: parentSessionTone(session.status),
                      borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title,
                          style: AppTypography.labelSm,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${ParentFormat.time(session.startsAt)}${end == null ? '' : ' – ${ParentFormat.time(end)}'} · ${session.tutorName}',
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2),
                      ),
                      const SizedBox(height: 6),
                      ParentStatusBadge(
                          status: session.status, label: session.statusLabel),
                    ]),
              ),
              if (onTap != null)
                const Center(
                    child: Icon(Icons.chevron_right,
                        size: 20, color: AppPalette.n500)),
            ]),
          ),
        ),
      ),
    );
  }
}
