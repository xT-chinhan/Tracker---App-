// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingWalletMeta {

 String get id; String get name; String get type;
/// Create a copy of SavingWalletMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingWalletMetaCopyWith<SavingWalletMeta> get copyWith => _$SavingWalletMetaCopyWithImpl<SavingWalletMeta>(this as SavingWalletMeta, _$identity);

  /// Serializes this SavingWalletMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingWalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type);

@override
String toString() {
  return 'SavingWalletMeta(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class $SavingWalletMetaCopyWith<$Res>  {
  factory $SavingWalletMetaCopyWith(SavingWalletMeta value, $Res Function(SavingWalletMeta) _then) = _$SavingWalletMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type
});




}
/// @nodoc
class _$SavingWalletMetaCopyWithImpl<$Res>
    implements $SavingWalletMetaCopyWith<$Res> {
  _$SavingWalletMetaCopyWithImpl(this._self, this._then);

  final SavingWalletMeta _self;
  final $Res Function(SavingWalletMeta) _then;

/// Create a copy of SavingWalletMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingWalletMeta].
extension SavingWalletMetaPatterns on SavingWalletMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingWalletMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingWalletMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingWalletMeta value)  $default,){
final _that = this;
switch (_that) {
case _SavingWalletMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingWalletMeta value)?  $default,){
final _that = this;
switch (_that) {
case _SavingWalletMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingWalletMeta() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type)  $default,) {final _that = this;
switch (_that) {
case _SavingWalletMeta():
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type)?  $default,) {final _that = this;
switch (_that) {
case _SavingWalletMeta() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingWalletMeta implements SavingWalletMeta {
  const _SavingWalletMeta({required this.id, required this.name, required this.type});
  factory _SavingWalletMeta.fromJson(Map<String, dynamic> json) => _$SavingWalletMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;

/// Create a copy of SavingWalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingWalletMetaCopyWith<_SavingWalletMeta> get copyWith => __$SavingWalletMetaCopyWithImpl<_SavingWalletMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingWalletMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingWalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type);

@override
String toString() {
  return 'SavingWalletMeta(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SavingWalletMetaCopyWith<$Res> implements $SavingWalletMetaCopyWith<$Res> {
  factory _$SavingWalletMetaCopyWith(_SavingWalletMeta value, $Res Function(_SavingWalletMeta) _then) = __$SavingWalletMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type
});




}
/// @nodoc
class __$SavingWalletMetaCopyWithImpl<$Res>
    implements _$SavingWalletMetaCopyWith<$Res> {
  __$SavingWalletMetaCopyWithImpl(this._self, this._then);

  final _SavingWalletMeta _self;
  final $Res Function(_SavingWalletMeta) _then;

/// Create a copy of SavingWalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(_SavingWalletMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SavingEntryItem {

 String get id; String get goalId; String get walletId; String get type;@JsonKey(fromJson: _toInt) int get amount; DateTime get date; DateTime get createdAt; SavingWalletMeta? get wallet;
/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingEntryItemCopyWith<SavingEntryItem> get copyWith => _$SavingEntryItemCopyWithImpl<SavingEntryItem>(this as SavingEntryItem, _$identity);

  /// Serializes this SavingEntryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingEntryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,walletId,type,amount,date,createdAt,wallet);

@override
String toString() {
  return 'SavingEntryItem(id: $id, goalId: $goalId, walletId: $walletId, type: $type, amount: $amount, date: $date, createdAt: $createdAt, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class $SavingEntryItemCopyWith<$Res>  {
  factory $SavingEntryItemCopyWith(SavingEntryItem value, $Res Function(SavingEntryItem) _then) = _$SavingEntryItemCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, String walletId, String type,@JsonKey(fromJson: _toInt) int amount, DateTime date, DateTime createdAt, SavingWalletMeta? wallet
});


$SavingWalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class _$SavingEntryItemCopyWithImpl<$Res>
    implements $SavingEntryItemCopyWith<$Res> {
  _$SavingEntryItemCopyWithImpl(this._self, this._then);

  final SavingEntryItem _self;
  final $Res Function(SavingEntryItem) _then;

/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? walletId = null,Object? type = null,Object? amount = null,Object? date = null,Object? createdAt = null,Object? wallet = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as SavingWalletMeta?,
  ));
}
/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingWalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $SavingWalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [SavingEntryItem].
extension SavingEntryItemPatterns on SavingEntryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingEntryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingEntryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingEntryItem value)  $default,){
final _that = this;
switch (_that) {
case _SavingEntryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingEntryItem value)?  $default,){
final _that = this;
switch (_that) {
case _SavingEntryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  String walletId,  String type, @JsonKey(fromJson: _toInt)  int amount,  DateTime date,  DateTime createdAt,  SavingWalletMeta? wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingEntryItem() when $default != null:
return $default(_that.id,_that.goalId,_that.walletId,_that.type,_that.amount,_that.date,_that.createdAt,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  String walletId,  String type, @JsonKey(fromJson: _toInt)  int amount,  DateTime date,  DateTime createdAt,  SavingWalletMeta? wallet)  $default,) {final _that = this;
switch (_that) {
case _SavingEntryItem():
return $default(_that.id,_that.goalId,_that.walletId,_that.type,_that.amount,_that.date,_that.createdAt,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  String walletId,  String type, @JsonKey(fromJson: _toInt)  int amount,  DateTime date,  DateTime createdAt,  SavingWalletMeta? wallet)?  $default,) {final _that = this;
switch (_that) {
case _SavingEntryItem() when $default != null:
return $default(_that.id,_that.goalId,_that.walletId,_that.type,_that.amount,_that.date,_that.createdAt,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingEntryItem implements SavingEntryItem {
  const _SavingEntryItem({required this.id, required this.goalId, required this.walletId, required this.type, @JsonKey(fromJson: _toInt) required this.amount, required this.date, required this.createdAt, this.wallet});
  factory _SavingEntryItem.fromJson(Map<String, dynamic> json) => _$SavingEntryItemFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  String walletId;
@override final  String type;
@override@JsonKey(fromJson: _toInt) final  int amount;
@override final  DateTime date;
@override final  DateTime createdAt;
@override final  SavingWalletMeta? wallet;

/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingEntryItemCopyWith<_SavingEntryItem> get copyWith => __$SavingEntryItemCopyWithImpl<_SavingEntryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingEntryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingEntryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalId,walletId,type,amount,date,createdAt,wallet);

@override
String toString() {
  return 'SavingEntryItem(id: $id, goalId: $goalId, walletId: $walletId, type: $type, amount: $amount, date: $date, createdAt: $createdAt, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$SavingEntryItemCopyWith<$Res> implements $SavingEntryItemCopyWith<$Res> {
  factory _$SavingEntryItemCopyWith(_SavingEntryItem value, $Res Function(_SavingEntryItem) _then) = __$SavingEntryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, String walletId, String type,@JsonKey(fromJson: _toInt) int amount, DateTime date, DateTime createdAt, SavingWalletMeta? wallet
});


@override $SavingWalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class __$SavingEntryItemCopyWithImpl<$Res>
    implements _$SavingEntryItemCopyWith<$Res> {
  __$SavingEntryItemCopyWithImpl(this._self, this._then);

  final _SavingEntryItem _self;
  final $Res Function(_SavingEntryItem) _then;

/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? walletId = null,Object? type = null,Object? amount = null,Object? date = null,Object? createdAt = null,Object? wallet = freezed,}) {
  return _then(_SavingEntryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as SavingWalletMeta?,
  ));
}

/// Create a copy of SavingEntryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavingWalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $SavingWalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// @nodoc
mixin _$SavingGoalItem {

 String get id; String get name;@JsonKey(fromJson: _toInt) int get targetAmount;@JsonKey(fromJson: _toInt) int get savedAmount; DateTime get startDate; DateTime get targetDate; String? get icon; String? get color; String get status;@JsonKey(fromJson: _toInt) int get remaining;@JsonKey(fromJson: _toDouble) double get progress;@JsonKey(fromJson: _toInt) int get daysLeft;@JsonKey(fromJson: _toInt) int get dailyRequired;
/// Create a copy of SavingGoalItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalItemCopyWith<SavingGoalItem> get copyWith => _$SavingGoalItemCopyWithImpl<SavingGoalItem>(this as SavingGoalItem, _$identity);

  /// Serializes this SavingGoalItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoalItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.status, status) || other.status == status)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.dailyRequired, dailyRequired) || other.dailyRequired == dailyRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,startDate,targetDate,icon,color,status,remaining,progress,daysLeft,dailyRequired);

@override
String toString() {
  return 'SavingGoalItem(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color, status: $status, remaining: $remaining, progress: $progress, daysLeft: $daysLeft, dailyRequired: $dailyRequired)';
}


}

/// @nodoc
abstract mixin class $SavingGoalItemCopyWith<$Res>  {
  factory $SavingGoalItemCopyWith(SavingGoalItem value, $Res Function(SavingGoalItem) _then) = _$SavingGoalItemCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toInt) int targetAmount,@JsonKey(fromJson: _toInt) int savedAmount, DateTime startDate, DateTime targetDate, String? icon, String? color, String status,@JsonKey(fromJson: _toInt) int remaining,@JsonKey(fromJson: _toDouble) double progress,@JsonKey(fromJson: _toInt) int daysLeft,@JsonKey(fromJson: _toInt) int dailyRequired
});




}
/// @nodoc
class _$SavingGoalItemCopyWithImpl<$Res>
    implements $SavingGoalItemCopyWith<$Res> {
  _$SavingGoalItemCopyWithImpl(this._self, this._then);

  final SavingGoalItem _self;
  final $Res Function(SavingGoalItem) _then;

/// Create a copy of SavingGoalItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? startDate = null,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,Object? status = null,Object? remaining = null,Object? progress = null,Object? daysLeft = null,Object? dailyRequired = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,dailyRequired: null == dailyRequired ? _self.dailyRequired : dailyRequired // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoalItem].
extension SavingGoalItemPatterns on SavingGoalItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoalItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoalItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoalItem value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoalItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoalItem value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoalItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoalItem() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired)  $default,) {final _that = this;
switch (_that) {
case _SavingGoalItem():
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoalItem() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingGoalItem implements SavingGoalItem {
  const _SavingGoalItem({required this.id, required this.name, @JsonKey(fromJson: _toInt) required this.targetAmount, @JsonKey(fromJson: _toInt) this.savedAmount = 0, required this.startDate, required this.targetDate, this.icon, this.color, this.status = 'ACTIVE', @JsonKey(fromJson: _toInt) this.remaining = 0, @JsonKey(fromJson: _toDouble) this.progress = 0.0, @JsonKey(fromJson: _toInt) this.daysLeft = 0, @JsonKey(fromJson: _toInt) this.dailyRequired = 0});
  factory _SavingGoalItem.fromJson(Map<String, dynamic> json) => _$SavingGoalItemFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _toInt) final  int targetAmount;
@override@JsonKey(fromJson: _toInt) final  int savedAmount;
@override final  DateTime startDate;
@override final  DateTime targetDate;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  String status;
@override@JsonKey(fromJson: _toInt) final  int remaining;
@override@JsonKey(fromJson: _toDouble) final  double progress;
@override@JsonKey(fromJson: _toInt) final  int daysLeft;
@override@JsonKey(fromJson: _toInt) final  int dailyRequired;

/// Create a copy of SavingGoalItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalItemCopyWith<_SavingGoalItem> get copyWith => __$SavingGoalItemCopyWithImpl<_SavingGoalItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingGoalItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoalItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.status, status) || other.status == status)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.dailyRequired, dailyRequired) || other.dailyRequired == dailyRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,startDate,targetDate,icon,color,status,remaining,progress,daysLeft,dailyRequired);

@override
String toString() {
  return 'SavingGoalItem(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color, status: $status, remaining: $remaining, progress: $progress, daysLeft: $daysLeft, dailyRequired: $dailyRequired)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalItemCopyWith<$Res> implements $SavingGoalItemCopyWith<$Res> {
  factory _$SavingGoalItemCopyWith(_SavingGoalItem value, $Res Function(_SavingGoalItem) _then) = __$SavingGoalItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toInt) int targetAmount,@JsonKey(fromJson: _toInt) int savedAmount, DateTime startDate, DateTime targetDate, String? icon, String? color, String status,@JsonKey(fromJson: _toInt) int remaining,@JsonKey(fromJson: _toDouble) double progress,@JsonKey(fromJson: _toInt) int daysLeft,@JsonKey(fromJson: _toInt) int dailyRequired
});




}
/// @nodoc
class __$SavingGoalItemCopyWithImpl<$Res>
    implements _$SavingGoalItemCopyWith<$Res> {
  __$SavingGoalItemCopyWithImpl(this._self, this._then);

  final _SavingGoalItem _self;
  final $Res Function(_SavingGoalItem) _then;

/// Create a copy of SavingGoalItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? startDate = null,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,Object? status = null,Object? remaining = null,Object? progress = null,Object? daysLeft = null,Object? dailyRequired = null,}) {
  return _then(_SavingGoalItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,dailyRequired: null == dailyRequired ? _self.dailyRequired : dailyRequired // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SavingGoalDetail {

 String get id; String get name;@JsonKey(fromJson: _toInt) int get targetAmount;@JsonKey(fromJson: _toInt) int get savedAmount; DateTime get startDate; DateTime get targetDate; String? get icon; String? get color; String get status;@JsonKey(fromJson: _toInt) int get remaining;@JsonKey(fromJson: _toDouble) double get progress;@JsonKey(fromJson: _toInt) int get daysLeft;@JsonKey(fromJson: _toInt) int get dailyRequired; List<SavingEntryItem> get entries;
/// Create a copy of SavingGoalDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingGoalDetailCopyWith<SavingGoalDetail> get copyWith => _$SavingGoalDetailCopyWithImpl<SavingGoalDetail>(this as SavingGoalDetail, _$identity);

  /// Serializes this SavingGoalDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingGoalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.status, status) || other.status == status)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.dailyRequired, dailyRequired) || other.dailyRequired == dailyRequired)&&const DeepCollectionEquality().equals(other.entries, entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,startDate,targetDate,icon,color,status,remaining,progress,daysLeft,dailyRequired,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'SavingGoalDetail(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color, status: $status, remaining: $remaining, progress: $progress, daysLeft: $daysLeft, dailyRequired: $dailyRequired, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $SavingGoalDetailCopyWith<$Res>  {
  factory $SavingGoalDetailCopyWith(SavingGoalDetail value, $Res Function(SavingGoalDetail) _then) = _$SavingGoalDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toInt) int targetAmount,@JsonKey(fromJson: _toInt) int savedAmount, DateTime startDate, DateTime targetDate, String? icon, String? color, String status,@JsonKey(fromJson: _toInt) int remaining,@JsonKey(fromJson: _toDouble) double progress,@JsonKey(fromJson: _toInt) int daysLeft,@JsonKey(fromJson: _toInt) int dailyRequired, List<SavingEntryItem> entries
});




}
/// @nodoc
class _$SavingGoalDetailCopyWithImpl<$Res>
    implements $SavingGoalDetailCopyWith<$Res> {
  _$SavingGoalDetailCopyWithImpl(this._self, this._then);

  final SavingGoalDetail _self;
  final $Res Function(SavingGoalDetail) _then;

/// Create a copy of SavingGoalDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? startDate = null,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,Object? status = null,Object? remaining = null,Object? progress = null,Object? daysLeft = null,Object? dailyRequired = null,Object? entries = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,dailyRequired: null == dailyRequired ? _self.dailyRequired : dailyRequired // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<SavingEntryItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingGoalDetail].
extension SavingGoalDetailPatterns on SavingGoalDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingGoalDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingGoalDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingGoalDetail value)  $default,){
final _that = this;
switch (_that) {
case _SavingGoalDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingGoalDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SavingGoalDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired,  List<SavingEntryItem> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingGoalDetail() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired,  List<SavingEntryItem> entries)  $default,) {final _that = this;
switch (_that) {
case _SavingGoalDetail():
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _toInt)  int targetAmount, @JsonKey(fromJson: _toInt)  int savedAmount,  DateTime startDate,  DateTime targetDate,  String? icon,  String? color,  String status, @JsonKey(fromJson: _toInt)  int remaining, @JsonKey(fromJson: _toDouble)  double progress, @JsonKey(fromJson: _toInt)  int daysLeft, @JsonKey(fromJson: _toInt)  int dailyRequired,  List<SavingEntryItem> entries)?  $default,) {final _that = this;
switch (_that) {
case _SavingGoalDetail() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.savedAmount,_that.startDate,_that.targetDate,_that.icon,_that.color,_that.status,_that.remaining,_that.progress,_that.daysLeft,_that.dailyRequired,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingGoalDetail implements SavingGoalDetail {
  const _SavingGoalDetail({required this.id, required this.name, @JsonKey(fromJson: _toInt) required this.targetAmount, @JsonKey(fromJson: _toInt) this.savedAmount = 0, required this.startDate, required this.targetDate, this.icon, this.color, this.status = 'ACTIVE', @JsonKey(fromJson: _toInt) this.remaining = 0, @JsonKey(fromJson: _toDouble) this.progress = 0.0, @JsonKey(fromJson: _toInt) this.daysLeft = 0, @JsonKey(fromJson: _toInt) this.dailyRequired = 0, final  List<SavingEntryItem> entries = const <SavingEntryItem>[]}): _entries = entries;
  factory _SavingGoalDetail.fromJson(Map<String, dynamic> json) => _$SavingGoalDetailFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _toInt) final  int targetAmount;
@override@JsonKey(fromJson: _toInt) final  int savedAmount;
@override final  DateTime startDate;
@override final  DateTime targetDate;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  String status;
@override@JsonKey(fromJson: _toInt) final  int remaining;
@override@JsonKey(fromJson: _toDouble) final  double progress;
@override@JsonKey(fromJson: _toInt) final  int daysLeft;
@override@JsonKey(fromJson: _toInt) final  int dailyRequired;
 final  List<SavingEntryItem> _entries;
@override@JsonKey() List<SavingEntryItem> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of SavingGoalDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingGoalDetailCopyWith<_SavingGoalDetail> get copyWith => __$SavingGoalDetailCopyWithImpl<_SavingGoalDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingGoalDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingGoalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.savedAmount, savedAmount) || other.savedAmount == savedAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.status, status) || other.status == status)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.dailyRequired, dailyRequired) || other.dailyRequired == dailyRequired)&&const DeepCollectionEquality().equals(other._entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,savedAmount,startDate,targetDate,icon,color,status,remaining,progress,daysLeft,dailyRequired,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'SavingGoalDetail(id: $id, name: $name, targetAmount: $targetAmount, savedAmount: $savedAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color, status: $status, remaining: $remaining, progress: $progress, daysLeft: $daysLeft, dailyRequired: $dailyRequired, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$SavingGoalDetailCopyWith<$Res> implements $SavingGoalDetailCopyWith<$Res> {
  factory _$SavingGoalDetailCopyWith(_SavingGoalDetail value, $Res Function(_SavingGoalDetail) _then) = __$SavingGoalDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _toInt) int targetAmount,@JsonKey(fromJson: _toInt) int savedAmount, DateTime startDate, DateTime targetDate, String? icon, String? color, String status,@JsonKey(fromJson: _toInt) int remaining,@JsonKey(fromJson: _toDouble) double progress,@JsonKey(fromJson: _toInt) int daysLeft,@JsonKey(fromJson: _toInt) int dailyRequired, List<SavingEntryItem> entries
});




}
/// @nodoc
class __$SavingGoalDetailCopyWithImpl<$Res>
    implements _$SavingGoalDetailCopyWith<$Res> {
  __$SavingGoalDetailCopyWithImpl(this._self, this._then);

  final _SavingGoalDetail _self;
  final $Res Function(_SavingGoalDetail) _then;

/// Create a copy of SavingGoalDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? savedAmount = null,Object? startDate = null,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,Object? status = null,Object? remaining = null,Object? progress = null,Object? daysLeft = null,Object? dailyRequired = null,Object? entries = null,}) {
  return _then(_SavingGoalDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,savedAmount: null == savedAmount ? _self.savedAmount : savedAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,dailyRequired: null == dailyRequired ? _self.dailyRequired : dailyRequired // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<SavingEntryItem>,
  ));
}


}


/// @nodoc
mixin _$CreateGoalDto {

 String get name; int get targetAmount; String? get startDate; String get targetDate; String? get icon; String? get color;
/// Create a copy of CreateGoalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoalDtoCopyWith<CreateGoalDto> get copyWith => _$CreateGoalDtoCopyWithImpl<CreateGoalDto>(this as CreateGoalDto, _$identity);

  /// Serializes this CreateGoalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoalDto&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,targetAmount,startDate,targetDate,icon,color);

@override
String toString() {
  return 'CreateGoalDto(name: $name, targetAmount: $targetAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $CreateGoalDtoCopyWith<$Res>  {
  factory $CreateGoalDtoCopyWith(CreateGoalDto value, $Res Function(CreateGoalDto) _then) = _$CreateGoalDtoCopyWithImpl;
@useResult
$Res call({
 String name, int targetAmount, String? startDate, String targetDate, String? icon, String? color
});




}
/// @nodoc
class _$CreateGoalDtoCopyWithImpl<$Res>
    implements $CreateGoalDtoCopyWith<$Res> {
  _$CreateGoalDtoCopyWithImpl(this._self, this._then);

  final CreateGoalDto _self;
  final $Res Function(CreateGoalDto) _then;

/// Create a copy of CreateGoalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? targetAmount = null,Object? startDate = freezed,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoalDto].
extension CreateGoalDtoPatterns on CreateGoalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoalDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoalDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int targetAmount,  String? startDate,  String targetDate,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoalDto() when $default != null:
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int targetAmount,  String? startDate,  String targetDate,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CreateGoalDto():
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int targetAmount,  String? startDate,  String targetDate,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoalDto() when $default != null:
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGoalDto implements CreateGoalDto {
  const _CreateGoalDto({required this.name, required this.targetAmount, this.startDate, required this.targetDate, this.icon, this.color});
  factory _CreateGoalDto.fromJson(Map<String, dynamic> json) => _$CreateGoalDtoFromJson(json);

@override final  String name;
@override final  int targetAmount;
@override final  String? startDate;
@override final  String targetDate;
@override final  String? icon;
@override final  String? color;

/// Create a copy of CreateGoalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoalDtoCopyWith<_CreateGoalDto> get copyWith => __$CreateGoalDtoCopyWithImpl<_CreateGoalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGoalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoalDto&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,targetAmount,startDate,targetDate,icon,color);

@override
String toString() {
  return 'CreateGoalDto(name: $name, targetAmount: $targetAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CreateGoalDtoCopyWith<$Res> implements $CreateGoalDtoCopyWith<$Res> {
  factory _$CreateGoalDtoCopyWith(_CreateGoalDto value, $Res Function(_CreateGoalDto) _then) = __$CreateGoalDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, int targetAmount, String? startDate, String targetDate, String? icon, String? color
});




}
/// @nodoc
class __$CreateGoalDtoCopyWithImpl<$Res>
    implements _$CreateGoalDtoCopyWith<$Res> {
  __$CreateGoalDtoCopyWithImpl(this._self, this._then);

  final _CreateGoalDto _self;
  final $Res Function(_CreateGoalDto) _then;

/// Create a copy of CreateGoalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? targetAmount = null,Object? startDate = freezed,Object? targetDate = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_CreateGoalDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateGoalDto {

 String? get name; int? get targetAmount; String? get startDate; String? get targetDate; String? get icon; String? get color;
/// Create a copy of UpdateGoalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGoalDtoCopyWith<UpdateGoalDto> get copyWith => _$UpdateGoalDtoCopyWithImpl<UpdateGoalDto>(this as UpdateGoalDto, _$identity);

  /// Serializes this UpdateGoalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGoalDto&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,targetAmount,startDate,targetDate,icon,color);

@override
String toString() {
  return 'UpdateGoalDto(name: $name, targetAmount: $targetAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $UpdateGoalDtoCopyWith<$Res>  {
  factory $UpdateGoalDtoCopyWith(UpdateGoalDto value, $Res Function(UpdateGoalDto) _then) = _$UpdateGoalDtoCopyWithImpl;
@useResult
$Res call({
 String? name, int? targetAmount, String? startDate, String? targetDate, String? icon, String? color
});




}
/// @nodoc
class _$UpdateGoalDtoCopyWithImpl<$Res>
    implements $UpdateGoalDtoCopyWith<$Res> {
  _$UpdateGoalDtoCopyWithImpl(this._self, this._then);

  final UpdateGoalDto _self;
  final $Res Function(UpdateGoalDto) _then;

/// Create a copy of UpdateGoalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? targetAmount = freezed,Object? startDate = freezed,Object? targetDate = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGoalDto].
extension UpdateGoalDtoPatterns on UpdateGoalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGoalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGoalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGoalDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGoalDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  int? targetAmount,  String? startDate,  String? targetDate,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGoalDto() when $default != null:
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  int? targetAmount,  String? startDate,  String? targetDate,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalDto():
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  int? targetAmount,  String? startDate,  String? targetDate,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalDto() when $default != null:
return $default(_that.name,_that.targetAmount,_that.startDate,_that.targetDate,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGoalDto implements UpdateGoalDto {
  const _UpdateGoalDto({this.name, this.targetAmount, this.startDate, this.targetDate, this.icon, this.color});
  factory _UpdateGoalDto.fromJson(Map<String, dynamic> json) => _$UpdateGoalDtoFromJson(json);

@override final  String? name;
@override final  int? targetAmount;
@override final  String? startDate;
@override final  String? targetDate;
@override final  String? icon;
@override final  String? color;

/// Create a copy of UpdateGoalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGoalDtoCopyWith<_UpdateGoalDto> get copyWith => __$UpdateGoalDtoCopyWithImpl<_UpdateGoalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGoalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGoalDto&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,targetAmount,startDate,targetDate,icon,color);

@override
String toString() {
  return 'UpdateGoalDto(name: $name, targetAmount: $targetAmount, startDate: $startDate, targetDate: $targetDate, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$UpdateGoalDtoCopyWith<$Res> implements $UpdateGoalDtoCopyWith<$Res> {
  factory _$UpdateGoalDtoCopyWith(_UpdateGoalDto value, $Res Function(_UpdateGoalDto) _then) = __$UpdateGoalDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, int? targetAmount, String? startDate, String? targetDate, String? icon, String? color
});




}
/// @nodoc
class __$UpdateGoalDtoCopyWithImpl<$Res>
    implements _$UpdateGoalDtoCopyWith<$Res> {
  __$UpdateGoalDtoCopyWithImpl(this._self, this._then);

  final _UpdateGoalDto _self;
  final $Res Function(_UpdateGoalDto) _then;

/// Create a copy of UpdateGoalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? targetAmount = freezed,Object? startDate = freezed,Object? targetDate = freezed,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_UpdateGoalDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DepositDto {

 int get amount; String get walletId; String? get date;
/// Create a copy of DepositDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositDtoCopyWith<DepositDto> get copyWith => _$DepositDtoCopyWithImpl<DepositDto>(this as DepositDto, _$identity);

  /// Serializes this DepositDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepositDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,walletId,date);

@override
String toString() {
  return 'DepositDto(amount: $amount, walletId: $walletId, date: $date)';
}


}

/// @nodoc
abstract mixin class $DepositDtoCopyWith<$Res>  {
  factory $DepositDtoCopyWith(DepositDto value, $Res Function(DepositDto) _then) = _$DepositDtoCopyWithImpl;
@useResult
$Res call({
 int amount, String walletId, String? date
});




}
/// @nodoc
class _$DepositDtoCopyWithImpl<$Res>
    implements $DepositDtoCopyWith<$Res> {
  _$DepositDtoCopyWithImpl(this._self, this._then);

  final DepositDto _self;
  final $Res Function(DepositDto) _then;

/// Create a copy of DepositDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? walletId = null,Object? date = freezed,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DepositDto].
extension DepositDtoPatterns on DepositDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepositDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepositDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepositDto value)  $default,){
final _that = this;
switch (_that) {
case _DepositDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepositDto value)?  $default,){
final _that = this;
switch (_that) {
case _DepositDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amount,  String walletId,  String? date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepositDto() when $default != null:
return $default(_that.amount,_that.walletId,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amount,  String walletId,  String? date)  $default,) {final _that = this;
switch (_that) {
case _DepositDto():
return $default(_that.amount,_that.walletId,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amount,  String walletId,  String? date)?  $default,) {final _that = this;
switch (_that) {
case _DepositDto() when $default != null:
return $default(_that.amount,_that.walletId,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DepositDto implements DepositDto {
  const _DepositDto({required this.amount, required this.walletId, this.date});
  factory _DepositDto.fromJson(Map<String, dynamic> json) => _$DepositDtoFromJson(json);

@override final  int amount;
@override final  String walletId;
@override final  String? date;

/// Create a copy of DepositDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositDtoCopyWith<_DepositDto> get copyWith => __$DepositDtoCopyWithImpl<_DepositDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepositDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepositDto&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,walletId,date);

@override
String toString() {
  return 'DepositDto(amount: $amount, walletId: $walletId, date: $date)';
}


}

/// @nodoc
abstract mixin class _$DepositDtoCopyWith<$Res> implements $DepositDtoCopyWith<$Res> {
  factory _$DepositDtoCopyWith(_DepositDto value, $Res Function(_DepositDto) _then) = __$DepositDtoCopyWithImpl;
@override @useResult
$Res call({
 int amount, String walletId, String? date
});




}
/// @nodoc
class __$DepositDtoCopyWithImpl<$Res>
    implements _$DepositDtoCopyWith<$Res> {
  __$DepositDtoCopyWithImpl(this._self, this._then);

  final _DepositDto _self;
  final $Res Function(_DepositDto) _then;

/// Create a copy of DepositDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? walletId = null,Object? date = freezed,}) {
  return _then(_DepositDto(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WithdrawDto {

 String get walletId;
/// Create a copy of WithdrawDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawDtoCopyWith<WithdrawDto> get copyWith => _$WithdrawDtoCopyWithImpl<WithdrawDto>(this as WithdrawDto, _$identity);

  /// Serializes this WithdrawDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawDto&&(identical(other.walletId, walletId) || other.walletId == walletId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId);

@override
String toString() {
  return 'WithdrawDto(walletId: $walletId)';
}


}

/// @nodoc
abstract mixin class $WithdrawDtoCopyWith<$Res>  {
  factory $WithdrawDtoCopyWith(WithdrawDto value, $Res Function(WithdrawDto) _then) = _$WithdrawDtoCopyWithImpl;
@useResult
$Res call({
 String walletId
});




}
/// @nodoc
class _$WithdrawDtoCopyWithImpl<$Res>
    implements $WithdrawDtoCopyWith<$Res> {
  _$WithdrawDtoCopyWithImpl(this._self, this._then);

  final WithdrawDto _self;
  final $Res Function(WithdrawDto) _then;

/// Create a copy of WithdrawDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? walletId = null,}) {
  return _then(_self.copyWith(
walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WithdrawDto].
extension WithdrawDtoPatterns on WithdrawDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WithdrawDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WithdrawDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WithdrawDto value)  $default,){
final _that = this;
switch (_that) {
case _WithdrawDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WithdrawDto value)?  $default,){
final _that = this;
switch (_that) {
case _WithdrawDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String walletId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WithdrawDto() when $default != null:
return $default(_that.walletId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String walletId)  $default,) {final _that = this;
switch (_that) {
case _WithdrawDto():
return $default(_that.walletId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String walletId)?  $default,) {final _that = this;
switch (_that) {
case _WithdrawDto() when $default != null:
return $default(_that.walletId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WithdrawDto implements WithdrawDto {
  const _WithdrawDto({required this.walletId});
  factory _WithdrawDto.fromJson(Map<String, dynamic> json) => _$WithdrawDtoFromJson(json);

@override final  String walletId;

/// Create a copy of WithdrawDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawDtoCopyWith<_WithdrawDto> get copyWith => __$WithdrawDtoCopyWithImpl<_WithdrawDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WithdrawDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawDto&&(identical(other.walletId, walletId) || other.walletId == walletId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,walletId);

@override
String toString() {
  return 'WithdrawDto(walletId: $walletId)';
}


}

/// @nodoc
abstract mixin class _$WithdrawDtoCopyWith<$Res> implements $WithdrawDtoCopyWith<$Res> {
  factory _$WithdrawDtoCopyWith(_WithdrawDto value, $Res Function(_WithdrawDto) _then) = __$WithdrawDtoCopyWithImpl;
@override @useResult
$Res call({
 String walletId
});




}
/// @nodoc
class __$WithdrawDtoCopyWithImpl<$Res>
    implements _$WithdrawDtoCopyWith<$Res> {
  __$WithdrawDtoCopyWithImpl(this._self, this._then);

  final _WithdrawDto _self;
  final $Res Function(_WithdrawDto) _then;

/// Create a copy of WithdrawDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? walletId = null,}) {
  return _then(_WithdrawDto(
walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
