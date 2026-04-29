import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';

class ForgotPasswordSentPage extends StatelessWidget {
  const ForgotPasswordSentPage({super.key, this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SoeAppBar(title: ''),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppPalette.successBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppPalette.success,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check,
                      size: 34, color: AppPalette.white),
                ),
              ),
              const SizedBox(height: 22),
              Text(tr.forgotPasswordSent.title,
                  style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                tr.forgotPasswordSent.body(email: email ?? '—'),
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppPalette.n100,
                  borderRadius: AppRadius.rMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        size: 16, color: AppPalette.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr.forgotPasswordSent.spamHint,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.n700),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SoeButton(
                label: tr.forgotPasswordSent.back,
                size: SoeButtonSize.lg,
                fullWidth: true,
                onPressed: () => context.go(RouteNames.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
