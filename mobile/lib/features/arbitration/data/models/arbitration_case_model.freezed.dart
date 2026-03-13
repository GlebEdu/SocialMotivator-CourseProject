// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arbitration_case_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArbitrationCaseModel {

 String get id; String get goalId; String get createdByUserId; List<String> get arbitratorUserIds; String get reason; ArbitrationDecision get decision; DateTime get createdAt; DateTime? get resolvedAt;
/// Create a copy of ArbitrationCaseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArbitrationCaseModelCopyWith<ArbitrationCaseModel> get copyWith => _$ArbitrationCaseModelCopyWithImpl<ArbitrationCaseModel>(this as ArbitrationCaseModel, _$identity);

  /// Serializes this ArbitrationCaseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArbitrationCaseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.arbitratorUserIds, arbitratorUserIds)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,createdByUserId,const DeepCollectionEquality().hash(arbitratorUserIds),reason,decision,createdAt,resolvedAt);

@override
String toString() {
  return 'ArbitrationCaseModel(id: $id, goalId: $goalId, createdByUserId: $createdByUserId, arbitratorUserIds: $arbitratorUserIds, reason: $reason, decision: $decision, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $ArbitrationCaseModelCopyWith<$Res>  {
  factory $ArbitrationCaseModelCopyWith(ArbitrationCaseModel value, $Res Function(ArbitrationCaseModel) _then) = _$ArbitrationCaseModelCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, String createdByUserId, List<String> arbitratorUserIds, String reason, ArbitrationDecision decision, DateTime createdAt, DateTime? resolvedAt
});




}
/// @nodoc
class _$ArbitrationCaseModelCopyWithImpl<$Res>
    implements $ArbitrationCaseModelCopyWith<$Res> {
  _$ArbitrationCaseModelCopyWithImpl(this._self, this._then);

  final ArbitrationCaseModel _self;
  final $Res Function(ArbitrationCaseModel) _then;

/// Create a copy of ArbitrationCaseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? createdByUserId = null,Object? arbitratorUserIds = null,Object? reason = null,Object? decision = null,Object? createdAt = null,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,arbitratorUserIds: null == arbitratorUserIds ? _self.arbitratorUserIds : arbitratorUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ArbitrationDecision,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArbitrationCaseModel].
extension ArbitrationCaseModelPatterns on ArbitrationCaseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArbitrationCaseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArbitrationCaseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArbitrationCaseModel value)  $default,){
final _that = this;
switch (_that) {
case _ArbitrationCaseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArbitrationCaseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ArbitrationCaseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  String createdByUserId,  List<String> arbitratorUserIds,  String reason,  ArbitrationDecision decision,  DateTime createdAt,  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArbitrationCaseModel() when $default != null:
return $default(_that.id,_that.goalId,_that.createdByUserId,_that.arbitratorUserIds,_that.reason,_that.decision,_that.createdAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  String createdByUserId,  List<String> arbitratorUserIds,  String reason,  ArbitrationDecision decision,  DateTime createdAt,  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _ArbitrationCaseModel():
return $default(_that.id,_that.goalId,_that.createdByUserId,_that.arbitratorUserIds,_that.reason,_that.decision,_that.createdAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  String createdByUserId,  List<String> arbitratorUserIds,  String reason,  ArbitrationDecision decision,  DateTime createdAt,  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _ArbitrationCaseModel() when $default != null:
return $default(_that.id,_that.goalId,_that.createdByUserId,_that.arbitratorUserIds,_that.reason,_that.decision,_that.createdAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArbitrationCaseModel extends ArbitrationCaseModel {
  const _ArbitrationCaseModel({required this.id, required this.goalId, required this.createdByUserId, required final  List<String> arbitratorUserIds, required this.reason, required this.decision, required this.createdAt, this.resolvedAt}): _arbitratorUserIds = arbitratorUserIds,super._();
  factory _ArbitrationCaseModel.fromJson(Map<String, dynamic> json) => _$ArbitrationCaseModelFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  String createdByUserId;
 final  List<String> _arbitratorUserIds;
@override List<String> get arbitratorUserIds {
  if (_arbitratorUserIds is EqualUnmodifiableListView) return _arbitratorUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arbitratorUserIds);
}

@override final  String reason;
@override final  ArbitrationDecision decision;
@override final  DateTime createdAt;
@override final  DateTime? resolvedAt;

/// Create a copy of ArbitrationCaseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArbitrationCaseModelCopyWith<_ArbitrationCaseModel> get copyWith => __$ArbitrationCaseModelCopyWithImpl<_ArbitrationCaseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArbitrationCaseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArbitrationCaseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._arbitratorUserIds, _arbitratorUserIds)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,createdByUserId,const DeepCollectionEquality().hash(_arbitratorUserIds),reason,decision,createdAt,resolvedAt);

@override
String toString() {
  return 'ArbitrationCaseModel(id: $id, goalId: $goalId, createdByUserId: $createdByUserId, arbitratorUserIds: $arbitratorUserIds, reason: $reason, decision: $decision, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$ArbitrationCaseModelCopyWith<$Res> implements $ArbitrationCaseModelCopyWith<$Res> {
  factory _$ArbitrationCaseModelCopyWith(_ArbitrationCaseModel value, $Res Function(_ArbitrationCaseModel) _then) = __$ArbitrationCaseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, String createdByUserId, List<String> arbitratorUserIds, String reason, ArbitrationDecision decision, DateTime createdAt, DateTime? resolvedAt
});




}
/// @nodoc
class __$ArbitrationCaseModelCopyWithImpl<$Res>
    implements _$ArbitrationCaseModelCopyWith<$Res> {
  __$ArbitrationCaseModelCopyWithImpl(this._self, this._then);

  final _ArbitrationCaseModel _self;
  final $Res Function(_ArbitrationCaseModel) _then;

/// Create a copy of ArbitrationCaseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? createdByUserId = null,Object? arbitratorUserIds = null,Object? reason = null,Object? decision = null,Object? createdAt = null,Object? resolvedAt = freezed,}) {
  return _then(_ArbitrationCaseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,arbitratorUserIds: null == arbitratorUserIds ? _self._arbitratorUserIds : arbitratorUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ArbitrationDecision,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
