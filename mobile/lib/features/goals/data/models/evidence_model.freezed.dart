// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evidence_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvidenceModel {

 String get id; String get goalId; String get submittedByUserId; String get title; String get description; DateTime get createdAt; String? get attachmentUrl;
/// Create a copy of EvidenceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceModelCopyWith<EvidenceModel> get copyWith => _$EvidenceModelCopyWithImpl<EvidenceModel>(this as EvidenceModel, _$identity);

  /// Serializes this EvidenceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,submittedByUserId,title,description,createdAt,attachmentUrl);

@override
String toString() {
  return 'EvidenceModel(id: $id, goalId: $goalId, submittedByUserId: $submittedByUserId, title: $title, description: $description, createdAt: $createdAt, attachmentUrl: $attachmentUrl)';
}


}

/// @nodoc
abstract mixin class $EvidenceModelCopyWith<$Res>  {
  factory $EvidenceModelCopyWith(EvidenceModel value, $Res Function(EvidenceModel) _then) = _$EvidenceModelCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, String submittedByUserId, String title, String description, DateTime createdAt, String? attachmentUrl
});




}
/// @nodoc
class _$EvidenceModelCopyWithImpl<$Res>
    implements $EvidenceModelCopyWith<$Res> {
  _$EvidenceModelCopyWithImpl(this._self, this._then);

  final EvidenceModel _self;
  final $Res Function(EvidenceModel) _then;

/// Create a copy of EvidenceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? submittedByUserId = null,Object? title = null,Object? description = null,Object? createdAt = null,Object? attachmentUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,submittedByUserId: null == submittedByUserId ? _self.submittedByUserId : submittedByUserId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceModel].
extension EvidenceModelPatterns on EvidenceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceModel value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceModel value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  String submittedByUserId,  String title,  String description,  DateTime createdAt,  String? attachmentUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceModel() when $default != null:
return $default(_that.id,_that.goalId,_that.submittedByUserId,_that.title,_that.description,_that.createdAt,_that.attachmentUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  String submittedByUserId,  String title,  String description,  DateTime createdAt,  String? attachmentUrl)  $default,) {final _that = this;
switch (_that) {
case _EvidenceModel():
return $default(_that.id,_that.goalId,_that.submittedByUserId,_that.title,_that.description,_that.createdAt,_that.attachmentUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  String submittedByUserId,  String title,  String description,  DateTime createdAt,  String? attachmentUrl)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceModel() when $default != null:
return $default(_that.id,_that.goalId,_that.submittedByUserId,_that.title,_that.description,_that.createdAt,_that.attachmentUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EvidenceModel extends EvidenceModel {
  const _EvidenceModel({required this.id, required this.goalId, required this.submittedByUserId, required this.title, required this.description, required this.createdAt, this.attachmentUrl}): super._();
  factory _EvidenceModel.fromJson(Map<String, dynamic> json) => _$EvidenceModelFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  String submittedByUserId;
@override final  String title;
@override final  String description;
@override final  DateTime createdAt;
@override final  String? attachmentUrl;

/// Create a copy of EvidenceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceModelCopyWith<_EvidenceModel> get copyWith => __$EvidenceModelCopyWithImpl<_EvidenceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.submittedByUserId, submittedByUserId) || other.submittedByUserId == submittedByUserId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,submittedByUserId,title,description,createdAt,attachmentUrl);

@override
String toString() {
  return 'EvidenceModel(id: $id, goalId: $goalId, submittedByUserId: $submittedByUserId, title: $title, description: $description, createdAt: $createdAt, attachmentUrl: $attachmentUrl)';
}


}

/// @nodoc
abstract mixin class _$EvidenceModelCopyWith<$Res> implements $EvidenceModelCopyWith<$Res> {
  factory _$EvidenceModelCopyWith(_EvidenceModel value, $Res Function(_EvidenceModel) _then) = __$EvidenceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, String submittedByUserId, String title, String description, DateTime createdAt, String? attachmentUrl
});




}
/// @nodoc
class __$EvidenceModelCopyWithImpl<$Res>
    implements _$EvidenceModelCopyWith<$Res> {
  __$EvidenceModelCopyWithImpl(this._self, this._then);

  final _EvidenceModel _self;
  final $Res Function(_EvidenceModel) _then;

/// Create a copy of EvidenceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? submittedByUserId = null,Object? title = null,Object? description = null,Object? createdAt = null,Object? attachmentUrl = freezed,}) {
  return _then(_EvidenceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,submittedByUserId: null == submittedByUserId ? _self.submittedByUserId : submittedByUserId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
