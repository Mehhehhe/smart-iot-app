// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_definitions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError('It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DeviceVal {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double field0) single,
    required TResult Function(MultiVal field0) three,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double field0)? single,
    TResult? Function(MultiVal field0)? three,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double field0)? single,
    TResult Function(MultiVal field0)? three,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceVal_Single value) single,
    required TResult Function(DeviceVal_Three value) three,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceVal_Single value)? single,
    TResult? Function(DeviceVal_Three value)? three,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceVal_Single value)? single,
    TResult Function(DeviceVal_Three value)? three,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceValCopyWith<$Res> {
  factory $DeviceValCopyWith(DeviceVal value, $Res Function(DeviceVal) then) = _$DeviceValCopyWithImpl<$Res, DeviceVal>;
}

/// @nodoc
class _$DeviceValCopyWithImpl<$Res, $Val extends DeviceVal> implements $DeviceValCopyWith<$Res> {
  _$DeviceValCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DeviceVal_SingleCopyWith<$Res> {
  factory _$$DeviceVal_SingleCopyWith(_$DeviceVal_Single value, $Res Function(_$DeviceVal_Single) then) = __$$DeviceVal_SingleCopyWithImpl<$Res>;
  @useResult
  $Res call({double field0});
}

/// @nodoc
class __$$DeviceVal_SingleCopyWithImpl<$Res> extends _$DeviceValCopyWithImpl<$Res, _$DeviceVal_Single> implements _$$DeviceVal_SingleCopyWith<$Res> {
  __$$DeviceVal_SingleCopyWithImpl(_$DeviceVal_Single _value, $Res Function(_$DeviceVal_Single) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$DeviceVal_Single(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$DeviceVal_Single implements DeviceVal_Single {
  const _$DeviceVal_Single(this.field0);

  @override
  final double field0;

  @override
  String toString() {
    return 'DeviceVal.single(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$DeviceVal_Single && (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceVal_SingleCopyWith<_$DeviceVal_Single> get copyWith => __$$DeviceVal_SingleCopyWithImpl<_$DeviceVal_Single>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double field0) single,
    required TResult Function(MultiVal field0) three,
  }) {
    return single(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double field0)? single,
    TResult? Function(MultiVal field0)? three,
  }) {
    return single?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double field0)? single,
    TResult Function(MultiVal field0)? three,
    required TResult orElse(),
  }) {
    if (single != null) {
      return single(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceVal_Single value) single,
    required TResult Function(DeviceVal_Three value) three,
  }) {
    return single(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceVal_Single value)? single,
    TResult? Function(DeviceVal_Three value)? three,
  }) {
    return single?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceVal_Single value)? single,
    TResult Function(DeviceVal_Three value)? three,
    required TResult orElse(),
  }) {
    if (single != null) {
      return single(this);
    }
    return orElse();
  }
}

abstract class DeviceVal_Single implements DeviceVal {
  const factory DeviceVal_Single(final double field0) = _$DeviceVal_Single;

  @override
  double get field0;
  @JsonKey(ignore: true)
  _$$DeviceVal_SingleCopyWith<_$DeviceVal_Single> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeviceVal_ThreeCopyWith<$Res> {
  factory _$$DeviceVal_ThreeCopyWith(_$DeviceVal_Three value, $Res Function(_$DeviceVal_Three) then) = __$$DeviceVal_ThreeCopyWithImpl<$Res>;
  @useResult
  $Res call({MultiVal field0});
}

/// @nodoc
class __$$DeviceVal_ThreeCopyWithImpl<$Res> extends _$DeviceValCopyWithImpl<$Res, _$DeviceVal_Three> implements _$$DeviceVal_ThreeCopyWith<$Res> {
  __$$DeviceVal_ThreeCopyWithImpl(_$DeviceVal_Three _value, $Res Function(_$DeviceVal_Three) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$DeviceVal_Three(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as MultiVal,
    ));
  }
}

/// @nodoc

class _$DeviceVal_Three implements DeviceVal_Three {
  const _$DeviceVal_Three(this.field0);

  @override
  final MultiVal field0;

  @override
  String toString() {
    return 'DeviceVal.three(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$DeviceVal_Three && (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceVal_ThreeCopyWith<_$DeviceVal_Three> get copyWith => __$$DeviceVal_ThreeCopyWithImpl<_$DeviceVal_Three>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double field0) single,
    required TResult Function(MultiVal field0) three,
  }) {
    return three(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double field0)? single,
    TResult? Function(MultiVal field0)? three,
  }) {
    return three?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double field0)? single,
    TResult Function(MultiVal field0)? three,
    required TResult orElse(),
  }) {
    if (three != null) {
      return three(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DeviceVal_Single value) single,
    required TResult Function(DeviceVal_Three value) three,
  }) {
    return three(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DeviceVal_Single value)? single,
    TResult? Function(DeviceVal_Three value)? three,
  }) {
    return three?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DeviceVal_Single value)? single,
    TResult Function(DeviceVal_Three value)? three,
    required TResult orElse(),
  }) {
    if (three != null) {
      return three(this);
    }
    return orElse();
  }
}

abstract class DeviceVal_Three implements DeviceVal {
  const factory DeviceVal_Three(final MultiVal field0) = _$DeviceVal_Three;

  @override
  MultiVal get field0;
  @JsonKey(ignore: true)
  _$$DeviceVal_ThreeCopyWith<_$DeviceVal_Three> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MaReturnTypes {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Float64List field0) single,
    required TResult Function(TripleVec field0) triple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Float64List field0)? single,
    TResult? Function(TripleVec field0)? triple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Float64List field0)? single,
    TResult Function(TripleVec field0)? triple,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MaReturnTypes_Single value) single,
    required TResult Function(MaReturnTypes_Triple value) triple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MaReturnTypes_Single value)? single,
    TResult? Function(MaReturnTypes_Triple value)? triple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MaReturnTypes_Single value)? single,
    TResult Function(MaReturnTypes_Triple value)? triple,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaReturnTypesCopyWith<$Res> {
  factory $MaReturnTypesCopyWith(MaReturnTypes value, $Res Function(MaReturnTypes) then) = _$MaReturnTypesCopyWithImpl<$Res, MaReturnTypes>;
}

/// @nodoc
class _$MaReturnTypesCopyWithImpl<$Res, $Val extends MaReturnTypes> implements $MaReturnTypesCopyWith<$Res> {
  _$MaReturnTypesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MaReturnTypes_SingleCopyWith<$Res> {
  factory _$$MaReturnTypes_SingleCopyWith(_$MaReturnTypes_Single value, $Res Function(_$MaReturnTypes_Single) then) = __$$MaReturnTypes_SingleCopyWithImpl<$Res>;
  @useResult
  $Res call({Float64List field0});
}

/// @nodoc
class __$$MaReturnTypes_SingleCopyWithImpl<$Res> extends _$MaReturnTypesCopyWithImpl<$Res, _$MaReturnTypes_Single> implements _$$MaReturnTypes_SingleCopyWith<$Res> {
  __$$MaReturnTypes_SingleCopyWithImpl(_$MaReturnTypes_Single _value, $Res Function(_$MaReturnTypes_Single) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MaReturnTypes_Single(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Float64List,
    ));
  }
}

/// @nodoc

class _$MaReturnTypes_Single implements MaReturnTypes_Single {
  const _$MaReturnTypes_Single(this.field0);

  @override
  final Float64List field0;

  @override
  String toString() {
    return 'MaReturnTypes.single(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$MaReturnTypes_Single && const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MaReturnTypes_SingleCopyWith<_$MaReturnTypes_Single> get copyWith => __$$MaReturnTypes_SingleCopyWithImpl<_$MaReturnTypes_Single>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Float64List field0) single,
    required TResult Function(TripleVec field0) triple,
  }) {
    return single(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Float64List field0)? single,
    TResult? Function(TripleVec field0)? triple,
  }) {
    return single?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Float64List field0)? single,
    TResult Function(TripleVec field0)? triple,
    required TResult orElse(),
  }) {
    if (single != null) {
      return single(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MaReturnTypes_Single value) single,
    required TResult Function(MaReturnTypes_Triple value) triple,
  }) {
    return single(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MaReturnTypes_Single value)? single,
    TResult? Function(MaReturnTypes_Triple value)? triple,
  }) {
    return single?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MaReturnTypes_Single value)? single,
    TResult Function(MaReturnTypes_Triple value)? triple,
    required TResult orElse(),
  }) {
    if (single != null) {
      return single(this);
    }
    return orElse();
  }
}

abstract class MaReturnTypes_Single implements MaReturnTypes {
  const factory MaReturnTypes_Single(final Float64List field0) = _$MaReturnTypes_Single;

  @override
  Float64List get field0;
  @JsonKey(ignore: true)
  _$$MaReturnTypes_SingleCopyWith<_$MaReturnTypes_Single> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MaReturnTypes_TripleCopyWith<$Res> {
  factory _$$MaReturnTypes_TripleCopyWith(_$MaReturnTypes_Triple value, $Res Function(_$MaReturnTypes_Triple) then) = __$$MaReturnTypes_TripleCopyWithImpl<$Res>;
  @useResult
  $Res call({TripleVec field0});
}

/// @nodoc
class __$$MaReturnTypes_TripleCopyWithImpl<$Res> extends _$MaReturnTypesCopyWithImpl<$Res, _$MaReturnTypes_Triple> implements _$$MaReturnTypes_TripleCopyWith<$Res> {
  __$$MaReturnTypes_TripleCopyWithImpl(_$MaReturnTypes_Triple _value, $Res Function(_$MaReturnTypes_Triple) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MaReturnTypes_Triple(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as TripleVec,
    ));
  }
}

/// @nodoc

class _$MaReturnTypes_Triple implements MaReturnTypes_Triple {
  const _$MaReturnTypes_Triple(this.field0);

  @override
  final TripleVec field0;

  @override
  String toString() {
    return 'MaReturnTypes.triple(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$MaReturnTypes_Triple && (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MaReturnTypes_TripleCopyWith<_$MaReturnTypes_Triple> get copyWith => __$$MaReturnTypes_TripleCopyWithImpl<_$MaReturnTypes_Triple>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Float64List field0) single,
    required TResult Function(TripleVec field0) triple,
  }) {
    return triple(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Float64List field0)? single,
    TResult? Function(TripleVec field0)? triple,
  }) {
    return triple?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Float64List field0)? single,
    TResult Function(TripleVec field0)? triple,
    required TResult orElse(),
  }) {
    if (triple != null) {
      return triple(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MaReturnTypes_Single value) single,
    required TResult Function(MaReturnTypes_Triple value) triple,
  }) {
    return triple(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MaReturnTypes_Single value)? single,
    TResult? Function(MaReturnTypes_Triple value)? triple,
  }) {
    return triple?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MaReturnTypes_Single value)? single,
    TResult Function(MaReturnTypes_Triple value)? triple,
    required TResult orElse(),
  }) {
    if (triple != null) {
      return triple(this);
    }
    return orElse();
  }
}

abstract class MaReturnTypes_Triple implements MaReturnTypes {
  const factory MaReturnTypes_Triple(final TripleVec field0) = _$MaReturnTypes_Triple;

  @override
  TripleVec get field0;
  @JsonKey(ignore: true)
  _$$MaReturnTypes_TripleCopyWith<_$MaReturnTypes_Triple> get copyWith => throw _privateConstructorUsedError;
}
