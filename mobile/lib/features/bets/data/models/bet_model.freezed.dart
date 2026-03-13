// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BetModel {

 String get id; String get goalId; String get userId; BetSide get side; double get amount; DateTime get createdAt;
/// Create a copy of BetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetModelCopyWith<BetModel> get copyWith => _$BetModelCopyWithImpl<BetModel>(this as BetModel, _$identity);

  /// Serializes this BetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.side, side) || other.side == side)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,userId,side,amount,createdAt);

@override
String toString() {
  return 'BetModel(id: $id, goalId: $goalId, userId: $userId, side: $side, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BetModelCopyWith<$Res>  {
  factory $BetModelCopyWith(BetModel value, $Res Function(BetModel) _then) = _$BetModelCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, String userId, BetSide side, double amount, DateTime createdAt
});




}
/// @nodoc
class _$BetModelCopyWithImpl<$Res>
    implements $BetModelCopyWith<$Res> {
  _$BetModelCopyWithImpl(this._self, this._then);

  final BetModel _self;
  final $Res Function(BetModel) _then;

/// Create a copy of BetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? userId = null,Object? side = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BetSide,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BetModel].
extension BetModelPatterns on BetModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetModel value)  $default,){
final _that = this;
switch (_that) {
case _BetModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetModel value)?  $default,){
final _that = this;
switch (_that) {
case _BetModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  String userId,  BetSide side,  double amount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetModel() when $default != null:
return $default(_that.id,_that.goalId,_that.userId,_that.side,_that.amount,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  String userId,  BetSide side,  double amount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BetModel():
return $default(_that.id,_that.goalId,_that.userId,_that.side,_that.amount,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  String userId,  BetSide side,  double amount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BetModel() when $default != null:
return $default(_that.id,_that.goalId,_that.userId,_that.side,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BetModel extends BetModel {
  const _BetModel({required this.id, required this.goalId, required this.userId, required this.side, required this.amount, required this.createdAt}): super._();
  factory _BetModel.fromJson(Map<String, dynamic> json) => _$BetModelFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  String userId;
@override final  BetSide side;
@override final  double amount;
@override final  DateTime createdAt;

/// Create a copy of BetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetModelCopyWith<_BetModel> get copyWith => __$BetModelCopyWithImpl<_BetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.side, side) || other.side == side)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,userId,side,amount,createdAt);

@override
String toString() {
  return 'BetModel(id: $id, goalId: $goalId, userId: $userId, side: $side, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BetModelCopyWith<$Res> implements $BetModelCopyWith<$Res> {
  factory _$BetModelCopyWith(_BetModel value, $Res Function(_BetModel) _then) = __$BetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, String userId, BetSide side, double amount, DateTime createdAt
});




}
/// @nodoc
class __$BetModelCopyWithImpl<$Res>
    implements _$BetModelCopyWith<$Res> {
  __$BetModelCopyWithImpl(this._self, this._then);

  final _BetModel _self;
  final $Res Function(_BetModel) _then;

/// Create a copy of BetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? userId = null,Object? side = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_BetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BetSide,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
