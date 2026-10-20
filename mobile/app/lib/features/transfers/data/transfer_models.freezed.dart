// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateTransferDto {

 String get fromWalletId; String get toWalletId; int get amount; String? get note; String? get occurredAt;
/// Create a copy of CreateTransferDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTransferDtoCopyWith<CreateTransferDto> get copyWith => _$CreateTransferDtoCopyWithImpl<CreateTransferDto>(this as CreateTransferDto, _$identity);

  /// Serializes this CreateTransferDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTransferDto&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromWalletId,toWalletId,amount,note,occurredAt);

@override
String toString() {
  return 'CreateTransferDto(fromWalletId: $fromWalletId, toWalletId: $toWalletId, amount: $amount, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $CreateTransferDtoCopyWith<$Res>  {
  factory $CreateTransferDtoCopyWith(CreateTransferDto value, $Res Function(CreateTransferDto) _then) = _$CreateTransferDtoCopyWithImpl;
@useResult
$Res call({
 String fromWalletId, String toWalletId, int amount, String? note, String? occurredAt
});




}
/// @nodoc
class _$CreateTransferDtoCopyWithImpl<$Res>
    implements $CreateTransferDtoCopyWith<$Res> {
  _$CreateTransferDtoCopyWithImpl(this._self, this._then);

  final CreateTransferDto _self;
  final $Res Function(CreateTransferDto) _then;

/// Create a copy of CreateTransferDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromWalletId = null,Object? toWalletId = null,Object? amount = null,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_self.copyWith(
fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTransferDto].
extension CreateTransferDtoPatterns on CreateTransferDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTransferDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTransferDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTransferDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateTransferDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTransferDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTransferDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromWalletId,  String toWalletId,  int amount,  String? note,  String? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTransferDto() when $default != null:
return $default(_that.fromWalletId,_that.toWalletId,_that.amount,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromWalletId,  String toWalletId,  int amount,  String? note,  String? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _CreateTransferDto():
return $default(_that.fromWalletId,_that.toWalletId,_that.amount,_that.note,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromWalletId,  String toWalletId,  int amount,  String? note,  String? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateTransferDto() when $default != null:
return $default(_that.fromWalletId,_that.toWalletId,_that.amount,_that.note,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTransferDto implements CreateTransferDto {
  const _CreateTransferDto({required this.fromWalletId, required this.toWalletId, required this.amount, this.note, this.occurredAt});
  factory _CreateTransferDto.fromJson(Map<String, dynamic> json) => _$CreateTransferDtoFromJson(json);

@override final  String fromWalletId;
@override final  String toWalletId;
@override final  int amount;
@override final  String? note;
@override final  String? occurredAt;

/// Create a copy of CreateTransferDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTransferDtoCopyWith<_CreateTransferDto> get copyWith => __$CreateTransferDtoCopyWithImpl<_CreateTransferDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTransferDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTransferDto&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromWalletId,toWalletId,amount,note,occurredAt);

@override
String toString() {
  return 'CreateTransferDto(fromWalletId: $fromWalletId, toWalletId: $toWalletId, amount: $amount, note: $note, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$CreateTransferDtoCopyWith<$Res> implements $CreateTransferDtoCopyWith<$Res> {
  factory _$CreateTransferDtoCopyWith(_CreateTransferDto value, $Res Function(_CreateTransferDto) _then) = __$CreateTransferDtoCopyWithImpl;
@override @useResult
$Res call({
 String fromWalletId, String toWalletId, int amount, String? note, String? occurredAt
});




}
/// @nodoc
class __$CreateTransferDtoCopyWithImpl<$Res>
    implements _$CreateTransferDtoCopyWith<$Res> {
  __$CreateTransferDtoCopyWithImpl(this._self, this._then);

  final _CreateTransferDto _self;
  final $Res Function(_CreateTransferDto) _then;

/// Create a copy of CreateTransferDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromWalletId = null,Object? toWalletId = null,Object? amount = null,Object? note = freezed,Object? occurredAt = freezed,}) {
  return _then(_CreateTransferDto(
fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TransferItem {

 String get id; String get fromWalletId; String get toWalletId; int get amount; DateTime get occurredAt; String? get note; WalletMeta? get fromWallet; WalletMeta? get toWallet; DateTime? get createdAt;
/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferItemCopyWith<TransferItem> get copyWith => _$TransferItemCopyWithImpl<TransferItem>(this as TransferItem, _$identity);

  /// Serializes this TransferItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.fromWallet, fromWallet) || other.fromWallet == fromWallet)&&(identical(other.toWallet, toWallet) || other.toWallet == toWallet)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromWalletId,toWalletId,amount,occurredAt,note,fromWallet,toWallet,createdAt);

@override
String toString() {
  return 'TransferItem(id: $id, fromWalletId: $fromWalletId, toWalletId: $toWalletId, amount: $amount, occurredAt: $occurredAt, note: $note, fromWallet: $fromWallet, toWallet: $toWallet, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransferItemCopyWith<$Res>  {
  factory $TransferItemCopyWith(TransferItem value, $Res Function(TransferItem) _then) = _$TransferItemCopyWithImpl;
@useResult
$Res call({
 String id, String fromWalletId, String toWalletId, int amount, DateTime occurredAt, String? note, WalletMeta? fromWallet, WalletMeta? toWallet, DateTime? createdAt
});


$WalletMetaCopyWith<$Res>? get fromWallet;$WalletMetaCopyWith<$Res>? get toWallet;

}
/// @nodoc
class _$TransferItemCopyWithImpl<$Res>
    implements $TransferItemCopyWith<$Res> {
  _$TransferItemCopyWithImpl(this._self, this._then);

  final TransferItem _self;
  final $Res Function(TransferItem) _then;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromWalletId = null,Object? toWalletId = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,Object? fromWallet = freezed,Object? toWallet = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,fromWallet: freezed == fromWallet ? _self.fromWallet : fromWallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,toWallet: freezed == toWallet ? _self.toWallet : toWallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get fromWallet {
    if (_self.fromWallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.fromWallet!, (value) {
    return _then(_self.copyWith(fromWallet: value));
  });
}/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get toWallet {
    if (_self.toWallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.toWallet!, (value) {
    return _then(_self.copyWith(toWallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransferItem].
extension TransferItemPatterns on TransferItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferItem value)  $default,){
final _that = this;
switch (_that) {
case _TransferItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferItem value)?  $default,){
final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromWalletId,  String toWalletId,  int amount,  DateTime occurredAt,  String? note,  WalletMeta? fromWallet,  WalletMeta? toWallet,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
return $default(_that.id,_that.fromWalletId,_that.toWalletId,_that.amount,_that.occurredAt,_that.note,_that.fromWallet,_that.toWallet,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromWalletId,  String toWalletId,  int amount,  DateTime occurredAt,  String? note,  WalletMeta? fromWallet,  WalletMeta? toWallet,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransferItem():
return $default(_that.id,_that.fromWalletId,_that.toWalletId,_that.amount,_that.occurredAt,_that.note,_that.fromWallet,_that.toWallet,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromWalletId,  String toWalletId,  int amount,  DateTime occurredAt,  String? note,  WalletMeta? fromWallet,  WalletMeta? toWallet,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransferItem() when $default != null:
return $default(_that.id,_that.fromWalletId,_that.toWalletId,_that.amount,_that.occurredAt,_that.note,_that.fromWallet,_that.toWallet,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferItem implements TransferItem {
  const _TransferItem({required this.id, required this.fromWalletId, required this.toWalletId, required this.amount, required this.occurredAt, this.note, this.fromWallet, this.toWallet, this.createdAt});
  factory _TransferItem.fromJson(Map<String, dynamic> json) => _$TransferItemFromJson(json);

@override final  String id;
@override final  String fromWalletId;
@override final  String toWalletId;
@override final  int amount;
@override final  DateTime occurredAt;
@override final  String? note;
@override final  WalletMeta? fromWallet;
@override final  WalletMeta? toWallet;
@override final  DateTime? createdAt;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferItemCopyWith<_TransferItem> get copyWith => __$TransferItemCopyWithImpl<_TransferItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fromWalletId, fromWalletId) || other.fromWalletId == fromWalletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.fromWallet, fromWallet) || other.fromWallet == fromWallet)&&(identical(other.toWallet, toWallet) || other.toWallet == toWallet)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromWalletId,toWalletId,amount,occurredAt,note,fromWallet,toWallet,createdAt);

@override
String toString() {
  return 'TransferItem(id: $id, fromWalletId: $fromWalletId, toWalletId: $toWalletId, amount: $amount, occurredAt: $occurredAt, note: $note, fromWallet: $fromWallet, toWallet: $toWallet, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransferItemCopyWith<$Res> implements $TransferItemCopyWith<$Res> {
  factory _$TransferItemCopyWith(_TransferItem value, $Res Function(_TransferItem) _then) = __$TransferItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromWalletId, String toWalletId, int amount, DateTime occurredAt, String? note, WalletMeta? fromWallet, WalletMeta? toWallet, DateTime? createdAt
});


@override $WalletMetaCopyWith<$Res>? get fromWallet;@override $WalletMetaCopyWith<$Res>? get toWallet;

}
/// @nodoc
class __$TransferItemCopyWithImpl<$Res>
    implements _$TransferItemCopyWith<$Res> {
  __$TransferItemCopyWithImpl(this._self, this._then);

  final _TransferItem _self;
  final $Res Function(_TransferItem) _then;

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromWalletId = null,Object? toWalletId = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,Object? fromWallet = freezed,Object? toWallet = freezed,Object? createdAt = freezed,}) {
  return _then(_TransferItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWalletId: null == fromWalletId ? _self.fromWalletId : fromWalletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: null == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,fromWallet: freezed == fromWallet ? _self.fromWallet : fromWallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,toWallet: freezed == toWallet ? _self.toWallet : toWallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get fromWallet {
    if (_self.fromWallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.fromWallet!, (value) {
    return _then(_self.copyWith(fromWallet: value));
  });
}/// Create a copy of TransferItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get toWallet {
    if (_self.toWallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.toWallet!, (value) {
    return _then(_self.copyWith(toWallet: value));
  });
}
}

// dart format on
