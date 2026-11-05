import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../widgets/launch_view.dart';

/// AUT-00 — launch screen, shown while the app starts (the router guard then sends to AUT-01
/// on the first launch, to sign-in or to the user's space): the navy launch of the colourful
/// direction, without its progress bar. No action.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppPalette.navy,
        body: LaunchView(showProgress: false),
      );
}
