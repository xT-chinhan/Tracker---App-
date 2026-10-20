// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringWalletMeta {

 String get id; String get name; String get type; bool get isArchived;
/// Create a copy of RecurringWalletMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringWalletMetaCopyWith<RecurringWalletMeta> get copyWith => _$RecurringWalletMetaCopyWithImpl<RecurringWalletMeta>(this as RecurringWalletMeta, _$identity);

  /// Serializes this RecurringWalletMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringWalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isArchived);

@override
String toString() {
  return 'RecurringWalletMeta(id: $id, name: $name, type: $type, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $RecurringWalletMetaCopyWith<$Res>  {
  factory $RecurringWalletMetaCopyWith(RecurringWalletMeta value, $Res Function(RecurringWalletMeta) _then) = _$RecurringWalletMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, bool isArchived
});




}
/// @nodoc
class _$RecurringWalletMetaCopyWithImpl<$Res>
    implements $RecurringWalletMetaCopyWith<$Res> {
  _$RecurringWalletMetaCopyWithImpl(this._self, this._then);

  final RecurringWalletMeta _self;
  final $Res Function(RecurringWalletMeta) _then;

/// Create a copy of RecurringWalletMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isArchived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringWalletMeta].
extension RecurringWalletMetaPatterns on RecurringWalletMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringWalletMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringWalletMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringWalletMeta value)  $default,){
final _that = this;
switch (_that) {
case _RecurringWalletMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringWalletMeta value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringWalletMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringWalletMeta() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isArchived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool isArchived)  $default,) {final _that = this;
switch (_that) {
case _RecurringWalletMeta():
return $default(_that.id,_that.name,_that.type,_that.isArchived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  bool isArchived)?  $default,) {final _that = this;
switch (_that) {
case _RecurringWalletMeta() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringWalletMeta implements RecurringWalletMeta {
  const _RecurringWalletMeta({required this.id, required this.name, required this.type, this.isArchived = false});
  factory _RecurringWalletMeta.fromJson(Map<String, dynamic> json) => _$RecurringWalletMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey() final  bool isArchived;

/// Create a copy of RecurringWalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringWalletMetaCopyWith<_RecurringWalletMeta> get copyWith => __$RecurringWalletMetaCopyWithImpl<_RecurringWalletMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringWalletMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringWalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isArchived);

@override
String toString() {
  return 'RecurringWalletMeta(id: $id, name: $name, type: $type, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$RecurringWalletMetaCopyWith<$Res> implements $RecurringWalletMetaCopyWith<$Res> {
  factory _$RecurringWalletMetaCopyWith(_RecurringWalletMeta value, $Res Function(_RecurringWalletMeta) _then) = __$RecurringWalletMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, bool isArchived
});




}
/// @nodoc
class __$RecurringWalletMetaCopyWithImpl<$Res>
    implements _$RecurringWalletMetaCopyWith<$Res> {
  __$RecurringWalletMetaCopyWithImpl(this._self, this._then);

  final _RecurringWalletMeta _self;
  final $Res Function(_RecurringWalletMeta) _then;

/// Create a copy of RecurringWalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isArchived = null,}) {
  return _then(_RecurringWalletMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RecurringCategoryMeta {

 String get id; String get name; String get type; String? get icon; String? get color; bool get isArchived;
/// Create a copy of RecurringCategoryMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringCategoryMetaCopyWith<RecurringCategoryMeta> get copyWith => _$RecurringCategoryMetaCopyWithImpl<RecurringCategoryMeta>(this as RecurringCategoryMeta, _$identity);

  /// Serializes this RecurringCategoryMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringCategoryMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,isArchived);

@override
String toString() {
  return 'RecurringCategoryMeta(id: $id, name: $name, type: $type, icon: $icon, color: $color, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $RecurringCategoryMetaCopyWith<$Res>  {
  factory $RecurringCategoryMetaCopyWith(RecurringCategoryMeta value, $Res Function(RecurringCategoryMeta) _then) = _$RecurringCategoryMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String? icon, String? color, bool isArchived
});




}
/// @nodoc
class _$RecurringCategoryMetaCopyWithImpl<$Res>
    implements $RecurringCategoryMetaCopyWith<$Res> {
  _$RecurringCategoryMetaCopyWithImpl(this._self, this._then);

  final RecurringCategoryMeta _self;
  final $Res Function(RecurringCategoryMeta) _then;

/// Create a copy of RecurringCategoryMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,Object? isArchived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringCategoryMeta].
extension RecurringCategoryMetaPatterns on RecurringCategoryMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringCategoryMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringCategoryMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringCategoryMeta value)  $default,){
final _that = this;
switch (_that) {
case _RecurringCategoryMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringCategoryMeta value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringCategoryMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? icon,  String? color,  bool isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringCategoryMeta() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isArchived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String? icon,  String? color,  bool isArchived)  $default,) {final _that = this;
switch (_that) {
case _RecurringCategoryMeta():
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isArchived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  String? icon,  String? color,  bool isArchived)?  $default,) {final _that = this;
switch (_that) {
case _RecurringCategoryMeta() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringCategoryMeta implements RecurringCategoryMeta {
  const _RecurringCategoryMeta({required this.id, required this.name, required this.type, this.icon, this.color, this.isArchived = false});
  factory _RecurringCategoryMeta.fromJson(Map<String, dynamic> json) => _$RecurringCategoryMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  bool isArchived;

/// Create a copy of RecurringCategoryMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringCategoryMetaCopyWith<_RecurringCategoryMeta> get copyWith => __$RecurringCategoryMetaCopyWithImpl<_RecurringCategoryMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringCategoryMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringCategoryMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,isArchived);

@override
String toString() {
  return 'RecurringCategoryMeta(id: $id, name: $name, type: $type, icon: $icon, color: $color, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$RecurringCategoryMetaCopyWith<$Res> implements $RecurringCategoryMetaCopyWith<$Res> {
  factory _$RecurringCategoryMetaCopyWith(_RecurringCategoryMeta value, $Res Function(_RecurringCategoryMeta) _then) = __$RecurringCategoryMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String? icon, String? color, bool isArchived
});




}
/// @nodoc
class __$RecurringCategoryMetaCopyWithImpl<$Res>
    implements _$RecurringCategoryMetaCopyWith<$Res> {
  __$RecurringCategoryMetaCopyWithImpl(this._self, this._then);

  final _RecurringCategoryMeta _self;
  final $Res Function(_RecurringCategoryMeta) _then;

/// Create a copy of RecurringCategoryMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,Object? isArchived = null,}) {
  return _then(_RecurringCategoryMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RecurringCount {

@JsonKey(fromJson: _toInt) int get transactions;
/// Create a copy of RecurringCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringCountCopyWith<RecurringCount> get copyWith => _$RecurringCountCopyWithImpl<RecurringCount>(this as RecurringCount, _$identity);

  /// Serializes this RecurringCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringCount&&(identical(other.transactions, transactions) || other.transactions == transactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactions);

@override
String toString() {
  return 'RecurringCount(transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $RecurringCountCopyWith<$Res>  {
  factory $RecurringCountCopyWith(RecurringCount value, $Res Function(RecurringCount) _then) = _$RecurringCountCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int transactions
});




}
/// @nodoc
class _$RecurringCountCopyWithImpl<$Res>
    implements $RecurringCountCopyWith<$Res> {
  _$RecurringCountCopyWithImpl(this._self, this._then);

  final RecurringCount _self;
  final $Res Function(RecurringCount) _then;

/// Create a copy of RecurringCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactions = null,}) {
  return _then(_self.copyWith(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringCount].
extension RecurringCountPatterns on RecurringCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringCount value)  $default,){
final _that = this;
switch (_that) {
case _RecurringCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringCount value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringCount() when $default != null:
return $default(_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int transactions)  $default,) {final _that = this;
switch (_that) {
case _RecurringCount():
return $default(_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int transactions)?  $default,) {final _that = this;
switch (_that) {
case _RecurringCount() when $default != null:
return $default(_that.transactions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringCount implements RecurringCount {
  const _RecurringCount({@JsonKey(fromJson: _toInt) this.transactions = 0});
  factory _RecurringCount.fromJson(Map<String, dynamic> json) => _$RecurringCountFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int transactions;

/// Create a copy of RecurringCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringCountCopyWith<_RecurringCount> get copyWith => __$RecurringCountCopyWithImpl<_RecurringCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringCount&&(identical(other.transactions, transactions) || other.transactions == transactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactions);

@override
String toString() {
  return 'RecurringCount(transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$RecurringCountCopyWith<$Res> implements $RecurringCountCopyWith<$Res> {
  factory _$RecurringCountCopyWith(_RecurringCount value, $Res Function(_RecurringCount) _then) = __$RecurringCountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int transactions
});




}
/// @nodoc
class __$RecurringCountCopyWithImpl<$Res>
    implements _$RecurringCountCopyWith<$Res> {
  __$RecurringCountCopyWithImpl(this._self, this._then);

  final _RecurringCount _self;
  final $Res Function(_RecurringCount) _then;

/// Create a copy of RecurringCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactions = null,}) {
  return _then(_RecurringCount(
transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecurringRuleItem {

 String get id; String get userId; String get walletId; String get categoryId;@JsonKey(fromJson: _toInt) int get amount; String get title; String? get note; String get frequency; int get interval; DateTime get startDate; DateTime? get endDate; int get anchorDay; DateTime get nextRunAt; DateTime? get lastRunAt; bool get isActive; DateTime get createdAt; DateTime get updatedAt; RecurringWalletMeta? get wallet; RecurringCategoryMeta? get category;@JsonKey(name: '_count') RecurringCount? get count;
/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleItemCopyWith<RecurringRuleItem> get copyWith => _$RecurringRuleItemCopyWithImpl<RecurringRuleItem>(this as RecurringRuleItem, _$identity);

  /// Serializes this RecurringRuleItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRuleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.anchorDay, anchorDay) || other.anchorDay == anchorDay)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.category, category) || other.category == category)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate,anchorDay,nextRunAt,lastRunAt,isActive,createdAt,updatedAt,wallet,category,count]);

@override
String toString() {
  return 'RecurringRuleItem(id: $id, userId: $userId, walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate, anchorDay: $anchorDay, nextRunAt: $nextRunAt, lastRunAt: $lastRunAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, wallet: $wallet, category: $category, count: $count)';
}


}

/// @nodoc
abstract mixin class $RecurringRuleItemCopyWith<$Res>  {
  factory $RecurringRuleItemCopyWith(RecurringRuleItem value, $Res Function(RecurringRuleItem) _then) = _$RecurringRuleItemCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String walletId, String categoryId,@JsonKey(fromJson: _toInt) int amount, String title, String? note, String frequency, int interval, DateTime startDate, DateTime? endDate, int anchorDay, DateTime nextRunAt, DateTime? lastRunAt, bool isActive, DateTime createdAt, DateTime updatedAt, RecurringWalletMeta? wallet, RecurringCategoryMeta? category,@JsonKey(name: '_count') RecurringCount? count
});


$RecurringWalletMetaCopyWith<$Res>? get wallet;$RecurringCategoryMetaCopyWith<$Res>? get category;$RecurringCountCopyWith<$Res>? get count;

}
/// @nodoc
class _$RecurringRuleItemCopyWithImpl<$Res>
    implements $RecurringRuleItemCopyWith<$Res> {
  _$RecurringRuleItemCopyWithImpl(this._self, this._then);

  final RecurringRuleItem _self;
  final $Res Function(RecurringRuleItem) _then;

/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? walletId = null,Object? categoryId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? frequency = null,Object? interval = null,Object? startDate = null,Object? endDate = freezed,Object? anchorDay = null,Object? nextRunAt = null,Object? lastRunAt = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? wallet = freezed,Object? category = freezed,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,anchorDay: null == anchorDay ? _self.anchorDay : anchorDay // ignore: cast_nullable_to_non_nullable
as int,nextRunAt: null == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as RecurringWalletMeta?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecurringCategoryMeta?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as RecurringCount?,
  ));
}
/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringWalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $RecurringWalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $RecurringCategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $RecurringCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecurringRuleItem].
extension RecurringRuleItemPatterns on RecurringRuleItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRuleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRuleItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRuleItem value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRuleItem value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String walletId,  String categoryId, @JsonKey(fromJson: _toInt)  int amount,  String title,  String? note,  String frequency,  int interval,  DateTime startDate,  DateTime? endDate,  int anchorDay,  DateTime nextRunAt,  DateTime? lastRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  RecurringWalletMeta? wallet,  RecurringCategoryMeta? category, @JsonKey(name: '_count')  RecurringCount? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRuleItem() when $default != null:
return $default(_that.id,_that.userId,_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate,_that.anchorDay,_that.nextRunAt,_that.lastRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.wallet,_that.category,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String walletId,  String categoryId, @JsonKey(fromJson: _toInt)  int amount,  String title,  String? note,  String frequency,  int interval,  DateTime startDate,  DateTime? endDate,  int anchorDay,  DateTime nextRunAt,  DateTime? lastRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  RecurringWalletMeta? wallet,  RecurringCategoryMeta? category, @JsonKey(name: '_count')  RecurringCount? count)  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleItem():
return $default(_that.id,_that.userId,_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate,_that.anchorDay,_that.nextRunAt,_that.lastRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.wallet,_that.category,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String walletId,  String categoryId, @JsonKey(fromJson: _toInt)  int amount,  String title,  String? note,  String frequency,  int interval,  DateTime startDate,  DateTime? endDate,  int anchorDay,  DateTime nextRunAt,  DateTime? lastRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  RecurringWalletMeta? wallet,  RecurringCategoryMeta? category, @JsonKey(name: '_count')  RecurringCount? count)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleItem() when $default != null:
return $default(_that.id,_that.userId,_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate,_that.anchorDay,_that.nextRunAt,_that.lastRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.wallet,_that.category,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringRuleItem implements RecurringRuleItem {
  const _RecurringRuleItem({required this.id, required this.userId, required this.walletId, required this.categoryId, @JsonKey(fromJson: _toInt) required this.amount, required this.title, this.note, required this.frequency, this.interval = 1, required this.startDate, this.endDate, this.anchorDay = 1, required this.nextRunAt, this.lastRunAt, this.isActive = true, required this.createdAt, required this.updatedAt, this.wallet, this.category, @JsonKey(name: '_count') this.count});
  factory _RecurringRuleItem.fromJson(Map<String, dynamic> json) => _$RecurringRuleItemFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String walletId;
@override final  String categoryId;
@override@JsonKey(fromJson: _toInt) final  int amount;
@override final  String title;
@override final  String? note;
@override final  String frequency;
@override@JsonKey() final  int interval;
@override final  DateTime startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  int anchorDay;
@override final  DateTime nextRunAt;
@override final  DateTime? lastRunAt;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  RecurringWalletMeta? wallet;
@override final  RecurringCategoryMeta? category;
@override@JsonKey(name: '_count') final  RecurringCount? count;

/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleItemCopyWith<_RecurringRuleItem> get copyWith => __$RecurringRuleItemCopyWithImpl<_RecurringRuleItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringRuleItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRuleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.anchorDay, anchorDay) || other.anchorDay == anchorDay)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.category, category) || other.category == category)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate,anchorDay,nextRunAt,lastRunAt,isActive,createdAt,updatedAt,wallet,category,count]);

@override
String toString() {
  return 'RecurringRuleItem(id: $id, userId: $userId, walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate, anchorDay: $anchorDay, nextRunAt: $nextRunAt, lastRunAt: $lastRunAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, wallet: $wallet, category: $category, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleItemCopyWith<$Res> implements $RecurringRuleItemCopyWith<$Res> {
  factory _$RecurringRuleItemCopyWith(_RecurringRuleItem value, $Res Function(_RecurringRuleItem) _then) = __$RecurringRuleItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String walletId, String categoryId,@JsonKey(fromJson: _toInt) int amount, String title, String? note, String frequency, int interval, DateTime startDate, DateTime? endDate, int anchorDay, DateTime nextRunAt, DateTime? lastRunAt, bool isActive, DateTime createdAt, DateTime updatedAt, RecurringWalletMeta? wallet, RecurringCategoryMeta? category,@JsonKey(name: '_count') RecurringCount? count
});


@override $RecurringWalletMetaCopyWith<$Res>? get wallet;@override $RecurringCategoryMetaCopyWith<$Res>? get category;@override $RecurringCountCopyWith<$Res>? get count;

}
/// @nodoc
class __$RecurringRuleItemCopyWithImpl<$Res>
    implements _$RecurringRuleItemCopyWith<$Res> {
  __$RecurringRuleItemCopyWithImpl(this._self, this._then);

  final _RecurringRuleItem _self;
  final $Res Function(_RecurringRuleItem) _then;

/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? walletId = null,Object? categoryId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? frequency = null,Object? interval = null,Object? startDate = null,Object? endDate = freezed,Object? anchorDay = null,Object? nextRunAt = null,Object? lastRunAt = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? wallet = freezed,Object? category = freezed,Object? count = freezed,}) {
  return _then(_RecurringRuleItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,anchorDay: null == anchorDay ? _self.anchorDay : anchorDay // ignore: cast_nullable_to_non_nullable
as int,nextRunAt: null == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as RecurringWalletMeta?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecurringCategoryMeta?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as RecurringCount?,
  ));
}

/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringWalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $RecurringWalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $RecurringCategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of RecurringRuleItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $RecurringCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}
}


/// @nodoc
mixin _$CreateRecurringDto {

 String get walletId; String get categoryId; int get amount; String get title; String? get note; String get frequency; int? get interval; String get startDate; String? get endDate;
/// Create a copy of CreateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRecurringDtoCopyWith<CreateRecurringDto> get copyWith => _$CreateRecurringDtoCopyWithImpl<CreateRecurringDto>(this as CreateRecurringDto, _$identity);

  /// Serializes this CreateRecurringDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRecurringDto&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate);

@override
String toString() {
  return 'CreateRecurringDto(walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $CreateRecurringDtoCopyWith<$Res>  {
  factory $CreateRecurringDtoCopyWith(CreateRecurringDto value, $Res Function(CreateRecurringDto) _then) = _$CreateRecurringDtoCopyWithImpl;
@useResult
$Res call({
 String walletId, String categoryId, int amount, String title, String? note, String frequency, int? interval, String startDate, String? endDate
});




}
/// @nodoc
class _$CreateRecurringDtoCopyWithImpl<$Res>
    implements $CreateRecurringDtoCopyWith<$Res> {
  _$CreateRecurringDtoCopyWithImpl(this._self, this._then);

  final CreateRecurringDto _self;
  final $Res Function(CreateRecurringDto) _then;

/// Create a copy of CreateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? walletId = null,Object? categoryId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? frequency = null,Object? interval = freezed,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRecurringDto].
extension CreateRecurringDtoPatterns on CreateRecurringDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRecurringDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRecurringDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRecurringDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateRecurringDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRecurringDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRecurringDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String walletId,  String categoryId,  int amount,  String title,  String? note,  String frequency,  int? interval,  String startDate,  String? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRecurringDto() when $default != null:
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String walletId,  String categoryId,  int amount,  String title,  String? note,  String frequency,  int? interval,  String startDate,  String? endDate)  $default,) {final _that = this;
switch (_that) {
case _CreateRecurringDto():
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String walletId,  String categoryId,  int amount,  String title,  String? note,  String frequency,  int? interval,  String startDate,  String? endDate)?  $default,) {final _that = this;
switch (_that) {
case _CreateRecurringDto() when $default != null:
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRecurringDto implements CreateRecurringDto {
  const _CreateRecurringDto({required this.walletId, required this.categoryId, required this.amount, required this.title, this.note, required this.frequency, this.interval, required this.startDate, this.endDate});
  factory _CreateRecurringDto.fromJson(Map<String, dynamic> json) => _$CreateRecurringDtoFromJson(json);

@override final  String walletId;
@override final  String categoryId;
@override final  int amount;
@override final  String title;
@override final  String? note;
@override final  String frequency;
@override final  int? interval;
@override final  String startDate;
@override final  String? endDate;

/// Create a copy of CreateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRecurringDtoCopyWith<_CreateRecurringDto> get copyWith => __$CreateRecurringDtoCopyWithImpl<_CreateRecurringDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRecurringDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRecurringDto&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate);

@override
String toString() {
  return 'CreateRecurringDto(walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$CreateRecurringDtoCopyWith<$Res> implements $CreateRecurringDtoCopyWith<$Res> {
  factory _$CreateRecurringDtoCopyWith(_CreateRecurringDto value, $Res Function(_CreateRecurringDto) _then) = __$CreateRecurringDtoCopyWithImpl;
@override @useResult
$Res call({
 String walletId, String categoryId, int amount, String title, String? note, String frequency, int? interval, String startDate, String? endDate
});




}
/// @nodoc
class __$CreateRecurringDtoCopyWithImpl<$Res>
    implements _$CreateRecurringDtoCopyWith<$Res> {
  __$CreateRecurringDtoCopyWithImpl(this._self, this._then);

  final _CreateRecurringDto _self;
  final $Res Function(_CreateRecurringDto) _then;

/// Create a copy of CreateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? walletId = null,Object? categoryId = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? frequency = null,Object? interval = freezed,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_CreateRecurringDto(
walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateRecurringDto {

 String? get walletId; String? get categoryId; int? get amount; String? get title; String? get note; String? get frequency; int? get interval; String? get startDate; String? get endDate;
/// Create a copy of UpdateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateRecurringDtoCopyWith<UpdateRecurringDto> get copyWith => _$UpdateRecurringDtoCopyWithImpl<UpdateRecurringDto>(this as UpdateRecurringDto, _$identity);

  /// Serializes this UpdateRecurringDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateRecurringDto&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate);

@override
String toString() {
  return 'UpdateRecurringDto(walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $UpdateRecurringDtoCopyWith<$Res>  {
  factory $UpdateRecurringDtoCopyWith(UpdateRecurringDto value, $Res Function(UpdateRecurringDto) _then) = _$UpdateRecurringDtoCopyWithImpl;
@useResult
$Res call({
 String? walletId, String? categoryId, int? amount, String? title, String? note, String? frequency, int? interval, String? startDate, String? endDate
});




}
/// @nodoc
class _$UpdateRecurringDtoCopyWithImpl<$Res>
    implements $UpdateRecurringDtoCopyWith<$Res> {
  _$UpdateRecurringDtoCopyWithImpl(this._self, this._then);

  final UpdateRecurringDto _self;
  final $Res Function(UpdateRecurringDto) _then;

/// Create a copy of UpdateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? walletId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? title = freezed,Object? note = freezed,Object? frequency = freezed,Object? interval = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateRecurringDto].
extension UpdateRecurringDtoPatterns on UpdateRecurringDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateRecurringDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateRecurringDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateRecurringDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateRecurringDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateRecurringDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateRecurringDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? walletId,  String? categoryId,  int? amount,  String? title,  String? note,  String? frequency,  int? interval,  String? startDate,  String? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateRecurringDto() when $default != null:
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? walletId,  String? categoryId,  int? amount,  String? title,  String? note,  String? frequency,  int? interval,  String? startDate,  String? endDate)  $default,) {final _that = this;
switch (_that) {
case _UpdateRecurringDto():
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? walletId,  String? categoryId,  int? amount,  String? title,  String? note,  String? frequency,  int? interval,  String? startDate,  String? endDate)?  $default,) {final _that = this;
switch (_that) {
case _UpdateRecurringDto() when $default != null:
return $default(_that.walletId,_that.categoryId,_that.amount,_that.title,_that.note,_that.frequency,_that.interval,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateRecurringDto implements UpdateRecurringDto {
  const _UpdateRecurringDto({this.walletId, this.categoryId, this.amount, this.title, this.note, this.frequency, this.interval, this.startDate, this.endDate});
  factory _UpdateRecurringDto.fromJson(Map<String, dynamic> json) => _$UpdateRecurringDtoFromJson(json);

@override final  String? walletId;
@override final  String? categoryId;
@override final  int? amount;
@override final  String? title;
@override final  String? note;
@override final  String? frequency;
@override final  int? interval;
@override final  String? startDate;
@override final  String? endDate;

/// Create a copy of UpdateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateRecurringDtoCopyWith<_UpdateRecurringDto> get copyWith => __$UpdateRecurringDtoCopyWithImpl<_UpdateRecurringDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateRecurringDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateRecurringDto&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId,categoryId,amount,title,note,frequency,interval,startDate,endDate);

@override
String toString() {
  return 'UpdateRecurringDto(walletId: $walletId, categoryId: $categoryId, amount: $amount, title: $title, note: $note, frequency: $frequency, interval: $interval, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$UpdateRecurringDtoCopyWith<$Res> implements $UpdateRecurringDtoCopyWith<$Res> {
  factory _$UpdateRecurringDtoCopyWith(_UpdateRecurringDto value, $Res Function(_UpdateRecurringDto) _then) = __$UpdateRecurringDtoCopyWithImpl;
@override @useResult
$Res call({
 String? walletId, String? categoryId, int? amount, String? title, String? note, String? frequency, int? interval, String? startDate, String? endDate
});




}
/// @nodoc
class __$UpdateRecurringDtoCopyWithImpl<$Res>
    implements _$UpdateRecurringDtoCopyWith<$Res> {
  __$UpdateRecurringDtoCopyWithImpl(this._self, this._then);

  final _UpdateRecurringDto _self;
  final $Res Function(_UpdateRecurringDto) _then;

/// Create a copy of UpdateRecurringDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? walletId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? title = freezed,Object? note = freezed,Object? frequency = freezed,Object? interval = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_UpdateRecurringDto(
walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecurringPreviewItem {

 DateTime get scheduledFor; String get date;
/// Create a copy of RecurringPreviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringPreviewItemCopyWith<RecurringPreviewItem> get copyWith => _$RecurringPreviewItemCopyWithImpl<RecurringPreviewItem>(this as RecurringPreviewItem, _$identity);

  /// Serializes this RecurringPreviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringPreviewItem&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scheduledFor,date);

@override
String toString() {
  return 'RecurringPreviewItem(scheduledFor: $scheduledFor, date: $date)';
}


}

/// @nodoc
abstract mixin class $RecurringPreviewItemCopyWith<$Res>  {
  factory $RecurringPreviewItemCopyWith(RecurringPreviewItem value, $Res Function(RecurringPreviewItem) _then) = _$RecurringPreviewItemCopyWithImpl;
@useResult
$Res call({
 DateTime scheduledFor, String date
});




}
/// @nodoc
class _$RecurringPreviewItemCopyWithImpl<$Res>
    implements $RecurringPreviewItemCopyWith<$Res> {
  _$RecurringPreviewItemCopyWithImpl(this._self, this._then);

  final RecurringPreviewItem _self;
  final $Res Function(RecurringPreviewItem) _then;

/// Create a copy of RecurringPreviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scheduledFor = null,Object? date = null,}) {
  return _then(_self.copyWith(
scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringPreviewItem].
extension RecurringPreviewItemPatterns on RecurringPreviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringPreviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringPreviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringPreviewItem value)  $default,){
final _that = this;
switch (_that) {
case _RecurringPreviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringPreviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringPreviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime scheduledFor,  String date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringPreviewItem() when $default != null:
return $default(_that.scheduledFor,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime scheduledFor,  String date)  $default,) {final _that = this;
switch (_that) {
case _RecurringPreviewItem():
return $default(_that.scheduledFor,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime scheduledFor,  String date)?  $default,) {final _that = this;
switch (_that) {
case _RecurringPreviewItem() when $default != null:
return $default(_that.scheduledFor,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringPreviewItem implements RecurringPreviewItem {
  const _RecurringPreviewItem({required this.scheduledFor, required this.date});
  factory _RecurringPreviewItem.fromJson(Map<String, dynamic> json) => _$RecurringPreviewItemFromJson(json);

@override final  DateTime scheduledFor;
@override final  String date;

/// Create a copy of RecurringPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringPreviewItemCopyWith<_RecurringPreviewItem> get copyWith => __$RecurringPreviewItemCopyWithImpl<_RecurringPreviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringPreviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringPreviewItem&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scheduledFor,date);

@override
String toString() {
  return 'RecurringPreviewItem(scheduledFor: $scheduledFor, date: $date)';
}


}

/// @nodoc
abstract mixin class _$RecurringPreviewItemCopyWith<$Res> implements $RecurringPreviewItemCopyWith<$Res> {
  factory _$RecurringPreviewItemCopyWith(_RecurringPreviewItem value, $Res Function(_RecurringPreviewItem) _then) = __$RecurringPreviewItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime scheduledFor, String date
});




}
/// @nodoc
class __$RecurringPreviewItemCopyWithImpl<$Res>
    implements _$RecurringPreviewItemCopyWith<$Res> {
  __$RecurringPreviewItemCopyWithImpl(this._self, this._then);

  final _RecurringPreviewItem _self;
  final $Res Function(_RecurringPreviewItem) _then;

/// Create a copy of RecurringPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scheduledFor = null,Object? date = null,}) {
  return _then(_RecurringPreviewItem(
scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RecurringPreviewResponse {

 String get ruleId; bool get isActive; List<RecurringPreviewItem> get items;
/// Create a copy of RecurringPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringPreviewResponseCopyWith<RecurringPreviewResponse> get copyWith => _$RecurringPreviewResponseCopyWithImpl<RecurringPreviewResponse>(this as RecurringPreviewResponse, _$identity);

  /// Serializes this RecurringPreviewResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringPreviewResponse&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ruleId,isActive,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'RecurringPreviewResponse(ruleId: $ruleId, isActive: $isActive, items: $items)';
}


}

/// @nodoc
abstract mixin class $RecurringPreviewResponseCopyWith<$Res>  {
  factory $RecurringPreviewResponseCopyWith(RecurringPreviewResponse value, $Res Function(RecurringPreviewResponse) _then) = _$RecurringPreviewResponseCopyWithImpl;
@useResult
$Res call({
 String ruleId, bool isActive, List<RecurringPreviewItem> items
});




}
/// @nodoc
class _$RecurringPreviewResponseCopyWithImpl<$Res>
    implements $RecurringPreviewResponseCopyWith<$Res> {
  _$RecurringPreviewResponseCopyWithImpl(this._self, this._then);

  final RecurringPreviewResponse _self;
  final $Res Function(RecurringPreviewResponse) _then;

/// Create a copy of RecurringPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ruleId = null,Object? isActive = null,Object? items = null,}) {
  return _then(_self.copyWith(
ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringPreviewItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringPreviewResponse].
extension RecurringPreviewResponsePatterns on RecurringPreviewResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringPreviewResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringPreviewResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecurringPreviewResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringPreviewResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringPreviewResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ruleId,  bool isActive,  List<RecurringPreviewItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringPreviewResponse() when $default != null:
return $default(_that.ruleId,_that.isActive,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ruleId,  bool isActive,  List<RecurringPreviewItem> items)  $default,) {final _that = this;
switch (_that) {
case _RecurringPreviewResponse():
return $default(_that.ruleId,_that.isActive,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ruleId,  bool isActive,  List<RecurringPreviewItem> items)?  $default,) {final _that = this;
switch (_that) {
case _RecurringPreviewResponse() when $default != null:
return $default(_that.ruleId,_that.isActive,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringPreviewResponse implements RecurringPreviewResponse {
  const _RecurringPreviewResponse({required this.ruleId, this.isActive = true, final  List<RecurringPreviewItem> items = const <RecurringPreviewItem>[]}): _items = items;
  factory _RecurringPreviewResponse.fromJson(Map<String, dynamic> json) => _$RecurringPreviewResponseFromJson(json);

@override final  String ruleId;
@override@JsonKey() final  bool isActive;
 final  List<RecurringPreviewItem> _items;
@override@JsonKey() List<RecurringPreviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of RecurringPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringPreviewResponseCopyWith<_RecurringPreviewResponse> get copyWith => __$RecurringPreviewResponseCopyWithImpl<_RecurringPreviewResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringPreviewResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringPreviewResponse&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ruleId,isActive,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'RecurringPreviewResponse(ruleId: $ruleId, isActive: $isActive, items: $items)';
}


}

/// @nodoc
abstract mixin class _$RecurringPreviewResponseCopyWith<$Res> implements $RecurringPreviewResponseCopyWith<$Res> {
  factory _$RecurringPreviewResponseCopyWith(_RecurringPreviewResponse value, $Res Function(_RecurringPreviewResponse) _then) = __$RecurringPreviewResponseCopyWithImpl;
@override @useResult
$Res call({
 String ruleId, bool isActive, List<RecurringPreviewItem> items
});




}
/// @nodoc
class __$RecurringPreviewResponseCopyWithImpl<$Res>
    implements _$RecurringPreviewResponseCopyWith<$Res> {
  __$RecurringPreviewResponseCopyWithImpl(this._self, this._then);

  final _RecurringPreviewResponse _self;
  final $Res Function(_RecurringPreviewResponse) _then;

/// Create a copy of RecurringPreviewResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ruleId = null,Object? isActive = null,Object? items = null,}) {
  return _then(_RecurringPreviewResponse(
ruleId: null == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringPreviewItem>,
  ));
}


}

// dart format on
