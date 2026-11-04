/// Sign-up steps (AUT-02 to AUT-06), as the API v2 names them.
enum SignUpStep { profile, identity, contact, password, address }

/// The answers of the sign-up wizard, kept in memory until the account is created.
/// Field names follow the API (soe/docs/api/v2/openapi.yml, SignUpAnswers).
class SignUpAnswers {
  const SignUpAnswers({
    this.role,
    this.civility,
    this.firstName = '',
    this.lastName = '',
    this.lang = 'fr',
    this.linkWithChildren,
    this.phone = '',
    this.email = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.neighborhood = '',
    this.city,
    this.landmark = '',
    this.acceptTermsOfUse = false,
    this.acceptTermsOfSale = false,
    this.acceptPrivacy = false,
  });

  final String? role;
  final String? civility;
  final String firstName;
  final String lastName;
  final String lang;
  final String? linkWithChildren;
  final String phone;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String neighborhood;
  final String? city;
  final String landmark;
  final bool acceptTermsOfUse;
  final bool acceptTermsOfSale;
  final bool acceptPrivacy;

  bool get isParent => role == 'parent';

  SignUpAnswers copyWith({
    String? role,
    String? civility,
    String? firstName,
    String? lastName,
    String? lang,
    String? linkWithChildren,
    String? phone,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? neighborhood,
    String? city,
    String? landmark,
    bool? acceptTermsOfUse,
    bool? acceptTermsOfSale,
    bool? acceptPrivacy,
  }) =>
      SignUpAnswers(
        role: role ?? this.role,
        civility: civility ?? this.civility,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        lang: lang ?? this.lang,
        linkWithChildren: linkWithChildren ?? this.linkWithChildren,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        password: password ?? this.password,
        passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
        neighborhood: neighborhood ?? this.neighborhood,
        city: city ?? this.city,
        landmark: landmark ?? this.landmark,
        acceptTermsOfUse: acceptTermsOfUse ?? this.acceptTermsOfUse,
        acceptTermsOfSale: acceptTermsOfSale ?? this.acceptTermsOfSale,
        acceptPrivacy: acceptPrivacy ?? this.acceptPrivacy,
      );

  Map<String, Object?> toJson() => {
        'role': role,
        'civility': civility,
        'first_name': firstName,
        'last_name': lastName,
        'lang': lang,
        if (isParent) 'link_with_children': linkWithChildren,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'neighborhood': neighborhood,
        'city': city,
        'landmark': landmark,
        'accept_terms_of_use': acceptTermsOfUse,
        if (isParent) 'accept_terms_of_sale': acceptTermsOfSale,
        'accept_privacy': acceptPrivacy,
      };
}
