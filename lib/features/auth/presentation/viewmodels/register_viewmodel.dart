import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers.dart';
import 'auth_state.dart';

class RegisterViewModel extends StateNotifier<AuthState> {
  RegisterViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> submit(RegisterParams params) async {
    state = const AuthState.loading();
    final result =
        await _ref.read(registerUsecaseProvider).call(params: params);
    state = switch (result) {
      Ok(:final value) => () {
          syncAuthState(_ref, value.accessToken, value.user.role.apiValue);
          return AuthState.authenticated(value);
        }(),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, AuthState>(
  RegisterViewModel.new,
);
