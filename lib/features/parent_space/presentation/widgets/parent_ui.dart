import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';

/// Shared bits of the parent space v2 screens: formats, badges, the async body.
abstract final class ParentFormat {
  static String amount(BuildContext context, int value) =>
      Translations.of(context).parentSpace.amount(
          amount: NumberFormat.decimalPattern('fr')
              .format(value)
              .replaceAll(',', ' '));

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  static String day(BuildContext context, DateTime date) =>
      toBeginningOfSentenceCase(
          DateFormat('EEE d MMM', _locale(context)).format(date)) ??
      '';

  static String dayLong(BuildContext context, DateTime date) =>
      toBeginningOfSentenceCase(
          DateFormat('EEEE d MMMM', _locale(context)).format(date)) ??
      '';

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String dateTime(BuildContext context, DateTime date) =>
      '${day(context, date)}, ${time(date)}';
}

/// The message of a failed action: the server's text when it has one (conflict, validation,
/// rate limit), else the shared error texts (network, timeout...).
String parentFailureMessage(BuildContext context, Failure failure) =>
    switch (failure) {
      ConflictFailure(:final message) when message != null => message,
      ValidationFailure(:final message) when message != null => message,
      RateLimitedFailure(:final message) when message != null => message,
      _ => failureMessage(failure, Translations.of(context)),
    };

/// A status of the parent's planning as a badge (the label comes from the API).
class ParentStatusBadge extends StatelessWidget {
  const ParentStatusBadge(
      {super.key, required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) => SoeBadge(
        label: label,
        tone: switch (status) {
          'approved' || 'paid' => SoeBadgeTone.success,
          'report_to_approve' ||
          'in_progress' ||
          'issued' =>
            SoeBadgeTone.warning,
          'disputed' || 'suspended' || 'overdue' => SoeBadgeTone.danger,
          _ => SoeBadgeTone.neutral,
        },
      );
}

/// Loading skeletons, the error view with « Réessayer », or the content.
class ParentAsyncBody<T> extends StatelessWidget {
  const ParentAsyncBody({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => value.when(
        data: builder,
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SoeSkeleton(height: 28, width: 200),
            SizedBox(height: 16),
            SoeSkeleton(height: 96),
            SizedBox(height: 12),
            SoeSkeleton(height: 96),
          ],
        ),
        error: (error, _) =>
            ErrorView(failure: asFailure(error), onRetry: onRetry),
      );
}

/// A section title of the parent screens.
class ParentSectionTitle extends StatelessWidget {
  const ParentSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: AppTypography.title.copyWith(color: AppPalette.text))),
          if (trailing != null) trailing!,
        ]),
      );
}
