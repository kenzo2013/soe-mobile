import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';
import '../providers.dart';
import '../widgets/tutor_ui.dart';

/// REP-22 — Ma qualité: the tutor's private view of the average rating, the punctuality from
/// the check-ins and the reports sent on time. A figure with nothing to measure shows « — ».
class TutorQualityPage extends ConsumerWidget {
  const TutorQualityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.quality;
    final value = ref.watch(tutorQualityProvider);
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: AppBar(title: Text(tr.title)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorQualityProvider.future),
        child: TutorAsyncBody<TutorQuality>(
          value: value,
          onRetry: () => ref.invalidate(tutorQualityProvider),
          builder: (quality) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(tr.title,
                  style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: SoeBadge(label: tr.private, tone: SoeBadgeTone.info),
              ),
              const SizedBox(height: 12),
              Text(tr.intro,
                  style: AppTypography.body.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 16),
              _Figure(
                title: tr.rating,
                value: _rating(context, quality.rating),
                caption: tr.reviews(n: quality.reviewsCount),
              ),
              const SizedBox(height: 12),
              _Figure(
                title: tr.punctuality,
                value: _percent(context, quality.punctualityPercent),
                caption: tr.punctualityText(
                    n: quality.periodMonths,
                    minutes: quality.punctualityGraceMinutes),
              ),
              const SizedBox(height: 12),
              _Figure(
                title: tr.reports,
                value: _percent(context, quality.onTimeReportsPercent),
                caption: tr.reportsText(hours: quality.reportSubmissionHours),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// « 4,8 / 5 » (one decimal, in the reader's language), « — » without any review.
  static String _rating(BuildContext context, double? rating) {
    final tr = Translations.of(context).tutorSpace.quality;
    if (rating == null) return tr.none;
    final locale = Localizations.localeOf(context).languageCode;
    return tr.ratingValue(rating: NumberFormat('0.0', locale).format(rating));
  }

  static String _percent(BuildContext context, int? percent) {
    final tr = Translations.of(context).tutorSpace.quality;
    return percent == null ? tr.none : tr.percent(value: percent);
  }
}

/// One figure of the view: its title, the value in large and what it measures.
class _Figure extends StatelessWidget {
  const _Figure(
      {required this.title, required this.value, required this.caption});

  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => SoeCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 12),
          Text(value,
              style: AppTypography.h1.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 2),
          Text(caption,
              style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        ]),
      );
}
