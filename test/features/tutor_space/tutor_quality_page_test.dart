import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_quality_page.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/i18n/translations.g.dart';

import '../../helpers/pump_app.dart';

TutorQuality _quality({
  double? rating = 4.8,
  int reviews = 12,
  int? punctuality = 96,
  int? reports = 100,
}) =>
    TutorQuality.fromJson({
      'rating': rating,
      'reviews_count': reviews,
      'punctuality_percent': punctuality,
      'on_time_reports_percent': reports,
      'period_months': 3,
      'punctuality_grace_minutes': 10,
      'report_submission_hours': 24,
    });

void main() {
  testWidgets('shows the rating, the punctuality and the reports on time',
      (tester) async {
    await pumpAppWith(
      tester,
      overrides: [tutorQualityProvider.overrideWith((ref) async => _quality())],
      child: const TutorQualityPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vue privée'), findsOneWidget);
    expect(find.text('4,8 / 5'), findsOneWidget);
    expect(find.text('12 avis de familles'), findsOneWidget);
    expect(find.text('96 %'), findsOneWidget);
    expect(find.textContaining('3 derniers mois'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(find.text('dans les 24 h'), findsOneWidget);
  });

  testWidgets('shows « — » for the figures with nothing to measure',
      (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorQualityProvider.overrideWith((ref) async => _quality(
            rating: null, reviews: 0, punctuality: null, reports: null)),
      ],
      child: const TutorQualityPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('Aucun avis de famille pour l’instant'), findsOneWidget);
  });

  testWidgets('formats the rating in English', (tester) async {
    await pumpAppWith(
      tester,
      locale: AppLocale.en,
      overrides: [tutorQualityProvider.overrideWith((ref) async => _quality())],
      child: const TutorQualityPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('4.8 / 5'), findsOneWidget);
    expect(find.text('96%'), findsOneWidget);
  });
}
