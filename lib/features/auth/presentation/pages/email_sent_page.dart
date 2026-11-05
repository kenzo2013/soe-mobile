import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controllers.dart';
import '../widgets/auth_feedback.dart';
import '../widgets/auth_scaffold.dart';

/// AUT-07 — e-mail check with the 6-digit code (after a sign-up, or a sign-in of an
/// unverified account). Then AUT-08 after a sign-up, the user's space otherwise.
class EmailSentPage extends ConsumerStatefulWidget {
  const EmailSentPage({super.key});

  @override
  ConsumerState<EmailSentPage> createState() => _EmailSentPageState();
}

class _EmailSentPageState extends ConsumerState<EmailSentPage> {
  String _code = '';

  Future<void> _verify() async {
    final controller = ref.read(confirmationControllerProvider.notifier);
    final afterSignUp = ref.read(confirmationControllerProvider).afterSignUp;
    final session = await controller.submit(_code);
    if (session == null || !mounted) return;
    context.go(afterSignUp
        ? RouteNames.emailConfirmed
        : homeForRole(session.user.role.apiValue));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(confirmationControllerProvider);
    final pending = state.pending;
    if (pending == null) {
      // Nothing pending (app restarted): back to sign-in.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouteNames.login);
      });
      return const SizedBox.shrink();
    }
    final codeFailure = state.failure is CodeFailure
        ? failureMessage(state.failure!, tr)
        : null;
    final ready = _code.length == 6;

    return AuthScaffold(
      bottom: AuthSubmit(
        button: SoeButton(
          label: tr.auth.code.submit,
          onPressed: ready ? _verify : null,
          loading: state.busy,
          fullWidth: true,
        ),
        hint: ready ? null : tr.auth.code.missing,
      ),
      children: [
        AuthHeading(
            title: tr.auth.code.heading,
            lead: tr.auth.code.lead(email: pending.maskedEmail)),
        if (state.failure is! CodeFailure)
          AuthErrorText(
            failure: state.failure,
            onRestart: state.failure is LinkExpiredFailure
                ? () {
                    final afterSignUp = state.afterSignUp;
                    ref.read(confirmationControllerProvider.notifier).abandon();
                    context.go(
                        afterSignUp ? RouteNames.roleChoice : RouteNames.login);
                  }
                : null,
          ),
        SoeOtpField(
          errorText: codeFailure,
          onChanged: (code) => setState(() => _code = code),
          onCompleted: (code) {
            setState(() => _code = code);
            _verify();
          },
        ),
        const SizedBox(height: 12),
        ResendCodeButton(
          // A new code gives a new pending check: the countdown starts again.
          key: ObjectKey(pending),
          seconds: pending.resendIn,
          onResend: () async {
            await ref.read(confirmationControllerProvider.notifier).resend();
          },
        ),
      ],
    );
  }
}
