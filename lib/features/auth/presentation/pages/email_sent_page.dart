import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../viewmodels/register_flow_viewmodel.dart';

class EmailSentPage extends ConsumerStatefulWidget {
  const EmailSentPage({super.key});

  @override
  ConsumerState<EmailSentPage> createState() => _EmailSentPageState();
}

class _EmailSentPageState extends ConsumerState<EmailSentPage> {
  Timer? _timer;
  int _seconds = 60;
  late final String _email;

  @override
  void initState() {
    super.initState();
    // On capture l'email localement AVANT de vider le flow, sinon on
    // perdrait la valeur en route.
    _email = ref.read(registerFlowViewModelProvider).email;
    Future.microtask(
      () => ref.read(registerFlowViewModelProvider.notifier).reset(),
    );
    _start();
  }

  void _start() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final email = _email;

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(RouteNames.login),
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: AppPalette.infoBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.mail_outline,
                        size: 48, color: AppPalette.teal),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppPalette.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppPalette.white, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check,
                          size: 14, color: AppPalette.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(tr.emailSent.title,
                  style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                tr.emailSent.subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppPalette.n100,
                  borderRadius: AppRadius.rSm,
                ),
                child: Text(
                  email.isEmpty ? '—' : email,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr.emailSent.expiry,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 28),
              SoeButton(
                label: tr.emailSent.openMail,
                icon: Icons.mail_outline,
                size: SoeButtonSize.lg,
                fullWidth: true,
                onPressed: () {
                  // Pas d'API pour ouvrir l'app mail sans `url_launcher`.
                  // À brancher quand le package est ajouté.
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppPalette.n100,
                  borderRadius: AppRadius.rMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: AppPalette.n700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _seconds > 0
                            ? tr.emailSent.resendIn(seconds: _seconds)
                            : tr.emailSent.resend,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.n700),
                      ),
                    ),
                    if (_seconds <= 0)
                      TextButton(
                        onPressed: _start,
                        child: Text(
                          tr.emailSent.resend,
                          style: AppTypography.caption.copyWith(
                            color: AppPalette.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
