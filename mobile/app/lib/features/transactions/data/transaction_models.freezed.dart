// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateTransactionDto {

 String get categoryId; String get walletId; int get amount; String get title; String? get note; String? get occurredAt;
/// Create a copy of CreateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTransactionDtoCopyWith<CreateTransactionDto> get copyWith => _$CreateTransactionDtoCopyWithImpl<CreateTransactionDto>(this as CreateTransactionDto, _$identity);

  /// Serializes this CreateTransactionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTransactionDto&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,walletId,amount,title,note,occurredAt);

@override
String toString() {
  return 'CreateTransactionDto(categoryId: $categoryId, walletId: $walletId, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $CreateTransactionDtoCopyWith<$Res>  {
  factory $CreateTransactionDtoCopyWith(CreateTransactionDto value, $Res Function(CreateTransactionDto) _then) = _$CreateTransactionDtoCopyWithImpl;
@useResult
$Res call({
 String categoryId, String walletId, int amount, String title, String? note, String? occurredAt
});




}
/// @nodoc
class _$CreateTransactionDtoCopyWithImpl<$Res>
    implements $CreateTransactionDtoCopyWith<$Res> {
  _$CreateTransactionDtoCopyWithImpl(this._self, this._then);

  final CreateTransactionDto _self;
  final $Res Function(CreateTransactionDto) _then;

/// Create a copy of CreateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? walletId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTransactionDto].
extension CreateTransactionDtoPatterns on CreateTransactionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTransactionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTransactionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTransactionDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateTransactionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTransactionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTransactionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String walletId,  int amount,  String title,  String? note,  String? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTransactionDto() when $default != null:
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String walletId,  int amount,  String title,  String? note,  String? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _CreateTransactionDto():
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String walletId,  int amount,  String title,  String? note,  String? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateTransactionDto() when $default != null:
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTransactionDto implements CreateTransactionDto {
  const _CreateTransactionDto({required this.categoryId, required this.walletId, required this.amount, required this.title, this.note, this.occurredAt});
  factory _CreateTransactionDto.fromJson(Map<String, dynamic> json) => _$CreateTransactionDtoFromJson(json);

@override final  String categoryId;
@override final  String walletId;
@override final  int amount;
@override final  String title;
@override final  String? note;
@override final  String? occurredAt;

/// Create a copy of CreateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTransactionDtoCopyWith<_CreateTransactionDto> get copyWith => __$CreateTransactionDtoCopyWithImpl<_CreateTransactionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTransactionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTransactionDto&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,walletId,amount,title,note,occurredAt);

@override
String toString() {
  return 'CreateTransactionDto(categoryId: $categoryId, walletId: $walletId, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$CreateTransactionDtoCopyWith<$Res> implements $CreateTransactionDtoCopyWith<$Res> {
  factory _$CreateTransactionDtoCopyWith(_CreateTransactionDto value, $Res Function(_CreateTransactionDto) _then) = __$CreateTransactionDtoCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String walletId, int amount, String title, String? note, String? occurredAt
});




}
/// @nodoc
class __$CreateTransactionDtoCopyWithImpl<$Res>
    implements _$CreateTransactionDtoCopyWith<$Res> {
  __$CreateTransactionDtoCopyWithImpl(this._self, this._then);

  final _CreateTransactionDto _self;
  final $Res Function(_CreateTransactionDto) _then;

/// Create a copy of CreateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? walletId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_CreateTransactionDto(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateTransactionDto {

 String? get categoryId; String? get walletId; int? get amount; String? get title; String? get note; String? get occurredAt;
/// Create a copy of UpdateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTransactionDtoCopyWith<UpdateTransactionDto> get copyWith => _$UpdateTransactionDtoCopyWithImpl<UpdateTransactionDto>(this as UpdateTransactionDto, _$identity);

  /// Serializes this UpdateTransactionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTransactionDto&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,walletId,amount,title,note,occurredAt);

@override
String toString() {
  return 'UpdateTransactionDto(categoryId: $categoryId, walletId: $walletId, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $UpdateTransactionDtoCopyWith<$Res>  {
  factory $UpdateTransactionDtoCopyWith(UpdateTransactionDto value, $Res Function(UpdateTransactionDto) _then) = _$UpdateTransactionDtoCopyWithImpl;
@useResult
$Res call({
 String? categoryId, String? walletId, int? amount, String? title, String? note, String? occurredAt
});




}
/// @nodoc
class _$UpdateTransactionDtoCopyWithImpl<$Res>
    implements $UpdateTransactionDtoCopyWith<$Res> {
  _$UpdateTransactionDtoCopyWithImpl(this._self, this._then);

  final UpdateTransactionDto _self;
  final $Res Function(UpdateTransactionDto) _then;

/// Create a copy of UpdateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? walletId = freezed,Object? amount = freezed,Object? title = freezed,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTransactionDto].
extension UpdateTransactionDtoPatterns on UpdateTransactionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTransactionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTransactionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTransactionDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTransactionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTransactionDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTransactionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  String? walletId,  int? amount,  String? title,  String? note,  String? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTransactionDto() when $default != null:
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  String? walletId,  int? amount,  String? title,  String? note,  String? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _UpdateTransactionDto():
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  String? walletId,  int? amount,  String? title,  String? note,  String? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTransactionDto() when $default != null:
return $default(_that.categoryId,_that.walletId,_that.amount,_that.title,_that.note,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateTransactionDto implements UpdateTransactionDto {
  const _UpdateTransactionDto({this.categoryId, this.walletId, this.amount, this.title, this.note, this.occurredAt});
  factory _UpdateTransactionDto.fromJson(Map<String, dynamic> json) => _$UpdateTransactionDtoFromJson(json);

@override final  String? categoryId;
@override final  String? walletId;
@override final  int? amount;
@override final  String? title;
@override final  String? note;
@override final  String? occurredAt;

/// Create a copy of UpdateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTransactionDtoCopyWith<_UpdateTransactionDto> get copyWith => __$UpdateTransactionDtoCopyWithImpl<_UpdateTransactionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTransactionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTransactionDto&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,walletId,amount,title,note,occurredAt);

@override
String toString() {
  return 'UpdateTransactionDto(categoryId: $categoryId, walletId: $walletId, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$UpdateTransactionDtoCopyWith<$Res> implements $UpdateTransactionDtoCopyWith<$Res> {
  factory _$UpdateTransactionDtoCopyWith(_UpdateTransactionDto value, $Res Function(_UpdateTransactionDto) _then) = __$UpdateTransactionDtoCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, String? walletId, int? amount, String? title, String? note, String? occurredAt
});




}
/// @nodoc
class __$UpdateTransactionDtoCopyWithImpl<$Res>
    implements _$UpdateTransactionDtoCopyWith<$Res> {
  __$UpdateTransactionDtoCopyWithImpl(this._self, this._then);

  final _UpdateTransactionDto _self;
  final $Res Function(_UpdateTransactionDto) _then;

/// Create a copy of UpdateTransactionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? walletId = freezed,Object? amount = freezed,Object? title = freezed,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_UpdateTransactionDto(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
