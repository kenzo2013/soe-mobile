import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../data/parent_models.dart';
import 'parent_ui.dart';

/// A session in a list: day, subject and child, time, tutor, status.
class ParentSessionTile extends StatelessWidget {
  const ParentSessionTile({super.key, required this.session, this.onTap});

  final ParentSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final end = session.endsAt;
    return SoeCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Column(children: [
            Text(
                ParentFormat.day(context, session.startsAt)
                    .split(' ')
                    .first
                    .toUpperCase(),
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            Text('${session.startsAt.day}', style: AppTypography.title),
          ]),
        ),
        Container(
            width: 2,
            height: 36,
            color: AppPalette.teal500,
            margin: const EdgeInsets.symmetric(horizontal: 10)),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.title,
                style: AppTypography.labelSm, overflow: TextOverflow.ellipsis),
            Text(
              '${ParentFormat.time(session.startsAt)}${end == null ? '' : ' – ${ParentFormat.time(end)}'} · ${session.tutorName}',
              style: AppTypography.caption.copyWith(color: AppPalette.text2),
            ),
          ]),
        ),
        ParentStatusBadge(status: session.status, label: session.statusLabel),
      ]),
    );
  }
}
