import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user.dart';
import '../providers.dart';
import 'auth_state.dart';

class ResetPasswordViewModel extends StateNotifier<AuthState> {
  ResetPasswordViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> submit({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthState.loading();
    final result = await _ref.read(resetPasswordUsecaseProvider).call(
          token: token,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    state = switch (result) {
      Ok(:final value) => () {
          // Sync globaux
          _ref.read(authTokenProvider.notifier).state = value.accessToken;
          _ref.read(currentRoleProvider.notifier).state = value.user.role.apiValue;
          _ref.read(secureStorageProvider).write(
                StorageKeys.authToken,
                value.accessToken,
              );
          return AuthState.authenticated(value);
        }(),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final resetPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ResetPasswordViewModel, AuthState>(
  ResetPasswordViewModel.new,
);
