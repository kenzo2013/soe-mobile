import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/auth_flow.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/core_providers.dart';
import '../providers.dart';

/// Busy flag, the last failure, and per-field errors of a screen.
class FlowState {
  const FlowState(
      {this.busy = false, this.failure, this.fieldErrors = const {}});

  final bool busy;
  final Failure? failure;
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;
}

FlowState _failed(Failure failure) => FlowState(
      failure: failure,
      fieldErrors: failure is ValidationFailure ? failure.errors : const {},
    );

/// AUT-09.
class SignInController extends Notifier<FlowState> {
  @override
  FlowState build() => const FlowState();

  Future<SignInOutcome?> submit(String login, String password) async {
    state = const FlowState(busy: true);
    final result = await ref
        .read(authRepositoryProvider)
        .signIn(login: login, password: password);
    return _finish(ref, result, (outcome) {
      if (outcome is SignedIn) syncSession(ref, outcome.session);
      if (outcome is ConfirmationRequired)
        ref
            .read(confirmationControllerProvider.notifier)
            .start(outcome.pending);
    });
  }

  T? _finish<T>(Ref ref, Result<T, Failure> result, void Function(T) onOk) {
    switch (result) {
      case Ok(:final value):
        state = const FlowState();
        onOk(value);
        return value;
      case Err(:final failure):
        state = _failed(failure);
        return null;
    }
  }
}

final signInControllerProvider =
    NotifierProvider<SignInController, FlowState>(SignInController.new);

/// AUT-02 to AUT-06: the answers in memory, validated step by step by the API.
class SignUpState extends FlowState {
  const SignUpState(
      {this.answers = const SignUpAnswers(),
      super.busy,
      super.failure,
      super.fieldErrors});

  final SignUpAnswers answers;
}

class SignUpController extends Notifier<SignUpState> {
  @override
  SignUpState build() {
    // The answers hold a password: they never outlive a sign-in or a sign-out.
    ref.listen(authTokenProvider, (previous, next) {
      if (previous != next) reset();
    });
    return const SignUpState();
  }

  void update(SignUpAnswers Function(SignUpAnswers) change) =>
      state = SignUpState(
          answers: change(state.answers), fieldErrors: state.fieldErrors);

  /// True when the step is valid (the screen moves on).
  Future<bool> validate(SignUpStep step) async {
    state = SignUpState(answers: state.answers, busy: true);
    final result = await ref
        .read(authRepositoryProvider)
        .validateSignUpStep(step: step, answers: state.answers);
    switch (result) {
      case Ok():
        state = SignUpState(answers: state.answers);
        return true;
      case Err(:final failure):
        _fail(failure);
        return false;
    }
  }

  /// Creates the account; the e-mail code screen follows.
  Future<PendingConfirmation?> create() async {
    state = SignUpState(answers: state.answers, busy: true);
    switch (await ref.read(authRepositoryProvider).signUp(state.answers)) {
      case Ok(:final value):
        // The account exists: the answers (password included) are no longer needed.
        reset();
        ref
            .read(confirmationControllerProvider.notifier)
            .start(value, afterSignUp: true);
        return value;
      case Err(:final failure):
        _fail(failure);
        return null;
    }
  }

  void _fail(Failure failure) {
    final failed = _failed(failure);
    state = SignUpState(
        answers: state.answers,
        failure: failed.failure,
        fieldErrors: failed.fieldErrors);
  }

  void reset() => state = const SignUpState();
}

final signUpControllerProvider =
    NotifierProvider<SignUpController, SignUpState>(SignUpController.new);

/// AUT-07: the pending e-mail check.
class ConfirmationState extends FlowState {
  const ConfirmationState(
      {this.pending, this.afterSignUp = false, super.busy, super.failure});

  final PendingConfirmation? pending;
  final bool afterSignUp;
}

class ConfirmationController extends Notifier<ConfirmationState> {
  @override
  ConfirmationState build() => const ConfirmationState();

  /// The check expired: forget it (the screen goes back to the start).
  void abandon() => state = const ConfirmationState();

  void start(PendingConfirmation pending, {bool afterSignUp = false}) =>
      state = ConfirmationState(pending: pending, afterSignUp: afterSignUp);

  Future<AuthSession?> submit(String code) async {
    final pending = state.pending;
    if (pending == null) return null;
    state = ConfirmationState(
        pending: pending, afterSignUp: state.afterSignUp, busy: true);
    final result = await ref
        .read(authRepositoryProvider)
        .confirmEmail(pendingToken: pending.pendingToken, code: code);
    switch (result) {
      case Ok(:final value):
        syncSession(ref, value);
        state =
            ConfirmationState(pending: pending, afterSignUp: state.afterSignUp);
        return value;
      case Err(:final failure):
        state = ConfirmationState(
            pending: pending, afterSignUp: state.afterSignUp, failure: failure);
        return null;
    }
  }

  Future<bool> resend() async {
    final pending = state.pending;
    if (pending == null) return false;
    final result = await ref
        .read(authRepositoryProvider)
        .resendConfirmation(pending.pendingToken);
    switch (result) {
      case Ok(:final value):
        state =
            ConfirmationState(pending: value, afterSignUp: state.afterSignUp);
        return true;
      case Err(:final failure):
        state = ConfirmationState(
            pending: pending, afterSignUp: state.afterSignUp, failure: failure);
        return false;
    }
  }
}

final confirmationControllerProvider =
    NotifierProvider<ConfirmationController, ConfirmationState>(
        ConfirmationController.new);

/// AUT-10: login → code → new password.
class PasswordResetState extends FlowState {
  const PasswordResetState(
      {this.login = '',
      this.ticket,
      this.verifiedToken,
      super.busy,
      super.failure,
      super.fieldErrors});

  final String login;
  final PasswordResetTicket? ticket;
  final String? verifiedToken;

  PasswordResetState copy({
    bool busy = false,
    Failure? failure,
    Map<String, List<String>> fieldErrors = const {},
    PasswordResetTicket? ticket,
    String? verifiedToken,
    String? login,
  }) =>
      PasswordResetState(
        login: login ?? this.login,
        ticket: ticket ?? this.ticket,
        verifiedToken: verifiedToken ?? this.verifiedToken,
        busy: busy,
        failure: failure,
        fieldErrors: fieldErrors,
      );
}

class PasswordResetController extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  /// The reset expired: forget it (the screen goes back to step 1).
  void abandon() => state = const PasswordResetState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> request(String login) async {
    state = PasswordResetState(login: login, busy: true);
    return switch (await _repo.requestPasswordReset(login)) {
      Ok(:final value) => _ok(state.copy(ticket: value)),
      Err(:final failure) => _err(failure),
    };
  }

  Future<bool> verify(String code) async {
    final ticket = state.ticket;
    if (ticket == null) return false;
    state = state.copy(busy: true);
    return switch (await _repo.verifyResetCode(
        resetToken: ticket.resetToken, code: code)) {
      Ok(:final value) => _ok(state.copy(verifiedToken: value)),
      Err(:final failure) => _err(failure),
    };
  }

  Future<bool> resend() async {
    final ticket = state.ticket;
    if (ticket == null) return false;
    return switch (await _repo.resendPasswordReset(ticket.resetToken)) {
      Ok(:final value) => _ok(state.copy(ticket: value)),
      Err(:final failure) => _err(failure),
    };
  }

  Future<AuthSession?> reset(String password, String confirmation) async {
    final token = state.verifiedToken;
    if (token == null) return null;
    state = state.copy(busy: true);
    switch (await _repo.resetPassword(
        verifiedToken: token,
        password: password,
        passwordConfirmation: confirmation)) {
      case Ok(:final value):
        // The state is kept: clearing it would send the screen back to step 1 while it
        // is leaving for the user's space.
        syncSession(ref, value);
        state = state.copy();
        return value;
      case Err(:final failure):
        _err(failure);
        return null;
    }
  }

  bool _ok(PasswordResetState next) {
    state = next;
    return true;
  }

  bool _err(Failure failure) {
    final failed = _failed(failure);
    state =
        state.copy(failure: failed.failure, fieldErrors: failed.fieldErrors);
    return false;
  }
}

final passwordResetControllerProvider =
    NotifierProvider<PasswordResetController, PasswordResetState>(
        PasswordResetController.new);
