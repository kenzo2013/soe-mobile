// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorMiniDto _$TutorMiniDtoFromJson(Map<String, dynamic> json) {
  return _TutorMiniDto.fromJson(json);
}

/// @nodoc
mixin _$TutorMiniDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int? get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this TutorMiniDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorMiniDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorMiniDtoCopyWith<TutorMiniDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorMiniDtoCopyWith<$Res> {
  factory $TutorMiniDtoCopyWith(
          TutorMiniDto value, $Res Function(TutorMiniDto) then) =
      _$TutorMiniDtoCopyWithImpl<$Res, TutorMiniDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      String? category,
      double? rating,
      @JsonKey(name: 'review_count') int? reviewCount,
      @JsonKey(name: 'avatar_url') String? avatarUrl});
}

/// @nodoc
class _$TutorMiniDtoCopyWithImpl<$Res, $Val extends TutorMiniDto>
    implements $TutorMiniDtoCopyWith<$Res> {
  _$TutorMiniDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorMiniDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? category = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? avatarUrl = freezed,
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
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorMiniDtoImplCopyWith<$Res>
    implements $TutorMiniDtoCopyWith<$Res> {
  factory _$$TutorMiniDtoImplCopyWith(
          _$TutorMiniDtoImpl value, $Res Function(_$TutorMiniDtoImpl) then) =
      __$$TutorMiniDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName,
      String? category,
      double? rating,
      @JsonKey(name: 'review_count') int? reviewCount,
      @JsonKey(name: 'avatar_url') String? avatarUrl});
}

/// @nodoc
class __$$TutorMiniDtoImplCopyWithImpl<$Res>
    extends _$TutorMiniDtoCopyWithImpl<$Res, _$TutorMiniDtoImpl>
    implements _$$TutorMiniDtoImplCopyWith<$Res> {
  __$$TutorMiniDtoImplCopyWithImpl(
      _$TutorMiniDtoImpl _value, $Res Function(_$TutorMiniDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorMiniDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? category = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$TutorMiniDtoImpl(
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
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorMiniDtoImpl implements _TutorMiniDto {
  const _$TutorMiniDtoImpl(
      {required this.id,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') required this.lastName,
      this.category,
      this.rating,
      @JsonKey(name: 'review_count') this.reviewCount,
      @JsonKey(name: 'avatar_url') this.avatarUrl});

  factory _$TutorMiniDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorMiniDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  final String? category;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @override
  String toString() {
    return 'TutorMiniDto(id: $id, firstName: $firstName, lastName: $lastName, category: $category, rating: $rating, reviewCount: $reviewCount, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorMiniDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName,
      category, rating, reviewCount, avatarUrl);

  /// Create a copy of TutorMiniDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorMiniDtoImplCopyWith<_$TutorMiniDtoImpl> get copyWith =>
      __$$TutorMiniDtoImplCopyWithImpl<_$TutorMiniDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorMiniDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorMiniDto implements TutorMiniDto {
  const factory _TutorMiniDto(
          {required final String id,
          @JsonKey(name: 'first_name') required final String firstName,
          @JsonKey(name: 'last_name') required final String lastName,
          final String? category,
          final double? rating,
          @JsonKey(name: 'review_count') final int? reviewCount,
          @JsonKey(name: 'avatar_url') final String? avatarUrl}) =
      _$TutorMiniDtoImpl;

  factory _TutorMiniDto.fromJson(Map<String, dynamic> json) =
      _$TutorMiniDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  String? get category;
  @override
  double? get rating;
  @override
  @JsonKey(name: 'review_count')
  int? get reviewCount;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// Create a copy of TutorMiniDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorMiniDtoImplCopyWith<_$TutorMiniDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReservationDetailDto _$ReservationDetailDtoFromJson(Map<String, dynamic> json) {
  return _ReservationDetailDto.fromJson(json);
}

/// @nodoc
mixin _$ReservationDetailDto {
  String get id => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_id')
  String? get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_name')
  String? get childName => throw _privateConstructorUsedError;
  List<String> get subjects => throw _privateConstructorUsedError;
  int get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_start_date')
  String? get estimatedStartDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_tutor_gender')
  String? get preferredTutorGender => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_per_session')
  int? get amountPerSession => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_count')
  int? get sessionCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'program_text')
  String? get programText => throw _privateConstructorUsedError;
  TutorMiniDto? get tutor => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReservationDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationDetailDtoCopyWith<ReservationDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationDetailDtoCopyWith<$Res> {
  factory $ReservationDetailDtoCopyWith(ReservationDetailDto value,
          $Res Function(ReservationDetailDto) then) =
      _$ReservationDetailDtoCopyWithImpl<$Res, ReservationDetailDto>;
  @useResult
  $Res call(
      {String id,
      String? reference,
      String? status,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'child_name') String? childName,
      List<String> subjects,
      int frequency,
      @JsonKey(name: 'estimated_start_date') String? estimatedStartDate,
      @JsonKey(name: 'preferred_tutor_gender') String? preferredTutorGender,
      String? location,
      int? amount,
      @JsonKey(name: 'amount_per_session') int? amountPerSession,
      @JsonKey(name: 'session_count') int? sessionCount,
      @JsonKey(name: 'program_text') String? programText,
      TutorMiniDto? tutor,
      @JsonKey(name: 'created_at') String? createdAt});

  $TutorMiniDtoCopyWith<$Res>? get tutor;
}

/// @nodoc
class _$ReservationDetailDtoCopyWithImpl<$Res,
        $Val extends ReservationDetailDto>
    implements $ReservationDetailDtoCopyWith<$Res> {
  _$ReservationDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? status = freezed,
    Object? childId = freezed,
    Object? childName = freezed,
    Object? subjects = null,
    Object? frequency = null,
    Object? estimatedStartDate = freezed,
    Object? preferredTutorGender = freezed,
    Object? location = freezed,
    Object? amount = freezed,
    Object? amountPerSession = freezed,
    Object? sessionCount = freezed,
    Object? programText = freezed,
    Object? tutor = freezed,
    Object? createdAt = freezed,
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
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedStartDate: freezed == estimatedStartDate
          ? _value.estimatedStartDate
          : estimatedStartDate // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTutorGender: freezed == preferredTutorGender
          ? _value.preferredTutorGender
          : preferredTutorGender // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      amountPerSession: freezed == amountPerSession
          ? _value.amountPerSession
          : amountPerSession // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionCount: freezed == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int?,
      programText: freezed == programText
          ? _value.programText
          : programText // ignore: cast_nullable_to_non_nullable
              as String?,
      tutor: freezed == tutor
          ? _value.tutor
          : tutor // ignore: cast_nullable_to_non_nullable
              as TutorMiniDto?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TutorMiniDtoCopyWith<$Res>? get tutor {
    if (_value.tutor == null) {
      return null;
    }

    return $TutorMiniDtoCopyWith<$Res>(_value.tutor!, (value) {
      return _then(_value.copyWith(tutor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReservationDetailDtoImplCopyWith<$Res>
    implements $ReservationDetailDtoCopyWith<$Res> {
  factory _$$ReservationDetailDtoImplCopyWith(_$ReservationDetailDtoImpl value,
          $Res Function(_$ReservationDetailDtoImpl) then) =
      __$$ReservationDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? reference,
      String? status,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'child_name') String? childName,
      List<String> subjects,
      int frequency,
      @JsonKey(name: 'estimated_start_date') String? estimatedStartDate,
      @JsonKey(name: 'preferred_tutor_gender') String? preferredTutorGender,
      String? location,
      int? amount,
      @JsonKey(name: 'amount_per_session') int? amountPerSession,
      @JsonKey(name: 'session_count') int? sessionCount,
      @JsonKey(name: 'program_text') String? programText,
      TutorMiniDto? tutor,
      @JsonKey(name: 'created_at') String? createdAt});

  @override
  $TutorMiniDtoCopyWith<$Res>? get tutor;
}

/// @nodoc
class __$$ReservationDetailDtoImplCopyWithImpl<$Res>
    extends _$ReservationDetailDtoCopyWithImpl<$Res, _$ReservationDetailDtoImpl>
    implements _$$ReservationDetailDtoImplCopyWith<$Res> {
  __$$ReservationDetailDtoImplCopyWithImpl(_$ReservationDetailDtoImpl _value,
      $Res Function(_$ReservationDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? status = freezed,
    Object? childId = freezed,
    Object? childName = freezed,
    Object? subjects = null,
    Object? frequency = null,
    Object? estimatedStartDate = freezed,
    Object? preferredTutorGender = freezed,
    Object? location = freezed,
    Object? amount = freezed,
    Object? amountPerSession = freezed,
    Object? sessionCount = freezed,
    Object? programText = freezed,
    Object? tutor = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ReservationDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      childName: freezed == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String?,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedStartDate: freezed == estimatedStartDate
          ? _value.estimatedStartDate
          : estimatedStartDate // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTutorGender: freezed == preferredTutorGender
          ? _value.preferredTutorGender
          : preferredTutorGender // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      amountPerSession: freezed == amountPerSession
          ? _value.amountPerSession
          : amountPerSession // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionCount: freezed == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int?,
      programText: freezed == programText
          ? _value.programText
          : programText // ignore: cast_nullable_to_non_nullable
              as String?,
      tutor: freezed == tutor
          ? _value.tutor
          : tutor // ignore: cast_nullable_to_non_nullable
              as TutorMiniDto?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationDetailDtoImpl implements _ReservationDetailDto {
  const _$ReservationDetailDtoImpl(
      {required this.id,
      this.reference,
      this.status,
      @JsonKey(name: 'child_id') this.childId,
      @JsonKey(name: 'child_name') this.childName,
      final List<String> subjects = const <String>[],
      this.frequency = 1,
      @JsonKey(name: 'estimated_start_date') this.estimatedStartDate,
      @JsonKey(name: 'preferred_tutor_gender') this.preferredTutorGender,
      this.location,
      this.amount,
      @JsonKey(name: 'amount_per_session') this.amountPerSession,
      @JsonKey(name: 'session_count') this.sessionCount,
      @JsonKey(name: 'program_text') this.programText,
      this.tutor,
      @JsonKey(name: 'created_at') this.createdAt})
      : _subjects = subjects;

  factory _$ReservationDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationDetailDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? reference;
  @override
  final String? status;
  @override
  @JsonKey(name: 'child_id')
  final String? childId;
  @override
  @JsonKey(name: 'child_name')
  final String? childName;
  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  @JsonKey()
  final int frequency;
  @override
  @JsonKey(name: 'estimated_start_date')
  final String? estimatedStartDate;
  @override
  @JsonKey(name: 'preferred_tutor_gender')
  final String? preferredTutorGender;
  @override
  final String? location;
  @override
  final int? amount;
  @override
  @JsonKey(name: 'amount_per_session')
  final int? amountPerSession;
  @override
  @JsonKey(name: 'session_count')
  final int? sessionCount;
  @override
  @JsonKey(name: 'program_text')
  final String? programText;
  @override
  final TutorMiniDto? tutor;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'ReservationDetailDto(id: $id, reference: $reference, status: $status, childId: $childId, childName: $childName, subjects: $subjects, frequency: $frequency, estimatedStartDate: $estimatedStartDate, preferredTutorGender: $preferredTutorGender, location: $location, amount: $amount, amountPerSession: $amountPerSession, sessionCount: $sessionCount, programText: $programText, tutor: $tutor, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.estimatedStartDate, estimatedStartDate) ||
                other.estimatedStartDate == estimatedStartDate) &&
            (identical(other.preferredTutorGender, preferredTutorGender) ||
                other.preferredTutorGender == preferredTutorGender) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.amountPerSession, amountPerSession) ||
                other.amountPerSession == amountPerSession) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.programText, programText) ||
                other.programText == programText) &&
            (identical(other.tutor, tutor) || other.tutor == tutor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reference,
      status,
      childId,
      childName,
      const DeepCollectionEquality().hash(_subjects),
      frequency,
      estimatedStartDate,
      preferredTutorGender,
      location,
      amount,
      amountPerSession,
      sessionCount,
      programText,
      tutor,
      createdAt);

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationDetailDtoImplCopyWith<_$ReservationDetailDtoImpl>
      get copyWith =>
          __$$ReservationDetailDtoImplCopyWithImpl<_$ReservationDetailDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _ReservationDetailDto implements ReservationDetailDto {
  const factory _ReservationDetailDto(
      {required final String id,
      final String? reference,
      final String? status,
      @JsonKey(name: 'child_id') final String? childId,
      @JsonKey(name: 'child_name') final String? childName,
      final List<String> subjects,
      final int frequency,
      @JsonKey(name: 'estimated_start_date') final String? estimatedStartDate,
      @JsonKey(name: 'preferred_tutor_gender')
      final String? preferredTutorGender,
      final String? location,
      final int? amount,
      @JsonKey(name: 'amount_per_session') final int? amountPerSession,
      @JsonKey(name: 'session_count') final int? sessionCount,
      @JsonKey(name: 'program_text') final String? programText,
      final TutorMiniDto? tutor,
      @JsonKey(name: 'created_at')
      final String? createdAt}) = _$ReservationDetailDtoImpl;

  factory _ReservationDetailDto.fromJson(Map<String, dynamic> json) =
      _$ReservationDetailDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get reference;
  @override
  String? get status;
  @override
  @JsonKey(name: 'child_id')
  String? get childId;
  @override
  @JsonKey(name: 'child_name')
  String? get childName;
  @override
  List<String> get subjects;
  @override
  int get frequency;
  @override
  @JsonKey(name: 'estimated_start_date')
  String? get estimatedStartDate;
  @override
  @JsonKey(name: 'preferred_tutor_gender')
  String? get preferredTutorGender;
  @override
  String? get location;
  @override
  int? get amount;
  @override
  @JsonKey(name: 'amount_per_session')
  int? get amountPerSession;
  @override
  @JsonKey(name: 'session_count')
  int? get sessionCount;
  @override
  @JsonKey(name: 'program_text')
  String? get programText;
  @override
  TutorMiniDto? get tutor;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of ReservationDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationDetailDtoImplCopyWith<_$ReservationDetailDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
