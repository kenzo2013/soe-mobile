import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/otp_confirm_viewmodel.dart';
import '../viewmodels/register_flow_viewmodel.dart';

/// Écran « Code de confirmation envoyé par email » — saisie OTP 6 chiffres.
///
/// L'email vient du flow d'inscription (RegisterFlowState). On capture localement
/// avant de reset le flow. Au succès, redirection vers /login.
class EmailSentPage extends ConsumerStatefulWidget {
  const EmailSentPage({super.key, this.email});

  /// Email passé par le caller (ex: login → 412 "compte non confirmé").
  /// Si null, on lit depuis le RegisterFlow state.
  final String? email;

  @override
  ConsumerState<EmailSentPage> createState() => _EmailSentPageState();
}

class _EmailSentPageState extends ConsumerState<EmailSentPage> {
  Timer? _timer;
  int _seconds = 60;
  late final String _email;
  String _code = '';

  @override
  void initState() {
    super.initState();
    final fromFlow = ref.read(registerFlowViewModelProvider).email;
    _email = widget.email?.isNotEmpty == true ? widget.email! : fromFlow;
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

  void _verify() {
    if (_code.length != 6) return;
    ref.read(otpConfirmViewModelProvider.notifier).verify(
          email: _email,
          code: _code,
        );
  }

  void _resend(Translations tr) {
    ref.read(otpConfirmViewModelProvider.notifier).resend(email: _email);
    SoeToast.show(
      context,
      message: tr.otp.resendSent,
      tone: SoeToastTone.info,
    );
    _start();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(otpConfirmViewModelProvider);

    ref.listen<AuthState>(otpConfirmViewModelProvider, (prev, next) {
      next.whenOrNull(
        registered: (_) {
          // La page suivante (EmailConfirmedPage) affiche deja un retour
          // visuel "Bienvenue sur SOE" + bouton Se connecter — pas de
          // toast redondant ici.
          context.go(RouteNames.emailConfirmed);
        },
        error: (f) => SoeToast.show(
          context,
          message: _label(f, tr),
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isLoading =
        state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(RouteNames.login),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppPalette.infoBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 44,
                    color: AppPalette.teal,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                tr.otp.confirmTitle,
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tr.otp.confirmSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppPalette.n100,
                    borderRadius: AppRadius.rSm,
                  ),
                  child: Text(
                    _email.isEmpty ? '—' : _email,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SoeOtpField(
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: 18),
              SoeButton(
                label: tr.otp.confirmCta,
                size: SoeButtonSize.lg,
                fullWidth: true,
                loading: isLoading,
                onPressed:
                    (_code.length != 6 || isLoading) ? null : _verify,
              ),
              const SizedBox(height: 14),
              _ResendBlock(
                seconds: _seconds,
                onResend: () => _resend(tr),
                trResendIn: (s) => tr.otp.resendIn(seconds: s),
                trResend: tr.otp.resend,
              ),
              const SizedBox(height: 16),
              Text(
                tr.otp.expiry,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppPalette.n700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(Failure f, Translations tr) => switch (f) {
        ValidationFailure(:final message) => message ?? tr.otp.invalidCode,
        ConflictFailure(:final message) => message ?? tr.otp.invalidCode,
        NetworkFailure() => tr.errors.network,
        _ => tr.errors.unknown,
      };
}

class _ResendBlock extends StatelessWidget {
  const _ResendBlock({
    required this.seconds,
    required this.onResend,
    required this.trResendIn,
    required this.trResend,
  });

  final int seconds;
  final VoidCallback onResend;
  final String Function(int) trResendIn;
  final String trResend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppPalette.n100,
        borderRadius: AppRadius.rMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: AppPalette.n700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              seconds > 0 ? trResendIn(seconds) : trResend,
              style: AppTypography.caption.copyWith(color: AppPalette.n700),
            ),
          ),
          if (seconds <= 0)
            TextButton(
              onPressed: onResend,
              child: Text(
                trResend,
                style: AppTypography.caption.copyWith(
                  color: AppPalette.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
