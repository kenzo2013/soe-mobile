import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_models.dart';

/// Shared bits of the tutor space v2 screens: formats, badges, the async body.
abstract final class TutorFormat {
  static String amount(BuildContext context, int value) =>
      Translations.of(context).tutorSpace.amount(
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

  static String month(BuildContext context, DateTime date) =>
      toBeginningOfSentenceCase(
          DateFormat('MMMM yyyy', _locale(context)).format(date)) ??
      '';

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String dateTime(BuildContext context, DateTime date) =>
      '${day(context, date)}, ${time(date)}';

  /// « 16:00 – 17:30 » for a session.
  static String hours(TutorSession session) =>
      '${time(session.startsAt)}${session.endsAt == null ? '' : ' – ${time(session.endsAt!)}'}';

  /// The day name of the API (`monday`), translated.
  static String weekday(BuildContext context, String? day) {
    final tr = Translations.of(context).tutorSpace.days;
    return switch (day) {
      'monday' => tr.monday,
      'tuesday' => tr.tuesday,
      'wednesday' => tr.wednesday,
      'thursday' => tr.thursday,
      'friday' => tr.friday,
      'saturday' => tr.saturday,
      'sunday' => tr.sunday,
      _ => day ?? '',
    };
  }

  /// An option of the planning (« monday 16:00 ») as « Lundi 16:00 ».
  static String option(BuildContext context, String option) {
    final parts = option.split(' ');
    return parts.length == 2
        ? '${weekday(context, parts.first)} ${parts.last}'
        : option;
  }
}

/// The message of a failed action: the server's text when it has one (conflict, validation,
/// check-in codes, rate limit), else the shared error texts (network, timeout...).
String tutorFailureMessage(BuildContext context, Failure failure) =>
    switch (failure) {
      ConflictFailure(:final message) when message != null => message,
      ValidationFailure(:final message) when message != null => message,
      CodeFailure(:final message) when message != null => message,
      RateLimitedFailure(:final message) when message != null => message,
      _ => failureMessage(failure, Translations.of(context)),
    };

/// A state of a session (planned, to_report...) as a badge; the label comes from the API.
class TutorStateBadge extends StatelessWidget {
  const TutorStateBadge({super.key, required this.state, required this.label});

  final String state;
  final String label;

  @override
  Widget build(BuildContext context) => SoeBadge(
        label: label,
        tone: switch (state) {
          'approved' || 'signed' => SoeBadgeTone.success,
          'to_report' || 'sent' || 'proposed' => SoeBadgeTone.warning,
          'report_sent' || 'waiting' => SoeBadgeTone.info,
          'disputed' ||
          'suspended' ||
          'change_requested' =>
            SoeBadgeTone.danger,
          _ => SoeBadgeTone.neutral,
        },
      );
}

/// Loading skeletons, the error view with « Réessayer », or the content.
class TutorAsyncBody<T> extends StatelessWidget {
  const TutorAsyncBody({
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

/// A section title of the tutor screens.
class TutorSectionTitle extends StatelessWidget {
  const TutorSectionTitle(this.title, {super.key, this.trailing});

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

/// A label above its value (session details, report fields).
class TutorField extends StatelessWidget {
  const TutorField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: AppTypography.overline.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 2),
          SelectableText(value, style: AppTypography.body),
        ]),
      );
}

/// The padding of a bottom sheet, above the keyboard.
class TutorSheet extends StatelessWidget {
  const TutorSheet({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children),
          ),
        ),
      );
}

/// A session in a list: time, subject · pupil, state.
class TutorSessionTile extends StatelessWidget {
  const TutorSessionTile({
    super.key,
    required this.session,
    required this.onTap,
    this.showDay = true,
  });

  final TutorSession session;
  final VoidCallback onTap;
  final bool showDay;

  @override
  Widget build(BuildContext context) => SoeCard(
        onTap: onTap,
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  showDay
                      ? '${TutorFormat.day(context, session.date)} · ${TutorFormat.hours(session)}'
                      : TutorFormat.hours(session),
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 2),
              Text(session.title, style: AppTypography.label),
              if (session.schoolClass != null)
                Text(session.schoolClass!,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
            ]),
          ),
          const SizedBox(width: 8),
          TutorStateBadge(state: session.state, label: session.stateLabel),
        ]),
      );
}
