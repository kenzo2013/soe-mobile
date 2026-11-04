import '../../i18n/translations.g.dart';
import 'failure.dart';

/// The one mapping from a [Failure] to a displayed message (ErrorView, toasts, dialogs).
/// 409 and 422 carry a message already translated by the server (Accept-Language).
String failureMessage(Failure failure, Translations tr) => switch (failure) {
      NetworkFailure() => tr.errors.network,
      TimeoutFailure() => tr.errors.timeout,
      UnauthorizedFailure() => tr.errors.unauthorized,
      InvalidCredentialsFailure() => tr.errors.invalidCredentials,
      EmailNotConfirmedFailure() => tr.errors.emailNotConfirmed,
      ForbiddenFailure() => tr.errors.forbidden,
      NotFoundFailure() => tr.errors.notFound,
      ConflictFailure(:final message) => message ?? tr.errors.conflict,
      ValidationFailure(:final message) => message ?? tr.errors.validation,
      ServerFailure(:final message) => message ?? tr.errors.server,
      CancelledFailure() => tr.errors.cancelled,
      UnknownFailure() => tr.errors.unknown,
    };
