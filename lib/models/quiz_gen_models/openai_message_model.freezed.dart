// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'openai_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OpenAIMessageModel {
  String get message => throw _privateConstructorUsedError;
  OpenAIMessageRoles get role => throw _privateConstructorUsedError;
  List<String>? get imageURLs => throw _privateConstructorUsedError;
  List<String>? get imageFileIDs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OpenAIMessageModelCopyWith<OpenAIMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenAIMessageModelCopyWith<$Res> {
  factory $OpenAIMessageModelCopyWith(
          OpenAIMessageModel value, $Res Function(OpenAIMessageModel) then) =
      _$OpenAIMessageModelCopyWithImpl<$Res, OpenAIMessageModel>;
  @useResult
  $Res call(
      {String message,
      OpenAIMessageRoles role,
      List<String>? imageURLs,
      List<String>? imageFileIDs});
}

/// @nodoc
class _$OpenAIMessageModelCopyWithImpl<$Res, $Val extends OpenAIMessageModel>
    implements $OpenAIMessageModelCopyWith<$Res> {
  _$OpenAIMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? role = null,
    Object? imageURLs = freezed,
    Object? imageFileIDs = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as OpenAIMessageRoles,
      imageURLs: freezed == imageURLs
          ? _value.imageURLs
          : imageURLs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageFileIDs: freezed == imageFileIDs
          ? _value.imageFileIDs
          : imageFileIDs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OpenAIMessageModelImplCopyWith<$Res>
    implements $OpenAIMessageModelCopyWith<$Res> {
  factory _$$OpenAIMessageModelImplCopyWith(_$OpenAIMessageModelImpl value,
          $Res Function(_$OpenAIMessageModelImpl) then) =
      __$$OpenAIMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      OpenAIMessageRoles role,
      List<String>? imageURLs,
      List<String>? imageFileIDs});
}

/// @nodoc
class __$$OpenAIMessageModelImplCopyWithImpl<$Res>
    extends _$OpenAIMessageModelCopyWithImpl<$Res, _$OpenAIMessageModelImpl>
    implements _$$OpenAIMessageModelImplCopyWith<$Res> {
  __$$OpenAIMessageModelImplCopyWithImpl(_$OpenAIMessageModelImpl _value,
      $Res Function(_$OpenAIMessageModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? role = null,
    Object? imageURLs = freezed,
    Object? imageFileIDs = freezed,
  }) {
    return _then(_$OpenAIMessageModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as OpenAIMessageRoles,
      imageURLs: freezed == imageURLs
          ? _value._imageURLs
          : imageURLs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageFileIDs: freezed == imageFileIDs
          ? _value._imageFileIDs
          : imageFileIDs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$OpenAIMessageModelImpl
    with DiagnosticableTreeMixin
    implements _OpenAIMessageModel {
  const _$OpenAIMessageModelImpl(
      {required this.message,
      required this.role,
      final List<String>? imageURLs,
      final List<String>? imageFileIDs})
      : _imageURLs = imageURLs,
        _imageFileIDs = imageFileIDs;

  @override
  final String message;
  @override
  final OpenAIMessageRoles role;
  final List<String>? _imageURLs;
  @override
  List<String>? get imageURLs {
    final value = _imageURLs;
    if (value == null) return null;
    if (_imageURLs is EqualUnmodifiableListView) return _imageURLs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _imageFileIDs;
  @override
  List<String>? get imageFileIDs {
    final value = _imageFileIDs;
    if (value == null) return null;
    if (_imageFileIDs is EqualUnmodifiableListView) return _imageFileIDs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'OpenAIMessageModel(message: $message, role: $role, imageURLs: $imageURLs, imageFileIDs: $imageFileIDs)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'OpenAIMessageModel'))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('imageURLs', imageURLs))
      ..add(DiagnosticsProperty('imageFileIDs', imageFileIDs));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenAIMessageModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality()
                .equals(other._imageURLs, _imageURLs) &&
            const DeepCollectionEquality()
                .equals(other._imageFileIDs, _imageFileIDs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      role,
      const DeepCollectionEquality().hash(_imageURLs),
      const DeepCollectionEquality().hash(_imageFileIDs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenAIMessageModelImplCopyWith<_$OpenAIMessageModelImpl> get copyWith =>
      __$$OpenAIMessageModelImplCopyWithImpl<_$OpenAIMessageModelImpl>(
          this, _$identity);
}

abstract class _OpenAIMessageModel implements OpenAIMessageModel {
  const factory _OpenAIMessageModel(
      {required final String message,
      required final OpenAIMessageRoles role,
      final List<String>? imageURLs,
      final List<String>? imageFileIDs}) = _$OpenAIMessageModelImpl;

  @override
  String get message;
  @override
  OpenAIMessageRoles get role;
  @override
  List<String>? get imageURLs;
  @override
  List<String>? get imageFileIDs;
  @override
  @JsonKey(ignore: true)
  _$$OpenAIMessageModelImplCopyWith<_$OpenAIMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
