import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/verify_reset_code_viewmodel.dart';

/// Étape 2 du flow reset : saisie du code OTP reçu par email.
/// Au succès, redirige vers `/password/reset?email=X&code=Y` pour la
/// saisie du nouveau mot de passe.
class ForgotPasswordSentPage extends ConsumerStatefulWidget {
  const ForgotPasswordSentPage({super.key, this.email});
  final String? email;

  @override
  ConsumerState<ForgotPasswordSentPage> createState() =>
      _ForgotPasswordSentPageState();
}

class _ForgotPasswordSentPageState
    extends ConsumerState<ForgotPasswordSentPage> {
  Timer? _timer;
  int _seconds = 60;
  String _code = '';

  String get _email => widget.email ?? '';

  @override
  void initState() {
    super.initState();
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
    if (_email.isEmpty || _code.length != 6) return;
    ref.read(verifyResetCodeViewModelProvider.notifier).verify(
          email: _email,
          code: _code,
        );
  }

  void _resend(Translations tr) {
    if (_email.isEmpty) return;
    ref.read(verifyResetCodeViewModelProvider.notifier).resend(email: _email);
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
    final state = ref.watch(verifyResetCodeViewModelProvider);

    ref.listen<AuthState>(verifyResetCodeViewModelProvider, (prev, next) {
      next.whenOrNull(
        passwordResetCodeValidated: () {
          context.go(
            '${RouteNames.passwordReset}'
            '?email=${Uri.encodeComponent(_email)}'
            '&code=${Uri.encodeComponent(_code)}',
          );
        },
        error: (f) => SoeToast.show(
          context,
          message: _label(f, tr),
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SoeAppBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppPalette.successBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.lock_reset,
                    size: 44,
                    color: AppPalette.success,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                tr.otp.resetTitle,
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tr.otp.resetSubtitle,
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
                textAlign: TextAlign.center,
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
                label: tr.otp.verifyCta,
                size: SoeButtonSize.lg,
                fullWidth: true,
                loading: isLoading,
                onPressed: (_code.length != 6 || isLoading) ? null : _verify,
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
                            ? tr.otp.resendIn(seconds: _seconds)
                            : tr.otp.resend,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.n700),
                      ),
                    ),
                    if (_seconds <= 0)
                      TextButton(
                        onPressed: () => _resend(tr),
                        child: Text(
                          tr.otp.resend,
                          style: AppTypography.caption.copyWith(
                            color: AppPalette.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
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
