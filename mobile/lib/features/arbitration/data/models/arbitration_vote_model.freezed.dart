// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arbitration_vote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArbitrationVoteModel {

 String get id; String get caseId; String get voterUserId; ArbitrationDecision get decision; DateTime get createdAt; String? get comment;
/// Create a copy of ArbitrationVoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArbitrationVoteModelCopyWith<ArbitrationVoteModel> get copyWith => _$ArbitrationVoteModelCopyWithImpl<ArbitrationVoteModel>(this as ArbitrationVoteModel, _$identity);

  /// Serializes this ArbitrationVoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArbitrationVoteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.voterUserId, voterUserId) || other.voterUserId == voterUserId)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,voterUserId,decision,createdAt,comment);

@override
String toString() {
  return 'ArbitrationVoteModel(id: $id, caseId: $caseId, voterUserId: $voterUserId, decision: $decision, createdAt: $createdAt, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $ArbitrationVoteModelCopyWith<$Res>  {
  factory $ArbitrationVoteModelCopyWith(ArbitrationVoteModel value, $Res Function(ArbitrationVoteModel) _then) = _$ArbitrationVoteModelCopyWithImpl;
@useResult
$Res call({
 String id, String caseId, String voterUserId, ArbitrationDecision decision, DateTime createdAt, String? comment
});




}
/// @nodoc
class _$ArbitrationVoteModelCopyWithImpl<$Res>
    implements $ArbitrationVoteModelCopyWith<$Res> {
  _$ArbitrationVoteModelCopyWithImpl(this._self, this._then);

  final ArbitrationVoteModel _self;
  final $Res Function(ArbitrationVoteModel) _then;

/// Create a copy of ArbitrationVoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? caseId = null,Object? voterUserId = null,Object? decision = null,Object? createdAt = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,voterUserId: null == voterUserId ? _self.voterUserId : voterUserId // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ArbitrationDecision,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArbitrationVoteModel].
extension ArbitrationVoteModelPatterns on ArbitrationVoteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArbitrationVoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArbitrationVoteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArbitrationVoteModel value)  $default,){
final _that = this;
switch (_that) {
case _ArbitrationVoteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArbitrationVoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _ArbitrationVoteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String caseId,  String voterUserId,  ArbitrationDecision decision,  DateTime createdAt,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArbitrationVoteModel() when $default != null:
return $default(_that.id,_that.caseId,_that.voterUserId,_that.decision,_that.createdAt,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String caseId,  String voterUserId,  ArbitrationDecision decision,  DateTime createdAt,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _ArbitrationVoteModel():
return $default(_that.id,_that.caseId,_that.voterUserId,_that.decision,_that.createdAt,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String caseId,  String voterUserId,  ArbitrationDecision decision,  DateTime createdAt,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _ArbitrationVoteModel() when $default != null:
return $default(_that.id,_that.caseId,_that.voterUserId,_that.decision,_that.createdAt,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArbitrationVoteModel extends ArbitrationVoteModel {
  const _ArbitrationVoteModel({required this.id, required this.caseId, required this.voterUserId, required this.decision, required this.createdAt, this.comment}): super._();
  factory _ArbitrationVoteModel.fromJson(Map<String, dynamic> json) => _$ArbitrationVoteModelFromJson(json);

@override final  String id;
@override final  String caseId;
@override final  String voterUserId;
@override final  ArbitrationDecision decision;
@override final  DateTime createdAt;
@override final  String? comment;

/// Create a copy of ArbitrationVoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArbitrationVoteModelCopyWith<_ArbitrationVoteModel> get copyWith => __$ArbitrationVoteModelCopyWithImpl<_ArbitrationVoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArbitrationVoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArbitrationVoteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.voterUserId, voterUserId) || other.voterUserId == voterUserId)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,voterUserId,decision,createdAt,comment);

@override
String toString() {
  return 'ArbitrationVoteModel(id: $id, caseId: $caseId, voterUserId: $voterUserId, decision: $decision, createdAt: $createdAt, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ArbitrationVoteModelCopyWith<$Res> implements $ArbitrationVoteModelCopyWith<$Res> {
  factory _$ArbitrationVoteModelCopyWith(_ArbitrationVoteModel value, $Res Function(_ArbitrationVoteModel) _then) = __$ArbitrationVoteModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String caseId, String voterUserId, ArbitrationDecision decision, DateTime createdAt, String? comment
});




}
/// @nodoc
class __$ArbitrationVoteModelCopyWithImpl<$Res>
    implements _$ArbitrationVoteModelCopyWith<$Res> {
  __$ArbitrationVoteModelCopyWithImpl(this._self, this._then);

  final _ArbitrationVoteModel _self;
  final $Res Function(_ArbitrationVoteModel) _then;

/// Create a copy of ArbitrationVoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? caseId = null,Object? voterUserId = null,Object? decision = null,Object? createdAt = null,Object? comment = freezed,}) {
  return _then(_ArbitrationVoteModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,voterUserId: null == voterUserId ? _self.voterUserId : voterUserId // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ArbitrationDecision,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
