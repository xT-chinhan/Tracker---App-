// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletItem {

 String get id; String get name; String get type; int get initialBalance; int get balance; String? get icon; String? get color; bool get isArchived; String? get userId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of WalletItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletItemCopyWith<WalletItem> get copyWith => _$WalletItemCopyWithImpl<WalletItem>(this as WalletItem, _$identity);

  /// Serializes this WalletItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,initialBalance,balance,icon,color,isArchived,userId,createdAt,updatedAt);

@override
String toString() {
  return 'WalletItem(id: $id, name: $name, type: $type, initialBalance: $initialBalance, balance: $balance, icon: $icon, color: $color, isArchived: $isArchived, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WalletItemCopyWith<$Res>  {
  factory $WalletItemCopyWith(WalletItem value, $Res Function(WalletItem) _then) = _$WalletItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, int initialBalance, int balance, String? icon, String? color, bool isArchived, String? userId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$WalletItemCopyWithImpl<$Res>
    implements $WalletItemCopyWith<$Res> {
  _$WalletItemCopyWithImpl(this._self, this._then);

  final WalletItem _self;
  final $Res Function(WalletItem) _then;

/// Create a copy of WalletItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? balance = null,Object? icon = freezed,Object? color = freezed,Object? isArchived = null,Object? userId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletItem].
extension WalletItemPatterns on WalletItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletItem value)  $default,){
final _that = this;
switch (_that) {
case _WalletItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletItem value)?  $default,){
final _that = this;
switch (_that) {
case _WalletItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  int initialBalance,  int balance,  String? icon,  String? color,  bool isArchived,  String? userId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.userId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  int initialBalance,  int balance,  String? icon,  String? color,  bool isArchived,  String? userId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WalletItem():
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.userId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  int initialBalance,  int balance,  String? icon,  String? color,  bool isArchived,  String? userId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WalletItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.userId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletItem implements WalletItem {
  const _WalletItem({required this.id, required this.name, required this.type, this.initialBalance = 0, this.balance = 0, this.icon, this.color, this.isArchived = false, this.userId, this.createdAt, this.updatedAt});
  factory _WalletItem.fromJson(Map<String, dynamic> json) => _$WalletItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey() final  int initialBalance;
@override@JsonKey() final  int balance;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  bool isArchived;
@override final  String? userId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of WalletItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletItemCopyWith<_WalletItem> get copyWith => __$WalletItemCopyWithImpl<_WalletItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,initialBalance,balance,icon,color,isArchived,userId,createdAt,updatedAt);

@override
String toString() {
  return 'WalletItem(id: $id, name: $name, type: $type, initialBalance: $initialBalance, balance: $balance, icon: $icon, color: $color, isArchived: $isArchived, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WalletItemCopyWith<$Res> implements $WalletItemCopyWith<$Res> {
  factory _$WalletItemCopyWith(_WalletItem value, $Res Function(_WalletItem) _then) = __$WalletItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, int initialBalance, int balance, String? icon, String? color, bool isArchived, String? userId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$WalletItemCopyWithImpl<$Res>
    implements _$WalletItemCopyWith<$Res> {
  __$WalletItemCopyWithImpl(this._self, this._then);

  final _WalletItem _self;
  final $Res Function(_WalletItem) _then;

/// Create a copy of WalletItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? balance = null,Object? icon = freezed,Object? color = freezed,Object? isArchived = null,Object? userId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WalletItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$WalletListResponse {

 int get totalBalance; List<WalletItem> get items;
/// Create a copy of WalletListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletListResponseCopyWith<WalletListResponse> get copyWith => _$WalletListResponseCopyWithImpl<WalletListResponse>(this as WalletListResponse, _$identity);

  /// Serializes this WalletListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletListResponse&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBalance,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'WalletListResponse(totalBalance: $totalBalance, items: $items)';
}


}

/// @nodoc
abstract mixin class $WalletListResponseCopyWith<$Res>  {
  factory $WalletListResponseCopyWith(WalletListResponse value, $Res Function(WalletListResponse) _then) = _$WalletListResponseCopyWithImpl;
@useResult
$Res call({
 int totalBalance, List<WalletItem> items
});




}
/// @nodoc
class _$WalletListResponseCopyWithImpl<$Res>
    implements $WalletListResponseCopyWith<$Res> {
  _$WalletListResponseCopyWithImpl(this._self, this._then);

  final WalletListResponse _self;
  final $Res Function(WalletListResponse) _then;

/// Create a copy of WalletListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBalance = null,Object? items = null,}) {
  return _then(_self.copyWith(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<WalletItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletListResponse].
extension WalletListResponsePatterns on WalletListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletListResponse value)  $default,){
final _that = this;
switch (_that) {
case _WalletListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WalletListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBalance,  List<WalletItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletListResponse() when $default != null:
return $default(_that.totalBalance,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBalance,  List<WalletItem> items)  $default,) {final _that = this;
switch (_that) {
case _WalletListResponse():
return $default(_that.totalBalance,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBalance,  List<WalletItem> items)?  $default,) {final _that = this;
switch (_that) {
case _WalletListResponse() when $default != null:
return $default(_that.totalBalance,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletListResponse implements WalletListResponse {
  const _WalletListResponse({this.totalBalance = 0, final  List<WalletItem> items = const <WalletItem>[]}): _items = items;
  factory _WalletListResponse.fromJson(Map<String, dynamic> json) => _$WalletListResponseFromJson(json);

@override@JsonKey() final  int totalBalance;
 final  List<WalletItem> _items;
@override@JsonKey() List<WalletItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of WalletListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletListResponseCopyWith<_WalletListResponse> get copyWith => __$WalletListResponseCopyWithImpl<_WalletListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletListResponse&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalBalance,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'WalletListResponse(totalBalance: $totalBalance, items: $items)';
}


}

/// @nodoc
abstract mixin class _$WalletListResponseCopyWith<$Res> implements $WalletListResponseCopyWith<$Res> {
  factory _$WalletListResponseCopyWith(_WalletListResponse value, $Res Function(_WalletListResponse) _then) = __$WalletListResponseCopyWithImpl;
@override @useResult
$Res call({
 int totalBalance, List<WalletItem> items
});




}
/// @nodoc
class __$WalletListResponseCopyWithImpl<$Res>
    implements _$WalletListResponseCopyWith<$Res> {
  __$WalletListResponseCopyWithImpl(this._self, this._then);

  final _WalletListResponse _self;
  final $Res Function(_WalletListResponse) _then;

/// Create a copy of WalletListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBalance = null,Object? items = null,}) {
  return _then(_WalletListResponse(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<WalletItem>,
  ));
}


}


/// @nodoc
mixin _$CreateWalletDto {

 String get name; String get type; int? get initialBalance; String? get icon; String? get color;
/// Create a copy of CreateWalletDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWalletDtoCopyWith<CreateWalletDto> get copyWith => _$CreateWalletDtoCopyWithImpl<CreateWalletDto>(this as CreateWalletDto, _$identity);

  /// Serializes this CreateWalletDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWalletDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,initialBalance,icon,color);

@override
String toString() {
  return 'CreateWalletDto(name: $name, type: $type, initialBalance: $initialBalance, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $CreateWalletDtoCopyWith<$Res>  {
  factory $CreateWalletDtoCopyWith(CreateWalletDto value, $Res Function(CreateWalletDto) _then) = _$CreateWalletDtoCopyWithImpl;
@useResult
$Res call({
 String name, String type, int? initialBalance, String? icon, String? color
});




}
/// @nodoc
class _$CreateWalletDtoCopyWithImpl<$Res>
    implements $CreateWalletDtoCopyWith<$Res> {
  _$CreateWalletDtoCopyWithImpl(this._self, this._then);

  final CreateWalletDto _self;
  final $Res Function(CreateWalletDto) _then;

/// Create a copy of CreateWalletDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? initialBalance = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: freezed == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWalletDto].
extension CreateWalletDtoPatterns on CreateWalletDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWalletDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWalletDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWalletDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateWalletDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWalletDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWalletDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  int? initialBalance,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWalletDto() when $default != null:
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  int? initialBalance,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CreateWalletDto():
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  int? initialBalance,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CreateWalletDto() when $default != null:
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWalletDto implements CreateWalletDto {
  const _CreateWalletDto({required this.name, required this.type, this.initialBalance, this.icon, this.color});
  factory _CreateWalletDto.fromJson(Map<String, dynamic> json) => _$CreateWalletDtoFromJson(json);

@override final  String name;
@override final  String type;
@override final  int? initialBalance;
@override final  String? icon;
@override final  String? color;

/// Create a copy of CreateWalletDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWalletDtoCopyWith<_CreateWalletDto> get copyWith => __$CreateWalletDtoCopyWithImpl<_CreateWalletDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWalletDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWalletDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,initialBalance,icon,color);

@override
String toString() {
  return 'CreateWalletDto(name: $name, type: $type, initialBalance: $initialBalance, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CreateWalletDtoCopyWith<$Res> implements $CreateWalletDtoCopyWith<$Res> {
  factory _$CreateWalletDtoCopyWith(_CreateWalletDto value, $Res Function(_CreateWalletDto) _then) = __$CreateWalletDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, int? initialBalance, String? icon, String? color
});




}
/// @nodoc
class __$CreateWalletDtoCopyWithImpl<$Res>
    implements _$CreateWalletDtoCopyWith<$Res> {
  __$CreateWalletDtoCopyWithImpl(this._self, this._then);

  final _CreateWalletDto _self;
  final $Res Function(_CreateWalletDto) _then;

/// Create a copy of CreateWalletDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? initialBalance = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_CreateWalletDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: freezed == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateWalletDto {

 String? get name; String? get type; int? get initialBalance; String? get icon; String? get color;
/// Create a copy of UpdateWalletDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateWalletDtoCopyWith<UpdateWalletDto> get copyWith => _$UpdateWalletDtoCopyWithImpl<UpdateWalletDto>(this as UpdateWalletDto, _$identity);

  /// Serializes this UpdateWalletDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateWalletDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,initialBalance,icon,color);

@override
String toString() {
  return 'UpdateWalletDto(name: $name, type: $type, initialBalance: $initialBalance, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $UpdateWalletDtoCopyWith<$Res>  {
  factory $UpdateWalletDtoCopyWith(UpdateWalletDto value, $Res Function(UpdateWalletDto) _then) = _$UpdateWalletDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? type, int? initialBalance, String? icon, String? color
});




}
/// @nodoc
class _$UpdateWalletDtoCopyWithImpl<$Res>
    implements $UpdateWalletDtoCopyWith<$Res> {
  _$UpdateWalletDtoCopyWithImpl(this._self, this._then);

  final UpdateWalletDto _self;
  final $Res Function(UpdateWalletDto) _then;

/// Create a copy of UpdateWalletDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? type = freezed,Object? initialBalance = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,initialBalance: freezed == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateWalletDto].
extension UpdateWalletDtoPatterns on UpdateWalletDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateWalletDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateWalletDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateWalletDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateWalletDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateWalletDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateWalletDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? type,  int? initialBalance,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateWalletDto() when $default != null:
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? type,  int? initialBalance,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _UpdateWalletDto():
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? type,  int? initialBalance,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _UpdateWalletDto() when $default != null:
return $default(_that.name,_that.type,_that.initialBalance,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateWalletDto implements UpdateWalletDto {
  const _UpdateWalletDto({this.name, this.type, this.initialBalance, this.icon, this.color});
  factory _UpdateWalletDto.fromJson(Map<String, dynamic> json) => _$UpdateWalletDtoFromJson(json);

@override final  String? name;
@override final  String? type;
@override final  int? initialBalance;
@override final  String? icon;
@override final  String? color;

/// Create a copy of UpdateWalletDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateWalletDtoCopyWith<_UpdateWalletDto> get copyWith => __$UpdateWalletDtoCopyWithImpl<_UpdateWalletDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateWalletDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateWalletDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,initialBalance,icon,color);

@override
String toString() {
  return 'UpdateWalletDto(name: $name, type: $type, initialBalance: $initialBalance, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$UpdateWalletDtoCopyWith<$Res> implements $UpdateWalletDtoCopyWith<$Res> {
  factory _$UpdateWalletDtoCopyWith(_UpdateWalletDto value, $Res Function(_UpdateWalletDto) _then) = __$UpdateWalletDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? type, int? initialBalance, String? icon, String? color
});




}
/// @nodoc
class __$UpdateWalletDtoCopyWithImpl<$Res>
    implements _$UpdateWalletDtoCopyWith<$Res> {
  __$UpdateWalletDtoCopyWithImpl(this._self, this._then);

  final _UpdateWalletDto _self;
  final $Res Function(_UpdateWalletDto) _then;

/// Create a copy of UpdateWalletDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? type = freezed,Object? initialBalance = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_UpdateWalletDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,initialBalance: freezed == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
