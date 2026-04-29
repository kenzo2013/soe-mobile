import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

enum SoeAvatarSize { mini, list, profile, detail }

/// Avatar circulaire SOE — 4 tailles : mini 36 / list 52 / profile 92 / detail 116.
///
/// Fallback : initiales sur fond teal.
class SoeAvatar extends StatelessWidget {
  const SoeAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = SoeAvatarSize.list,
  });

  final String? imageUrl;
  final String? name;
  final SoeAvatarSize size;

  double get _diameter => switch (size) {
        SoeAvatarSize.mini => 36,
        SoeAvatarSize.list => 52,
        SoeAvatarSize.profile => 92,
        SoeAvatarSize.detail => 116,
      };

  double get _fontSize => switch (size) {
        SoeAvatarSize.mini => 13,
        SoeAvatarSize.list => 18,
        SoeAvatarSize.profile => 28,
        SoeAvatarSize.detail => 36,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.teal,
        image: imageUrl == null
            ? null
            : DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? null
          : Text(
              _initials(name),
              style: TextStyle(
                color: AppPalette.white,
                fontWeight: FontWeight.w700,
                fontSize: _fontSize,
              ),
            ),
    );
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
