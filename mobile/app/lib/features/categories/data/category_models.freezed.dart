// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryItem {

 String get id; String get name; String get type; String? get icon; String? get color; String? get userId; bool get isArchived; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CategoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryItemCopyWith<CategoryItem> get copyWith => _$CategoryItemCopyWithImpl<CategoryItem>(this as CategoryItem, _$identity);

  /// Serializes this CategoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,userId,isArchived,createdAt,updatedAt);

@override
String toString() {
  return 'CategoryItem(id: $id, name: $name, type: $type, icon: $icon, color: $color, userId: $userId, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CategoryItemCopyWith<$Res>  {
  factory $CategoryItemCopyWith(CategoryItem value, $Res Function(CategoryItem) _then) = _$CategoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String? icon, String? color, String? userId, bool isArchived, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CategoryItemCopyWithImpl<$Res>
    implements $CategoryItemCopyWith<$Res> {
  _$CategoryItemCopyWithImpl(this._self, this._then);

  final CategoryItem _self;
  final $Res Function(CategoryItem) _then;

/// Create a copy of CategoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,Object? userId = freezed,Object? isArchived = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryItem].
extension CategoryItemPatterns on CategoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryItem value)  $default,){
final _that = this;
switch (_that) {
case _CategoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? icon,  String? color,  String? userId,  bool isArchived,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.userId,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? icon,  String? color,  String? userId,  bool isArchived,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CategoryItem():
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.userId,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  String? icon,  String? color,  String? userId,  bool isArchived,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CategoryItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.userId,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryItem implements CategoryItem {
  const _CategoryItem({required this.id, required this.name, required this.type, this.icon, this.color, this.userId, this.isArchived = false, this.createdAt, this.updatedAt});
  factory _CategoryItem.fromJson(Map<String, dynamic> json) => _$CategoryItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  String? icon;
@override final  String? color;
@override final  String? userId;
@override@JsonKey() final  bool isArchived;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryItemCopyWith<_CategoryItem> get copyWith => __$CategoryItemCopyWithImpl<_CategoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,userId,isArchived,createdAt,updatedAt);

@override
String toString() {
  return 'CategoryItem(id: $id, name: $name, type: $type, icon: $icon, color: $color, userId: $userId, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CategoryItemCopyWith<$Res> implements $CategoryItemCopyWith<$Res> {
  factory _$CategoryItemCopyWith(_CategoryItem value, $Res Function(_CategoryItem) _then) = __$CategoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String? icon, String? color, String? userId, bool isArchived, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CategoryItemCopyWithImpl<$Res>
    implements _$CategoryItemCopyWith<$Res> {
  __$CategoryItemCopyWithImpl(this._self, this._then);

  final _CategoryItem _self;
  final $Res Function(_CategoryItem) _then;

/// Create a copy of CategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,Object? userId = freezed,Object? isArchived = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CategoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateCategoryDto {

 String get name; String get type; String? get icon; String? get color;
/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCategoryDtoCopyWith<CreateCategoryDto> get copyWith => _$CreateCategoryDtoCopyWithImpl<CreateCategoryDto>(this as CreateCategoryDto, _$identity);

  /// Serializes this CreateCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,icon,color);

@override
String toString() {
  return 'CreateCategoryDto(name: $name, type: $type, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $CreateCategoryDtoCopyWith<$Res>  {
  factory $CreateCategoryDtoCopyWith(CreateCategoryDto value, $Res Function(CreateCategoryDto) _then) = _$CreateCategoryDtoCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? icon, String? color
});




}
/// @nodoc
class _$CreateCategoryDtoCopyWithImpl<$Res>
    implements $CreateCategoryDtoCopyWith<$Res> {
  _$CreateCategoryDtoCopyWithImpl(this._self, this._then);

  final CreateCategoryDto _self;
  final $Res Function(CreateCategoryDto) _then;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCategoryDto].
extension CreateCategoryDtoPatterns on CreateCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
return $default(_that.name,_that.type,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CreateCategoryDto():
return $default(_that.name,_that.type,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CreateCategoryDto() when $default != null:
return $default(_that.name,_that.type,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCategoryDto implements CreateCategoryDto {
  const _CreateCategoryDto({required this.name, required this.type, this.icon, this.color});
  factory _CreateCategoryDto.fromJson(Map<String, dynamic> json) => _$CreateCategoryDtoFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? icon;
@override final  String? color;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCategoryDtoCopyWith<_CreateCategoryDto> get copyWith => __$CreateCategoryDtoCopyWithImpl<_CreateCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,icon,color);

@override
String toString() {
  return 'CreateCategoryDto(name: $name, type: $type, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CreateCategoryDtoCopyWith<$Res> implements $CreateCategoryDtoCopyWith<$Res> {
  factory _$CreateCategoryDtoCopyWith(_CreateCategoryDto value, $Res Function(_CreateCategoryDto) _then) = __$CreateCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? icon, String? color
});




}
/// @nodoc
class __$CreateCategoryDtoCopyWithImpl<$Res>
    implements _$CreateCategoryDtoCopyWith<$Res> {
  __$CreateCategoryDtoCopyWithImpl(this._self, this._then);

  final _CreateCategoryDto _self;
  final $Res Function(_CreateCategoryDto) _then;

/// Create a copy of CreateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_CreateCategoryDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
