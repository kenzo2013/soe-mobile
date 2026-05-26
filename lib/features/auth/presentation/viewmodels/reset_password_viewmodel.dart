import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../providers.dart';
import 'auth_state.dart';

class ResetPasswordViewModel extends StateNotifier<AuthState> {
  ResetPasswordViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> submit({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthState.loading();
    final result = await _ref.read(resetPasswordUsecaseProvider).call(
          email: email,
          code: code,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    state = switch (result) {
      Ok() => const AuthState.passwordResetSucceeded(),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final resetPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ResetPasswordViewModel, AuthState>(
  ResetPasswordViewModel.new,
);
