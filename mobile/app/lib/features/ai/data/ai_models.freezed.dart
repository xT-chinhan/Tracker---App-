// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiConversationItem {

 String get id; String? get title; bool get archived; bool get pinned; String? get scope;@JsonKey(fromJson: _toInt) int get messageCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AiConversationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConversationItemCopyWith<AiConversationItem> get copyWith => _$AiConversationItemCopyWithImpl<AiConversationItem>(this as AiConversationItem, _$identity);

  /// Serializes this AiConversationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConversationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,messageCount,createdAt,updatedAt);

@override
String toString() {
  return 'AiConversationItem(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AiConversationItemCopyWith<$Res>  {
  factory $AiConversationItemCopyWith(AiConversationItem value, $Res Function(AiConversationItem) _then) = _$AiConversationItemCopyWithImpl;
@useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope,@JsonKey(fromJson: _toInt) int messageCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AiConversationItemCopyWithImpl<$Res>
    implements $AiConversationItemCopyWith<$Res> {
  _$AiConversationItemCopyWithImpl(this._self, this._then);

  final AiConversationItem _self;
  final $Res Function(AiConversationItem) _then;

/// Create a copy of AiConversationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? messageCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConversationItem].
extension AiConversationItemPatterns on AiConversationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConversationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConversationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConversationItem value)  $default,){
final _that = this;
switch (_that) {
case _AiConversationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConversationItem value)?  $default,){
final _that = this;
switch (_that) {
case _AiConversationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope, @JsonKey(fromJson: _toInt)  int messageCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConversationItem() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messageCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope, @JsonKey(fromJson: _toInt)  int messageCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AiConversationItem():
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messageCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  bool archived,  bool pinned,  String? scope, @JsonKey(fromJson: _toInt)  int messageCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiConversationItem() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messageCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConversationItem implements AiConversationItem {
  const _AiConversationItem({required this.id, this.title, this.archived = false, this.pinned = false, this.scope, @JsonKey(fromJson: _toInt) this.messageCount = 0, required this.createdAt, required this.updatedAt});
  factory _AiConversationItem.fromJson(Map<String, dynamic> json) => _$AiConversationItemFromJson(json);

@override final  String id;
@override final  String? title;
@override@JsonKey() final  bool archived;
@override@JsonKey() final  bool pinned;
@override final  String? scope;
@override@JsonKey(fromJson: _toInt) final  int messageCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AiConversationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConversationItemCopyWith<_AiConversationItem> get copyWith => __$AiConversationItemCopyWithImpl<_AiConversationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConversationItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConversationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,messageCount,createdAt,updatedAt);

@override
String toString() {
  return 'AiConversationItem(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AiConversationItemCopyWith<$Res> implements $AiConversationItemCopyWith<$Res> {
  factory _$AiConversationItemCopyWith(_AiConversationItem value, $Res Function(_AiConversationItem) _then) = __$AiConversationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope,@JsonKey(fromJson: _toInt) int messageCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AiConversationItemCopyWithImpl<$Res>
    implements _$AiConversationItemCopyWith<$Res> {
  __$AiConversationItemCopyWithImpl(this._self, this._then);

  final _AiConversationItem _self;
  final $Res Function(_AiConversationItem) _then;

/// Create a copy of AiConversationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? messageCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AiConversationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AiConversationPage {

 List<AiConversationItem> get items;@JsonKey(fromJson: _toInt) int get total;@JsonKey(fromJson: _toInt) int get page;@JsonKey(fromJson: _toInt) int get limit;
/// Create a copy of AiConversationPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConversationPageCopyWith<AiConversationPage> get copyWith => _$AiConversationPageCopyWithImpl<AiConversationPage>(this as AiConversationPage, _$identity);

  /// Serializes this AiConversationPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConversationPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,limit);

@override
String toString() {
  return 'AiConversationPage(items: $items, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $AiConversationPageCopyWith<$Res>  {
  factory $AiConversationPageCopyWith(AiConversationPage value, $Res Function(AiConversationPage) _then) = _$AiConversationPageCopyWithImpl;
@useResult
$Res call({
 List<AiConversationItem> items,@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int page,@JsonKey(fromJson: _toInt) int limit
});




}
/// @nodoc
class _$AiConversationPageCopyWithImpl<$Res>
    implements $AiConversationPageCopyWith<$Res> {
  _$AiConversationPageCopyWithImpl(this._self, this._then);

  final AiConversationPage _self;
  final $Res Function(AiConversationPage) _then;

/// Create a copy of AiConversationPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AiConversationItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConversationPage].
extension AiConversationPagePatterns on AiConversationPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConversationPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConversationPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConversationPage value)  $default,){
final _that = this;
switch (_that) {
case _AiConversationPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConversationPage value)?  $default,){
final _that = this;
switch (_that) {
case _AiConversationPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AiConversationItem> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int page, @JsonKey(fromJson: _toInt)  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConversationPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AiConversationItem> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int page, @JsonKey(fromJson: _toInt)  int limit)  $default,) {final _that = this;
switch (_that) {
case _AiConversationPage():
return $default(_that.items,_that.total,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AiConversationItem> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int page, @JsonKey(fromJson: _toInt)  int limit)?  $default,) {final _that = this;
switch (_that) {
case _AiConversationPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConversationPage implements AiConversationPage {
  const _AiConversationPage({final  List<AiConversationItem> items = const <AiConversationItem>[], @JsonKey(fromJson: _toInt) this.total = 0, @JsonKey(fromJson: _toInt) this.page = 1, @JsonKey(fromJson: _toInt) this.limit = 20}): _items = items;
  factory _AiConversationPage.fromJson(Map<String, dynamic> json) => _$AiConversationPageFromJson(json);

 final  List<AiConversationItem> _items;
@override@JsonKey() List<AiConversationItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(fromJson: _toInt) final  int total;
@override@JsonKey(fromJson: _toInt) final  int page;
@override@JsonKey(fromJson: _toInt) final  int limit;

/// Create a copy of AiConversationPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConversationPageCopyWith<_AiConversationPage> get copyWith => __$AiConversationPageCopyWithImpl<_AiConversationPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConversationPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConversationPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,limit);

@override
String toString() {
  return 'AiConversationPage(items: $items, total: $total, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$AiConversationPageCopyWith<$Res> implements $AiConversationPageCopyWith<$Res> {
  factory _$AiConversationPageCopyWith(_AiConversationPage value, $Res Function(_AiConversationPage) _then) = __$AiConversationPageCopyWithImpl;
@override @useResult
$Res call({
 List<AiConversationItem> items,@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int page,@JsonKey(fromJson: _toInt) int limit
});




}
/// @nodoc
class __$AiConversationPageCopyWithImpl<$Res>
    implements _$AiConversationPageCopyWith<$Res> {
  __$AiConversationPageCopyWithImpl(this._self, this._then);

  final _AiConversationPage _self;
  final $Res Function(_AiConversationPage) _then;

/// Create a copy of AiConversationPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,}) {
  return _then(_AiConversationPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AiConversationItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AiDraftItem {

 String get id; String get messageId; String get skill; String get kind; String get status; Map<String, dynamic>? get payload; Map<String, dynamic>? get finalPayload; dynamic get result; DateTime? get resolvedAt; DateTime get createdAt;
/// Create a copy of AiDraftItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<AiDraftItem> get copyWith => _$AiDraftItemCopyWithImpl<AiDraftItem>(this as AiDraftItem, _$identity);

  /// Serializes this AiDraftItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDraftItem&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.finalPayload, finalPayload)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,skill,kind,status,const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(finalPayload),const DeepCollectionEquality().hash(result),resolvedAt,createdAt);

@override
String toString() {
  return 'AiDraftItem(id: $id, messageId: $messageId, skill: $skill, kind: $kind, status: $status, payload: $payload, finalPayload: $finalPayload, result: $result, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AiDraftItemCopyWith<$Res>  {
  factory $AiDraftItemCopyWith(AiDraftItem value, $Res Function(AiDraftItem) _then) = _$AiDraftItemCopyWithImpl;
@useResult
$Res call({
 String id, String messageId, String skill, String kind, String status, Map<String, dynamic>? payload, Map<String, dynamic>? finalPayload, dynamic result, DateTime? resolvedAt, DateTime createdAt
});




}
/// @nodoc
class _$AiDraftItemCopyWithImpl<$Res>
    implements $AiDraftItemCopyWith<$Res> {
  _$AiDraftItemCopyWithImpl(this._self, this._then);

  final AiDraftItem _self;
  final $Res Function(AiDraftItem) _then;

/// Create a copy of AiDraftItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? skill = null,Object? kind = null,Object? status = null,Object? payload = freezed,Object? finalPayload = freezed,Object? result = freezed,Object? resolvedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,finalPayload: freezed == finalPayload ? _self.finalPayload : finalPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiDraftItem].
extension AiDraftItemPatterns on AiDraftItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiDraftItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiDraftItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiDraftItem value)  $default,){
final _that = this;
switch (_that) {
case _AiDraftItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiDraftItem value)?  $default,){
final _that = this;
switch (_that) {
case _AiDraftItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String messageId,  String skill,  String kind,  String status,  Map<String, dynamic>? payload,  Map<String, dynamic>? finalPayload,  dynamic result,  DateTime? resolvedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiDraftItem() when $default != null:
return $default(_that.id,_that.messageId,_that.skill,_that.kind,_that.status,_that.payload,_that.finalPayload,_that.result,_that.resolvedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String messageId,  String skill,  String kind,  String status,  Map<String, dynamic>? payload,  Map<String, dynamic>? finalPayload,  dynamic result,  DateTime? resolvedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AiDraftItem():
return $default(_that.id,_that.messageId,_that.skill,_that.kind,_that.status,_that.payload,_that.finalPayload,_that.result,_that.resolvedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String messageId,  String skill,  String kind,  String status,  Map<String, dynamic>? payload,  Map<String, dynamic>? finalPayload,  dynamic result,  DateTime? resolvedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AiDraftItem() when $default != null:
return $default(_that.id,_that.messageId,_that.skill,_that.kind,_that.status,_that.payload,_that.finalPayload,_that.result,_that.resolvedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiDraftItem implements AiDraftItem {
  const _AiDraftItem({required this.id, required this.messageId, required this.skill, required this.kind, this.status = 'PROPOSED', final  Map<String, dynamic>? payload, final  Map<String, dynamic>? finalPayload, this.result, this.resolvedAt, required this.createdAt}): _payload = payload,_finalPayload = finalPayload;
  factory _AiDraftItem.fromJson(Map<String, dynamic> json) => _$AiDraftItemFromJson(json);

@override final  String id;
@override final  String messageId;
@override final  String skill;
@override final  String kind;
@override@JsonKey() final  String status;
 final  Map<String, dynamic>? _payload;
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _finalPayload;
@override Map<String, dynamic>? get finalPayload {
  final value = _finalPayload;
  if (value == null) return null;
  if (_finalPayload is EqualUnmodifiableMapView) return _finalPayload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  dynamic result;
@override final  DateTime? resolvedAt;
@override final  DateTime createdAt;

/// Create a copy of AiDraftItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiDraftItemCopyWith<_AiDraftItem> get copyWith => __$AiDraftItemCopyWithImpl<_AiDraftItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiDraftItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiDraftItem&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._payload, _payload)&&const DeepCollectionEquality().equals(other._finalPayload, _finalPayload)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,skill,kind,status,const DeepCollectionEquality().hash(_payload),const DeepCollectionEquality().hash(_finalPayload),const DeepCollectionEquality().hash(result),resolvedAt,createdAt);

@override
String toString() {
  return 'AiDraftItem(id: $id, messageId: $messageId, skill: $skill, kind: $kind, status: $status, payload: $payload, finalPayload: $finalPayload, result: $result, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AiDraftItemCopyWith<$Res> implements $AiDraftItemCopyWith<$Res> {
  factory _$AiDraftItemCopyWith(_AiDraftItem value, $Res Function(_AiDraftItem) _then) = __$AiDraftItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String messageId, String skill, String kind, String status, Map<String, dynamic>? payload, Map<String, dynamic>? finalPayload, dynamic result, DateTime? resolvedAt, DateTime createdAt
});




}
/// @nodoc
class __$AiDraftItemCopyWithImpl<$Res>
    implements _$AiDraftItemCopyWith<$Res> {
  __$AiDraftItemCopyWithImpl(this._self, this._then);

  final _AiDraftItem _self;
  final $Res Function(_AiDraftItem) _then;

/// Create a copy of AiDraftItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? skill = null,Object? kind = null,Object? status = null,Object? payload = freezed,Object? finalPayload = freezed,Object? result = freezed,Object? resolvedAt = freezed,Object? createdAt = null,}) {
  return _then(_AiDraftItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,finalPayload: freezed == finalPayload ? _self._finalPayload : finalPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AiMessageTokens {

@JsonKey(fromJson: _toInt) int get prompt;@JsonKey(fromJson: _toInt) int get eval;
/// Create a copy of AiMessageTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMessageTokensCopyWith<AiMessageTokens> get copyWith => _$AiMessageTokensCopyWithImpl<AiMessageTokens>(this as AiMessageTokens, _$identity);

  /// Serializes this AiMessageTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMessageTokens&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.eval, eval) || other.eval == eval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,eval);

@override
String toString() {
  return 'AiMessageTokens(prompt: $prompt, eval: $eval)';
}


}

/// @nodoc
abstract mixin class $AiMessageTokensCopyWith<$Res>  {
  factory $AiMessageTokensCopyWith(AiMessageTokens value, $Res Function(AiMessageTokens) _then) = _$AiMessageTokensCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int prompt,@JsonKey(fromJson: _toInt) int eval
});




}
/// @nodoc
class _$AiMessageTokensCopyWithImpl<$Res>
    implements $AiMessageTokensCopyWith<$Res> {
  _$AiMessageTokensCopyWithImpl(this._self, this._then);

  final AiMessageTokens _self;
  final $Res Function(AiMessageTokens) _then;

/// Create a copy of AiMessageTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompt = null,Object? eval = null,}) {
  return _then(_self.copyWith(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as int,eval: null == eval ? _self.eval : eval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiMessageTokens].
extension AiMessageTokensPatterns on AiMessageTokens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMessageTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMessageTokens() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMessageTokens value)  $default,){
final _that = this;
switch (_that) {
case _AiMessageTokens():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMessageTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AiMessageTokens() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int prompt, @JsonKey(fromJson: _toInt)  int eval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMessageTokens() when $default != null:
return $default(_that.prompt,_that.eval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int prompt, @JsonKey(fromJson: _toInt)  int eval)  $default,) {final _that = this;
switch (_that) {
case _AiMessageTokens():
return $default(_that.prompt,_that.eval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int prompt, @JsonKey(fromJson: _toInt)  int eval)?  $default,) {final _that = this;
switch (_that) {
case _AiMessageTokens() when $default != null:
return $default(_that.prompt,_that.eval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiMessageTokens implements AiMessageTokens {
  const _AiMessageTokens({@JsonKey(fromJson: _toInt) this.prompt = 0, @JsonKey(fromJson: _toInt) this.eval = 0});
  factory _AiMessageTokens.fromJson(Map<String, dynamic> json) => _$AiMessageTokensFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int prompt;
@override@JsonKey(fromJson: _toInt) final  int eval;

/// Create a copy of AiMessageTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMessageTokensCopyWith<_AiMessageTokens> get copyWith => __$AiMessageTokensCopyWithImpl<_AiMessageTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiMessageTokensToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMessageTokens&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.eval, eval) || other.eval == eval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prompt,eval);

@override
String toString() {
  return 'AiMessageTokens(prompt: $prompt, eval: $eval)';
}


}

/// @nodoc
abstract mixin class _$AiMessageTokensCopyWith<$Res> implements $AiMessageTokensCopyWith<$Res> {
  factory _$AiMessageTokensCopyWith(_AiMessageTokens value, $Res Function(_AiMessageTokens) _then) = __$AiMessageTokensCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int prompt,@JsonKey(fromJson: _toInt) int eval
});




}
/// @nodoc
class __$AiMessageTokensCopyWithImpl<$Res>
    implements _$AiMessageTokensCopyWith<$Res> {
  __$AiMessageTokensCopyWithImpl(this._self, this._then);

  final _AiMessageTokens _self;
  final $Res Function(_AiMessageTokens) _then;

/// Create a copy of AiMessageTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompt = null,Object? eval = null,}) {
  return _then(_AiMessageTokens(
prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as int,eval: null == eval ? _self.eval : eval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AiMessageItem {

 String get id; String get conversationId; String get role; String get content; String? get skill; String? get routeBy; String? get status; int? get latencyMs; AiMessageTokens? get tokens; List<String> get followUps; DateTime get createdAt; AiDraftItem? get draft;
/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMessageItemCopyWith<AiMessageItem> get copyWith => _$AiMessageItemCopyWithImpl<AiMessageItem>(this as AiMessageItem, _$identity);

  /// Serializes this AiMessageItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMessageItem&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.routeBy, routeBy) || other.routeBy == routeBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&const DeepCollectionEquality().equals(other.followUps, followUps)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.draft, draft) || other.draft == draft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,role,content,skill,routeBy,status,latencyMs,tokens,const DeepCollectionEquality().hash(followUps),createdAt,draft);

@override
String toString() {
  return 'AiMessageItem(id: $id, conversationId: $conversationId, role: $role, content: $content, skill: $skill, routeBy: $routeBy, status: $status, latencyMs: $latencyMs, tokens: $tokens, followUps: $followUps, createdAt: $createdAt, draft: $draft)';
}


}

/// @nodoc
abstract mixin class $AiMessageItemCopyWith<$Res>  {
  factory $AiMessageItemCopyWith(AiMessageItem value, $Res Function(AiMessageItem) _then) = _$AiMessageItemCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String role, String content, String? skill, String? routeBy, String? status, int? latencyMs, AiMessageTokens? tokens, List<String> followUps, DateTime createdAt, AiDraftItem? draft
});


$AiMessageTokensCopyWith<$Res>? get tokens;$AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class _$AiMessageItemCopyWithImpl<$Res>
    implements $AiMessageItemCopyWith<$Res> {
  _$AiMessageItemCopyWithImpl(this._self, this._then);

  final AiMessageItem _self;
  final $Res Function(AiMessageItem) _then;

/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? role = null,Object? content = null,Object? skill = freezed,Object? routeBy = freezed,Object? status = freezed,Object? latencyMs = freezed,Object? tokens = freezed,Object? followUps = null,Object? createdAt = null,Object? draft = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String?,routeBy: freezed == routeBy ? _self.routeBy : routeBy // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,tokens: freezed == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AiMessageTokens?,followUps: null == followUps ? _self.followUps : followUps // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,
  ));
}
/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageTokensCopyWith<$Res>? get tokens {
    if (_self.tokens == null) {
    return null;
  }

  return $AiMessageTokensCopyWith<$Res>(_self.tokens!, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiMessageItem].
extension AiMessageItemPatterns on AiMessageItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMessageItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMessageItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMessageItem value)  $default,){
final _that = this;
switch (_that) {
case _AiMessageItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMessageItem value)?  $default,){
final _that = this;
switch (_that) {
case _AiMessageItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String role,  String content,  String? skill,  String? routeBy,  String? status,  int? latencyMs,  AiMessageTokens? tokens,  List<String> followUps,  DateTime createdAt,  AiDraftItem? draft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMessageItem() when $default != null:
return $default(_that.id,_that.conversationId,_that.role,_that.content,_that.skill,_that.routeBy,_that.status,_that.latencyMs,_that.tokens,_that.followUps,_that.createdAt,_that.draft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String role,  String content,  String? skill,  String? routeBy,  String? status,  int? latencyMs,  AiMessageTokens? tokens,  List<String> followUps,  DateTime createdAt,  AiDraftItem? draft)  $default,) {final _that = this;
switch (_that) {
case _AiMessageItem():
return $default(_that.id,_that.conversationId,_that.role,_that.content,_that.skill,_that.routeBy,_that.status,_that.latencyMs,_that.tokens,_that.followUps,_that.createdAt,_that.draft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String role,  String content,  String? skill,  String? routeBy,  String? status,  int? latencyMs,  AiMessageTokens? tokens,  List<String> followUps,  DateTime createdAt,  AiDraftItem? draft)?  $default,) {final _that = this;
switch (_that) {
case _AiMessageItem() when $default != null:
return $default(_that.id,_that.conversationId,_that.role,_that.content,_that.skill,_that.routeBy,_that.status,_that.latencyMs,_that.tokens,_that.followUps,_that.createdAt,_that.draft);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiMessageItem implements AiMessageItem {
  const _AiMessageItem({required this.id, required this.conversationId, required this.role, required this.content, this.skill, this.routeBy, this.status, this.latencyMs, this.tokens, final  List<String> followUps = const <String>[], required this.createdAt, this.draft}): _followUps = followUps;
  factory _AiMessageItem.fromJson(Map<String, dynamic> json) => _$AiMessageItemFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String role;
@override final  String content;
@override final  String? skill;
@override final  String? routeBy;
@override final  String? status;
@override final  int? latencyMs;
@override final  AiMessageTokens? tokens;
 final  List<String> _followUps;
@override@JsonKey() List<String> get followUps {
  if (_followUps is EqualUnmodifiableListView) return _followUps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followUps);
}

@override final  DateTime createdAt;
@override final  AiDraftItem? draft;

/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMessageItemCopyWith<_AiMessageItem> get copyWith => __$AiMessageItemCopyWithImpl<_AiMessageItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiMessageItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMessageItem&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.routeBy, routeBy) || other.routeBy == routeBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.tokens, tokens) || other.tokens == tokens)&&const DeepCollectionEquality().equals(other._followUps, _followUps)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.draft, draft) || other.draft == draft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,role,content,skill,routeBy,status,latencyMs,tokens,const DeepCollectionEquality().hash(_followUps),createdAt,draft);

@override
String toString() {
  return 'AiMessageItem(id: $id, conversationId: $conversationId, role: $role, content: $content, skill: $skill, routeBy: $routeBy, status: $status, latencyMs: $latencyMs, tokens: $tokens, followUps: $followUps, createdAt: $createdAt, draft: $draft)';
}


}

/// @nodoc
abstract mixin class _$AiMessageItemCopyWith<$Res> implements $AiMessageItemCopyWith<$Res> {
  factory _$AiMessageItemCopyWith(_AiMessageItem value, $Res Function(_AiMessageItem) _then) = __$AiMessageItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String role, String content, String? skill, String? routeBy, String? status, int? latencyMs, AiMessageTokens? tokens, List<String> followUps, DateTime createdAt, AiDraftItem? draft
});


@override $AiMessageTokensCopyWith<$Res>? get tokens;@override $AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class __$AiMessageItemCopyWithImpl<$Res>
    implements _$AiMessageItemCopyWith<$Res> {
  __$AiMessageItemCopyWithImpl(this._self, this._then);

  final _AiMessageItem _self;
  final $Res Function(_AiMessageItem) _then;

/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? role = null,Object? content = null,Object? skill = freezed,Object? routeBy = freezed,Object? status = freezed,Object? latencyMs = freezed,Object? tokens = freezed,Object? followUps = null,Object? createdAt = null,Object? draft = freezed,}) {
  return _then(_AiMessageItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String?,routeBy: freezed == routeBy ? _self.routeBy : routeBy // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,tokens: freezed == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AiMessageTokens?,followUps: null == followUps ? _self._followUps : followUps // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,
  ));
}

/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageTokensCopyWith<$Res>? get tokens {
    if (_self.tokens == null) {
    return null;
  }

  return $AiMessageTokensCopyWith<$Res>(_self.tokens!, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of AiMessageItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// @nodoc
mixin _$AiConversationDetail {

 String get id; String? get title; bool get archived; bool get pinned; String? get scope; List<AiMessageItem> get messages; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AiConversationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConversationDetailCopyWith<AiConversationDetail> get copyWith => _$AiConversationDetailCopyWithImpl<AiConversationDetail>(this as AiConversationDetail, _$identity);

  /// Serializes this AiConversationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConversationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,const DeepCollectionEquality().hash(messages),createdAt,updatedAt);

@override
String toString() {
  return 'AiConversationDetail(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, messages: $messages, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AiConversationDetailCopyWith<$Res>  {
  factory $AiConversationDetailCopyWith(AiConversationDetail value, $Res Function(AiConversationDetail) _then) = _$AiConversationDetailCopyWithImpl;
@useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope, List<AiMessageItem> messages, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AiConversationDetailCopyWithImpl<$Res>
    implements $AiConversationDetailCopyWith<$Res> {
  _$AiConversationDetailCopyWithImpl(this._self, this._then);

  final AiConversationDetail _self;
  final $Res Function(AiConversationDetail) _then;

/// Create a copy of AiConversationDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? messages = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<AiMessageItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConversationDetail].
extension AiConversationDetailPatterns on AiConversationDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConversationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConversationDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConversationDetail value)  $default,){
final _that = this;
switch (_that) {
case _AiConversationDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConversationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AiConversationDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  List<AiMessageItem> messages,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConversationDetail() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messages,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  List<AiMessageItem> messages,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AiConversationDetail():
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messages,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  List<AiMessageItem> messages,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiConversationDetail() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.messages,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConversationDetail implements AiConversationDetail {
  const _AiConversationDetail({required this.id, this.title, this.archived = false, this.pinned = false, this.scope, final  List<AiMessageItem> messages = const <AiMessageItem>[], required this.createdAt, required this.updatedAt}): _messages = messages;
  factory _AiConversationDetail.fromJson(Map<String, dynamic> json) => _$AiConversationDetailFromJson(json);

@override final  String id;
@override final  String? title;
@override@JsonKey() final  bool archived;
@override@JsonKey() final  bool pinned;
@override final  String? scope;
 final  List<AiMessageItem> _messages;
@override@JsonKey() List<AiMessageItem> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AiConversationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConversationDetailCopyWith<_AiConversationDetail> get copyWith => __$AiConversationDetailCopyWithImpl<_AiConversationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConversationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConversationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,const DeepCollectionEquality().hash(_messages),createdAt,updatedAt);

@override
String toString() {
  return 'AiConversationDetail(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, messages: $messages, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AiConversationDetailCopyWith<$Res> implements $AiConversationDetailCopyWith<$Res> {
  factory _$AiConversationDetailCopyWith(_AiConversationDetail value, $Res Function(_AiConversationDetail) _then) = __$AiConversationDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope, List<AiMessageItem> messages, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AiConversationDetailCopyWithImpl<$Res>
    implements _$AiConversationDetailCopyWith<$Res> {
  __$AiConversationDetailCopyWithImpl(this._self, this._then);

  final _AiConversationDetail _self;
  final $Res Function(_AiConversationDetail) _then;

/// Create a copy of AiConversationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? messages = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AiConversationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<AiMessageItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CreateConversationResponse {

 String get id; String? get title; bool get archived; bool get pinned; String? get scope; Map<String, dynamic>? get autoArchived; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CreateConversationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateConversationResponseCopyWith<CreateConversationResponse> get copyWith => _$CreateConversationResponseCopyWithImpl<CreateConversationResponse>(this as CreateConversationResponse, _$identity);

  /// Serializes this CreateConversationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other.autoArchived, autoArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,const DeepCollectionEquality().hash(autoArchived),createdAt,updatedAt);

@override
String toString() {
  return 'CreateConversationResponse(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, autoArchived: $autoArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CreateConversationResponseCopyWith<$Res>  {
  factory $CreateConversationResponseCopyWith(CreateConversationResponse value, $Res Function(CreateConversationResponse) _then) = _$CreateConversationResponseCopyWithImpl;
@useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope, Map<String, dynamic>? autoArchived, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CreateConversationResponseCopyWithImpl<$Res>
    implements $CreateConversationResponseCopyWith<$Res> {
  _$CreateConversationResponseCopyWithImpl(this._self, this._then);

  final CreateConversationResponse _self;
  final $Res Function(CreateConversationResponse) _then;

/// Create a copy of CreateConversationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? autoArchived = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,autoArchived: freezed == autoArchived ? _self.autoArchived : autoArchived // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateConversationResponse].
extension CreateConversationResponsePatterns on CreateConversationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateConversationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateConversationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateConversationResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreateConversationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateConversationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreateConversationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  Map<String, dynamic>? autoArchived,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateConversationResponse() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.autoArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  Map<String, dynamic>? autoArchived,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CreateConversationResponse():
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.autoArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  bool archived,  bool pinned,  String? scope,  Map<String, dynamic>? autoArchived,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateConversationResponse() when $default != null:
return $default(_that.id,_that.title,_that.archived,_that.pinned,_that.scope,_that.autoArchived,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateConversationResponse implements CreateConversationResponse {
  const _CreateConversationResponse({required this.id, this.title, this.archived = false, this.pinned = false, this.scope, final  Map<String, dynamic>? autoArchived, required this.createdAt, required this.updatedAt}): _autoArchived = autoArchived;
  factory _CreateConversationResponse.fromJson(Map<String, dynamic> json) => _$CreateConversationResponseFromJson(json);

@override final  String id;
@override final  String? title;
@override@JsonKey() final  bool archived;
@override@JsonKey() final  bool pinned;
@override final  String? scope;
 final  Map<String, dynamic>? _autoArchived;
@override Map<String, dynamic>? get autoArchived {
  final value = _autoArchived;
  if (value == null) return null;
  if (_autoArchived is EqualUnmodifiableMapView) return _autoArchived;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CreateConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateConversationResponseCopyWith<_CreateConversationResponse> get copyWith => __$CreateConversationResponseCopyWithImpl<_CreateConversationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateConversationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateConversationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.scope, scope) || other.scope == scope)&&const DeepCollectionEquality().equals(other._autoArchived, _autoArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,archived,pinned,scope,const DeepCollectionEquality().hash(_autoArchived),createdAt,updatedAt);

@override
String toString() {
  return 'CreateConversationResponse(id: $id, title: $title, archived: $archived, pinned: $pinned, scope: $scope, autoArchived: $autoArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CreateConversationResponseCopyWith<$Res> implements $CreateConversationResponseCopyWith<$Res> {
  factory _$CreateConversationResponseCopyWith(_CreateConversationResponse value, $Res Function(_CreateConversationResponse) _then) = __$CreateConversationResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, bool archived, bool pinned, String? scope, Map<String, dynamic>? autoArchived, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CreateConversationResponseCopyWithImpl<$Res>
    implements _$CreateConversationResponseCopyWith<$Res> {
  __$CreateConversationResponseCopyWithImpl(this._self, this._then);

  final _CreateConversationResponse _self;
  final $Res Function(_CreateConversationResponse) _then;

/// Create a copy of CreateConversationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? archived = null,Object? pinned = null,Object? scope = freezed,Object? autoArchived = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CreateConversationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,autoArchived: freezed == autoArchived ? _self._autoArchived : autoArchived // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PostMessageResponse {

 AiMessageItem get userMessage; AiMessageItem get message; AiDraftItem? get draft;
/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostMessageResponseCopyWith<PostMessageResponse> get copyWith => _$PostMessageResponseCopyWithImpl<PostMessageResponse>(this as PostMessageResponse, _$identity);

  /// Serializes this PostMessageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostMessageResponse&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.message, message) || other.message == message)&&(identical(other.draft, draft) || other.draft == draft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,message,draft);

@override
String toString() {
  return 'PostMessageResponse(userMessage: $userMessage, message: $message, draft: $draft)';
}


}

/// @nodoc
abstract mixin class $PostMessageResponseCopyWith<$Res>  {
  factory $PostMessageResponseCopyWith(PostMessageResponse value, $Res Function(PostMessageResponse) _then) = _$PostMessageResponseCopyWithImpl;
@useResult
$Res call({
 AiMessageItem userMessage, AiMessageItem message, AiDraftItem? draft
});


$AiMessageItemCopyWith<$Res> get userMessage;$AiMessageItemCopyWith<$Res> get message;$AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class _$PostMessageResponseCopyWithImpl<$Res>
    implements $PostMessageResponseCopyWith<$Res> {
  _$PostMessageResponseCopyWithImpl(this._self, this._then);

  final PostMessageResponse _self;
  final $Res Function(PostMessageResponse) _then;

/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userMessage = null,Object? message = null,Object? draft = freezed,}) {
  return _then(_self.copyWith(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as AiMessageItem,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as AiMessageItem,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,
  ));
}
/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageItemCopyWith<$Res> get userMessage {
  
  return $AiMessageItemCopyWith<$Res>(_self.userMessage, (value) {
    return _then(_self.copyWith(userMessage: value));
  });
}/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageItemCopyWith<$Res> get message {
  
  return $AiMessageItemCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostMessageResponse].
extension PostMessageResponsePatterns on PostMessageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostMessageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostMessageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostMessageResponse value)  $default,){
final _that = this;
switch (_that) {
case _PostMessageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostMessageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PostMessageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AiMessageItem userMessage,  AiMessageItem message,  AiDraftItem? draft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostMessageResponse() when $default != null:
return $default(_that.userMessage,_that.message,_that.draft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AiMessageItem userMessage,  AiMessageItem message,  AiDraftItem? draft)  $default,) {final _that = this;
switch (_that) {
case _PostMessageResponse():
return $default(_that.userMessage,_that.message,_that.draft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AiMessageItem userMessage,  AiMessageItem message,  AiDraftItem? draft)?  $default,) {final _that = this;
switch (_that) {
case _PostMessageResponse() when $default != null:
return $default(_that.userMessage,_that.message,_that.draft);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostMessageResponse implements PostMessageResponse {
  const _PostMessageResponse({required this.userMessage, required this.message, this.draft});
  factory _PostMessageResponse.fromJson(Map<String, dynamic> json) => _$PostMessageResponseFromJson(json);

@override final  AiMessageItem userMessage;
@override final  AiMessageItem message;
@override final  AiDraftItem? draft;

/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostMessageResponseCopyWith<_PostMessageResponse> get copyWith => __$PostMessageResponseCopyWithImpl<_PostMessageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostMessageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostMessageResponse&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.message, message) || other.message == message)&&(identical(other.draft, draft) || other.draft == draft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,message,draft);

@override
String toString() {
  return 'PostMessageResponse(userMessage: $userMessage, message: $message, draft: $draft)';
}


}

/// @nodoc
abstract mixin class _$PostMessageResponseCopyWith<$Res> implements $PostMessageResponseCopyWith<$Res> {
  factory _$PostMessageResponseCopyWith(_PostMessageResponse value, $Res Function(_PostMessageResponse) _then) = __$PostMessageResponseCopyWithImpl;
@override @useResult
$Res call({
 AiMessageItem userMessage, AiMessageItem message, AiDraftItem? draft
});


@override $AiMessageItemCopyWith<$Res> get userMessage;@override $AiMessageItemCopyWith<$Res> get message;@override $AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class __$PostMessageResponseCopyWithImpl<$Res>
    implements _$PostMessageResponseCopyWith<$Res> {
  __$PostMessageResponseCopyWithImpl(this._self, this._then);

  final _PostMessageResponse _self;
  final $Res Function(_PostMessageResponse) _then;

/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userMessage = null,Object? message = null,Object? draft = freezed,}) {
  return _then(_PostMessageResponse(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as AiMessageItem,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as AiMessageItem,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,
  ));
}

/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageItemCopyWith<$Res> get userMessage {
  
  return $AiMessageItemCopyWith<$Res>(_self.userMessage, (value) {
    return _then(_self.copyWith(userMessage: value));
  });
}/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiMessageItemCopyWith<$Res> get message {
  
  return $AiMessageItemCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}/// Create a copy of PostMessageResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// @nodoc
mixin _$ConfirmDraftResponse {

 AiDraftItem? get draft; dynamic get result; bool get idempotent;
/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmDraftResponseCopyWith<ConfirmDraftResponse> get copyWith => _$ConfirmDraftResponseCopyWithImpl<ConfirmDraftResponse>(this as ConfirmDraftResponse, _$identity);

  /// Serializes this ConfirmDraftResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmDraftResponse&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.idempotent, idempotent) || other.idempotent == idempotent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draft,const DeepCollectionEquality().hash(result),idempotent);

@override
String toString() {
  return 'ConfirmDraftResponse(draft: $draft, result: $result, idempotent: $idempotent)';
}


}

/// @nodoc
abstract mixin class $ConfirmDraftResponseCopyWith<$Res>  {
  factory $ConfirmDraftResponseCopyWith(ConfirmDraftResponse value, $Res Function(ConfirmDraftResponse) _then) = _$ConfirmDraftResponseCopyWithImpl;
@useResult
$Res call({
 AiDraftItem? draft, dynamic result, bool idempotent
});


$AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class _$ConfirmDraftResponseCopyWithImpl<$Res>
    implements $ConfirmDraftResponseCopyWith<$Res> {
  _$ConfirmDraftResponseCopyWithImpl(this._self, this._then);

  final ConfirmDraftResponse _self;
  final $Res Function(ConfirmDraftResponse) _then;

/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = freezed,Object? result = freezed,Object? idempotent = null,}) {
  return _then(_self.copyWith(
draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,idempotent: null == idempotent ? _self.idempotent : idempotent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConfirmDraftResponse].
extension ConfirmDraftResponsePatterns on ConfirmDraftResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmDraftResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmDraftResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmDraftResponse value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmDraftResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmDraftResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmDraftResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AiDraftItem? draft,  dynamic result,  bool idempotent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmDraftResponse() when $default != null:
return $default(_that.draft,_that.result,_that.idempotent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AiDraftItem? draft,  dynamic result,  bool idempotent)  $default,) {final _that = this;
switch (_that) {
case _ConfirmDraftResponse():
return $default(_that.draft,_that.result,_that.idempotent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AiDraftItem? draft,  dynamic result,  bool idempotent)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmDraftResponse() when $default != null:
return $default(_that.draft,_that.result,_that.idempotent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmDraftResponse implements ConfirmDraftResponse {
  const _ConfirmDraftResponse({this.draft, this.result, this.idempotent = false});
  factory _ConfirmDraftResponse.fromJson(Map<String, dynamic> json) => _$ConfirmDraftResponseFromJson(json);

@override final  AiDraftItem? draft;
@override final  dynamic result;
@override@JsonKey() final  bool idempotent;

/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmDraftResponseCopyWith<_ConfirmDraftResponse> get copyWith => __$ConfirmDraftResponseCopyWithImpl<_ConfirmDraftResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmDraftResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmDraftResponse&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.idempotent, idempotent) || other.idempotent == idempotent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draft,const DeepCollectionEquality().hash(result),idempotent);

@override
String toString() {
  return 'ConfirmDraftResponse(draft: $draft, result: $result, idempotent: $idempotent)';
}


}

/// @nodoc
abstract mixin class _$ConfirmDraftResponseCopyWith<$Res> implements $ConfirmDraftResponseCopyWith<$Res> {
  factory _$ConfirmDraftResponseCopyWith(_ConfirmDraftResponse value, $Res Function(_ConfirmDraftResponse) _then) = __$ConfirmDraftResponseCopyWithImpl;
@override @useResult
$Res call({
 AiDraftItem? draft, dynamic result, bool idempotent
});


@override $AiDraftItemCopyWith<$Res>? get draft;

}
/// @nodoc
class __$ConfirmDraftResponseCopyWithImpl<$Res>
    implements _$ConfirmDraftResponseCopyWith<$Res> {
  __$ConfirmDraftResponseCopyWithImpl(this._self, this._then);

  final _ConfirmDraftResponse _self;
  final $Res Function(_ConfirmDraftResponse) _then;

/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = freezed,Object? result = freezed,Object? idempotent = null,}) {
  return _then(_ConfirmDraftResponse(
draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AiDraftItem?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,idempotent: null == idempotent ? _self.idempotent : idempotent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConfirmDraftResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiDraftItemCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $AiDraftItemCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// @nodoc
mixin _$AiUsage {

@JsonKey(fromJson: _toInt) int get messagesToday;@JsonKey(fromJson: _toInt) int get dailyMessageLimit;@JsonKey(fromJson: _toInt) int get activeConversations;@JsonKey(fromJson: _toInt) int get maxConversations; DateTime? get resetAt;
/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiUsageCopyWith<AiUsage> get copyWith => _$AiUsageCopyWithImpl<AiUsage>(this as AiUsage, _$identity);

  /// Serializes this AiUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiUsage&&(identical(other.messagesToday, messagesToday) || other.messagesToday == messagesToday)&&(identical(other.dailyMessageLimit, dailyMessageLimit) || other.dailyMessageLimit == dailyMessageLimit)&&(identical(other.activeConversations, activeConversations) || other.activeConversations == activeConversations)&&(identical(other.maxConversations, maxConversations) || other.maxConversations == maxConversations)&&(identical(other.resetAt, resetAt) || other.resetAt == resetAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messagesToday,dailyMessageLimit,activeConversations,maxConversations,resetAt);

@override
String toString() {
  return 'AiUsage(messagesToday: $messagesToday, dailyMessageLimit: $dailyMessageLimit, activeConversations: $activeConversations, maxConversations: $maxConversations, resetAt: $resetAt)';
}


}

/// @nodoc
abstract mixin class $AiUsageCopyWith<$Res>  {
  factory $AiUsageCopyWith(AiUsage value, $Res Function(AiUsage) _then) = _$AiUsageCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int messagesToday,@JsonKey(fromJson: _toInt) int dailyMessageLimit,@JsonKey(fromJson: _toInt) int activeConversations,@JsonKey(fromJson: _toInt) int maxConversations, DateTime? resetAt
});




}
/// @nodoc
class _$AiUsageCopyWithImpl<$Res>
    implements $AiUsageCopyWith<$Res> {
  _$AiUsageCopyWithImpl(this._self, this._then);

  final AiUsage _self;
  final $Res Function(AiUsage) _then;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messagesToday = null,Object? dailyMessageLimit = null,Object? activeConversations = null,Object? maxConversations = null,Object? resetAt = freezed,}) {
  return _then(_self.copyWith(
messagesToday: null == messagesToday ? _self.messagesToday : messagesToday // ignore: cast_nullable_to_non_nullable
as int,dailyMessageLimit: null == dailyMessageLimit ? _self.dailyMessageLimit : dailyMessageLimit // ignore: cast_nullable_to_non_nullable
as int,activeConversations: null == activeConversations ? _self.activeConversations : activeConversations // ignore: cast_nullable_to_non_nullable
as int,maxConversations: null == maxConversations ? _self.maxConversations : maxConversations // ignore: cast_nullable_to_non_nullable
as int,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiUsage].
extension AiUsagePatterns on AiUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiUsage value)  $default,){
final _that = this;
switch (_that) {
case _AiUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiUsage value)?  $default,){
final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int messagesToday, @JsonKey(fromJson: _toInt)  int dailyMessageLimit, @JsonKey(fromJson: _toInt)  int activeConversations, @JsonKey(fromJson: _toInt)  int maxConversations,  DateTime? resetAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
return $default(_that.messagesToday,_that.dailyMessageLimit,_that.activeConversations,_that.maxConversations,_that.resetAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int messagesToday, @JsonKey(fromJson: _toInt)  int dailyMessageLimit, @JsonKey(fromJson: _toInt)  int activeConversations, @JsonKey(fromJson: _toInt)  int maxConversations,  DateTime? resetAt)  $default,) {final _that = this;
switch (_that) {
case _AiUsage():
return $default(_that.messagesToday,_that.dailyMessageLimit,_that.activeConversations,_that.maxConversations,_that.resetAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int messagesToday, @JsonKey(fromJson: _toInt)  int dailyMessageLimit, @JsonKey(fromJson: _toInt)  int activeConversations, @JsonKey(fromJson: _toInt)  int maxConversations,  DateTime? resetAt)?  $default,) {final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
return $default(_that.messagesToday,_that.dailyMessageLimit,_that.activeConversations,_that.maxConversations,_that.resetAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiUsage implements AiUsage {
  const _AiUsage({@JsonKey(fromJson: _toInt) this.messagesToday = 0, @JsonKey(fromJson: _toInt) this.dailyMessageLimit = 30, @JsonKey(fromJson: _toInt) this.activeConversations = 0, @JsonKey(fromJson: _toInt) this.maxConversations = 50, this.resetAt});
  factory _AiUsage.fromJson(Map<String, dynamic> json) => _$AiUsageFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int messagesToday;
@override@JsonKey(fromJson: _toInt) final  int dailyMessageLimit;
@override@JsonKey(fromJson: _toInt) final  int activeConversations;
@override@JsonKey(fromJson: _toInt) final  int maxConversations;
@override final  DateTime? resetAt;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiUsageCopyWith<_AiUsage> get copyWith => __$AiUsageCopyWithImpl<_AiUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiUsage&&(identical(other.messagesToday, messagesToday) || other.messagesToday == messagesToday)&&(identical(other.dailyMessageLimit, dailyMessageLimit) || other.dailyMessageLimit == dailyMessageLimit)&&(identical(other.activeConversations, activeConversations) || other.activeConversations == activeConversations)&&(identical(other.maxConversations, maxConversations) || other.maxConversations == maxConversations)&&(identical(other.resetAt, resetAt) || other.resetAt == resetAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messagesToday,dailyMessageLimit,activeConversations,maxConversations,resetAt);

@override
String toString() {
  return 'AiUsage(messagesToday: $messagesToday, dailyMessageLimit: $dailyMessageLimit, activeConversations: $activeConversations, maxConversations: $maxConversations, resetAt: $resetAt)';
}


}

/// @nodoc
abstract mixin class _$AiUsageCopyWith<$Res> implements $AiUsageCopyWith<$Res> {
  factory _$AiUsageCopyWith(_AiUsage value, $Res Function(_AiUsage) _then) = __$AiUsageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int messagesToday,@JsonKey(fromJson: _toInt) int dailyMessageLimit,@JsonKey(fromJson: _toInt) int activeConversations,@JsonKey(fromJson: _toInt) int maxConversations, DateTime? resetAt
});




}
/// @nodoc
class __$AiUsageCopyWithImpl<$Res>
    implements _$AiUsageCopyWith<$Res> {
  __$AiUsageCopyWithImpl(this._self, this._then);

  final _AiUsage _self;
  final $Res Function(_AiUsage) _then;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messagesToday = null,Object? dailyMessageLimit = null,Object? activeConversations = null,Object? maxConversations = null,Object? resetAt = freezed,}) {
  return _then(_AiUsage(
messagesToday: null == messagesToday ? _self.messagesToday : messagesToday // ignore: cast_nullable_to_non_nullable
as int,dailyMessageLimit: null == dailyMessageLimit ? _self.dailyMessageLimit : dailyMessageLimit // ignore: cast_nullable_to_non_nullable
as int,activeConversations: null == activeConversations ? _self.activeConversations : activeConversations // ignore: cast_nullable_to_non_nullable
as int,maxConversations: null == maxConversations ? _self.maxConversations : maxConversations // ignore: cast_nullable_to_non_nullable
as int,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AiSettings {

 bool get shareExamples; DateTime? get consentedAt; bool get asked;
/// Create a copy of AiSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSettingsCopyWith<AiSettings> get copyWith => _$AiSettingsCopyWithImpl<AiSettings>(this as AiSettings, _$identity);

  /// Serializes this AiSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSettings&&(identical(other.shareExamples, shareExamples) || other.shareExamples == shareExamples)&&(identical(other.consentedAt, consentedAt) || other.consentedAt == consentedAt)&&(identical(other.asked, asked) || other.asked == asked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareExamples,consentedAt,asked);

@override
String toString() {
  return 'AiSettings(shareExamples: $shareExamples, consentedAt: $consentedAt, asked: $asked)';
}


}

/// @nodoc
abstract mixin class $AiSettingsCopyWith<$Res>  {
  factory $AiSettingsCopyWith(AiSettings value, $Res Function(AiSettings) _then) = _$AiSettingsCopyWithImpl;
@useResult
$Res call({
 bool shareExamples, DateTime? consentedAt, bool asked
});




}
/// @nodoc
class _$AiSettingsCopyWithImpl<$Res>
    implements $AiSettingsCopyWith<$Res> {
  _$AiSettingsCopyWithImpl(this._self, this._then);

  final AiSettings _self;
  final $Res Function(AiSettings) _then;

/// Create a copy of AiSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareExamples = null,Object? consentedAt = freezed,Object? asked = null,}) {
  return _then(_self.copyWith(
shareExamples: null == shareExamples ? _self.shareExamples : shareExamples // ignore: cast_nullable_to_non_nullable
as bool,consentedAt: freezed == consentedAt ? _self.consentedAt : consentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,asked: null == asked ? _self.asked : asked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AiSettings].
extension AiSettingsPatterns on AiSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiSettings value)  $default,){
final _that = this;
switch (_that) {
case _AiSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AiSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool shareExamples,  DateTime? consentedAt,  bool asked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiSettings() when $default != null:
return $default(_that.shareExamples,_that.consentedAt,_that.asked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool shareExamples,  DateTime? consentedAt,  bool asked)  $default,) {final _that = this;
switch (_that) {
case _AiSettings():
return $default(_that.shareExamples,_that.consentedAt,_that.asked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool shareExamples,  DateTime? consentedAt,  bool asked)?  $default,) {final _that = this;
switch (_that) {
case _AiSettings() when $default != null:
return $default(_that.shareExamples,_that.consentedAt,_that.asked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiSettings implements AiSettings {
  const _AiSettings({this.shareExamples = false, this.consentedAt, this.asked = false});
  factory _AiSettings.fromJson(Map<String, dynamic> json) => _$AiSettingsFromJson(json);

@override@JsonKey() final  bool shareExamples;
@override final  DateTime? consentedAt;
@override@JsonKey() final  bool asked;

/// Create a copy of AiSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiSettingsCopyWith<_AiSettings> get copyWith => __$AiSettingsCopyWithImpl<_AiSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiSettings&&(identical(other.shareExamples, shareExamples) || other.shareExamples == shareExamples)&&(identical(other.consentedAt, consentedAt) || other.consentedAt == consentedAt)&&(identical(other.asked, asked) || other.asked == asked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareExamples,consentedAt,asked);

@override
String toString() {
  return 'AiSettings(shareExamples: $shareExamples, consentedAt: $consentedAt, asked: $asked)';
}


}

/// @nodoc
abstract mixin class _$AiSettingsCopyWith<$Res> implements $AiSettingsCopyWith<$Res> {
  factory _$AiSettingsCopyWith(_AiSettings value, $Res Function(_AiSettings) _then) = __$AiSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool shareExamples, DateTime? consentedAt, bool asked
});




}
/// @nodoc
class __$AiSettingsCopyWithImpl<$Res>
    implements _$AiSettingsCopyWith<$Res> {
  __$AiSettingsCopyWithImpl(this._self, this._then);

  final _AiSettings _self;
  final $Res Function(_AiSettings) _then;

/// Create a copy of AiSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareExamples = null,Object? consentedAt = freezed,Object? asked = null,}) {
  return _then(_AiSettings(
shareExamples: null == shareExamples ? _self.shareExamples : shareExamples // ignore: cast_nullable_to_non_nullable
as bool,consentedAt: freezed == consentedAt ? _self.consentedAt : consentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,asked: null == asked ? _self.asked : asked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AiMemoryItem {

 String get id; String get key; String get value;@JsonKey(fromJson: _toNullableDouble) double? get confidence; String? get source; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AiMemoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiMemoryItemCopyWith<AiMemoryItem> get copyWith => _$AiMemoryItemCopyWithImpl<AiMemoryItem>(this as AiMemoryItem, _$identity);

  /// Serializes this AiMemoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiMemoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,value,confidence,source,createdAt,updatedAt);

@override
String toString() {
  return 'AiMemoryItem(id: $id, key: $key, value: $value, confidence: $confidence, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AiMemoryItemCopyWith<$Res>  {
  factory $AiMemoryItemCopyWith(AiMemoryItem value, $Res Function(AiMemoryItem) _then) = _$AiMemoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String key, String value,@JsonKey(fromJson: _toNullableDouble) double? confidence, String? source, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AiMemoryItemCopyWithImpl<$Res>
    implements $AiMemoryItemCopyWith<$Res> {
  _$AiMemoryItemCopyWithImpl(this._self, this._then);

  final AiMemoryItem _self;
  final $Res Function(AiMemoryItem) _then;

/// Create a copy of AiMemoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? value = null,Object? confidence = freezed,Object? source = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiMemoryItem].
extension AiMemoryItemPatterns on AiMemoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiMemoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiMemoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiMemoryItem value)  $default,){
final _that = this;
switch (_that) {
case _AiMemoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiMemoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _AiMemoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  String value, @JsonKey(fromJson: _toNullableDouble)  double? confidence,  String? source,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiMemoryItem() when $default != null:
return $default(_that.id,_that.key,_that.value,_that.confidence,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  String value, @JsonKey(fromJson: _toNullableDouble)  double? confidence,  String? source,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AiMemoryItem():
return $default(_that.id,_that.key,_that.value,_that.confidence,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  String value, @JsonKey(fromJson: _toNullableDouble)  double? confidence,  String? source,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AiMemoryItem() when $default != null:
return $default(_that.id,_that.key,_that.value,_that.confidence,_that.source,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiMemoryItem implements AiMemoryItem {
  const _AiMemoryItem({required this.id, required this.key, required this.value, @JsonKey(fromJson: _toNullableDouble) this.confidence, this.source, required this.createdAt, required this.updatedAt});
  factory _AiMemoryItem.fromJson(Map<String, dynamic> json) => _$AiMemoryItemFromJson(json);

@override final  String id;
@override final  String key;
@override final  String value;
@override@JsonKey(fromJson: _toNullableDouble) final  double? confidence;
@override final  String? source;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AiMemoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiMemoryItemCopyWith<_AiMemoryItem> get copyWith => __$AiMemoryItemCopyWithImpl<_AiMemoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiMemoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiMemoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,value,confidence,source,createdAt,updatedAt);

@override
String toString() {
  return 'AiMemoryItem(id: $id, key: $key, value: $value, confidence: $confidence, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AiMemoryItemCopyWith<$Res> implements $AiMemoryItemCopyWith<$Res> {
  factory _$AiMemoryItemCopyWith(_AiMemoryItem value, $Res Function(_AiMemoryItem) _then) = __$AiMemoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, String value,@JsonKey(fromJson: _toNullableDouble) double? confidence, String? source, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AiMemoryItemCopyWithImpl<$Res>
    implements _$AiMemoryItemCopyWith<$Res> {
  __$AiMemoryItemCopyWithImpl(this._self, this._then);

  final _AiMemoryItem _self;
  final $Res Function(_AiMemoryItem) _then;

/// Create a copy of AiMemoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? value = null,Object? confidence = freezed,Object? source = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AiMemoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AiSkillItem {

 String get name; String? get label; String? get description; String? get scope;
/// Create a copy of AiSkillItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSkillItemCopyWith<AiSkillItem> get copyWith => _$AiSkillItemCopyWithImpl<AiSkillItem>(this as AiSkillItem, _$identity);

  /// Serializes this AiSkillItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSkillItem&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.scope, scope) || other.scope == scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,label,description,scope);

@override
String toString() {
  return 'AiSkillItem(name: $name, label: $label, description: $description, scope: $scope)';
}


}

/// @nodoc
abstract mixin class $AiSkillItemCopyWith<$Res>  {
  factory $AiSkillItemCopyWith(AiSkillItem value, $Res Function(AiSkillItem) _then) = _$AiSkillItemCopyWithImpl;
@useResult
$Res call({
 String name, String? label, String? description, String? scope
});




}
/// @nodoc
class _$AiSkillItemCopyWithImpl<$Res>
    implements $AiSkillItemCopyWith<$Res> {
  _$AiSkillItemCopyWithImpl(this._self, this._then);

  final AiSkillItem _self;
  final $Res Function(AiSkillItem) _then;

/// Create a copy of AiSkillItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? label = freezed,Object? description = freezed,Object? scope = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiSkillItem].
extension AiSkillItemPatterns on AiSkillItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiSkillItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiSkillItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiSkillItem value)  $default,){
final _that = this;
switch (_that) {
case _AiSkillItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiSkillItem value)?  $default,){
final _that = this;
switch (_that) {
case _AiSkillItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? label,  String? description,  String? scope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiSkillItem() when $default != null:
return $default(_that.name,_that.label,_that.description,_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? label,  String? description,  String? scope)  $default,) {final _that = this;
switch (_that) {
case _AiSkillItem():
return $default(_that.name,_that.label,_that.description,_that.scope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? label,  String? description,  String? scope)?  $default,) {final _that = this;
switch (_that) {
case _AiSkillItem() when $default != null:
return $default(_that.name,_that.label,_that.description,_that.scope);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiSkillItem implements AiSkillItem {
  const _AiSkillItem({required this.name, this.label, this.description, this.scope});
  factory _AiSkillItem.fromJson(Map<String, dynamic> json) => _$AiSkillItemFromJson(json);

@override final  String name;
@override final  String? label;
@override final  String? description;
@override final  String? scope;

/// Create a copy of AiSkillItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiSkillItemCopyWith<_AiSkillItem> get copyWith => __$AiSkillItemCopyWithImpl<_AiSkillItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiSkillItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiSkillItem&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.scope, scope) || other.scope == scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,label,description,scope);

@override
String toString() {
  return 'AiSkillItem(name: $name, label: $label, description: $description, scope: $scope)';
}


}

/// @nodoc
abstract mixin class _$AiSkillItemCopyWith<$Res> implements $AiSkillItemCopyWith<$Res> {
  factory _$AiSkillItemCopyWith(_AiSkillItem value, $Res Function(_AiSkillItem) _then) = __$AiSkillItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String? label, String? description, String? scope
});




}
/// @nodoc
class __$AiSkillItemCopyWithImpl<$Res>
    implements _$AiSkillItemCopyWith<$Res> {
  __$AiSkillItemCopyWithImpl(this._self, this._then);

  final _AiSkillItem _self;
  final $Res Function(_AiSkillItem) _then;

/// Create a copy of AiSkillItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? label = freezed,Object? description = freezed,Object? scope = freezed,}) {
  return _then(_AiSkillItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
