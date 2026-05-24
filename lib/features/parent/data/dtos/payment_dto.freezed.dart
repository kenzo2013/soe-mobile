// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentDto _$PaymentDtoFromJson(Map<String, dynamic> json) {
  return _PaymentDto.fromJson(json);
}

/// @nodoc
mixin _$PaymentDto {
  String get id => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'reservation_ref')
  String? get reservationRef => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this PaymentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentDtoCopyWith<PaymentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentDtoCopyWith<$Res> {
  factory $PaymentDtoCopyWith(
          PaymentDto value, $Res Function(PaymentDto) then) =
      _$PaymentDtoCopyWithImpl<$Res, PaymentDto>;
  @useResult
  $Res call(
      {String id,
      String? reference,
      int amount,
      String? method,
      String? status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'reservation_ref') String? reservationRef,
      String? phone});
}

/// @nodoc
class _$PaymentDtoCopyWithImpl<$Res, $Val extends PaymentDto>
    implements $PaymentDtoCopyWith<$Res> {
  _$PaymentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? amount = null,
    Object? method = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? reservationRef = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reservationRef: freezed == reservationRef
          ? _value.reservationRef
          : reservationRef // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentDtoImplCopyWith<$Res>
    implements $PaymentDtoCopyWith<$Res> {
  factory _$$PaymentDtoImplCopyWith(
          _$PaymentDtoImpl value, $Res Function(_$PaymentDtoImpl) then) =
      __$$PaymentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? reference,
      int amount,
      String? method,
      String? status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'reservation_ref') String? reservationRef,
      String? phone});
}

/// @nodoc
class __$$PaymentDtoImplCopyWithImpl<$Res>
    extends _$PaymentDtoCopyWithImpl<$Res, _$PaymentDtoImpl>
    implements _$$PaymentDtoImplCopyWith<$Res> {
  __$$PaymentDtoImplCopyWithImpl(
      _$PaymentDtoImpl _value, $Res Function(_$PaymentDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? amount = null,
    Object? method = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? reservationRef = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$PaymentDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reservationRef: freezed == reservationRef
          ? _value.reservationRef
          : reservationRef // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentDtoImpl implements _PaymentDto {
  const _$PaymentDtoImpl(
      {required this.id,
      this.reference,
      this.amount = 0,
      this.method,
      this.status,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'reservation_ref') this.reservationRef,
      this.phone});

  factory _$PaymentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? reference;
  @override
  @JsonKey()
  final int amount;
  @override
  final String? method;
  @override
  final String? status;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'reservation_ref')
  final String? reservationRef;
  @override
  final String? phone;

  @override
  String toString() {
    return 'PaymentDto(id: $id, reference: $reference, amount: $amount, method: $method, status: $status, createdAt: $createdAt, reservationRef: $reservationRef, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.reservationRef, reservationRef) ||
                other.reservationRef == reservationRef) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, reference, amount, method,
      status, createdAt, reservationRef, phone);

  /// Create a copy of PaymentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentDtoImplCopyWith<_$PaymentDtoImpl> get copyWith =>
      __$$PaymentDtoImplCopyWithImpl<_$PaymentDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentDtoImplToJson(
      this,
    );
  }
}

abstract class _PaymentDto implements PaymentDto {
  const factory _PaymentDto(
      {required final String id,
      final String? reference,
      final int amount,
      final String? method,
      final String? status,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'reservation_ref') final String? reservationRef,
      final String? phone}) = _$PaymentDtoImpl;

  factory _PaymentDto.fromJson(Map<String, dynamic> json) =
      _$PaymentDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get reference;
  @override
  int get amount;
  @override
  String? get method;
  @override
  String? get status;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'reservation_ref')
  String? get reservationRef;
  @override
  String? get phone;

  /// Create a copy of PaymentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentDtoImplCopyWith<_$PaymentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentReceiptDto _$PaymentReceiptDtoFromJson(Map<String, dynamic> json) {
  return _PaymentReceiptDto.fromJson(json);
}

/// @nodoc
mixin _$PaymentReceiptDto {
  PaymentDto get payment => throw _privateConstructorUsedError;
  @JsonKey(name: 'pdf_url')
  String? get pdfUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'tutor_name')
  String? get tutorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_name')
  String? get childName => throw _privateConstructorUsedError;

  /// Serializes this PaymentReceiptDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentReceiptDtoCopyWith<PaymentReceiptDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentReceiptDtoCopyWith<$Res> {
  factory $PaymentReceiptDtoCopyWith(
          PaymentReceiptDto value, $Res Function(PaymentReceiptDto) then) =
      _$PaymentReceiptDtoCopyWithImpl<$Res, PaymentReceiptDto>;
  @useResult
  $Res call(
      {PaymentDto payment,
      @JsonKey(name: 'pdf_url') String? pdfUrl,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName});

  $PaymentDtoCopyWith<$Res> get payment;
}

/// @nodoc
class _$PaymentReceiptDtoCopyWithImpl<$Res, $Val extends PaymentReceiptDto>
    implements $PaymentReceiptDtoCopyWith<$Res> {
  _$PaymentReceiptDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payment = null,
    Object? pdfUrl = freezed,
    Object? tutorName = freezed,
    Object? childName = freezed,
  }) {
    return _then(_value.copyWith(
      payment: null == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as PaymentDto,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tutorName: freezed == tutorName
          ? _value.tutorName
          : tutorName // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentDtoCopyWith<$Res> get payment {
    return $PaymentDtoCopyWith<$Res>(_value.payment, (value) {
      return _then(_value.copyWith(payment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaymentReceiptDtoImplCopyWith<$Res>
    implements $PaymentReceiptDtoCopyWith<$Res> {
  factory _$$PaymentReceiptDtoImplCopyWith(_$PaymentReceiptDtoImpl value,
          $Res Function(_$PaymentReceiptDtoImpl) then) =
      __$$PaymentReceiptDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PaymentDto payment,
      @JsonKey(name: 'pdf_url') String? pdfUrl,
      @JsonKey(name: 'tutor_name') String? tutorName,
      @JsonKey(name: 'child_name') String? childName});

  @override
  $PaymentDtoCopyWith<$Res> get payment;
}

/// @nodoc
class __$$PaymentReceiptDtoImplCopyWithImpl<$Res>
    extends _$PaymentReceiptDtoCopyWithImpl<$Res, _$PaymentReceiptDtoImpl>
    implements _$$PaymentReceiptDtoImplCopyWith<$Res> {
  __$$PaymentReceiptDtoImplCopyWithImpl(_$PaymentReceiptDtoImpl _value,
      $Res Function(_$PaymentReceiptDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payment = null,
    Object? pdfUrl = freezed,
    Object? tutorName = freezed,
    Object? childName = freezed,
  }) {
    return _then(_$PaymentReceiptDtoImpl(
      payment: null == payment
          ? _value.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as PaymentDto,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tutorName: freezed == tutorName
          ? _value.tutorName
          : tutorName // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentReceiptDtoImpl implements _PaymentReceiptDto {
  const _$PaymentReceiptDtoImpl(
      {required this.payment,
      @JsonKey(name: 'pdf_url') this.pdfUrl,
      @JsonKey(name: 'tutor_name') this.tutorName,
      @JsonKey(name: 'child_name') this.childName});

  factory _$PaymentReceiptDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentReceiptDtoImplFromJson(json);

  @override
  final PaymentDto payment;
  @override
  @JsonKey(name: 'pdf_url')
  final String? pdfUrl;
  @override
  @JsonKey(name: 'tutor_name')
  final String? tutorName;
  @override
  @JsonKey(name: 'child_name')
  final String? childName;

  @override
  String toString() {
    return 'PaymentReceiptDto(payment: $payment, pdfUrl: $pdfUrl, tutorName: $tutorName, childName: $childName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentReceiptDtoImpl &&
            (identical(other.payment, payment) || other.payment == payment) &&
            (identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl) &&
            (identical(other.tutorName, tutorName) ||
                other.tutorName == tutorName) &&
            (identical(other.childName, childName) ||
                other.childName == childName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, payment, pdfUrl, tutorName, childName);

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentReceiptDtoImplCopyWith<_$PaymentReceiptDtoImpl> get copyWith =>
      __$$PaymentReceiptDtoImplCopyWithImpl<_$PaymentReceiptDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentReceiptDtoImplToJson(
      this,
    );
  }
}

abstract class _PaymentReceiptDto implements PaymentReceiptDto {
  const factory _PaymentReceiptDto(
          {required final PaymentDto payment,
          @JsonKey(name: 'pdf_url') final String? pdfUrl,
          @JsonKey(name: 'tutor_name') final String? tutorName,
          @JsonKey(name: 'child_name') final String? childName}) =
      _$PaymentReceiptDtoImpl;

  factory _PaymentReceiptDto.fromJson(Map<String, dynamic> json) =
      _$PaymentReceiptDtoImpl.fromJson;

  @override
  PaymentDto get payment;
  @override
  @JsonKey(name: 'pdf_url')
  String? get pdfUrl;
  @override
  @JsonKey(name: 'tutor_name')
  String? get tutorName;
  @override
  @JsonKey(name: 'child_name')
  String? get childName;

  /// Create a copy of PaymentReceiptDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentReceiptDtoImplCopyWith<_$PaymentReceiptDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
