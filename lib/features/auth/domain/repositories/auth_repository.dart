import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/auth_flow.dart';
import '../entities/auth_session.dart';
import '../entities/sign_up_answers.dart';
import '../entities/user.dart';

/// Authentication with the API v2 (AUT-02 to AUT-11). The flow state lives in the tokens
/// the API returns (pending e-mail check, reset); a session is stored once signed in.
abstract class AuthRepository {
  /// AUT-09 — e-mail or phone (any format) + password.
  Future<Result<SignInOutcome, Failure>> signIn({
    required String login,
    required String password,
  });

  /// AUT-02 to AUT-06 — validates one step; field errors come back as [ValidationFailure].
  Future<Result<void, Failure>> validateSignUpStep({
    required SignUpStep step,
    required SignUpAnswers answers,
  });

  /// AUT-06 — creates the account; a code is sent to the e-mail.
  Future<Result<PendingConfirmation, Failure>> signUp(SignUpAnswers answers);

  /// AUT-07 — checks the e-mail code, then signed in.
  Future<Result<AuthSession, Failure>> confirmEmail({
    required String pendingToken,
    required String code,
  });

  Future<Result<PendingConfirmation, Failure>> resendConfirmation(
      String pendingToken);

  /// AUT-10 — same answer whether an account matches the login or not.
  Future<Result<PasswordResetTicket, Failure>> requestPasswordReset(
      String login);

  /// AUT-10 — returns the verified token (valid 10 minutes).
  Future<Result<String, Failure>> verifyResetCode({
    required String resetToken,
    required String code,
  });

  Future<Result<PasswordResetTicket, Failure>> resendPasswordReset(
      String resetToken);

  /// AUT-10 — the new password, then signed in.
  Future<Result<AuthSession, Failure>> resetPassword({
    required String verifiedToken,
    required String password,
    required String passwordConfirmation,
  });

  /// AUT-11 — revokes the token and clears the stored session.
  Future<Result<void, Failure>> logout();

  /// The signed-in account (GET /me), stored for the next reads.
  Future<Result<User, Failure>> fetchCurrentUser();
}
