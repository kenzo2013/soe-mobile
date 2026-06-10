// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_payment_method_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorPaymentMethodDto _$TutorPaymentMethodDtoFromJson(
    Map<String, dynamic> json) {
  return _TutorPaymentMethodDto.fromJson(json);
}

/// @nodoc
mixin _$TutorPaymentMethodDto {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(readValue: _isDefault)
  bool get isDefault => throw _privateConstructorUsedError;
  @JsonKey(readValue: _operator)
  String? get operator => throw _privateConstructorUsedError;
  @JsonKey(readValue: _phone)
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(readValue: _bank)
  String? get bank => throw _privateConstructorUsedError;
  @JsonKey(readValue: _holder)
  String? get holder => throw _privateConstructorUsedError;
  @JsonKey(readValue: _iban)
  String? get iban => throw _privateConstructorUsedError;
  @JsonKey(readValue: _accountNumber)
  String? get accountNumber => throw _privateConstructorUsedError;
  @JsonKey(readValue: _bankCode)
  String? get bankCode => throw _privateConstructorUsedError;
  @JsonKey(readValue: _branchCode)
  String? get branchCode => throw _privateConstructorUsedError;
  @JsonKey(readValue: _bic)
  String? get bic => throw _privateConstructorUsedError;
  @JsonKey(readValue: _key)
  String? get key => throw _privateConstructorUsedError;

  /// Serializes this TutorPaymentMethodDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorPaymentMethodDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorPaymentMethodDtoCopyWith<TutorPaymentMethodDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorPaymentMethodDtoCopyWith<$Res> {
  factory $TutorPaymentMethodDtoCopyWith(TutorPaymentMethodDto value,
          $Res Function(TutorPaymentMethodDto) then) =
      _$TutorPaymentMethodDtoCopyWithImpl<$Res, TutorPaymentMethodDto>;
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(readValue: _isDefault) bool isDefault,
      @JsonKey(readValue: _operator) String? operator,
      @JsonKey(readValue: _phone) String? phone,
      @JsonKey(readValue: _bank) String? bank,
      @JsonKey(readValue: _holder) String? holder,
      @JsonKey(readValue: _iban) String? iban,
      @JsonKey(readValue: _accountNumber) String? accountNumber,
      @JsonKey(readValue: _bankCode) String? bankCode,
      @JsonKey(readValue: _branchCode) String? branchCode,
      @JsonKey(readValue: _bic) String? bic,
      @JsonKey(readValue: _key) String? key});
}

/// @nodoc
class _$TutorPaymentMethodDtoCopyWithImpl<$Res,
        $Val extends TutorPaymentMethodDto>
    implements $TutorPaymentMethodDtoCopyWith<$Res> {
  _$TutorPaymentMethodDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorPaymentMethodDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? isDefault = null,
    Object? operator = freezed,
    Object? phone = freezed,
    Object? bank = freezed,
    Object? holder = freezed,
    Object? iban = freezed,
    Object? accountNumber = freezed,
    Object? bankCode = freezed,
    Object? branchCode = freezed,
    Object? bic = freezed,
    Object? key = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      operator: freezed == operator
          ? _value.operator
          : operator // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      bank: freezed == bank
          ? _value.bank
          : bank // ignore: cast_nullable_to_non_nullable
              as String?,
      holder: freezed == holder
          ? _value.holder
          : holder // ignore: cast_nullable_to_non_nullable
              as String?,
      iban: freezed == iban
          ? _value.iban
          : iban // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankCode: freezed == bankCode
          ? _value.bankCode
          : bankCode // ignore: cast_nullable_to_non_nullable
              as String?,
      branchCode: freezed == branchCode
          ? _value.branchCode
          : branchCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bic: freezed == bic
          ? _value.bic
          : bic // ignore: cast_nullable_to_non_nullable
              as String?,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorPaymentMethodDtoImplCopyWith<$Res>
    implements $TutorPaymentMethodDtoCopyWith<$Res> {
  factory _$$TutorPaymentMethodDtoImplCopyWith(
          _$TutorPaymentMethodDtoImpl value,
          $Res Function(_$TutorPaymentMethodDtoImpl) then) =
      __$$TutorPaymentMethodDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(readValue: _isDefault) bool isDefault,
      @JsonKey(readValue: _operator) String? operator,
      @JsonKey(readValue: _phone) String? phone,
      @JsonKey(readValue: _bank) String? bank,
      @JsonKey(readValue: _holder) String? holder,
      @JsonKey(readValue: _iban) String? iban,
      @JsonKey(readValue: _accountNumber) String? accountNumber,
      @JsonKey(readValue: _bankCode) String? bankCode,
      @JsonKey(readValue: _branchCode) String? branchCode,
      @JsonKey(readValue: _bic) String? bic,
      @JsonKey(readValue: _key) String? key});
}

/// @nodoc
class __$$TutorPaymentMethodDtoImplCopyWithImpl<$Res>
    extends _$TutorPaymentMethodDtoCopyWithImpl<$Res,
        _$TutorPaymentMethodDtoImpl>
    implements _$$TutorPaymentMethodDtoImplCopyWith<$Res> {
  __$$TutorPaymentMethodDtoImplCopyWithImpl(_$TutorPaymentMethodDtoImpl _value,
      $Res Function(_$TutorPaymentMethodDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorPaymentMethodDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? isDefault = null,
    Object? operator = freezed,
    Object? phone = freezed,
    Object? bank = freezed,
    Object? holder = freezed,
    Object? iban = freezed,
    Object? accountNumber = freezed,
    Object? bankCode = freezed,
    Object? branchCode = freezed,
    Object? bic = freezed,
    Object? key = freezed,
  }) {
    return _then(_$TutorPaymentMethodDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      operator: freezed == operator
          ? _value.operator
          : operator // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      bank: freezed == bank
          ? _value.bank
          : bank // ignore: cast_nullable_to_non_nullable
              as String?,
      holder: freezed == holder
          ? _value.holder
          : holder // ignore: cast_nullable_to_non_nullable
              as String?,
      iban: freezed == iban
          ? _value.iban
          : iban // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankCode: freezed == bankCode
          ? _value.bankCode
          : bankCode // ignore: cast_nullable_to_non_nullable
              as String?,
      branchCode: freezed == branchCode
          ? _value.branchCode
          : branchCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bic: freezed == bic
          ? _value.bic
          : bic // ignore: cast_nullable_to_non_nullable
              as String?,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorPaymentMethodDtoImpl implements _TutorPaymentMethodDto {
  const _$TutorPaymentMethodDtoImpl(
      {this.id = '',
      this.type = '',
      @JsonKey(readValue: _isDefault) this.isDefault = false,
      @JsonKey(readValue: _operator) this.operator,
      @JsonKey(readValue: _phone) this.phone,
      @JsonKey(readValue: _bank) this.bank,
      @JsonKey(readValue: _holder) this.holder,
      @JsonKey(readValue: _iban) this.iban,
      @JsonKey(readValue: _accountNumber) this.accountNumber,
      @JsonKey(readValue: _bankCode) this.bankCode,
      @JsonKey(readValue: _branchCode) this.branchCode,
      @JsonKey(readValue: _bic) this.bic,
      @JsonKey(readValue: _key) this.key});

  factory _$TutorPaymentMethodDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorPaymentMethodDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey(readValue: _isDefault)
  final bool isDefault;
  @override
  @JsonKey(readValue: _operator)
  final String? operator;
  @override
  @JsonKey(readValue: _phone)
  final String? phone;
  @override
  @JsonKey(readValue: _bank)
  final String? bank;
  @override
  @JsonKey(readValue: _holder)
  final String? holder;
  @override
  @JsonKey(readValue: _iban)
  final String? iban;
  @override
  @JsonKey(readValue: _accountNumber)
  final String? accountNumber;
  @override
  @JsonKey(readValue: _bankCode)
  final String? bankCode;
  @override
  @JsonKey(readValue: _branchCode)
  final String? branchCode;
  @override
  @JsonKey(readValue: _bic)
  final String? bic;
  @override
  @JsonKey(readValue: _key)
  final String? key;

  @override
  String toString() {
    return 'TutorPaymentMethodDto(id: $id, type: $type, isDefault: $isDefault, operator: $operator, phone: $phone, bank: $bank, holder: $holder, iban: $iban, accountNumber: $accountNumber, bankCode: $bankCode, branchCode: $branchCode, bic: $bic, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorPaymentMethodDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.bank, bank) || other.bank == bank) &&
            (identical(other.holder, holder) || other.holder == holder) &&
            (identical(other.iban, iban) || other.iban == iban) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.bankCode, bankCode) ||
                other.bankCode == bankCode) &&
            (identical(other.branchCode, branchCode) ||
                other.branchCode == branchCode) &&
            (identical(other.bic, bic) || other.bic == bic) &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, isDefault, operator,
      phone, bank, holder, iban, accountNumber, bankCode, branchCode, bic, key);

  /// Create a copy of TutorPaymentMethodDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorPaymentMethodDtoImplCopyWith<_$TutorPaymentMethodDtoImpl>
      get copyWith => __$$TutorPaymentMethodDtoImplCopyWithImpl<
          _$TutorPaymentMethodDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorPaymentMethodDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorPaymentMethodDto implements TutorPaymentMethodDto {
  const factory _TutorPaymentMethodDto(
          {final String id,
          final String type,
          @JsonKey(readValue: _isDefault) final bool isDefault,
          @JsonKey(readValue: _operator) final String? operator,
          @JsonKey(readValue: _phone) final String? phone,
          @JsonKey(readValue: _bank) final String? bank,
          @JsonKey(readValue: _holder) final String? holder,
          @JsonKey(readValue: _iban) final String? iban,
          @JsonKey(readValue: _accountNumber) final String? accountNumber,
          @JsonKey(readValue: _bankCode) final String? bankCode,
          @JsonKey(readValue: _branchCode) final String? branchCode,
          @JsonKey(readValue: _bic) final String? bic,
          @JsonKey(readValue: _key) final String? key}) =
      _$TutorPaymentMethodDtoImpl;

  factory _TutorPaymentMethodDto.fromJson(Map<String, dynamic> json) =
      _$TutorPaymentMethodDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  @JsonKey(readValue: _isDefault)
  bool get isDefault;
  @override
  @JsonKey(readValue: _operator)
  String? get operator;
  @override
  @JsonKey(readValue: _phone)
  String? get phone;
  @override
  @JsonKey(readValue: _bank)
  String? get bank;
  @override
  @JsonKey(readValue: _holder)
  String? get holder;
  @override
  @JsonKey(readValue: _iban)
  String? get iban;
  @override
  @JsonKey(readValue: _accountNumber)
  String? get accountNumber;
  @override
  @JsonKey(readValue: _bankCode)
  String? get bankCode;
  @override
  @JsonKey(readValue: _branchCode)
  String? get branchCode;
  @override
  @JsonKey(readValue: _bic)
  String? get bic;
  @override
  @JsonKey(readValue: _key)
  String? get key;

  /// Create a copy of TutorPaymentMethodDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorPaymentMethodDtoImplCopyWith<_$TutorPaymentMethodDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
