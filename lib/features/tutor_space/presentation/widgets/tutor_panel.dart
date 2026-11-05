import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';

/// A white card of rows separated by lines (Studio list card): an optional serif title, the
/// rows, an optional note on a soft background at the bottom.
class TutorPanel extends StatelessWidget {
  const TutorPanel({
    super.key,
    required this.children,
    this.title,
    this.footer,
    this.trailing,
  });

  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: AppRadius.rMd,
          border: Border.all(color: AppPalette.n300),
          boxShadow: AppShadows.sm,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.rMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(children: [
                    Expanded(
                        child: Text(title!,
                            style: AppTypography.h3
                                .copyWith(color: AppPalette.teal800))),
                    if (trailing != null) trailing!,
                  ]),
                ),
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                      height: 1, thickness: 1, color: AppPalette.n100),
                children[i],
              ],
              if (footer != null)
                Container(
                  color: AppPalette.n50,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: DefaultTextStyle.merge(
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.text2),
                      child: footer!),
                ),
            ],
          ),
        ),
      );
}

/// A row of a [TutorPanel]: a round leading (icon or initials), a title and a subtitle, a
/// trailing (amount, badge) and a chevron when it opens something.
class TutorPanelRow extends StatelessWidget {
  const TutorPanelRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.initials,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? initials;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leading = icon != null || initials != null;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            if (leading) ...[
              CircleAvatar(
                radius: 20,
                backgroundColor: AppPalette.teal50,
                child: icon != null
                    ? Icon(icon, size: 20, color: AppPalette.teal800)
                    : Text(initials!,
                        style: AppTypography.labelSm
                            .copyWith(color: AppPalette.teal800)),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.label
                            .copyWith(color: AppPalette.text)),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!,
                          style: AppTypography.caption
                              .copyWith(color: AppPalette.text2)),
                  ]),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppPalette.text2),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Initials of a name (« Ornella T. » → « OT »).
String tutorInitials(String? name) => (name ?? '')
    .split(RegExp(r'[\s,]+'))
    .where((part) =>
        part.isNotEmpty && RegExp(r'^\p{L}', unicode: true).hasMatch(part))
    .take(2)
    .map((part) => part.characters.first.toUpperCase())
    .join();
