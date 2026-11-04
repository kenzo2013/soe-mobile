import 'auth_session.dart';

/// E-mail check in progress (AUT-07): the encrypted token the API gave, the masked address
/// to show, and the seconds before a new code may be asked.
class PendingConfirmation {
  const PendingConfirmation({
    required this.pendingToken,
    required this.maskedEmail,
    required this.resendIn,
  });

  final String pendingToken;
  final String maskedEmail;
  final int resendIn;
}

/// Password reset in progress (AUT-10).
class PasswordResetTicket {
  const PasswordResetTicket({required this.resetToken, required this.resendIn});

  final String resetToken;
  final int resendIn;
}

/// Sign-in result (AUT-09): signed in, or the e-mail must be checked first.
sealed class SignInOutcome {
  const SignInOutcome();
}

final class SignedIn extends SignInOutcome {
  const SignedIn(this.session);
  final AuthSession session;
}

final class ConfirmationRequired extends SignInOutcome {
  const ConfirmationRequired(this.pending);
  final PendingConfirmation pending;
}
