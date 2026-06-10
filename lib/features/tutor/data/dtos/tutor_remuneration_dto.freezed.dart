// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_remuneration_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorRemunerationDto _$TutorRemunerationDtoFromJson(Map<String, dynamic> json) {
  return _TutorRemunerationDto.fromJson(json);
}

/// @nodoc
mixin _$TutorRemunerationDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _period)
  String get period => throw _privateConstructorUsedError;
  @JsonKey(readValue: _amount)
  int get amount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(readValue: _sessions)
  int get sessions => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_at')
  String? get paidAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String? get method => throw _privateConstructorUsedError;

  /// Serializes this TutorRemunerationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorRemunerationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorRemunerationDtoCopyWith<TutorRemunerationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorRemunerationDtoCopyWith<$Res> {
  factory $TutorRemunerationDtoCopyWith(TutorRemunerationDto value,
          $Res Function(TutorRemunerationDto) then) =
      _$TutorRemunerationDtoCopyWithImpl<$Res, TutorRemunerationDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _period) String period,
      @JsonKey(readValue: _amount) int amount,
      String status,
      @JsonKey(readValue: _sessions) int sessions,
      @JsonKey(name: 'paid_at') String? paidAt,
      @JsonKey(name: 'payment_method') String? method});
}

/// @nodoc
class _$TutorRemunerationDtoCopyWithImpl<$Res,
        $Val extends TutorRemunerationDto>
    implements $TutorRemunerationDtoCopyWith<$Res> {
  _$TutorRemunerationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorRemunerationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? period = null,
    Object? amount = null,
    Object? status = null,
    Object? sessions = null,
    Object? paidAt = freezed,
    Object? method = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as int,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorRemunerationDtoImplCopyWith<$Res>
    implements $TutorRemunerationDtoCopyWith<$Res> {
  factory _$$TutorRemunerationDtoImplCopyWith(_$TutorRemunerationDtoImpl value,
          $Res Function(_$TutorRemunerationDtoImpl) then) =
      __$$TutorRemunerationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _period) String period,
      @JsonKey(readValue: _amount) int amount,
      String status,
      @JsonKey(readValue: _sessions) int sessions,
      @JsonKey(name: 'paid_at') String? paidAt,
      @JsonKey(name: 'payment_method') String? method});
}

/// @nodoc
class __$$TutorRemunerationDtoImplCopyWithImpl<$Res>
    extends _$TutorRemunerationDtoCopyWithImpl<$Res, _$TutorRemunerationDtoImpl>
    implements _$$TutorRemunerationDtoImplCopyWith<$Res> {
  __$$TutorRemunerationDtoImplCopyWithImpl(_$TutorRemunerationDtoImpl _value,
      $Res Function(_$TutorRemunerationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorRemunerationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? period = null,
    Object? amount = null,
    Object? status = null,
    Object? sessions = null,
    Object? paidAt = freezed,
    Object? method = freezed,
  }) {
    return _then(_$TutorRemunerationDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as int,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as String?,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorRemunerationDtoImpl extends _TutorRemunerationDto {
  const _$TutorRemunerationDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _period) this.period = '',
      @JsonKey(readValue: _amount) this.amount = 0,
      this.status = 'pending',
      @JsonKey(readValue: _sessions) this.sessions = 0,
      @JsonKey(name: 'paid_at') this.paidAt,
      @JsonKey(name: 'payment_method') this.method})
      : super._();

  factory _$TutorRemunerationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorRemunerationDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _period)
  final String period;
  @override
  @JsonKey(readValue: _amount)
  final int amount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(readValue: _sessions)
  final int sessions;
  @override
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  @override
  @JsonKey(name: 'payment_method')
  final String? method;

  @override
  String toString() {
    return 'TutorRemunerationDto(id: $id, period: $period, amount: $amount, status: $status, sessions: $sessions, paidAt: $paidAt, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorRemunerationDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sessions, sessions) ||
                other.sessions == sessions) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.method, method) || other.method == method));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, period, amount, status, sessions, paidAt, method);

  /// Create a copy of TutorRemunerationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorRemunerationDtoImplCopyWith<_$TutorRemunerationDtoImpl>
      get copyWith =>
          __$$TutorRemunerationDtoImplCopyWithImpl<_$TutorRemunerationDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorRemunerationDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorRemunerationDto extends TutorRemunerationDto {
  const factory _TutorRemunerationDto(
          {final String id,
          @JsonKey(readValue: _period) final String period,
          @JsonKey(readValue: _amount) final int amount,
          final String status,
          @JsonKey(readValue: _sessions) final int sessions,
          @JsonKey(name: 'paid_at') final String? paidAt,
          @JsonKey(name: 'payment_method') final String? method}) =
      _$TutorRemunerationDtoImpl;
  const _TutorRemunerationDto._() : super._();

  factory _TutorRemunerationDto.fromJson(Map<String, dynamic> json) =
      _$TutorRemunerationDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _period)
  String get period;
  @override
  @JsonKey(readValue: _amount)
  int get amount;
  @override
  String get status;
  @override
  @JsonKey(readValue: _sessions)
  int get sessions;
  @override
  @JsonKey(name: 'paid_at')
  String? get paidAt;
  @override
  @JsonKey(name: 'payment_method')
  String? get method;

  /// Create a copy of TutorRemunerationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorRemunerationDtoImplCopyWith<_$TutorRemunerationDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
