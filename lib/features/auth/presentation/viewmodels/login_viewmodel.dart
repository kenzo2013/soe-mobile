import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../providers.dart';
import 'auth_state.dart';

class LoginViewModel extends StateNotifier<AuthState> {
  LoginViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> submit({required String email, required String password}) async {
    state = const AuthState.loading();
    final result = await _ref.read(loginUsecaseProvider).call(
          email: email,
          password: password,
        );
    state = switch (result) {
      Ok(:final value) => () {
          syncAuthState(_ref, value.accessToken, value.user.role.apiValue);
          return AuthState.authenticated(value);
        }(),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, AuthState>(
  LoginViewModel.new,
);
