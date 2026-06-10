import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';

class ParentGreetHeader extends StatelessWidget {
  const ParentGreetHeader({
    super.key,
    required this.firstName,
    required this.dateLine,
    this.notificationBadge = true,
  });

  final String firstName;
  final String dateLine;
  final bool notificationBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      child: Stack(
        children: [
          // Décor de marque en filigrane (AuthBg du design) : 2 ampoules
          // blanches très discrètes débordant des coins.
          Positioned(
            left: -120,
            bottom: -90,
            child: Opacity(
              opacity: 0.10,
              child: SvgPicture.asset(
                'assets/logo/bulb.svg',
                width: 300,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: 90,
            child: Opacity(
              opacity: 0.07,
              child: SvgPicture.asset(
                'assets/logo/bulb.svg',
                width: 180,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.notifications),
                        child: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          if (notificationBadge)
                            Positioned(
                              top: 8,
                              right: 9,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppPalette.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppPalette.tealDark,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bloc salutation — indenté de 6px (padding '...6px...' du design)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour,',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$firstName 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateLine,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
