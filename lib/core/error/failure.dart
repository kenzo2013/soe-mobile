/// Erreurs métier typées exposées à la Presentation.
///
/// Le ViewModel pattern-matche sur ces variantes ; la View en déduit le message.
// Implements Exception so that an AsyncNotifier may `throw failure` in `build` (the only
// allowed throw: AsyncValue captures it) without breaking the `only_throw_errors` lint.
sealed class Failure implements Exception {
  const Failure();
}

/// Any error captured by an AsyncValue as a Failure: a parsing error or a StateError must
/// never crash the error screen.
Failure asFailure(Object error) =>
    error is Failure ? error : const UnknownFailure();

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

/// Spécifique : login refusé parce que l'email n'a pas encore été confirmé.
/// L'API renvoie `{"error":"You have to confirm your email address before continuing."}`.
class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class ConflictFailure extends Failure {
  final String? message;
  const ConflictFailure([this.message]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  final String? message;
  const ValidationFailure(this.errors, [this.message]);
}

class ServerFailure extends Failure {
  final int code;
  final String? message;
  const ServerFailure(this.code, [this.message]);
}

/// 429: too many attempts (login, codes). [message] is the server's (translated) wait advice.
class RateLimitedFailure extends Failure {
  final String? message;
  const RateLimitedFailure([this.message]);
}

/// A refused 6-digit code (AUT-07, AUT-10): wrong, expired, or locked after too many tries.
enum CodeProblem { invalid, expired, locked }

class CodeFailure extends Failure {
  final CodeProblem problem;
  final String? message;
  const CodeFailure(this.problem, [this.message]);
}

/// The flow token (pending e-mail check, reset) expired: the user starts the flow again.
class LinkExpiredFailure extends Failure {
  final String? message;
  const LinkExpiredFailure([this.message]);
}

class CancelledFailure extends Failure {
  const CancelledFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
