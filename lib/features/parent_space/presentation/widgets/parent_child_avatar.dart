import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/parent_models.dart';
import '../providers.dart';

/// A child's photo, or their initial on a tint chosen from the id.
class ParentChildAvatar extends ConsumerWidget {
  const ParentChildAvatar({super.key, required this.child, this.radius = 24});

  final ParentChild child;
  final double radius;

  static const _tints = [
    (AppPalette.teal100, AppPalette.teal800),
    (AppPalette.gold100, AppPalette.gold700),
    (AppPalette.successBg, AppPalette.successText),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = _tints[child.id % _tints.length];
    final url =
        child.hasPhoto ? ref.watch(parentChildPhotoProvider(child.id)).valueOrNull : null;
    return CircleAvatar(
      radius: radius,
      backgroundColor: tint.$1,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Text(child.firstName.isEmpty ? '?' : child.firstName[0],
          style: AppTypography.title.copyWith(color: tint.$2)),
    );
  }
}
