import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../providers.dart';
import 'auth_state.dart';

/// VM de l'étape 1 du reset par code : vérifier que le code est valide
/// (sans le consommer) puis ouvrir l'écran de saisie du nouveau mdp.
class VerifyResetCodeViewModel extends StateNotifier<AuthState> {
  VerifyResetCodeViewModel(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  Future<void> verify({required String email, required String code}) async {
    state = const AuthState.loading();
    final result = await _ref.read(verifyResetCodeUsecaseProvider).call(
          email: email,
          code: code,
        );
    state = switch (result) {
      Ok() => const AuthState.passwordResetCodeValidated(),
      Err(:final failure) => AuthState.error(failure),
    };
  }

  Future<void> resend({required String email}) async {
    state = const AuthState.loading();
    final result =
        await _ref.read(requestPasswordResetUsecaseProvider).call(email: email);
    state = switch (result) {
      Ok() => AuthState.passwordResetSent(email),
      Err(:final failure) => AuthState.error(failure),
    };
  }
}

final verifyResetCodeViewModelProvider =
    StateNotifierProvider.autoDispose<VerifyResetCodeViewModel, AuthState>(
  VerifyResetCodeViewModel.new,
);
