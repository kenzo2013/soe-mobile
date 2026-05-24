import 'package:flutter/material.dart';

import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_skeleton.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  static const _circle = BorderRadius.all(Radius.circular(999));
  static const _r10 = BorderRadius.all(Radius.circular(10));
  static const _r14 = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const SoeSkeleton(height: 62, borderRadius: _r14),
        const SizedBox(height: 22),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Column(
              children: const [
                SoeSkeleton(width: 56, height: 56, borderRadius: _circle),
                SizedBox(height: 6),
                SoeSkeleton(width: 36, height: 9),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SoeSkeleton(width: 120, height: 14),
        const SizedBox(height: 12),
        SoeCard(
          child: Column(
            children: List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: const [
                    SoeSkeleton(width: 52, height: 52, borderRadius: _r10),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SoeSkeleton(height: 12),
                          SizedBox(height: 6),
                          SoeSkeleton(width: 120, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 22),
        const SoeSkeleton(width: 160, height: 14),
        const SizedBox(height: 12),
        SoeCard(
          child: Column(
            children: List.generate(2, (_) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: const [
                    SoeSkeleton(width: 36, height: 36, borderRadius: _r10),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SoeSkeleton(width: 120, height: 11),
                          SizedBox(height: 6),
                          SoeSkeleton(width: 180, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
