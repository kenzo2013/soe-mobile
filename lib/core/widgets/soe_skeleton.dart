import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

/// Skeleton SOE — animation shimmer sur fond n100.
class SoeSkeleton extends StatefulWidget {
  const SoeSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.rXs,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SoeSkeleton> createState() => _SoeSkeletonState();
}

class _SoeSkeletonState extends State<SoeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              stops: [
                (t - 0.3).clamp(0, 1).toDouble(),
                t.clamp(0, 1),
                (t + 0.3).clamp(0, 1).toDouble(),
              ],
              colors: const [
                AppPalette.n100,
                AppPalette.n300,
                AppPalette.n100,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton listile (avatar + 2 lignes).
class SoeSkeletonListTile extends StatelessWidget {
  const SoeSkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SoeSkeleton(
            width: 52,
            height: 52,
            borderRadius: AppRadius.rPill,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoeSkeleton(height: 14),
                SizedBox(height: 8),
                SoeSkeleton(height: 12, width: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
