import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_offer_models.dart';
import '../../data/tutor_student_models.dart';
import 'tutor_ui.dart';

/// Shared bits of the offers, applications and pupils screens (REP-10 to REP-14).
abstract final class TutorOfferFormat {
  static const _days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  /// « mer. 16:00 » for a weekly time (the short day name in the app's language).
  static String shortTime(BuildContext context, TutorWeeklyTime time) {
    final index = _days.indexOf(time.day);
    if (index < 0) return [time.day, time.from].whereType<String>().join(' ');
    // 2024-01-01 is a Monday.
    final day = DateFormat('EEE', Localizations.localeOf(context).languageCode)
        .format(DateTime(2024, 1, 1 + index));
    return [day, time.from].whereType<String>().join(' ');
  }

  /// « Yann M., 4e ».
  static String pupilName(String pupil, String? schoolClass) => [
        pupil,
        schoolClass
      ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  /// « YM » for « Yann M. ».
  static String initials(String name) => name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// The answer of SOE to an application, or the state of a pupil, as a badge.
class TutorToneBadge extends StatelessWidget {
  const TutorToneBadge({super.key, required this.state, required this.label});

  final String state;
  final String label;

  @override
  Widget build(BuildContext context) => SoeBadge(
        label: label,
        tone: switch (state) {
          'selected' || 'active' => SoeBadgeTone.success,
          'contract' || 'times' => SoeBadgeTone.warning,
          'sent' || 'waiting' => SoeBadgeTone.info,
          _ => SoeBadgeTone.neutral,
        },
      );
}

/// A round icon or initials on the left of a list tile.
class TutorTileLeading extends StatelessWidget {
  const TutorTileLeading({super.key, this.icon, this.text});

  final IconData? icon;
  final String? text;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: icon != null ? AppPalette.teal50 : AppPalette.gold100,
            shape: BoxShape.circle),
        child: icon != null
            ? Icon(icon, size: 20, color: AppPalette.teal500)
            : Text(text ?? '',
                style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700, color: AppPalette.gold700)),
      );
}

/// A tappable row of a list card: leading, title, subtitle, a badge and a chevron.
class TutorListTile extends StatelessWidget {
  const TutorListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.label),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                  ]),
            ),
            if (badge != null) ...[const SizedBox(width: 8), badge!],
            const Icon(Icons.chevron_right, color: AppPalette.text2),
          ]),
        ),
      );
}

/// A white card holding list tiles separated by lines, with an optional note at the bottom.
class TutorListCard extends StatelessWidget {
  const TutorListCard(
      {super.key, required this.children, this.note, this.raised = false});

  final List<Widget> children;
  final String? note;

  /// The first card of a tab, overlapping the band.
  final bool raised;

  @override
  Widget build(BuildContext context) => SoeCard(
        padding: EdgeInsets.zero,
        raised: raised,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: AppPalette.border),
                    children[i],
                  ],
                  if (note != null)
                    Container(
                      color: AppPalette.surfaceSoft,
                      padding: const EdgeInsets.all(16),
                      child: Text(note!,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                    ),
                ]),
          ),
        ),
      );
}

/// An offer in the list (REP-10): reference · neighbourhood, subjects · classes, start, pay.
class TutorOfferCard extends StatelessWidget {
  const TutorOfferCard({super.key, required this.offer, required this.onTap});

  final TutorOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.offers;
    final rate = offer.sessionRate;
    final start = TutorFormat.offerStart(context,
        label: offer.startLabel,
        date: offer.startDate,
        passed: offer.startPassed);
    return SoeCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.work_outline, size: 14, color: AppPalette.text2),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
                [offer.reference, offer.neighborhood]
                    .whereType<String>()
                    .where((s) => s.isNotEmpty)
                    .join(' · '),
                style: AppTypography.labelSm.copyWith(color: AppPalette.text2)),
          ),
          if (offer.applied)
            SoeBadge(
                label: tr.applied, tone: SoeBadgeTone.info, icon: Icons.check),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer.title(tr.and), style: AppTypography.subtitle),
              if (start != null)
                Text(tr.starts(date: start),
                    style:
                        AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            ]),
          ),
          if (rate != null) ...[
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  NumberFormat.decimalPattern('fr')
                      .format(rate)
                      .replaceAll(',', ' '),
                  style: AppTypography.numberM
                      .copyWith(color: AppPalette.successText)),
              Text(tr.perSession,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ],
        ]),
        const SizedBox(height: 12),
        SoeButton(
          label: tr.see,
          variant: SoeButtonVariant.secondary,
          size: SoeButtonSize.md,
          fullWidth: true,
          onPressed: onTap,
        ),
      ]),
    );
  }
}

/// A soft blue banner: an icon, a bold line, an optional text and an optional action on the right.
class TutorInfoBanner extends StatelessWidget {
  const TutorInfoBanner({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.info_outline,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(14, 12, actionLabel == null ? 14 : 4, 12),
        decoration: BoxDecoration(
            color: AppPalette.infoBg, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: AppPalette.infoText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: AppTypography.labelSm
                      .copyWith(color: AppPalette.infoText)),
              if (body != null) ...[
                const SizedBox(height: 2),
                Text(body!, style: AppTypography.bodySm),
              ],
            ]),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ]),
      );
}
