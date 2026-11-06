import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';
import '../../../common/presentation/pages/account_hub_page.dart';
import '../providers.dart';

/// « Mon conseiller SOE »: the family's advisor (from the home), the number with the opening
/// hours, « Appeler » (phone app) and « WhatsApp ». Nothing is shown before an advisor is
/// assigned.
class ParentAdvisorCard extends ConsumerWidget {
  const ParentAdvisorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final home = ref.watch(parentHomeProvider).valueOrNull;
    final advisor = home?.advisor;
    final name = advisor?.name ?? home?.advisorName;
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    final phone = advisor?.phone ?? home?.advisorPhone;
    final digits = phone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';
    final initials = advisor?.initials ??
        name
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();
    final whatsapp = advisor?.whatsappUrl == null
        ? Uri.https('wa.me', '/${digits.replaceAll('+', '')}')
        : Uri.parse(advisor!.whatsappUrl!);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppPalette.surfaceNav,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.home.advisor.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.onDark2)),
        const SizedBox(height: 12),
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppPalette.teal100,
            child: Text(initials,
                style: AppTypography.label.copyWith(color: AppPalette.teal800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style:
                      AppTypography.label.copyWith(color: AppPalette.onDark)),
              Text(advisor?.roleLabel ?? tr.advisor.role,
                  style: AppTypography.caption
                      .copyWith(color: AppPalette.onDark2)),
            ]),
          ),
        ]),
        if (phone != null && digits.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
              '${advisor?.phoneLabel ?? formatCameroonPhone(phone)} · ${advisor?.hoursLabel ?? tr.advisor.hours}',
              style: AppTypography.bodySm.copyWith(color: AppPalette.onDark)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.onDark,
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: AppPalette.onDark),
                    shape: const StadiumBorder()),
                onPressed: () => unawaited(launchUrl(
                    Uri(scheme: 'tel', path: digits),
                    mode: LaunchMode.externalApplication)),
                icon: const Icon(Icons.call_outlined, size: 18),
                label: _OneLine(tr.home.call),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.white,
                    foregroundColor: AppPalette.teal800,
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: const StadiumBorder()),
                onPressed: () => unawaited(
                    launchUrl(whatsapp, mode: LaunchMode.externalApplication)),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: _OneLine(tr.home.whatsapp),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

/// A button label on one line, shrunk when the column is narrow (tablet side column): « WhatsApp »
/// never breaks into « WhatsAp / p ».
class _OneLine extends StatelessWidget {
  const _OneLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, softWrap: false),
      );
}
