import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'register_flow_state.freezed.dart';

/// État du flow d'inscription multi-étapes.
@freezed
class RegisterFlowState with _$RegisterFlowState {
  const factory RegisterFlowState({
    @Default(1) int step,
    @Default(UserRole.parent) UserRole role,

    // Step 1 — identité
    @Default('Mr') String civility,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('fr') String lang,

    // Step 2 — contact
    @Default('') String email,

    /// Numéro de téléphone au format E.164 (avec indicatif), ex: « +237699000000 ».
    @Default('') String phone,

    /// Code ISO du pays choisi pour l'indicatif téléphonique (« CM » par défaut).
    @Default('CM') String phoneCountryCode,

    // Step 3 — mot de passe
    @Default('') String password,
    @Default('') String passwordConfirmation,

    // Step 4 — adresse + CGU
    @Default('') String address,
    @Default('') String neighborhood,
    @Default('') String city,
    @Default('Cameroun') String country,
    @Default('CM') String countryCode,
    @Default(false) bool acceptCgu,
  }) = _RegisterFlowState;

  const RegisterFlowState._();

  bool get canSubmitStep1 =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
  bool get canSubmitStep2 =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  bool get canSubmitStep3 =>
      password.length >= 6 && password == passwordConfirmation;
  bool get canSubmitStep4 => acceptCgu && city.trim().isNotEmpty;

  /// Force du mot de passe : 0..4.
  int get passwordStrength {
    var s = 0;
    if (password.length >= 6) s++;
    if (RegExp('[A-Z]').hasMatch(password) &&
        RegExp('[a-z]').hasMatch(password)) {
      s++;
    }
    if (RegExp(r'[\d!@#$%^&*(),.?":{}|<>]').hasMatch(password)) s++;
    if (password.length >= 12) s++;
    return s;
  }
}
