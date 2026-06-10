// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_job_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TutorJobDto _$TutorJobDtoFromJson(Map<String, dynamic> json) {
  return _TutorJobDto.fromJson(json);
}

/// @nodoc
mixin _$TutorJobDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: _title)
  String get title => throw _privateConstructorUsedError;
  @JsonKey(readValue: _price)
  int get pricePerHour => throw _privateConstructorUsedError;
  @JsonKey(readValue: _frequency)
  String get frequency => throw _privateConstructorUsedError;
  @JsonKey(readValue: _start)
  String get start => throw _privateConstructorUsedError;
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects => throw _privateConstructorUsedError;
  @JsonKey(name: 'school_classes')
  List<dynamic> get classes => throw _privateConstructorUsedError;
  @JsonKey(readValue: _location)
  String get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(readValue: _applied)
  bool get applied => throw _privateConstructorUsedError;
  @JsonKey(readValue: _summary)
  String get summary => throw _privateConstructorUsedError;

  /// Serializes this TutorJobDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TutorJobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorJobDtoCopyWith<TutorJobDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorJobDtoCopyWith<$Res> {
  factory $TutorJobDtoCopyWith(
          TutorJobDto value, $Res Function(TutorJobDto) then) =
      _$TutorJobDtoCopyWithImpl<$Res, TutorJobDto>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _title) String title,
      @JsonKey(readValue: _price) int pricePerHour,
      @JsonKey(readValue: _frequency) String frequency,
      @JsonKey(readValue: _start) String start,
      @JsonKey(name: 'subjects') List<dynamic> subjects,
      @JsonKey(name: 'school_classes') List<dynamic> classes,
      @JsonKey(readValue: _location) String location,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(readValue: _applied) bool applied,
      @JsonKey(readValue: _summary) String summary});
}

/// @nodoc
class _$TutorJobDtoCopyWithImpl<$Res, $Val extends TutorJobDto>
    implements $TutorJobDtoCopyWith<$Res> {
  _$TutorJobDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorJobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? pricePerHour = null,
    Object? frequency = null,
    Object? start = null,
    Object? subjects = null,
    Object? classes = null,
    Object? location = null,
    Object? createdAt = freezed,
    Object? applied = null,
    Object? summary = null,
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
      pricePerHour: null == pricePerHour
          ? _value.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      classes: null == classes
          ? _value.classes
          : classes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      applied: null == applied
          ? _value.applied
          : applied // ignore: cast_nullable_to_non_nullable
              as bool,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorJobDtoImplCopyWith<$Res>
    implements $TutorJobDtoCopyWith<$Res> {
  factory _$$TutorJobDtoImplCopyWith(
          _$TutorJobDtoImpl value, $Res Function(_$TutorJobDtoImpl) then) =
      __$$TutorJobDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(readValue: _title) String title,
      @JsonKey(readValue: _price) int pricePerHour,
      @JsonKey(readValue: _frequency) String frequency,
      @JsonKey(readValue: _start) String start,
      @JsonKey(name: 'subjects') List<dynamic> subjects,
      @JsonKey(name: 'school_classes') List<dynamic> classes,
      @JsonKey(readValue: _location) String location,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(readValue: _applied) bool applied,
      @JsonKey(readValue: _summary) String summary});
}

/// @nodoc
class __$$TutorJobDtoImplCopyWithImpl<$Res>
    extends _$TutorJobDtoCopyWithImpl<$Res, _$TutorJobDtoImpl>
    implements _$$TutorJobDtoImplCopyWith<$Res> {
  __$$TutorJobDtoImplCopyWithImpl(
      _$TutorJobDtoImpl _value, $Res Function(_$TutorJobDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorJobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? pricePerHour = null,
    Object? frequency = null,
    Object? start = null,
    Object? subjects = null,
    Object? classes = null,
    Object? location = null,
    Object? createdAt = freezed,
    Object? applied = null,
    Object? summary = null,
  }) {
    return _then(_$TutorJobDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      pricePerHour: null == pricePerHour
          ? _value.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      subjects: null == subjects
          ? _value._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      classes: null == classes
          ? _value._classes
          : classes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      applied: null == applied
          ? _value.applied
          : applied // ignore: cast_nullable_to_non_nullable
              as bool,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorJobDtoImpl implements _TutorJobDto {
  const _$TutorJobDtoImpl(
      {this.id = '',
      @JsonKey(readValue: _title) this.title = '',
      @JsonKey(readValue: _price) this.pricePerHour = 0,
      @JsonKey(readValue: _frequency) this.frequency = '',
      @JsonKey(readValue: _start) this.start = '',
      @JsonKey(name: 'subjects')
      final List<dynamic> subjects = const <dynamic>[],
      @JsonKey(name: 'school_classes')
      final List<dynamic> classes = const <dynamic>[],
      @JsonKey(readValue: _location) this.location = '',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(readValue: _applied) this.applied = false,
      @JsonKey(readValue: _summary) this.summary = ''})
      : _subjects = subjects,
        _classes = classes;

  factory _$TutorJobDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorJobDtoImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(readValue: _title)
  final String title;
  @override
  @JsonKey(readValue: _price)
  final int pricePerHour;
  @override
  @JsonKey(readValue: _frequency)
  final String frequency;
  @override
  @JsonKey(readValue: _start)
  final String start;
  final List<dynamic> _subjects;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  final List<dynamic> _classes;
  @override
  @JsonKey(name: 'school_classes')
  List<dynamic> get classes {
    if (_classes is EqualUnmodifiableListView) return _classes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_classes);
  }

  @override
  @JsonKey(readValue: _location)
  final String location;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(readValue: _applied)
  final bool applied;
  @override
  @JsonKey(readValue: _summary)
  final String summary;

  @override
  String toString() {
    return 'TutorJobDto(id: $id, title: $title, pricePerHour: $pricePerHour, frequency: $frequency, start: $start, subjects: $subjects, classes: $classes, location: $location, createdAt: $createdAt, applied: $applied, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorJobDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.start, start) || other.start == start) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            const DeepCollectionEquality().equals(other._classes, _classes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.applied, applied) || other.applied == applied) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      pricePerHour,
      frequency,
      start,
      const DeepCollectionEquality().hash(_subjects),
      const DeepCollectionEquality().hash(_classes),
      location,
      createdAt,
      applied,
      summary);

  /// Create a copy of TutorJobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorJobDtoImplCopyWith<_$TutorJobDtoImpl> get copyWith =>
      __$$TutorJobDtoImplCopyWithImpl<_$TutorJobDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorJobDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorJobDto implements TutorJobDto {
  const factory _TutorJobDto(
      {final String id,
      @JsonKey(readValue: _title) final String title,
      @JsonKey(readValue: _price) final int pricePerHour,
      @JsonKey(readValue: _frequency) final String frequency,
      @JsonKey(readValue: _start) final String start,
      @JsonKey(name: 'subjects') final List<dynamic> subjects,
      @JsonKey(name: 'school_classes') final List<dynamic> classes,
      @JsonKey(readValue: _location) final String location,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(readValue: _applied) final bool applied,
      @JsonKey(readValue: _summary) final String summary}) = _$TutorJobDtoImpl;

  factory _TutorJobDto.fromJson(Map<String, dynamic> json) =
      _$TutorJobDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: _title)
  String get title;
  @override
  @JsonKey(readValue: _price)
  int get pricePerHour;
  @override
  @JsonKey(readValue: _frequency)
  String get frequency;
  @override
  @JsonKey(readValue: _start)
  String get start;
  @override
  @JsonKey(name: 'subjects')
  List<dynamic> get subjects;
  @override
  @JsonKey(name: 'school_classes')
  List<dynamic> get classes;
  @override
  @JsonKey(readValue: _location)
  String get location;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(readValue: _applied)
  bool get applied;
  @override
  @JsonKey(readValue: _summary)
  String get summary;

  /// Create a copy of TutorJobDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorJobDtoImplCopyWith<_$TutorJobDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
