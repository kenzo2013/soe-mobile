// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorTrainingDto _$TutorTrainingDtoFromJson(Map<String, dynamic> json) {
  return _TutorTrainingDto.fromJson(json);
}

/// @nodoc
mixin _$TutorTrainingDto {
  String get degree => throw _privateConstructorUsedError;
  String get field => throw _privateConstructorUsedError;
  @JsonKey(name: 'year')
  String? get year => throw _privateConstructorUsedError;
  String? get institution => throw _privateConstructorUsedError;

  /// Serializes this TutorTrainingDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorTrainingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorTrainingDtoCopyWith<TutorTrainingDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorTrainingDtoCopyWith<$Res> {
  factory $TutorTrainingDtoCopyWith(
          TutorTrainingDto value, $Res Function(TutorTrainingDto) then) =
      _$TutorTrainingDtoCopyWithImpl<$Res, TutorTrainingDto>;
  @useResult
  $Res call(
      {String degree,
      String field,
      @JsonKey(name: 'year') String? year,
      String? institution});
}

/// @nodoc
class _$TutorTrainingDtoCopyWithImpl<$Res, $Val extends TutorTrainingDto>
    implements $TutorTrainingDtoCopyWith<$Res> {
  _$TutorTrainingDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorTrainingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? degree = null,
    Object? field = null,
    Object? year = freezed,
    Object? institution = freezed,
  }) {
    return _then(_value.copyWith(
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as String,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String?,
      institution: freezed == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorTrainingDtoImplCopyWith<$Res>
    implements $TutorTrainingDtoCopyWith<$Res> {
  factory _$$TutorTrainingDtoImplCopyWith(_$TutorTrainingDtoImpl value,
          $Res Function(_$TutorTrainingDtoImpl) then) =
      __$$TutorTrainingDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String degree,
      String field,
      @JsonKey(name: 'year') String? year,
      String? institution});
}

/// @nodoc
class __$$TutorTrainingDtoImplCopyWithImpl<$Res>
    extends _$TutorTrainingDtoCopyWithImpl<$Res, _$TutorTrainingDtoImpl>
    implements _$$TutorTrainingDtoImplCopyWith<$Res> {
  __$$TutorTrainingDtoImplCopyWithImpl(_$TutorTrainingDtoImpl _value,
      $Res Function(_$TutorTrainingDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorTrainingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? degree = null,
    Object? field = null,
    Object? year = freezed,
    Object? institution = freezed,
  }) {
    return _then(_$TutorTrainingDtoImpl(
      degree: null == degree
          ? _value.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as String,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String?,
      institution: freezed == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorTrainingDtoImpl implements _TutorTrainingDto {
  const _$TutorTrainingDtoImpl(
      {required this.degree,
      required this.field,
      @JsonKey(name: 'year') this.year,
      this.institution});

  factory _$TutorTrainingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorTrainingDtoImplFromJson(json);

  @override
  final String degree;
  @override
  final String field;
  @override
  @JsonKey(name: 'year')
  final String? year;
  @override
  final String? institution;

  @override
  String toString() {
    return 'TutorTrainingDto(degree: $degree, field: $field, year: $year, institution: $institution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorTrainingDtoImpl &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.institution, institution) ||
                other.institution == institution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, degree, field, year, institution);

  /// Create a copy of TutorTrainingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorTrainingDtoImplCopyWith<_$TutorTrainingDtoImpl> get copyWith =>
      __$$TutorTrainingDtoImplCopyWithImpl<_$TutorTrainingDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorTrainingDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorTrainingDto implements TutorTrainingDto {
  const factory _TutorTrainingDto(
      {required final String degree,
      required final String field,
      @JsonKey(name: 'year') final String? year,
      final String? institution}) = _$TutorTrainingDtoImpl;

  factory _TutorTrainingDto.fromJson(Map<String, dynamic> json) =
      _$TutorTrainingDtoImpl.fromJson;

  @override
  String get degree;
  @override
  String get field;
  @override
  @JsonKey(name: 'year')
  String? get year;
  @override
  String? get institution;

  /// Create a copy of TutorTrainingDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorTrainingDtoImplCopyWith<_$TutorTrainingDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorWorkDto _$TutorWorkDtoFromJson(Map<String, dynamic> json) {
  return _TutorWorkDto.fromJson(json);
}

/// @nodoc
mixin _$TutorWorkDto {
  String get position => throw _privateConstructorUsedError;
  String get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'period')
  String? get period => throw _privateConstructorUsedError;

  /// Serializes this TutorWorkDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorWorkDtoCopyWith<TutorWorkDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorWorkDtoCopyWith<$Res> {
  factory $TutorWorkDtoCopyWith(
          TutorWorkDto value, $Res Function(TutorWorkDto) then) =
      _$TutorWorkDtoCopyWithImpl<$Res, TutorWorkDto>;
  @useResult
  $Res call(
      {String position,
      String organization,
      @JsonKey(name: 'period') String? period});
}

/// @nodoc
class _$TutorWorkDtoCopyWithImpl<$Res, $Val extends TutorWorkDto>
    implements $TutorWorkDtoCopyWith<$Res> {
  _$TutorWorkDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? organization = null,
    Object? period = freezed,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      organization: null == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorWorkDtoImplCopyWith<$Res>
    implements $TutorWorkDtoCopyWith<$Res> {
  factory _$$TutorWorkDtoImplCopyWith(
          _$TutorWorkDtoImpl value, $Res Function(_$TutorWorkDtoImpl) then) =
      __$$TutorWorkDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String position,
      String organization,
      @JsonKey(name: 'period') String? period});
}

/// @nodoc
class __$$TutorWorkDtoImplCopyWithImpl<$Res>
    extends _$TutorWorkDtoCopyWithImpl<$Res, _$TutorWorkDtoImpl>
    implements _$$TutorWorkDtoImplCopyWith<$Res> {
  __$$TutorWorkDtoImplCopyWithImpl(
      _$TutorWorkDtoImpl _value, $Res Function(_$TutorWorkDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? organization = null,
    Object? period = freezed,
  }) {
    return _then(_$TutorWorkDtoImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      organization: null == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String,
      period: freezed == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorWorkDtoImpl implements _TutorWorkDto {
  const _$TutorWorkDtoImpl(
      {required this.position,
      required this.organization,
      @JsonKey(name: 'period') this.period});

  factory _$TutorWorkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorWorkDtoImplFromJson(json);

  @override
  final String position;
  @override
  final String organization;
  @override
  @JsonKey(name: 'period')
  final String? period;

  @override
  String toString() {
    return 'TutorWorkDto(position: $position, organization: $organization, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorWorkDtoImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, organization, period);

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorWorkDtoImplCopyWith<_$TutorWorkDtoImpl> get copyWith =>
      __$$TutorWorkDtoImplCopyWithImpl<_$TutorWorkDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorWorkDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorWorkDto implements TutorWorkDto {
  const factory _TutorWorkDto(
      {required final String position,
      required final String organization,
      @JsonKey(name: 'period') final String? period}) = _$TutorWorkDtoImpl;

  factory _TutorWorkDto.fromJson(Map<String, dynamic> json) =
      _$TutorWorkDtoImpl.fromJson;

  @override
  String get position;
  @override
  String get organization;
  @override
  @JsonKey(name: 'period')
  String? get period;

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorWorkDtoImplCopyWith<_$TutorWorkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorAvailabilityDto _$TutorAvailabilityDtoFromJson(Map<String, dynamic> json) {
  return _TutorAvailabilityDto.fromJson(json);
}

/// @nodoc
mixin _$TutorAvailabilityDto {
  int get weekday => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_range')
  String? get timeRange => throw _privateConstructorUsedError;

  /// Serializes this TutorAvailabilityDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorAvailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorAvailabilityDtoCopyWith<TutorAvailabilityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorAvailabilityDtoCopyWith<$Res> {
  factory $TutorAvailabilityDtoCopyWith(TutorAvailabilityDto value,
          $Res Function(TutorAvailabilityDto) then) =
      _$TutorAvailabilityDtoCopyWithImpl<$Res, TutorAvailabilityDto>;
  @useResult
  $Res call({int weekday, @JsonKey(name: 'time_range') String? timeRange});
}

/// @nodoc
class _$TutorAvailabilityDtoCopyWithImpl<$Res,
        $Val extends TutorAvailabilityDto>
    implements $TutorAvailabilityDtoCopyWith<$Res> {
  _$TutorAvailabilityDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorAvailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekday = null,
    Object? timeRange = freezed,
  }) {
    return _then(_value.copyWith(
      weekday: null == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorAvailabilityDtoImplCopyWith<$Res>
    implements $TutorAvailabilityDtoCopyWith<$Res> {
  factory _$$TutorAvailabilityDtoImplCopyWith(_$TutorAvailabilityDtoImpl value,
          $Res Function(_$TutorAvailabilityDtoImpl) then) =
      __$$TutorAvailabilityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int weekday, @JsonKey(name: 'time_range') String? timeRange});
}

/// @nodoc
class __$$TutorAvailabilityDtoImplCopyWithImpl<$Res>
    extends _$TutorAvailabilityDtoCopyWithImpl<$Res, _$TutorAvailabilityDtoImpl>
    implements _$$TutorAvailabilityDtoImplCopyWith<$Res> {
  __$$TutorAvailabilityDtoImplCopyWithImpl(_$TutorAvailabilityDtoImpl _value,
      $Res Function(_$TutorAvailabilityDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorAvailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekday = null,
    Object? timeRange = freezed,
  }) {
    return _then(_$TutorAvailabilityDtoImpl(
      weekday: null == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int,
      timeRange: freezed == timeRange
          ? _value.timeRange
          : timeRange // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorAvailabilityDtoImpl implements _TutorAvailabilityDto {
  const _$TutorAvailabilityDtoImpl(
      {this.weekday = 1, @JsonKey(name: 'time_range') this.timeRange});

  factory _$TutorAvailabilityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorAvailabilityDtoImplFromJson(json);

  @override
  @JsonKey()
  final int weekday;
  @override
  @JsonKey(name: 'time_range')
  final String? timeRange;

  @override
  String toString() {
    return 'TutorAvailabilityDto(weekday: $weekday, timeRange: $timeRange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorAvailabilityDtoImpl &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.timeRange, timeRange) ||
                other.timeRange == timeRange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weekday, timeRange);

  /// Create a copy of TutorAvailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorAvailabilityDtoImplCopyWith<_$TutorAvailabilityDtoImpl>
      get copyWith =>
          __$$TutorAvailabilityDtoImplCopyWithImpl<_$TutorAvailabilityDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorAvailabilityDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorAvailabilityDto implements TutorAvailabilityDto {
  const factory _TutorAvailabilityDto(
          {final int weekday,
          @JsonKey(name: 'time_range') final String? timeRange}) =
      _$TutorAvailabilityDtoImpl;

  factory _TutorAvailabilityDto.fromJson(Map<String, dynamic> json) =
      _$TutorAvailabilityDtoImpl.fromJson;

  @override
  int get weekday;
  @override
  @JsonKey(name: 'time_range')
  String? get timeRange;

  /// Create a copy of TutorAvailabilityDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorAvailabilityDtoImplCopyWith<_$TutorAvailabilityDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TutorReviewDto _$TutorReviewDtoFromJson(Map<String, dynamic> json) {
  return _TutorReviewDto.fromJson(json);
}

/// @nodoc
mixin _$TutorReviewDto {
  @JsonKey(name: 'author_name')
  String? get authorName => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TutorReviewDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorReviewDtoCopyWith<TutorReviewDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorReviewDtoCopyWith<$Res> {
  factory $TutorReviewDtoCopyWith(
          TutorReviewDto value, $Res Function(TutorReviewDto) then) =
      _$TutorReviewDtoCopyWithImpl<$Res, TutorReviewDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'author_name') String? authorName,
      double rating,
      String? comment,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$TutorReviewDtoCopyWithImpl<$Res, $Val extends TutorReviewDto>
    implements $TutorReviewDtoCopyWith<$Res> {
  _$TutorReviewDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorName = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorReviewDtoImplCopyWith<$Res>
    implements $TutorReviewDtoCopyWith<$Res> {
  factory _$$TutorReviewDtoImplCopyWith(_$TutorReviewDtoImpl value,
          $Res Function(_$TutorReviewDtoImpl) then) =
      __$$TutorReviewDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'author_name') String? authorName,
      double rating,
      String? comment,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$TutorReviewDtoImplCopyWithImpl<$Res>
    extends _$TutorReviewDtoCopyWithImpl<$Res, _$TutorReviewDtoImpl>
    implements _$$TutorReviewDtoImplCopyWith<$Res> {
  __$$TutorReviewDtoImplCopyWithImpl(
      _$TutorReviewDtoImpl _value, $Res Function(_$TutorReviewDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorName = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$TutorReviewDtoImpl(
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorReviewDtoImpl implements _TutorReviewDto {
  const _$TutorReviewDtoImpl(
      {@JsonKey(name: 'author_name') this.authorName,
      this.rating = 0.0,
      this.comment,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$TutorReviewDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorReviewDtoImplFromJson(json);

  @override
  @JsonKey(name: 'author_name')
  final String? authorName;
  @override
  @JsonKey()
  final double rating;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'TutorReviewDto(authorName: $authorName, rating: $rating, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorReviewDtoImpl &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, authorName, rating, comment, createdAt);

  /// Create a copy of TutorReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorReviewDtoImplCopyWith<_$TutorReviewDtoImpl> get copyWith =>
      __$$TutorReviewDtoImplCopyWithImpl<_$TutorReviewDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorReviewDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorReviewDto implements TutorReviewDto {
  const factory _TutorReviewDto(
          {@JsonKey(name: 'author_name') final String? authorName,
          final double rating,
          final String? comment,
          @JsonKey(name: 'created_at') final String? createdAt}) =
      _$TutorReviewDtoImpl;

  factory _TutorReviewDto.fromJson(Map<String, dynamic> json) =
      _$TutorReviewDtoImpl.fromJson;

  @override
  @JsonKey(name: 'author_name')
  String? get authorName;
  @override
  double get rating;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of TutorReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorReviewDtoImplCopyWith<_$TutorReviewDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorProfileDto _$TutorProfileDtoFromJson(Map<String, dynamic> json) {
  return _TutorProfileDto.fromJson(json);
}

/// @nodoc
mixin _$TutorProfileDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  List<String> get subjects => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience_years')
  int get experienceYears => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_count')
  int get sessionCount => throw _privateConstructorUsedError;
  List<TutorTrainingDto> get trainings => throw _privateConstructorUsedError;
  List<TutorWorkDto> get works => throw _privateConstructorUsedError;
  List<TutorAvailabilityDto> get availabilities =>
      throw _privateConstructorUsedError;
  List<TutorReviewDto> get reviews => throw _privateConstructorUsedError;

  /// Serializes this TutorProfileDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorProfileDtoCopyWith<TutorProfileDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorProfileDtoCopyWith<$Res> {
  factory $TutorProfileDtoCopyWith(
          TutorProfileDto value, $Res Function(TutorProfileDto) then) =
      _$TutorProfileDtoCopyWithImpl<$Res, TutorProfileDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      double rating,
      @JsonKey(name: 'review_count') int reviewCount,
      String? category,
      List<String> subjects,
      String? bio,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? city,
      @JsonKey(name: 'experience_years') int experienceYears,
      @JsonKey(name: 'session_count') int sessionCount,
      List<TutorTrainingDto> trainings,
      List<TutorWorkDto> works,
      List<TutorAvailabilityDto> availabilities,
      List<TutorReviewDto> reviews});
}

/// @nodoc
class _$TutorProfileDtoCopyWithImpl<$Res, $Val extends TutorProfileDto>
    implements $TutorProfileDtoCopyWith<$Res> {
  _$TutorProfileDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? category = freezed,
    Object? subjects = null,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? city = freezed,
    Object? experienceYears = null,
    Object? sessionCount = null,
    Object? trainings = null,
    Object? works = null,
    Object? availabilities = null,
    Object? reviews = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      trainings: null == trainings
          ? _value.trainings
          : trainings // ignore: cast_nullable_to_non_nullable
              as List<TutorTrainingDto>,
      works: null == works
          ? _value.works
          : works // ignore: cast_nullable_to_non_nullable
              as List<TutorWorkDto>,
      availabilities: null == availabilities
          ? _value.availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<TutorAvailabilityDto>,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<TutorReviewDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorProfileDtoImplCopyWith<$Res>
    implements $TutorProfileDtoCopyWith<$Res> {
  factory _$$TutorProfileDtoImplCopyWith(_$TutorProfileDtoImpl value,
          $Res Function(_$TutorProfileDtoImpl) then) =
      __$$TutorProfileDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      double rating,
      @JsonKey(name: 'review_count') int reviewCount,
      String? category,
      List<String> subjects,
      String? bio,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? city,
      @JsonKey(name: 'experience_years') int experienceYears,
      @JsonKey(name: 'session_count') int sessionCount,
      List<TutorTrainingDto> trainings,
      List<TutorWorkDto> works,
      List<TutorAvailabilityDto> availabilities,
      List<TutorReviewDto> reviews});
}

/// @nodoc
class __$$TutorProfileDtoImplCopyWithImpl<$Res>
    extends _$TutorProfileDtoCopyWithImpl<$Res, _$TutorProfileDtoImpl>
    implements _$$TutorProfileDtoImplCopyWith<$Res> {
  __$$TutorProfileDtoImplCopyWithImpl(
      _$TutorProfileDtoImpl _value, $Res Function(_$TutorProfileDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? category = freezed,
    Object? subjects = null,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? city = freezed,
    Object? experienceYears = null,
    Object? sessionCount = null,
    Object? trainings = null,
    Object? works = null,
    Object? availabilities = null,
    Object? reviews = null,
  }) {
    return _then(_$TutorProfileDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      trainings: null == trainings
          ? _value._trainings
          : trainings // ignore: cast_nullable_to_non_nullable
              as List<TutorTrainingDto>,
      works: null == works
          ? _value._works
          : works // ignore: cast_nullable_to_non_nullable
              as List<TutorWorkDto>,
      availabilities: null == availabilities
          ? _value._availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<TutorAvailabilityDto>,
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<TutorReviewDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorProfileDtoImpl implements _TutorProfileDto {
  const _$TutorProfileDtoImpl(
      {required this.id,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      this.rating = 0.0,
      @JsonKey(name: 'review_count') this.reviewCount = 0,
      this.category,
      final List<String> subjects = const <String>[],
      this.bio,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.city,
      @JsonKey(name: 'experience_years') this.experienceYears = 0,
      @JsonKey(name: 'session_count') this.sessionCount = 0,
      final List<TutorTrainingDto> trainings = const <TutorTrainingDto>[],
      final List<TutorWorkDto> works = const <TutorWorkDto>[],
      final List<TutorAvailabilityDto> availabilities =
          const <TutorAvailabilityDto>[],
      final List<TutorReviewDto> reviews = const <TutorReviewDto>[]})
      : _subjects = subjects,
        _trainings = trainings,
        _works = works,
        _availabilities = availabilities,
        _reviews = reviews;

  factory _$TutorProfileDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorProfileDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @override
  final String? category;
  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  final String? bio;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final String? city;
  @override
  @JsonKey(name: 'experience_years')
  final int experienceYears;
  @override
  @JsonKey(name: 'session_count')
  final int sessionCount;
  final List<TutorTrainingDto> _trainings;
  @override
  @JsonKey()
  List<TutorTrainingDto> get trainings {
    if (_trainings is EqualUnmodifiableListView) return _trainings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainings);
  }

  final List<TutorWorkDto> _works;
  @override
  @JsonKey()
  List<TutorWorkDto> get works {
    if (_works is EqualUnmodifiableListView) return _works;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_works);
  }

  final List<TutorAvailabilityDto> _availabilities;
  @override
  @JsonKey()
  List<TutorAvailabilityDto> get availabilities {
    if (_availabilities is EqualUnmodifiableListView) return _availabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availabilities);
  }

  final List<TutorReviewDto> _reviews;
  @override
  @JsonKey()
  List<TutorReviewDto> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  String toString() {
    return 'TutorProfileDto(id: $id, firstName: $firstName, lastName: $lastName, rating: $rating, reviewCount: $reviewCount, category: $category, subjects: $subjects, bio: $bio, avatarUrl: $avatarUrl, city: $city, experienceYears: $experienceYears, sessionCount: $sessionCount, trainings: $trainings, works: $works, availabilities: $availabilities, reviews: $reviews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorProfileDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            const DeepCollectionEquality()
                .equals(other._trainings, _trainings) &&
            const DeepCollectionEquality().equals(other._works, _works) &&
            const DeepCollectionEquality()
                .equals(other._availabilities, _availabilities) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      rating,
      reviewCount,
      category,
      const DeepCollectionEquality().hash(_subjects),
      bio,
      avatarUrl,
      city,
      experienceYears,
      sessionCount,
      const DeepCollectionEquality().hash(_trainings),
      const DeepCollectionEquality().hash(_works),
      const DeepCollectionEquality().hash(_availabilities),
      const DeepCollectionEquality().hash(_reviews));

  /// Create a copy of TutorProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorProfileDtoImplCopyWith<_$TutorProfileDtoImpl> get copyWith =>
      __$$TutorProfileDtoImplCopyWithImpl<_$TutorProfileDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorProfileDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorProfileDto implements TutorProfileDto {
  const factory _TutorProfileDto(
      {required final String id,
      @JsonKey(name: 'first_name') required final String firstName,
      @JsonKey(name: 'last_name') required final String lastName,
      final double rating,
      @JsonKey(name: 'review_count') final int reviewCount,
      final String? category,
      final List<String> subjects,
      final String? bio,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final String? city,
      @JsonKey(name: 'experience_years') final int experienceYears,
      @JsonKey(name: 'session_count') final int sessionCount,
      final List<TutorTrainingDto> trainings,
      final List<TutorWorkDto> works,
      final List<TutorAvailabilityDto> availabilities,
      final List<TutorReviewDto> reviews}) = _$TutorProfileDtoImpl;

  factory _TutorProfileDto.fromJson(Map<String, dynamic> json) =
      _$TutorProfileDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  double get rating;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;
  @override
  String? get category;
  @override
  List<String> get subjects;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String? get city;
  @override
  @JsonKey(name: 'experience_years')
  int get experienceYears;
  @override
  @JsonKey(name: 'session_count')
  int get sessionCount;
  @override
  List<TutorTrainingDto> get trainings;
  @override
  List<TutorWorkDto> get works;
  @override
  List<TutorAvailabilityDto> get availabilities;
  @override
  List<TutorReviewDto> get reviews;

  /// Create a copy of TutorProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorProfileDtoImplCopyWith<_$TutorProfileDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
