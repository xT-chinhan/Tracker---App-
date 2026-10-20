// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_template_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateQuickTemplateDto {

 String get label; String get title; int get amount; String get categoryId; String get walletId; String? get note;
/// Create a copy of CreateQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateQuickTemplateDtoCopyWith<CreateQuickTemplateDto> get copyWith => _$CreateQuickTemplateDtoCopyWithImpl<CreateQuickTemplateDto>(this as CreateQuickTemplateDto, _$identity);

  /// Serializes this CreateQuickTemplateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateQuickTemplateDto&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,amount,categoryId,walletId,note);

@override
String toString() {
  return 'CreateQuickTemplateDto(label: $label, title: $title, amount: $amount, categoryId: $categoryId, walletId: $walletId, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreateQuickTemplateDtoCopyWith<$Res>  {
  factory $CreateQuickTemplateDtoCopyWith(CreateQuickTemplateDto value, $Res Function(CreateQuickTemplateDto) _then) = _$CreateQuickTemplateDtoCopyWithImpl;
@useResult
$Res call({
 String label, String title, int amount, String categoryId, String walletId, String? note
});




}
/// @nodoc
class _$CreateQuickTemplateDtoCopyWithImpl<$Res>
    implements $CreateQuickTemplateDtoCopyWith<$Res> {
  _$CreateQuickTemplateDtoCopyWithImpl(this._self, this._then);

  final CreateQuickTemplateDto _self;
  final $Res Function(CreateQuickTemplateDto) _then;

/// Create a copy of CreateQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? walletId = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateQuickTemplateDto].
extension CreateQuickTemplateDtoPatterns on CreateQuickTemplateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateQuickTemplateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateQuickTemplateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateQuickTemplateDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateQuickTemplateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateQuickTemplateDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateQuickTemplateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String title,  int amount,  String categoryId,  String walletId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateQuickTemplateDto() when $default != null:
return $default(_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String title,  int amount,  String categoryId,  String walletId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateQuickTemplateDto():
return $default(_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String title,  int amount,  String categoryId,  String walletId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateQuickTemplateDto() when $default != null:
return $default(_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateQuickTemplateDto implements CreateQuickTemplateDto {
  const _CreateQuickTemplateDto({required this.label, required this.title, required this.amount, required this.categoryId, required this.walletId, this.note});
  factory _CreateQuickTemplateDto.fromJson(Map<String, dynamic> json) => _$CreateQuickTemplateDtoFromJson(json);

@override final  String label;
@override final  String title;
@override final  int amount;
@override final  String categoryId;
@override final  String walletId;
@override final  String? note;

/// Create a copy of CreateQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateQuickTemplateDtoCopyWith<_CreateQuickTemplateDto> get copyWith => __$CreateQuickTemplateDtoCopyWithImpl<_CreateQuickTemplateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateQuickTemplateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateQuickTemplateDto&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,title,amount,categoryId,walletId,note);

@override
String toString() {
  return 'CreateQuickTemplateDto(label: $label, title: $title, amount: $amount, categoryId: $categoryId, walletId: $walletId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateQuickTemplateDtoCopyWith<$Res> implements $CreateQuickTemplateDtoCopyWith<$Res> {
  factory _$CreateQuickTemplateDtoCopyWith(_CreateQuickTemplateDto value, $Res Function(_CreateQuickTemplateDto) _then) = __$CreateQuickTemplateDtoCopyWithImpl;
@override @useResult
$Res call({
 String label, String title, int amount, String categoryId, String walletId, String? note
});




}
/// @nodoc
class __$CreateQuickTemplateDtoCopyWithImpl<$Res>
    implements _$CreateQuickTemplateDtoCopyWith<$Res> {
  __$CreateQuickTemplateDtoCopyWithImpl(this._self, this._then);

  final _CreateQuickTemplateDto _self;
  final $Res Function(_CreateQuickTemplateDto) _then;

/// Create a copy of CreateQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? walletId = null,Object? note = freezed,}) {
  return _then(_CreateQuickTemplateDto(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UseQuickTemplateDto {

 String? get occurredAt; int? get amount;
/// Create a copy of UseQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseQuickTemplateDtoCopyWith<UseQuickTemplateDto> get copyWith => _$UseQuickTemplateDtoCopyWithImpl<UseQuickTemplateDto>(this as UseQuickTemplateDto, _$identity);

  /// Serializes this UseQuickTemplateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UseQuickTemplateDto&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurredAt,amount);

@override
String toString() {
  return 'UseQuickTemplateDto(occurredAt: $occurredAt, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $UseQuickTemplateDtoCopyWith<$Res>  {
  factory $UseQuickTemplateDtoCopyWith(UseQuickTemplateDto value, $Res Function(UseQuickTemplateDto) _then) = _$UseQuickTemplateDtoCopyWithImpl;
@useResult
$Res call({
 String? occurredAt, int? amount
});




}
/// @nodoc
class _$UseQuickTemplateDtoCopyWithImpl<$Res>
    implements $UseQuickTemplateDtoCopyWith<$Res> {
  _$UseQuickTemplateDtoCopyWithImpl(this._self, this._then);

  final UseQuickTemplateDto _self;
  final $Res Function(UseQuickTemplateDto) _then;

/// Create a copy of UseQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurredAt = freezed,Object? amount = freezed,}) {
  return _then(_self.copyWith(
occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UseQuickTemplateDto].
extension UseQuickTemplateDtoPatterns on UseQuickTemplateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UseQuickTemplateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UseQuickTemplateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UseQuickTemplateDto value)  $default,){
final _that = this;
switch (_that) {
case _UseQuickTemplateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UseQuickTemplateDto value)?  $default,){
final _that = this;
switch (_that) {
case _UseQuickTemplateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? occurredAt,  int? amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UseQuickTemplateDto() when $default != null:
return $default(_that.occurredAt,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? occurredAt,  int? amount)  $default,) {final _that = this;
switch (_that) {
case _UseQuickTemplateDto():
return $default(_that.occurredAt,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? occurredAt,  int? amount)?  $default,) {final _that = this;
switch (_that) {
case _UseQuickTemplateDto() when $default != null:
return $default(_that.occurredAt,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UseQuickTemplateDto implements UseQuickTemplateDto {
  const _UseQuickTemplateDto({this.occurredAt, this.amount});
  factory _UseQuickTemplateDto.fromJson(Map<String, dynamic> json) => _$UseQuickTemplateDtoFromJson(json);

@override final  String? occurredAt;
@override final  int? amount;

/// Create a copy of UseQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UseQuickTemplateDtoCopyWith<_UseQuickTemplateDto> get copyWith => __$UseQuickTemplateDtoCopyWithImpl<_UseQuickTemplateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UseQuickTemplateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UseQuickTemplateDto&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurredAt,amount);

@override
String toString() {
  return 'UseQuickTemplateDto(occurredAt: $occurredAt, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$UseQuickTemplateDtoCopyWith<$Res> implements $UseQuickTemplateDtoCopyWith<$Res> {
  factory _$UseQuickTemplateDtoCopyWith(_UseQuickTemplateDto value, $Res Function(_UseQuickTemplateDto) _then) = __$UseQuickTemplateDtoCopyWithImpl;
@override @useResult
$Res call({
 String? occurredAt, int? amount
});




}
/// @nodoc
class __$UseQuickTemplateDtoCopyWithImpl<$Res>
    implements _$UseQuickTemplateDtoCopyWith<$Res> {
  __$UseQuickTemplateDtoCopyWithImpl(this._self, this._then);

  final _UseQuickTemplateDto _self;
  final $Res Function(_UseQuickTemplateDto) _then;

/// Create a copy of UseQuickTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurredAt = freezed,Object? amount = freezed,}) {
  return _then(_UseQuickTemplateDto(
occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
