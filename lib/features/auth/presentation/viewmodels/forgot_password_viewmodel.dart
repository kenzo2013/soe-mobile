import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../providers.dart';
import 'auth_state.dart';

class ForgotPasswordViewModel extends StateNotifier<AuthState> {
  ForgotPasswordViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> submit({required String email}) async {
    state = const AuthState.loading();
    final result =
        await _ref.read(requestPasswordResetUsecaseProvider).call(email: email);
    state = switch (result) {
      Ok() => AuthState.passwordResetSent(email),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final forgotPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordViewModel, AuthState>(
  ForgotPasswordViewModel.new,
);
