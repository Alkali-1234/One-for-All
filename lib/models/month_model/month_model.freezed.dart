// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Month {
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;

  /// The list is actually unnecessary. (i forgor and it's too late to change it)
  List<Map<int, List<MabPost>>> get daysList =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthCopyWith<Month> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthCopyWith<$Res> {
  factory $MonthCopyWith(Month value, $Res Function(Month) then) =
      _$MonthCopyWithImpl<$Res, Month>;
  @useResult
  $Res call({int month, int year, List<Map<int, List<MabPost>>> daysList});
}

/// @nodoc
class _$MonthCopyWithImpl<$Res, $Val extends Month>
    implements $MonthCopyWith<$Res> {
  _$MonthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? daysList = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      daysList: null == daysList
          ? _value.daysList
          : daysList // ignore: cast_nullable_to_non_nullable
              as List<Map<int, List<MabPost>>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthImplCopyWith<$Res> implements $MonthCopyWith<$Res> {
  factory _$$MonthImplCopyWith(
          _$MonthImpl value, $Res Function(_$MonthImpl) then) =
      __$$MonthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int month, int year, List<Map<int, List<MabPost>>> daysList});
}

/// @nodoc
class __$$MonthImplCopyWithImpl<$Res>
    extends _$MonthCopyWithImpl<$Res, _$MonthImpl>
    implements _$$MonthImplCopyWith<$Res> {
  __$$MonthImplCopyWithImpl(
      _$MonthImpl _value, $Res Function(_$MonthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? year = null,
    Object? daysList = null,
  }) {
    return _then(_$MonthImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      daysList: null == daysList
          ? _value._daysList
          : daysList // ignore: cast_nullable_to_non_nullable
              as List<Map<int, List<MabPost>>>,
    ));
  }
}

/// @nodoc

class _$MonthImpl with DiagnosticableTreeMixin implements _Month {
  const _$MonthImpl(
      {required this.month,
      required this.year,
      required final List<Map<int, List<MabPost>>> daysList})
      : _daysList = daysList;

  @override
  final int month;
  @override
  final int year;

  /// The list is actually unnecessary. (i forgor and it's too late to change it)
  final List<Map<int, List<MabPost>>> _daysList;

  /// The list is actually unnecessary. (i forgor and it's too late to change it)
  @override
  List<Map<int, List<MabPost>>> get daysList {
    if (_daysList is EqualUnmodifiableListView) return _daysList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysList);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Month(month: $month, year: $year, daysList: $daysList)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Month'))
      ..add(DiagnosticsProperty('month', month))
      ..add(DiagnosticsProperty('year', year))
      ..add(DiagnosticsProperty('daysList', daysList));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(other._daysList, _daysList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, month, year, const DeepCollectionEquality().hash(_daysList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthImplCopyWith<_$MonthImpl> get copyWith =>
      __$$MonthImplCopyWithImpl<_$MonthImpl>(this, _$identity);
}

abstract class _Month implements Month {
  const factory _Month(
      {required final int month,
      required final int year,
      required final List<Map<int, List<MabPost>>> daysList}) = _$MonthImpl;

  @override
  int get month;
  @override
  int get year;
  @override

  /// The list is actually unnecessary. (i forgor and it's too late to change it)
  List<Map<int, List<MabPost>>> get daysList;
  @override
  @JsonKey(ignore: true)
  _$$MonthImplCopyWith<_$MonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
