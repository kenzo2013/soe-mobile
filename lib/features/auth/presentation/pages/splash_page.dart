import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../i18n/translations.g.dart';

/// AUT-00 — launch screen, shown while the app starts (the router guard then
/// sends to AUT-01 on the first launch, to sign-in or to the user's space).
/// Teal 800, white SOE logo, discreet loader, bulb watermark (6 %). No action.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.teal800,
      body: Stack(
        children: [
          Positioned(
            right: -48,
            bottom: -24,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0.06,
                child: SvgPicture.asset(
                  'assets/logo/bulb.svg',
                  width: 260,
                  colorFilter: const ColorFilter.mode(
                    AppPalette.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SoeBrandLogo(
                  width: 140,
                  variant: SoeBrandLogoVariant.full,
                ),
                const SizedBox(height: 28),
                Semantics(
                  label: Translations.of(context).splash.loading,
                  child: const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppPalette.gold400,
                      backgroundColor: Color(0x33FFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
