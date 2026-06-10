// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_contract_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorContractDto _$TutorContractDtoFromJson(Map<String, dynamic> json) {
  return _TutorContractDto.fromJson(json);
}

/// @nodoc
mixin _$TutorContractDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _reference)
  String get reference => throw _privateConstructorUsedError;
  @JsonKey(readValue: _parent)
  String get parent => throw _privateConstructorUsedError;
  @JsonKey(readValue: _student)
  String get student => throw _privateConstructorUsedError;
  @JsonKey(readValue: _signed)
  bool get signed => throw _privateConstructorUsedError;
  @JsonKey(name: 'signed_at')
  String? get signedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(readValue: _amount)
  int get monthlyAmount => throw _privateConstructorUsedError;
  @JsonKey(readValue: _amendment)
  bool get amendment => throw _privateConstructorUsedError;

  /// Serializes this TutorContractDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorContractDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorContractDtoCopyWith<TutorContractDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorContractDtoCopyWith<$Res> {
  factory $TutorContractDtoCopyWith(
          TutorContractDto value, $Res Function(TutorContractDto) then) =
      _$TutorContractDtoCopyWithImpl<$Res, TutorContractDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _reference) String reference,
      @JsonKey(readValue: _parent) String parent,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _signed) bool signed,
      @JsonKey(name: 'signed_at') String? signedAt,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(readValue: _amount) int monthlyAmount,
      @JsonKey(readValue: _amendment) bool amendment});
}

/// @nodoc
class _$TutorContractDtoCopyWithImpl<$Res, $Val extends TutorContractDto>
    implements $TutorContractDtoCopyWith<$Res> {
  _$TutorContractDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorContractDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? parent = null,
    Object? student = null,
    Object? signed = null,
    Object? signedAt = freezed,
    Object? createdAt = freezed,
    Object? monthlyAmount = null,
    Object? amendment = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as String,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      signed: null == signed
          ? _value.signed
          : signed // ignore: cast_nullable_to_non_nullable
              as bool,
      signedAt: freezed == signedAt
          ? _value.signedAt
          : signedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      monthlyAmount: null == monthlyAmount
          ? _value.monthlyAmount
          : monthlyAmount // ignore: cast_nullable_to_non_nullable
              as int,
      amendment: null == amendment
          ? _value.amendment
          : amendment // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorContractDtoImplCopyWith<$Res>
    implements $TutorContractDtoCopyWith<$Res> {
  factory _$$TutorContractDtoImplCopyWith(_$TutorContractDtoImpl value,
          $Res Function(_$TutorContractDtoImpl) then) =
      __$$TutorContractDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _reference) String reference,
      @JsonKey(readValue: _parent) String parent,
      @JsonKey(readValue: _student) String student,
      @JsonKey(readValue: _signed) bool signed,
      @JsonKey(name: 'signed_at') String? signedAt,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(readValue: _amount) int monthlyAmount,
      @JsonKey(readValue: _amendment) bool amendment});
}

/// @nodoc
class __$$TutorContractDtoImplCopyWithImpl<$Res>
    extends _$TutorContractDtoCopyWithImpl<$Res, _$TutorContractDtoImpl>
    implements _$$TutorContractDtoImplCopyWith<$Res> {
  __$$TutorContractDtoImplCopyWithImpl(_$TutorContractDtoImpl _value,
      $Res Function(_$TutorContractDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorContractDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? parent = null,
    Object? student = null,
    Object? signed = null,
    Object? signedAt = freezed,
    Object? createdAt = freezed,
    Object? monthlyAmount = null,
    Object? amendment = null,
  }) {
    return _then(_$TutorContractDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as String,
      student: null == student
          ? _value.student
          : student // ignore: cast_nullable_to_non_nullable
              as String,
      signed: null == signed
          ? _value.signed
          : signed // ignore: cast_nullable_to_non_nullable
              as bool,
      signedAt: freezed == signedAt
          ? _value.signedAt
          : signedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      monthlyAmount: null == monthlyAmount
          ? _value.monthlyAmount
          : monthlyAmount // ignore: cast_nullable_to_non_nullable
              as int,
      amendment: null == amendment
          ? _value.amendment
          : amendment // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorContractDtoImpl implements _TutorContractDto {
  const _$TutorContractDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _reference) this.reference = '',
      @JsonKey(readValue: _parent) this.parent = '',
      @JsonKey(readValue: _student) this.student = '',
      @JsonKey(readValue: _signed) this.signed = false,
      @JsonKey(name: 'signed_at') this.signedAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(readValue: _amount) this.monthlyAmount = 0,
      @JsonKey(readValue: _amendment) this.amendment = false});

  factory _$TutorContractDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorContractDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _reference)
  final String reference;
  @override
  @JsonKey(readValue: _parent)
  final String parent;
  @override
  @JsonKey(readValue: _student)
  final String student;
  @override
  @JsonKey(readValue: _signed)
  final bool signed;
  @override
  @JsonKey(name: 'signed_at')
  final String? signedAt;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(readValue: _amount)
  final int monthlyAmount;
  @override
  @JsonKey(readValue: _amendment)
  final bool amendment;

  @override
  String toString() {
    return 'TutorContractDto(id: $id, reference: $reference, parent: $parent, student: $student, signed: $signed, signedAt: $signedAt, createdAt: $createdAt, monthlyAmount: $monthlyAmount, amendment: $amendment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorContractDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.parent, parent) || other.parent == parent) &&
            (identical(other.student, student) || other.student == student) &&
            (identical(other.signed, signed) || other.signed == signed) &&
            (identical(other.signedAt, signedAt) ||
                other.signedAt == signedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.monthlyAmount, monthlyAmount) ||
                other.monthlyAmount == monthlyAmount) &&
            (identical(other.amendment, amendment) ||
                other.amendment == amendment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, reference, parent, student,
      signed, signedAt, createdAt, monthlyAmount, amendment);

  /// Create a copy of TutorContractDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorContractDtoImplCopyWith<_$TutorContractDtoImpl> get copyWith =>
      __$$TutorContractDtoImplCopyWithImpl<_$TutorContractDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorContractDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorContractDto implements TutorContractDto {
  const factory _TutorContractDto(
          {final String id,
          @JsonKey(readValue: _reference) final String reference,
          @JsonKey(readValue: _parent) final String parent,
          @JsonKey(readValue: _student) final String student,
          @JsonKey(readValue: _signed) final bool signed,
          @JsonKey(name: 'signed_at') final String? signedAt,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(readValue: _amount) final int monthlyAmount,
          @JsonKey(readValue: _amendment) final bool amendment}) =
      _$TutorContractDtoImpl;

  factory _TutorContractDto.fromJson(Map<String, dynamic> json) =
      _$TutorContractDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _reference)
  String get reference;
  @override
  @JsonKey(readValue: _parent)
  String get parent;
  @override
  @JsonKey(readValue: _student)
  String get student;
  @override
  @JsonKey(readValue: _signed)
  bool get signed;
  @override
  @JsonKey(name: 'signed_at')
  String? get signedAt;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(readValue: _amount)
  int get monthlyAmount;
  @override
  @JsonKey(readValue: _amendment)
  bool get amendment;

  /// Create a copy of TutorContractDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorContractDtoImplCopyWith<_$TutorContractDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
