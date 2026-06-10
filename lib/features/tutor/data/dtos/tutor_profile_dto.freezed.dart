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

TutorDescriptionDto _$TutorDescriptionDtoFromJson(Map<String, dynamic> json) {
  return _TutorDescriptionDto.fromJson(json);
}

/// @nodoc
mixin _$TutorDescriptionDto {
  String? get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  /// Serializes this TutorDescriptionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorDescriptionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorDescriptionDtoCopyWith<TutorDescriptionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorDescriptionDtoCopyWith<$Res> {
  factory $TutorDescriptionDtoCopyWith(
          TutorDescriptionDto value, $Res Function(TutorDescriptionDto) then) =
      _$TutorDescriptionDtoCopyWithImpl<$Res, TutorDescriptionDto>;
  @useResult
  $Res call({String? id, String content, String? category});
}

/// @nodoc
class _$TutorDescriptionDtoCopyWithImpl<$Res, $Val extends TutorDescriptionDto>
    implements $TutorDescriptionDtoCopyWith<$Res> {
  _$TutorDescriptionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorDescriptionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? content = null,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorDescriptionDtoImplCopyWith<$Res>
    implements $TutorDescriptionDtoCopyWith<$Res> {
  factory _$$TutorDescriptionDtoImplCopyWith(_$TutorDescriptionDtoImpl value,
          $Res Function(_$TutorDescriptionDtoImpl) then) =
      __$$TutorDescriptionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String content, String? category});
}

/// @nodoc
class __$$TutorDescriptionDtoImplCopyWithImpl<$Res>
    extends _$TutorDescriptionDtoCopyWithImpl<$Res, _$TutorDescriptionDtoImpl>
    implements _$$TutorDescriptionDtoImplCopyWith<$Res> {
  __$$TutorDescriptionDtoImplCopyWithImpl(_$TutorDescriptionDtoImpl _value,
      $Res Function(_$TutorDescriptionDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorDescriptionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? content = null,
    Object? category = freezed,
  }) {
    return _then(_$TutorDescriptionDtoImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorDescriptionDtoImpl implements _TutorDescriptionDto {
  const _$TutorDescriptionDtoImpl({this.id, this.content = '', this.category});

  factory _$TutorDescriptionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorDescriptionDtoImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey()
  final String content;
  @override
  final String? category;

  @override
  String toString() {
    return 'TutorDescriptionDto(id: $id, content: $content, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorDescriptionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, content, category);

  /// Create a copy of TutorDescriptionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorDescriptionDtoImplCopyWith<_$TutorDescriptionDtoImpl> get copyWith =>
      __$$TutorDescriptionDtoImplCopyWithImpl<_$TutorDescriptionDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorDescriptionDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorDescriptionDto implements TutorDescriptionDto {
  const factory _TutorDescriptionDto(
      {final String? id,
      final String content,
      final String? category}) = _$TutorDescriptionDtoImpl;

  factory _TutorDescriptionDto.fromJson(Map<String, dynamic> json) =
      _$TutorDescriptionDtoImpl.fromJson;

  @override
  String? get id;
  @override
  String get content;
  @override
  String? get category;

  /// Create a copy of TutorDescriptionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorDescriptionDtoImplCopyWith<_$TutorDescriptionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorTrainingDto _$TutorTrainingDtoFromJson(Map<String, dynamic> json) {
  return _TutorTrainingDto.fromJson(json);
}

/// @nodoc
mixin _$TutorTrainingDto {
  String get id => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(readValue: _levelRead)
  String get level => throw _privateConstructorUsedError;
  @JsonKey(readValue: _domainRead)
  String get domain => throw _privateConstructorUsedError;
  @JsonKey(readValue: _speciality)
  String get specialty => throw _privateConstructorUsedError;
  @JsonKey(readValue: _trainingDate)
  String get date => throw _privateConstructorUsedError;

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
      {String id,
      String category,
      @JsonKey(readValue: _levelRead) String level,
      @JsonKey(readValue: _domainRead) String domain,
      @JsonKey(readValue: _speciality) String specialty,
      @JsonKey(readValue: _trainingDate) String date});
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
    Object? id = null,
    Object? category = null,
    Object? level = null,
    Object? domain = null,
    Object? specialty = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
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
      {String id,
      String category,
      @JsonKey(readValue: _levelRead) String level,
      @JsonKey(readValue: _domainRead) String domain,
      @JsonKey(readValue: _speciality) String specialty,
      @JsonKey(readValue: _trainingDate) String date});
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
    Object? id = null,
    Object? category = null,
    Object? level = null,
    Object? domain = null,
    Object? specialty = null,
    Object? date = null,
  }) {
    return _then(_$TutorTrainingDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorTrainingDtoImpl implements _TutorTrainingDto {
  const _$TutorTrainingDtoImpl(
      {this.id = '',
      this.category = '',
      @JsonKey(readValue: _levelRead) this.level = '',
      @JsonKey(readValue: _domainRead) this.domain = '',
      @JsonKey(readValue: _speciality) this.specialty = '',
      @JsonKey(readValue: _trainingDate) this.date = ''});

  factory _$TutorTrainingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorTrainingDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey(readValue: _levelRead)
  final String level;
  @override
  @JsonKey(readValue: _domainRead)
  final String domain;
  @override
  @JsonKey(readValue: _speciality)
  final String specialty;
  @override
  @JsonKey(readValue: _trainingDate)
  final String date;

  @override
  String toString() {
    return 'TutorTrainingDto(id: $id, category: $category, level: $level, domain: $domain, specialty: $specialty, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorTrainingDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, level, domain, specialty, date);

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
          {final String id,
          final String category,
          @JsonKey(readValue: _levelRead) final String level,
          @JsonKey(readValue: _domainRead) final String domain,
          @JsonKey(readValue: _speciality) final String specialty,
          @JsonKey(readValue: _trainingDate) final String date}) =
      _$TutorTrainingDtoImpl;

  factory _TutorTrainingDto.fromJson(Map<String, dynamic> json) =
      _$TutorTrainingDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get category;
  @override
  @JsonKey(readValue: _levelRead)
  String get level;
  @override
  @JsonKey(readValue: _domainRead)
  String get domain;
  @override
  @JsonKey(readValue: _speciality)
  String get specialty;
  @override
  @JsonKey(readValue: _trainingDate)
  String get date;

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
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _workTitle)
  String get title => throw _privateConstructorUsedError;
  @JsonKey(readValue: _workCompany)
  String get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_position')
  bool get current => throw _privateConstructorUsedError;
  String get since => throw _privateConstructorUsedError;
  String? get until => throw _privateConstructorUsedError;

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
      {String id,
      @JsonKey(readValue: _workTitle) String title,
      @JsonKey(readValue: _workCompany) String company,
      @JsonKey(name: 'current_position') bool current,
      String since,
      String? until});
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
    Object? id = null,
    Object? title = null,
    Object? company = null,
    Object? current = null,
    Object? since = null,
    Object? until = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as bool,
      since: null == since
          ? _value.since
          : since // ignore: cast_nullable_to_non_nullable
              as String,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
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
      {String id,
      @JsonKey(readValue: _workTitle) String title,
      @JsonKey(readValue: _workCompany) String company,
      @JsonKey(name: 'current_position') bool current,
      String since,
      String? until});
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
    Object? id = null,
    Object? title = null,
    Object? company = null,
    Object? current = null,
    Object? since = null,
    Object? until = freezed,
  }) {
    return _then(_$TutorWorkDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as bool,
      since: null == since
          ? _value.since
          : since // ignore: cast_nullable_to_non_nullable
              as String,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorWorkDtoImpl implements _TutorWorkDto {
  const _$TutorWorkDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _workTitle) this.title = '',
      @JsonKey(readValue: _workCompany) this.company = '',
      @JsonKey(name: 'current_position') this.current = false,
      this.since = '',
      this.until});

  factory _$TutorWorkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorWorkDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _workTitle)
  final String title;
  @override
  @JsonKey(readValue: _workCompany)
  final String company;
  @override
  @JsonKey(name: 'current_position')
  final bool current;
  @override
  @JsonKey()
  final String since;
  @override
  final String? until;

  @override
  String toString() {
    return 'TutorWorkDto(id: $id, title: $title, company: $company, current: $current, since: $since, until: $until)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorWorkDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.since, since) || other.since == since) &&
            (identical(other.until, until) || other.until == until));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, company, current, since, until);

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
      {final String id,
      @JsonKey(readValue: _workTitle) final String title,
      @JsonKey(readValue: _workCompany) final String company,
      @JsonKey(name: 'current_position') final bool current,
      final String since,
      final String? until}) = _$TutorWorkDtoImpl;

  factory _TutorWorkDto.fromJson(Map<String, dynamic> json) =
      _$TutorWorkDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _workTitle)
  String get title;
  @override
  @JsonKey(readValue: _workCompany)
  String get company;
  @override
  @JsonKey(name: 'current_position')
  bool get current;
  @override
  String get since;
  @override
  String? get until;

  /// Create a copy of TutorWorkDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorWorkDtoImplCopyWith<_$TutorWorkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorIdentityDto _$TutorIdentityDtoFromJson(Map<String, dynamic> json) {
  return _TutorIdentityDto.fromJson(json);
}

/// @nodoc
mixin _$TutorIdentityDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _docType)
  String get type => throw _privateConstructorUsedError;
  @JsonKey(readValue: _expiresRead)
  String? get expirationDate => throw _privateConstructorUsedError;
  @JsonKey(readValue: _birthRead)
  String? get birthday =>
      throw _privateConstructorUsedError; // `image_urls` (nouveau format backend, mai 2026) : chemins ActiveStorage
// relatifs. readValue interdit sur les List → on lit via `name` + fallbacks
// gérés dans toEntity.
  @JsonKey(name: 'image_urls')
  List<dynamic> get imageUrls => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this TutorIdentityDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorIdentityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorIdentityDtoCopyWith<TutorIdentityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorIdentityDtoCopyWith<$Res> {
  factory $TutorIdentityDtoCopyWith(
          TutorIdentityDto value, $Res Function(TutorIdentityDto) then) =
      _$TutorIdentityDtoCopyWithImpl<$Res, TutorIdentityDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _docType) String type,
      @JsonKey(readValue: _expiresRead) String? expirationDate,
      @JsonKey(readValue: _birthRead) String? birthday,
      @JsonKey(name: 'image_urls') List<dynamic> imageUrls,
      String status});
}

/// @nodoc
class _$TutorIdentityDtoCopyWithImpl<$Res, $Val extends TutorIdentityDto>
    implements $TutorIdentityDtoCopyWith<$Res> {
  _$TutorIdentityDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorIdentityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? expirationDate = freezed,
    Object? birthday = freezed,
    Object? imageUrls = null,
    Object? status = null,
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
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorIdentityDtoImplCopyWith<$Res>
    implements $TutorIdentityDtoCopyWith<$Res> {
  factory _$$TutorIdentityDtoImplCopyWith(_$TutorIdentityDtoImpl value,
          $Res Function(_$TutorIdentityDtoImpl) then) =
      __$$TutorIdentityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _docType) String type,
      @JsonKey(readValue: _expiresRead) String? expirationDate,
      @JsonKey(readValue: _birthRead) String? birthday,
      @JsonKey(name: 'image_urls') List<dynamic> imageUrls,
      String status});
}

/// @nodoc
class __$$TutorIdentityDtoImplCopyWithImpl<$Res>
    extends _$TutorIdentityDtoCopyWithImpl<$Res, _$TutorIdentityDtoImpl>
    implements _$$TutorIdentityDtoImplCopyWith<$Res> {
  __$$TutorIdentityDtoImplCopyWithImpl(_$TutorIdentityDtoImpl _value,
      $Res Function(_$TutorIdentityDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorIdentityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? expirationDate = freezed,
    Object? birthday = freezed,
    Object? imageUrls = null,
    Object? status = null,
  }) {
    return _then(_$TutorIdentityDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorIdentityDtoImpl implements _TutorIdentityDto {
  const _$TutorIdentityDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _docType) this.type = '',
      @JsonKey(readValue: _expiresRead) this.expirationDate,
      @JsonKey(readValue: _birthRead) this.birthday,
      @JsonKey(name: 'image_urls')
      final List<dynamic> imageUrls = const <dynamic>[],
      this.status = 'pending'})
      : _imageUrls = imageUrls;

  factory _$TutorIdentityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorIdentityDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _docType)
  final String type;
  @override
  @JsonKey(readValue: _expiresRead)
  final String? expirationDate;
  @override
  @JsonKey(readValue: _birthRead)
  final String? birthday;
// `image_urls` (nouveau format backend, mai 2026) : chemins ActiveStorage
// relatifs. readValue interdit sur les List → on lit via `name` + fallbacks
// gérés dans toEntity.
  final List<dynamic> _imageUrls;
// `image_urls` (nouveau format backend, mai 2026) : chemins ActiveStorage
// relatifs. readValue interdit sur les List → on lit via `name` + fallbacks
// gérés dans toEntity.
  @override
  @JsonKey(name: 'image_urls')
  List<dynamic> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'TutorIdentityDto(id: $id, type: $type, expirationDate: $expirationDate, birthday: $birthday, imageUrls: $imageUrls, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorIdentityDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, expirationDate,
      birthday, const DeepCollectionEquality().hash(_imageUrls), status);

  /// Create a copy of TutorIdentityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorIdentityDtoImplCopyWith<_$TutorIdentityDtoImpl> get copyWith =>
      __$$TutorIdentityDtoImplCopyWithImpl<_$TutorIdentityDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorIdentityDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorIdentityDto implements TutorIdentityDto {
  const factory _TutorIdentityDto(
      {final String id,
      @JsonKey(readValue: _docType) final String type,
      @JsonKey(readValue: _expiresRead) final String? expirationDate,
      @JsonKey(readValue: _birthRead) final String? birthday,
      @JsonKey(name: 'image_urls') final List<dynamic> imageUrls,
      final String status}) = _$TutorIdentityDtoImpl;

  factory _TutorIdentityDto.fromJson(Map<String, dynamic> json) =
      _$TutorIdentityDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _docType)
  String get type;
  @override
  @JsonKey(readValue: _expiresRead)
  String? get expirationDate;
  @override
  @JsonKey(readValue: _birthRead)
  String?
      get birthday; // `image_urls` (nouveau format backend, mai 2026) : chemins ActiveStorage
// relatifs. readValue interdit sur les List → on lit via `name` + fallbacks
// gérés dans toEntity.
  @override
  @JsonKey(name: 'image_urls')
  List<dynamic> get imageUrls;
  @override
  String get status;

  /// Create a copy of TutorIdentityDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorIdentityDtoImplCopyWith<_$TutorIdentityDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorTeachingCourseDto _$TutorTeachingCourseDtoFromJson(
    Map<String, dynamic> json) {
  return _TutorTeachingCourseDto.fromJson(json);
}

/// @nodoc
mixin _$TutorTeachingCourseDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _className)
  String get classe => throw _privateConstructorUsedError;
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects => throw _privateConstructorUsedError;

  /// Serializes this TutorTeachingCourseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorTeachingCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorTeachingCourseDtoCopyWith<TutorTeachingCourseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorTeachingCourseDtoCopyWith<$Res> {
  factory $TutorTeachingCourseDtoCopyWith(TutorTeachingCourseDto value,
          $Res Function(TutorTeachingCourseDto) then) =
      _$TutorTeachingCourseDtoCopyWithImpl<$Res, TutorTeachingCourseDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _className) String classe,
      @JsonKey(name: 'subjects') List<dynamic> subjects});
}

/// @nodoc
class _$TutorTeachingCourseDtoCopyWithImpl<$Res,
        $Val extends TutorTeachingCourseDto>
    implements $TutorTeachingCourseDtoCopyWith<$Res> {
  _$TutorTeachingCourseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorTeachingCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classe = null,
    Object? subjects = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorTeachingCourseDtoImplCopyWith<$Res>
    implements $TutorTeachingCourseDtoCopyWith<$Res> {
  factory _$$TutorTeachingCourseDtoImplCopyWith(
          _$TutorTeachingCourseDtoImpl value,
          $Res Function(_$TutorTeachingCourseDtoImpl) then) =
      __$$TutorTeachingCourseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _className) String classe,
      @JsonKey(name: 'subjects') List<dynamic> subjects});
}

/// @nodoc
class __$$TutorTeachingCourseDtoImplCopyWithImpl<$Res>
    extends _$TutorTeachingCourseDtoCopyWithImpl<$Res,
        _$TutorTeachingCourseDtoImpl>
    implements _$$TutorTeachingCourseDtoImplCopyWith<$Res> {
  __$$TutorTeachingCourseDtoImplCopyWithImpl(
      _$TutorTeachingCourseDtoImpl _value,
      $Res Function(_$TutorTeachingCourseDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorTeachingCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classe = null,
    Object? subjects = null,
  }) {
    return _then(_$TutorTeachingCourseDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classe: null == classe
          ? _value.classe
          : classe // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorTeachingCourseDtoImpl implements _TutorTeachingCourseDto {
  const _$TutorTeachingCourseDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _className) this.classe = '',
      @JsonKey(name: 'subjects')
      final List<dynamic> subjects = const <dynamic>[]})
      : _subjects = subjects;

  factory _$TutorTeachingCourseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorTeachingCourseDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _className)
  final String classe;
  final List<dynamic> _subjects;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  String toString() {
    return 'TutorTeachingCourseDto(id: $id, classe: $classe, subjects: $subjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorTeachingCourseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classe, classe) || other.classe == classe) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, classe, const DeepCollectionEquality().hash(_subjects));

  /// Create a copy of TutorTeachingCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorTeachingCourseDtoImplCopyWith<_$TutorTeachingCourseDtoImpl>
      get copyWith => __$$TutorTeachingCourseDtoImplCopyWithImpl<
          _$TutorTeachingCourseDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorTeachingCourseDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorTeachingCourseDto implements TutorTeachingCourseDto {
  const factory _TutorTeachingCourseDto(
          {final String id,
          @JsonKey(readValue: _className) final String classe,
          @JsonKey(name: 'subjects') final List<dynamic> subjects}) =
      _$TutorTeachingCourseDtoImpl;

  factory _TutorTeachingCourseDto.fromJson(Map<String, dynamic> json) =
      _$TutorTeachingCourseDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _className)
  String get classe;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects;

  /// Create a copy of TutorTeachingCourseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorTeachingCourseDtoImplCopyWith<_$TutorTeachingCourseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TutorAvailabilitySlotDto _$TutorAvailabilitySlotDtoFromJson(
    Map<String, dynamic> json) {
  return _TutorAvailabilitySlotDto.fromJson(json);
}

/// @nodoc
mixin _$TutorAvailabilitySlotDto {
  String? get id => throw _privateConstructorUsedError;
  String get day => throw _privateConstructorUsedError;
  @JsonKey(readValue: _timeSlots)
  List<dynamic> get timeAvailabilities => throw _privateConstructorUsedError;

  /// Serializes this TutorAvailabilitySlotDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorAvailabilitySlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorAvailabilitySlotDtoCopyWith<TutorAvailabilitySlotDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorAvailabilitySlotDtoCopyWith<$Res> {
  factory $TutorAvailabilitySlotDtoCopyWith(TutorAvailabilitySlotDto value,
          $Res Function(TutorAvailabilitySlotDto) then) =
      _$TutorAvailabilitySlotDtoCopyWithImpl<$Res, TutorAvailabilitySlotDto>;
  @useResult
  $Res call(
      {String? id,
      String day,
      @JsonKey(readValue: _timeSlots) List<dynamic> timeAvailabilities});
}

/// @nodoc
class _$TutorAvailabilitySlotDtoCopyWithImpl<$Res,
        $Val extends TutorAvailabilitySlotDto>
    implements $TutorAvailabilitySlotDtoCopyWith<$Res> {
  _$TutorAvailabilitySlotDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorAvailabilitySlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? day = null,
    Object? timeAvailabilities = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      timeAvailabilities: null == timeAvailabilities
          ? _value.timeAvailabilities
          : timeAvailabilities // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorAvailabilitySlotDtoImplCopyWith<$Res>
    implements $TutorAvailabilitySlotDtoCopyWith<$Res> {
  factory _$$TutorAvailabilitySlotDtoImplCopyWith(
          _$TutorAvailabilitySlotDtoImpl value,
          $Res Function(_$TutorAvailabilitySlotDtoImpl) then) =
      __$$TutorAvailabilitySlotDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String day,
      @JsonKey(readValue: _timeSlots) List<dynamic> timeAvailabilities});
}

/// @nodoc
class __$$TutorAvailabilitySlotDtoImplCopyWithImpl<$Res>
    extends _$TutorAvailabilitySlotDtoCopyWithImpl<$Res,
        _$TutorAvailabilitySlotDtoImpl>
    implements _$$TutorAvailabilitySlotDtoImplCopyWith<$Res> {
  __$$TutorAvailabilitySlotDtoImplCopyWithImpl(
      _$TutorAvailabilitySlotDtoImpl _value,
      $Res Function(_$TutorAvailabilitySlotDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorAvailabilitySlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? day = null,
    Object? timeAvailabilities = null,
  }) {
    return _then(_$TutorAvailabilitySlotDtoImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      timeAvailabilities: null == timeAvailabilities
          ? _value._timeAvailabilities
          : timeAvailabilities // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorAvailabilitySlotDtoImpl implements _TutorAvailabilitySlotDto {
  const _$TutorAvailabilitySlotDtoImpl(
      {this.id,
      this.day = '',
      @JsonKey(readValue: _timeSlots)
      final List<dynamic> timeAvailabilities = const <dynamic>[]})
      : _timeAvailabilities = timeAvailabilities;

  factory _$TutorAvailabilitySlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorAvailabilitySlotDtoImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey()
  final String day;
  final List<dynamic> _timeAvailabilities;
  @override
  @JsonKey(readValue: _timeSlots)
  List<dynamic> get timeAvailabilities {
    if (_timeAvailabilities is EqualUnmodifiableListView)
      return _timeAvailabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeAvailabilities);
  }

  @override
  String toString() {
    return 'TutorAvailabilitySlotDto(id: $id, day: $day, timeAvailabilities: $timeAvailabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorAvailabilitySlotDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.day, day) || other.day == day) &&
            const DeepCollectionEquality()
                .equals(other._timeAvailabilities, _timeAvailabilities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, day,
      const DeepCollectionEquality().hash(_timeAvailabilities));

  /// Create a copy of TutorAvailabilitySlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorAvailabilitySlotDtoImplCopyWith<_$TutorAvailabilitySlotDtoImpl>
      get copyWith => __$$TutorAvailabilitySlotDtoImplCopyWithImpl<
          _$TutorAvailabilitySlotDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorAvailabilitySlotDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorAvailabilitySlotDto implements TutorAvailabilitySlotDto {
  const factory _TutorAvailabilitySlotDto(
      {final String? id,
      final String day,
      @JsonKey(readValue: _timeSlots)
      final List<dynamic> timeAvailabilities}) = _$TutorAvailabilitySlotDtoImpl;

  factory _TutorAvailabilitySlotDto.fromJson(Map<String, dynamic> json) =
      _$TutorAvailabilitySlotDtoImpl.fromJson;

  @override
  String? get id;
  @override
  String get day;
  @override
  @JsonKey(readValue: _timeSlots)
  List<dynamic> get timeAvailabilities;

  /// Create a copy of TutorAvailabilitySlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorAvailabilitySlotDtoImplCopyWith<_$TutorAvailabilitySlotDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
