import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';

/// « Mon conseiller SOE »: the family's advisor (from the home), the number to call.
/// Nothing is shown before an advisor is assigned.
class ParentAdvisorCard extends ConsumerWidget {
  const ParentAdvisorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).parentSpace;
    final home = ref.watch(parentHomeProvider).valueOrNull;
    final name = home?.advisorName;
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    final phone = home?.advisorPhone;
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppPalette.surfaceNav, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr.home.advisor.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.onDark2)),
        const SizedBox(height: 10),
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppPalette.teal100,
            child: Text(initials,
                style: AppTypography.label.copyWith(color: AppPalette.teal800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTypography.label
                          .copyWith(color: AppPalette.onDark)),
                  Text(tr.advisor.role,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.onDark2)),
                ]),
          ),
        ]),
        if (phone != null) ...[
          const SizedBox(height: 10),
          Text('$phone · ${tr.advisor.hours}',
              style: AppTypography.bodySm.copyWith(color: AppPalette.onDark)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: AppPalette.onDark,
                side: const BorderSide(color: AppPalette.onDark2),
                shape: const StadiumBorder()),
            // No dialer plug-in: the number is copied to call it.
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: phone));
              if (context.mounted) {
                SoeToast.show(context, message: phone);
              }
            },
            icon: const Icon(Icons.call_outlined, size: 18),
            label: Text(tr.home.call),
          ),
        ],
      ]),
    );
  }
}
