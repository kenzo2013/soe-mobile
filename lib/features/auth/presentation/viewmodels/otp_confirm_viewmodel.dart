import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../providers.dart';
import 'auth_state.dart';

/// VM de l'écran "saisir le code de confirmation reçu par email".
/// Émet `registered(user)` au succès — la page peut alors rediriger vers /login.
class OtpConfirmViewModel extends StateNotifier<AuthState> {
  OtpConfirmViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> verify({required String email, required String code}) async {
    state = const AuthState.loading();
    final result = await _ref.read(verifyConfirmationCodeUsecaseProvider).call(
          email: email,
          code: code,
        );
    state = switch (result) {
      Ok(:final value) => AuthState.registered(value),
      Err(:final failure) => AuthState.error(failure),
    };
  }

  Future<void> resend({required String email}) async {
    state = const AuthState.loading();
    final result =
        await _ref.read(resendConfirmationUsecaseProvider).call(email: email);
    state = switch (result) {
      Ok() => const AuthState.initial(),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final otpConfirmViewModelProvider =
    StateNotifierProvider.autoDispose<OtpConfirmViewModel, AuthState>(
  OtpConfirmViewModel.new,
);
