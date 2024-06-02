// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NoteContent<T> _$NoteContentFromJson<T extends BaseContentTypes>(
    Map<String, dynamic> json, T Function(Object?) fromJsonT) {
  return _NoteContent<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$NoteContent<T extends BaseContentTypes> {
  T get content => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NoteContentCopyWith<T, NoteContent<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteContentCopyWith<T extends BaseContentTypes, $Res> {
  factory $NoteContentCopyWith(
          NoteContent<T> value, $Res Function(NoteContent<T>) then) =
      _$NoteContentCopyWithImpl<T, $Res, NoteContent<T>>;
  @useResult
  $Res call({T content});
}

/// @nodoc
class _$NoteContentCopyWithImpl<T extends BaseContentTypes, $Res,
    $Val extends NoteContent<T>> implements $NoteContentCopyWith<T, $Res> {
  _$NoteContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as T,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NoteContentImplCopyWith<T extends BaseContentTypes, $Res>
    implements $NoteContentCopyWith<T, $Res> {
  factory _$$NoteContentImplCopyWith(_$NoteContentImpl<T> value,
          $Res Function(_$NoteContentImpl<T>) then) =
      __$$NoteContentImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T content});
}

/// @nodoc
class __$$NoteContentImplCopyWithImpl<T extends BaseContentTypes, $Res>
    extends _$NoteContentCopyWithImpl<T, $Res, _$NoteContentImpl<T>>
    implements _$$NoteContentImplCopyWith<T, $Res> {
  __$$NoteContentImplCopyWithImpl(
      _$NoteContentImpl<T> _value, $Res Function(_$NoteContentImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$NoteContentImpl<T>(
      null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$NoteContentImpl<T extends BaseContentTypes>
    with DiagnosticableTreeMixin
    implements _NoteContent<T> {
  const _$NoteContentImpl(this.content);

  factory _$NoteContentImpl.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$$NoteContentImplFromJson(json, fromJsonT);

  @override
  final T content;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NoteContent<$T>(content: $content)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NoteContent<$T>'))
      ..add(DiagnosticsProperty('content', content));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteContentImpl<T> &&
            const DeepCollectionEquality().equals(other.content, content));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(content));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteContentImplCopyWith<T, _$NoteContentImpl<T>> get copyWith =>
      __$$NoteContentImplCopyWithImpl<T, _$NoteContentImpl<T>>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$NoteContentImplToJson<T>(this, toJsonT);
  }
}

abstract class _NoteContent<T extends BaseContentTypes>
    implements NoteContent<T> {
  const factory _NoteContent(final T content) = _$NoteContentImpl<T>;

  factory _NoteContent.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =
      _$NoteContentImpl<T>.fromJson;

  @override
  T get content;
  @override
  @JsonKey(ignore: true)
  _$$NoteContentImplCopyWith<T, _$NoteContentImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
