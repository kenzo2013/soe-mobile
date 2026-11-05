import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../i18n/translations.g.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-10, step 2 — the 6-digit code received by e-mail.
class ForgotPasswordSentPage extends ConsumerStatefulWidget {
  const ForgotPasswordSentPage({super.key});

  @override
  ConsumerState<ForgotPasswordSentPage> createState() =>
      _ForgotPasswordSentPageState();
}

class _ForgotPasswordSentPageState
    extends ConsumerState<ForgotPasswordSentPage> {
  String _code = '';

  Future<void> _verify() async {
    if (await ref
            .read(passwordResetControllerProvider.notifier)
            .verify(_code) &&
        mounted) {
      unawaited(context.push(RouteNames.passwordReset));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(passwordResetControllerProvider);
    final ticket = state.ticket;
    if (ticket == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouteNames.passwordForgot);
      });
      return const SizedBox.shrink();
    }
    final ready = _code.length == 6;
    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
          label: tr.auth.reset.codeSubmit,
          onPressed: ready ? _verify : null,
          loading: state.busy,
          fullWidth: true,
        ),
        hint: ready ? null : tr.auth.code.missing,
      ),
      children: [
        AuthHeading(
            title: tr.auth.reset.codeHeading,
            lead: tr.auth.reset.codeLead(login: state.login)),
        if (state.failure is! CodeFailure)
          AuthErrorText(
            failure: state.failure,
            onRestart: state.failure is LinkExpiredFailure
                ? () {
                    ref
                        .read(passwordResetControllerProvider.notifier)
                        .abandon();
                    context.go(RouteNames.passwordForgot);
                  }
                : null,
          ),
        SoeOtpField(
          errorText: state.failure is CodeFailure
              ? failureMessage(state.failure!, tr)
              : null,
          onChanged: (code) => setState(() => _code = code),
          onCompleted: (code) {
            setState(() => _code = code);
            _verify();
          },
        ),
        const SizedBox(height: 12),
        ResendCodeButton(
          key: ObjectKey(ticket),
          seconds: ticket.resendIn,
          onResend: () async {
            await ref.read(passwordResetControllerProvider.notifier).resend();
          },
        ),
      ],
    );
  }
}
