// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterFlowState {
  int get step => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError; // Step 1 — identité
  String get civility => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get lang => throw _privateConstructorUsedError; // Step 2 — contact
  String get email => throw _privateConstructorUsedError;

  /// Numéro de téléphone au format E.164 (avec indicatif), ex: « +237699000000 ».
  String get phone => throw _privateConstructorUsedError;

  /// Code ISO du pays choisi pour l'indicatif téléphonique (« CM » par défaut).
  String get phoneCountryCode =>
      throw _privateConstructorUsedError; // Step 3 — mot de passe
  String get password => throw _privateConstructorUsedError;
  String get passwordConfirmation =>
      throw _privateConstructorUsedError; // Step 4 — adresse + CGU
  String get address => throw _privateConstructorUsedError;
  String get neighborhood => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get countryCode => throw _privateConstructorUsedError;
  bool get acceptCgu => throw _privateConstructorUsedError;

  /// Create a copy of RegisterFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterFlowStateCopyWith<RegisterFlowState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterFlowStateCopyWith<$Res> {
  factory $RegisterFlowStateCopyWith(
          RegisterFlowState value, $Res Function(RegisterFlowState) then) =
      _$RegisterFlowStateCopyWithImpl<$Res, RegisterFlowState>;
  @useResult
  $Res call(
      {int step,
      UserRole role,
      String civility,
      String firstName,
      String lastName,
      String lang,
      String email,
      String phone,
      String phoneCountryCode,
      String password,
      String passwordConfirmation,
      String address,
      String neighborhood,
      String city,
      String country,
      String countryCode,
      bool acceptCgu});
}

/// @nodoc
class _$RegisterFlowStateCopyWithImpl<$Res, $Val extends RegisterFlowState>
    implements $RegisterFlowStateCopyWith<$Res> {
  _$RegisterFlowStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? role = null,
    Object? civility = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? lang = null,
    Object? email = null,
    Object? phone = null,
    Object? phoneCountryCode = null,
    Object? password = null,
    Object? passwordConfirmation = null,
    Object? address = null,
    Object? neighborhood = null,
    Object? city = null,
    Object? country = null,
    Object? countryCode = null,
    Object? acceptCgu = null,
  }) {
    return _then(_value.copyWith(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      civility: null == civility
          ? _value.civility
          : civility // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      phoneCountryCode: null == phoneCountryCode
          ? _value.phoneCountryCode
          : phoneCountryCode // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      passwordConfirmation: null == passwordConfirmation
          ? _value.passwordConfirmation
          : passwordConfirmation // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      neighborhood: null == neighborhood
          ? _value.neighborhood
          : neighborhood // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      acceptCgu: null == acceptCgu
          ? _value.acceptCgu
          : acceptCgu // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterFlowStateImplCopyWith<$Res>
    implements $RegisterFlowStateCopyWith<$Res> {
  factory _$$RegisterFlowStateImplCopyWith(_$RegisterFlowStateImpl value,
          $Res Function(_$RegisterFlowStateImpl) then) =
      __$$RegisterFlowStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int step,
      UserRole role,
      String civility,
      String firstName,
      String lastName,
      String lang,
      String email,
      String phone,
      String phoneCountryCode,
      String password,
      String passwordConfirmation,
      String address,
      String neighborhood,
      String city,
      String country,
      String countryCode,
      bool acceptCgu});
}

/// @nodoc
class __$$RegisterFlowStateImplCopyWithImpl<$Res>
    extends _$RegisterFlowStateCopyWithImpl<$Res, _$RegisterFlowStateImpl>
    implements _$$RegisterFlowStateImplCopyWith<$Res> {
  __$$RegisterFlowStateImplCopyWithImpl(_$RegisterFlowStateImpl _value,
      $Res Function(_$RegisterFlowStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? role = null,
    Object? civility = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? lang = null,
    Object? email = null,
    Object? phone = null,
    Object? phoneCountryCode = null,
    Object? password = null,
    Object? passwordConfirmation = null,
    Object? address = null,
    Object? neighborhood = null,
    Object? city = null,
    Object? country = null,
    Object? countryCode = null,
    Object? acceptCgu = null,
  }) {
    return _then(_$RegisterFlowStateImpl(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      civility: null == civility
          ? _value.civility
          : civility // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      phoneCountryCode: null == phoneCountryCode
          ? _value.phoneCountryCode
          : phoneCountryCode // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      passwordConfirmation: null == passwordConfirmation
          ? _value.passwordConfirmation
          : passwordConfirmation // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      neighborhood: null == neighborhood
          ? _value.neighborhood
          : neighborhood // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      acceptCgu: null == acceptCgu
          ? _value.acceptCgu
          : acceptCgu // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RegisterFlowStateImpl extends _RegisterFlowState {
  const _$RegisterFlowStateImpl(
      {this.step = 1,
      this.role = UserRole.parent,
      this.civility = 'Mr',
      this.firstName = '',
      this.lastName = '',
      this.lang = 'fr',
      this.email = '',
      this.phone = '',
      this.phoneCountryCode = 'CM',
      this.password = '',
      this.passwordConfirmation = '',
      this.address = '',
      this.neighborhood = '',
      this.city = '',
      this.country = 'Cameroun',
      this.countryCode = 'CM',
      this.acceptCgu = false})
      : super._();

  @override
  @JsonKey()
  final int step;
  @override
  @JsonKey()
  final UserRole role;
// Step 1 — identité
  @override
  @JsonKey()
  final String civility;
  @override
  @JsonKey()
  final String firstName;
  @override
  @JsonKey()
  final String lastName;
  @override
  @JsonKey()
  final String lang;
// Step 2 — contact
  @override
  @JsonKey()
  final String email;

  /// Numéro de téléphone au format E.164 (avec indicatif), ex: « +237699000000 ».
  @override
  @JsonKey()
  final String phone;

  /// Code ISO du pays choisi pour l'indicatif téléphonique (« CM » par défaut).
  @override
  @JsonKey()
  final String phoneCountryCode;
// Step 3 — mot de passe
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String passwordConfirmation;
// Step 4 — adresse + CGU
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String neighborhood;
  @override
  @JsonKey()
  final String city;
  @override
  @JsonKey()
  final String country;
  @override
  @JsonKey()
  final String countryCode;
  @override
  @JsonKey()
  final bool acceptCgu;

  @override
  String toString() {
    return 'RegisterFlowState(step: $step, role: $role, civility: $civility, firstName: $firstName, lastName: $lastName, lang: $lang, email: $email, phone: $phone, phoneCountryCode: $phoneCountryCode, password: $password, passwordConfirmation: $passwordConfirmation, address: $address, neighborhood: $neighborhood, city: $city, country: $country, countryCode: $countryCode, acceptCgu: $acceptCgu)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterFlowStateImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.civility, civility) ||
                other.civility == civility) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.phoneCountryCode, phoneCountryCode) ||
                other.phoneCountryCode == phoneCountryCode) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.passwordConfirmation, passwordConfirmation) ||
                other.passwordConfirmation == passwordConfirmation) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.neighborhood, neighborhood) ||
                other.neighborhood == neighborhood) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.acceptCgu, acceptCgu) ||
                other.acceptCgu == acceptCgu));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      step,
      role,
      civility,
      firstName,
      lastName,
      lang,
      email,
      phone,
      phoneCountryCode,
      password,
      passwordConfirmation,
      address,
      neighborhood,
      city,
      country,
      countryCode,
      acceptCgu);

  /// Create a copy of RegisterFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterFlowStateImplCopyWith<_$RegisterFlowStateImpl> get copyWith =>
      __$$RegisterFlowStateImplCopyWithImpl<_$RegisterFlowStateImpl>(
          this, _$identity);
}

abstract class _RegisterFlowState extends RegisterFlowState {
  const factory _RegisterFlowState(
      {final int step,
      final UserRole role,
      final String civility,
      final String firstName,
      final String lastName,
      final String lang,
      final String email,
      final String phone,
      final String phoneCountryCode,
      final String password,
      final String passwordConfirmation,
      final String address,
      final String neighborhood,
      final String city,
      final String country,
      final String countryCode,
      final bool acceptCgu}) = _$RegisterFlowStateImpl;
  const _RegisterFlowState._() : super._();

  @override
  int get step;
  @override
  UserRole get role; // Step 1 — identité
  @override
  String get civility;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get lang; // Step 2 — contact
  @override
  String get email;

  /// Numéro de téléphone au format E.164 (avec indicatif), ex: « +237699000000 ».
  @override
  String get phone;

  /// Code ISO du pays choisi pour l'indicatif téléphonique (« CM » par défaut).
  @override
  String get phoneCountryCode; // Step 3 — mot de passe
  @override
  String get password;
  @override
  String get passwordConfirmation; // Step 4 — adresse + CGU
  @override
  String get address;
  @override
  String get neighborhood;
  @override
  String get city;
  @override
  String get country;
  @override
  String get countryCode;
  @override
  bool get acceptCgu;

  /// Create a copy of RegisterFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterFlowStateImplCopyWith<_$RegisterFlowStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
