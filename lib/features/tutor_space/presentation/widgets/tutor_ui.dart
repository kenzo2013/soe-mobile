import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// A length in minutes: « 2 h », « 1 h 30 », « 45 min ».
  static String duration(BuildContext context, int minutes) {
    final tr = Translations.of(context).tutorSpace.times.duration;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return tr.minutes(m: m);
    return m == 0
        ? tr.hours(h: h)
        : tr.hoursMinutes(h: h, m: m.toString().padLeft(2, '0'));
  }

  /// « Lun. », the short day name.
  static String weekdayShort(BuildContext context, DateTime date) =>
      toBeginningOfSentenceCase(
          DateFormat('EEE', _locale(context)).format(date)) ??
      '';

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
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800))),
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

/// Opens the phone app on the parent's number.
Future<bool> tutorCall(String phone) =>
    launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), '')),
        mode: LaunchMode.externalApplication);

/// Opens the maps app on the lessons address.
Future<bool> tutorDirections(String place) => launchUrl(
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': place}),
    mode: LaunchMode.externalApplication);

/// A row of a detail card: the label on the left, the value on the right, a line below.
class TutorInfoRow extends StatelessWidget {
  const TutorInfoRow(
      {super.key,
      required this.label,
      required this.value,
      this.valueColor,
      this.last = false});

  final String label;
  final String value;
  final Color? valueColor;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: AppPalette.n300))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Both expanded: a loose label would leave its unused share empty and pull the
          // value away from the right edge.
          Expanded(
            flex: 2,
            child: Text(label,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppTypography.label
                    .copyWith(color: valueColor ?? AppPalette.text)),
          ),
        ]),
      );
}

/// A centred state card: an icon in a circle, a title, a text, then [children] (figures,
/// steps, a button). Expired, accepted, waiting, not yet available, approved…
class TutorStatusCard extends StatelessWidget {
  const TutorStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = SoeBadgeTone.info,
    this.children = const [],
  });

  final IconData icon;
  final String title;
  final String body;
  final SoeBadgeTone tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      SoeBadgeTone.success => (AppPalette.successBg, AppPalette.success),
      SoeBadgeTone.warning => (AppPalette.gold50, AppPalette.warningText),
      SoeBadgeTone.danger => (AppPalette.dangerBg, AppPalette.dangerText),
      _ => (AppPalette.infoBg, AppPalette.teal800),
    };
    return SoeCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 32, color: fg),
        ),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: 8),
        Text(body,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
        ...children,
      ]),
    );
  }
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
