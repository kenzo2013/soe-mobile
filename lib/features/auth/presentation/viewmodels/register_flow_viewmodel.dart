import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import 'register_flow_state.dart';

class RegisterFlowViewModel extends StateNotifier<RegisterFlowState> {
  RegisterFlowViewModel({UserRole role = UserRole.parent})
      : super(RegisterFlowState(role: role));

  void setRole(UserRole role) => state = state.copyWith(role: role);

  void setIdentity({
    required String civility,
    required String firstName,
    required String lastName,
    required String lang,
  }) {
    state = state.copyWith(
      civility: civility,
      firstName: firstName,
      lastName: lastName,
      lang: lang,
    );
  }

  void setContact({required String email, required String phone}) {
    state = state.copyWith(email: email, phone: phone);
  }

  void setPassword({
    required String password,
    required String passwordConfirmation,
  }) {
    state = state.copyWith(
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  void setAddress({
    required String neighborhood,
    required String city,
    required String country,
    required String countryCode,
  }) {
    state = state.copyWith(
      neighborhood: neighborhood,
      city: city,
      country: country,
      countryCode: countryCode,
    );
  }

  void setAcceptCgu({required bool value}) =>
      state = state.copyWith(acceptCgu: value);

  void goToStep(int step) {
    if (step < 1 || step > 4) return;
    state = state.copyWith(step: step);
  }

  void next() {
    if (state.step < 4) state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (state.step > 1) state = state.copyWith(step: state.step - 1);
  }

  /// Vide complètement le flow (à appeler après succès `emailSent` ou abandon).
  void reset() {
    state = const RegisterFlowState();
  }
}

/// **Pas d'`autoDispose`** : on veut que le state du flow d'inscription
/// survive aux navigations push/pop entre les 4 étapes ET au préflight
/// `context.go(...)`. Reset explicite via `RegisterFlowViewModel.reset()`
/// après `emailSent` (succès) ou si l'utilisateur quitte vers `/login`.
final registerFlowViewModelProvider =
    StateNotifierProvider<RegisterFlowViewModel, RegisterFlowState>(
  (ref) => RegisterFlowViewModel(),
);
