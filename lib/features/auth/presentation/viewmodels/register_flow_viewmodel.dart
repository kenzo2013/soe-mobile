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

  void setContact({
    required String email,
    required String phone,
    String? phoneCountryCode,
  }) {
    state = state.copyWith(
      email: email,
      phone: phone,
      phoneCountryCode: phoneCountryCode ?? state.phoneCountryCode,
    );
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
    String? address,
    required String neighborhood,
    required String city,
    required String country,
    required String countryCode,
  }) {
    state = state.copyWith(
      address: address ?? state.address,
      neighborhood: neighborhood,
      city: city,
      country: country,
      countryCode: countryCode,
    );
  }

  /// Hydrate l'adresse depuis un Place Google sélectionné dans l'autocomplete.
  void setAddressFromPlace({
    required String address,
    required String city,
    required String country,
    required String countryCode,
    String? neighborhood,
  }) {
    state = state.copyWith(
      address: address,
      city: city,
      country: country,
      countryCode: countryCode,
      neighborhood: neighborhood ?? state.neighborhood,
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
