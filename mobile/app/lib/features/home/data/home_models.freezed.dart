// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletItemSummary {

 String get id; String get name; String get type; bool get isArchived; int get balance;
/// Create a copy of WalletItemSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletItemSummaryCopyWith<WalletItemSummary> get copyWith => _$WalletItemSummaryCopyWithImpl<WalletItemSummary>(this as WalletItemSummary, _$identity);

  /// Serializes this WalletItemSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletItemSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isArchived,balance);

@override
String toString() {
  return 'WalletItemSummary(id: $id, name: $name, type: $type, isArchived: $isArchived, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $WalletItemSummaryCopyWith<$Res>  {
  factory $WalletItemSummaryCopyWith(WalletItemSummary value, $Res Function(WalletItemSummary) _then) = _$WalletItemSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, bool isArchived, int balance
});




}
/// @nodoc
class _$WalletItemSummaryCopyWithImpl<$Res>
    implements $WalletItemSummaryCopyWith<$Res> {
  _$WalletItemSummaryCopyWithImpl(this._self, this._then);

  final WalletItemSummary _self;
  final $Res Function(WalletItemSummary) _then;

/// Create a copy of WalletItemSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isArchived = null,Object? balance = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletItemSummary].
extension WalletItemSummaryPatterns on WalletItemSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletItemSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletItemSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletItemSummary value)  $default,){
final _that = this;
switch (_that) {
case _WalletItemSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletItemSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WalletItemSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool isArchived,  int balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletItemSummary() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isArchived,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  bool isArchived,  int balance)  $default,) {final _that = this;
switch (_that) {
case _WalletItemSummary():
return $default(_that.id,_that.name,_that.type,_that.isArchived,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  bool isArchived,  int balance)?  $default,) {final _that = this;
switch (_that) {
case _WalletItemSummary() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isArchived,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletItemSummary implements WalletItemSummary {
  const _WalletItemSummary({required this.id, required this.name, required this.type, this.isArchived = false, required this.balance});
  factory _WalletItemSummary.fromJson(Map<String, dynamic> json) => _$WalletItemSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey() final  bool isArchived;
@override final  int balance;

/// Create a copy of WalletItemSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletItemSummaryCopyWith<_WalletItemSummary> get copyWith => __$WalletItemSummaryCopyWithImpl<_WalletItemSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletItemSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletItemSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isArchived,balance);

@override
String toString() {
  return 'WalletItemSummary(id: $id, name: $name, type: $type, isArchived: $isArchived, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$WalletItemSummaryCopyWith<$Res> implements $WalletItemSummaryCopyWith<$Res> {
  factory _$WalletItemSummaryCopyWith(_WalletItemSummary value, $Res Function(_WalletItemSummary) _then) = __$WalletItemSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, bool isArchived, int balance
});




}
/// @nodoc
class __$WalletItemSummaryCopyWithImpl<$Res>
    implements _$WalletItemSummaryCopyWith<$Res> {
  __$WalletItemSummaryCopyWithImpl(this._self, this._then);

  final _WalletItemSummary _self;
  final $Res Function(_WalletItemSummary) _then;

/// Create a copy of WalletItemSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isArchived = null,Object? balance = null,}) {
  return _then(_WalletItemSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatsBalance {

 int get balance; int get totalIncome; int get totalExpense; int get savings; List<WalletItemSummary> get wallets;
/// Create a copy of StatsBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsBalanceCopyWith<StatsBalance> get copyWith => _$StatsBalanceCopyWithImpl<StatsBalance>(this as StatsBalance, _$identity);

  /// Serializes this StatsBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsBalance&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.savings, savings) || other.savings == savings)&&const DeepCollectionEquality().equals(other.wallets, wallets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,totalIncome,totalExpense,savings,const DeepCollectionEquality().hash(wallets));

@override
String toString() {
  return 'StatsBalance(balance: $balance, totalIncome: $totalIncome, totalExpense: $totalExpense, savings: $savings, wallets: $wallets)';
}


}

/// @nodoc
abstract mixin class $StatsBalanceCopyWith<$Res>  {
  factory $StatsBalanceCopyWith(StatsBalance value, $Res Function(StatsBalance) _then) = _$StatsBalanceCopyWithImpl;
@useResult
$Res call({
 int balance, int totalIncome, int totalExpense, int savings, List<WalletItemSummary> wallets
});




}
/// @nodoc
class _$StatsBalanceCopyWithImpl<$Res>
    implements $StatsBalanceCopyWith<$Res> {
  _$StatsBalanceCopyWithImpl(this._self, this._then);

  final StatsBalance _self;
  final $Res Function(StatsBalance) _then;

/// Create a copy of StatsBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balance = null,Object? totalIncome = null,Object? totalExpense = null,Object? savings = null,Object? wallets = null,}) {
  return _then(_self.copyWith(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as int,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletItemSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsBalance].
extension StatsBalancePatterns on StatsBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsBalance value)  $default,){
final _that = this;
switch (_that) {
case _StatsBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsBalance value)?  $default,){
final _that = this;
switch (_that) {
case _StatsBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int balance,  int totalIncome,  int totalExpense,  int savings,  List<WalletItemSummary> wallets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsBalance() when $default != null:
return $default(_that.balance,_that.totalIncome,_that.totalExpense,_that.savings,_that.wallets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int balance,  int totalIncome,  int totalExpense,  int savings,  List<WalletItemSummary> wallets)  $default,) {final _that = this;
switch (_that) {
case _StatsBalance():
return $default(_that.balance,_that.totalIncome,_that.totalExpense,_that.savings,_that.wallets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int balance,  int totalIncome,  int totalExpense,  int savings,  List<WalletItemSummary> wallets)?  $default,) {final _that = this;
switch (_that) {
case _StatsBalance() when $default != null:
return $default(_that.balance,_that.totalIncome,_that.totalExpense,_that.savings,_that.wallets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsBalance implements StatsBalance {
  const _StatsBalance({required this.balance, required this.totalIncome, required this.totalExpense, required this.savings, final  List<WalletItemSummary> wallets = const <WalletItemSummary>[]}): _wallets = wallets;
  factory _StatsBalance.fromJson(Map<String, dynamic> json) => _$StatsBalanceFromJson(json);

@override final  int balance;
@override final  int totalIncome;
@override final  int totalExpense;
@override final  int savings;
 final  List<WalletItemSummary> _wallets;
@override@JsonKey() List<WalletItemSummary> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}


/// Create a copy of StatsBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsBalanceCopyWith<_StatsBalance> get copyWith => __$StatsBalanceCopyWithImpl<_StatsBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsBalance&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.savings, savings) || other.savings == savings)&&const DeepCollectionEquality().equals(other._wallets, _wallets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,balance,totalIncome,totalExpense,savings,const DeepCollectionEquality().hash(_wallets));

@override
String toString() {
  return 'StatsBalance(balance: $balance, totalIncome: $totalIncome, totalExpense: $totalExpense, savings: $savings, wallets: $wallets)';
}


}

/// @nodoc
abstract mixin class _$StatsBalanceCopyWith<$Res> implements $StatsBalanceCopyWith<$Res> {
  factory _$StatsBalanceCopyWith(_StatsBalance value, $Res Function(_StatsBalance) _then) = __$StatsBalanceCopyWithImpl;
@override @useResult
$Res call({
 int balance, int totalIncome, int totalExpense, int savings, List<WalletItemSummary> wallets
});




}
/// @nodoc
class __$StatsBalanceCopyWithImpl<$Res>
    implements _$StatsBalanceCopyWith<$Res> {
  __$StatsBalanceCopyWithImpl(this._self, this._then);

  final _StatsBalance _self;
  final $Res Function(_StatsBalance) _then;

/// Create a copy of StatsBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? totalIncome = null,Object? totalExpense = null,Object? savings = null,Object? wallets = null,}) {
  return _then(_StatsBalance(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as int,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<WalletItemSummary>,
  ));
}


}


/// @nodoc
mixin _$StatsSummary {

 int get income; int get expense; int get net; int get incomeCount; int get expenseCount; int get balance;
/// Create a copy of StatsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsSummaryCopyWith<StatsSummary> get copyWith => _$StatsSummaryCopyWithImpl<StatsSummary>(this as StatsSummary, _$identity);

  /// Serializes this StatsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsSummary&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.incomeCount, incomeCount) || other.incomeCount == incomeCount)&&(identical(other.expenseCount, expenseCount) || other.expenseCount == expenseCount)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,income,expense,net,incomeCount,expenseCount,balance);

@override
String toString() {
  return 'StatsSummary(income: $income, expense: $expense, net: $net, incomeCount: $incomeCount, expenseCount: $expenseCount, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $StatsSummaryCopyWith<$Res>  {
  factory $StatsSummaryCopyWith(StatsSummary value, $Res Function(StatsSummary) _then) = _$StatsSummaryCopyWithImpl;
@useResult
$Res call({
 int income, int expense, int net, int incomeCount, int expenseCount, int balance
});




}
/// @nodoc
class _$StatsSummaryCopyWithImpl<$Res>
    implements $StatsSummaryCopyWith<$Res> {
  _$StatsSummaryCopyWithImpl(this._self, this._then);

  final StatsSummary _self;
  final $Res Function(StatsSummary) _then;

/// Create a copy of StatsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,Object? net = null,Object? incomeCount = null,Object? expenseCount = null,Object? balance = null,}) {
  return _then(_self.copyWith(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,incomeCount: null == incomeCount ? _self.incomeCount : incomeCount // ignore: cast_nullable_to_non_nullable
as int,expenseCount: null == expenseCount ? _self.expenseCount : expenseCount // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsSummary].
extension StatsSummaryPatterns on StatsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsSummary value)  $default,){
final _that = this;
switch (_that) {
case _StatsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StatsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int income,  int expense,  int net,  int incomeCount,  int expenseCount,  int balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsSummary() when $default != null:
return $default(_that.income,_that.expense,_that.net,_that.incomeCount,_that.expenseCount,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int income,  int expense,  int net,  int incomeCount,  int expenseCount,  int balance)  $default,) {final _that = this;
switch (_that) {
case _StatsSummary():
return $default(_that.income,_that.expense,_that.net,_that.incomeCount,_that.expenseCount,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int income,  int expense,  int net,  int incomeCount,  int expenseCount,  int balance)?  $default,) {final _that = this;
switch (_that) {
case _StatsSummary() when $default != null:
return $default(_that.income,_that.expense,_that.net,_that.incomeCount,_that.expenseCount,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsSummary implements StatsSummary {
  const _StatsSummary({required this.income, required this.expense, required this.net, this.incomeCount = 0, this.expenseCount = 0, required this.balance});
  factory _StatsSummary.fromJson(Map<String, dynamic> json) => _$StatsSummaryFromJson(json);

@override final  int income;
@override final  int expense;
@override final  int net;
@override@JsonKey() final  int incomeCount;
@override@JsonKey() final  int expenseCount;
@override final  int balance;

/// Create a copy of StatsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsSummaryCopyWith<_StatsSummary> get copyWith => __$StatsSummaryCopyWithImpl<_StatsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsSummary&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.incomeCount, incomeCount) || other.incomeCount == incomeCount)&&(identical(other.expenseCount, expenseCount) || other.expenseCount == expenseCount)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,income,expense,net,incomeCount,expenseCount,balance);

@override
String toString() {
  return 'StatsSummary(income: $income, expense: $expense, net: $net, incomeCount: $incomeCount, expenseCount: $expenseCount, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$StatsSummaryCopyWith<$Res> implements $StatsSummaryCopyWith<$Res> {
  factory _$StatsSummaryCopyWith(_StatsSummary value, $Res Function(_StatsSummary) _then) = __$StatsSummaryCopyWithImpl;
@override @useResult
$Res call({
 int income, int expense, int net, int incomeCount, int expenseCount, int balance
});




}
/// @nodoc
class __$StatsSummaryCopyWithImpl<$Res>
    implements _$StatsSummaryCopyWith<$Res> {
  __$StatsSummaryCopyWithImpl(this._self, this._then);

  final _StatsSummary _self;
  final $Res Function(_StatsSummary) _then;

/// Create a copy of StatsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,Object? net = null,Object? incomeCount = null,Object? expenseCount = null,Object? balance = null,}) {
  return _then(_StatsSummary(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,incomeCount: null == incomeCount ? _self.incomeCount : incomeCount // ignore: cast_nullable_to_non_nullable
as int,expenseCount: null == expenseCount ? _self.expenseCount : expenseCount // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CategoryMeta {

 String get id; String get name; String? get icon; String? get color; String? get type;
/// Create a copy of CategoryMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<CategoryMeta> get copyWith => _$CategoryMetaCopyWithImpl<CategoryMeta>(this as CategoryMeta, _$identity);

  /// Serializes this CategoryMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type);

@override
String toString() {
  return 'CategoryMeta(id: $id, name: $name, icon: $icon, color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class $CategoryMetaCopyWith<$Res>  {
  factory $CategoryMetaCopyWith(CategoryMeta value, $Res Function(CategoryMeta) _then) = _$CategoryMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? icon, String? color, String? type
});




}
/// @nodoc
class _$CategoryMetaCopyWithImpl<$Res>
    implements $CategoryMetaCopyWith<$Res> {
  _$CategoryMetaCopyWithImpl(this._self, this._then);

  final CategoryMeta _self;
  final $Res Function(CategoryMeta) _then;

/// Create a copy of CategoryMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? color = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryMeta].
extension CategoryMetaPatterns on CategoryMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryMeta value)  $default,){
final _that = this;
switch (_that) {
case _CategoryMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryMeta value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? color,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryMeta() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? color,  String? type)  $default,) {final _that = this;
switch (_that) {
case _CategoryMeta():
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? icon,  String? color,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _CategoryMeta() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryMeta implements CategoryMeta {
  const _CategoryMeta({required this.id, required this.name, this.icon, this.color, this.type});
  factory _CategoryMeta.fromJson(Map<String, dynamic> json) => _$CategoryMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? icon;
@override final  String? color;
@override final  String? type;

/// Create a copy of CategoryMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryMetaCopyWith<_CategoryMeta> get copyWith => __$CategoryMetaCopyWithImpl<_CategoryMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type);

@override
String toString() {
  return 'CategoryMeta(id: $id, name: $name, icon: $icon, color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class _$CategoryMetaCopyWith<$Res> implements $CategoryMetaCopyWith<$Res> {
  factory _$CategoryMetaCopyWith(_CategoryMeta value, $Res Function(_CategoryMeta) _then) = __$CategoryMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? icon, String? color, String? type
});




}
/// @nodoc
class __$CategoryMetaCopyWithImpl<$Res>
    implements _$CategoryMetaCopyWith<$Res> {
  __$CategoryMetaCopyWithImpl(this._self, this._then);

  final _CategoryMeta _self;
  final $Res Function(_CategoryMeta) _then;

/// Create a copy of CategoryMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? color = freezed,Object? type = freezed,}) {
  return _then(_CategoryMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WalletMeta {

 String get id; String get name; String get type; String? get icon; String? get color; bool get isArchived;
/// Create a copy of WalletMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<WalletMeta> get copyWith => _$WalletMetaCopyWithImpl<WalletMeta>(this as WalletMeta, _$identity);

  /// Serializes this WalletMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,isArchived);

@override
String toString() {
  return 'WalletMeta(id: $id, name: $name, type: $type, icon: $icon, color: $color, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $WalletMetaCopyWith<$Res>  {
  factory $WalletMetaCopyWith(WalletMeta value, $Res Function(WalletMeta) _then) = _$WalletMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String? icon, String? color, bool isArchived
});




}
/// @nodoc
class _$WalletMetaCopyWithImpl<$Res>
    implements $WalletMetaCopyWith<$Res> {
  _$WalletMetaCopyWithImpl(this._self, this._then);

  final WalletMeta _self;
  final $Res Function(WalletMeta) _then;

/// Create a copy of WalletMeta
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


/// Adds pattern-matching-related methods to [WalletMeta].
extension WalletMetaPatterns on WalletMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletMeta value)  $default,){
final _that = this;
switch (_that) {
case _WalletMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletMeta value)?  $default,){
final _that = this;
switch (_that) {
case _WalletMeta() when $default != null:
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
case _WalletMeta() when $default != null:
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
case _WalletMeta():
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
case _WalletMeta() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletMeta implements WalletMeta {
  const _WalletMeta({required this.id, required this.name, required this.type, this.icon, this.color, this.isArchived = false});
  factory _WalletMeta.fromJson(Map<String, dynamic> json) => _$WalletMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  String? icon;
@override final  String? color;
@override@JsonKey() final  bool isArchived;

/// Create a copy of WalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletMetaCopyWith<_WalletMeta> get copyWith => __$WalletMetaCopyWithImpl<_WalletMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,icon,color,isArchived);

@override
String toString() {
  return 'WalletMeta(id: $id, name: $name, type: $type, icon: $icon, color: $color, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$WalletMetaCopyWith<$Res> implements $WalletMetaCopyWith<$Res> {
  factory _$WalletMetaCopyWith(_WalletMeta value, $Res Function(_WalletMeta) _then) = __$WalletMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String? icon, String? color, bool isArchived
});




}
/// @nodoc
class __$WalletMetaCopyWithImpl<$Res>
    implements _$WalletMetaCopyWith<$Res> {
  __$WalletMetaCopyWithImpl(this._self, this._then);

  final _WalletMeta _self;
  final $Res Function(_WalletMeta) _then;

/// Create a copy of WalletMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = freezed,Object? color = freezed,Object? isArchived = null,}) {
  return _then(_WalletMeta(
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
mixin _$TransactionItem {

 String get id; String get type; int get amount; String get title; String? get note; DateTime get occurredAt; CategoryMeta? get category; WalletMeta? get wallet; bool get recurring;
/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionItemCopyWith<TransactionItem> get copyWith => _$TransactionItemCopyWithImpl<TransactionItem>(this as TransactionItem, _$identity);

  /// Serializes this TransactionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.recurring, recurring) || other.recurring == recurring));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,note,occurredAt,category,wallet,recurring);

@override
String toString() {
  return 'TransactionItem(id: $id, type: $type, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt, category: $category, wallet: $wallet, recurring: $recurring)';
}


}

/// @nodoc
abstract mixin class $TransactionItemCopyWith<$Res>  {
  factory $TransactionItemCopyWith(TransactionItem value, $Res Function(TransactionItem) _then) = _$TransactionItemCopyWithImpl;
@useResult
$Res call({
 String id, String type, int amount, String title, String? note, DateTime occurredAt, CategoryMeta? category, WalletMeta? wallet, bool recurring
});


$CategoryMetaCopyWith<$Res>? get category;$WalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class _$TransactionItemCopyWithImpl<$Res>
    implements $TransactionItemCopyWith<$Res> {
  _$TransactionItemCopyWithImpl(this._self, this._then);

  final TransactionItem _self;
  final $Res Function(TransactionItem) _then;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? occurredAt = null,Object? category = freezed,Object? wallet = freezed,Object? recurring = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionItem].
extension TransactionItemPatterns on TransactionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionItem value)  $default,){
final _that = this;
switch (_that) {
case _TransactionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionItem value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  int amount,  String title,  String? note,  DateTime occurredAt,  CategoryMeta? category,  WalletMeta? wallet,  bool recurring)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionItem() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.note,_that.occurredAt,_that.category,_that.wallet,_that.recurring);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  int amount,  String title,  String? note,  DateTime occurredAt,  CategoryMeta? category,  WalletMeta? wallet,  bool recurring)  $default,) {final _that = this;
switch (_that) {
case _TransactionItem():
return $default(_that.id,_that.type,_that.amount,_that.title,_that.note,_that.occurredAt,_that.category,_that.wallet,_that.recurring);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  int amount,  String title,  String? note,  DateTime occurredAt,  CategoryMeta? category,  WalletMeta? wallet,  bool recurring)?  $default,) {final _that = this;
switch (_that) {
case _TransactionItem() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.note,_that.occurredAt,_that.category,_that.wallet,_that.recurring);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionItem implements TransactionItem {
  const _TransactionItem({required this.id, required this.type, required this.amount, required this.title, this.note, required this.occurredAt, this.category, this.wallet, this.recurring = false});
  factory _TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);

@override final  String id;
@override final  String type;
@override final  int amount;
@override final  String title;
@override final  String? note;
@override final  DateTime occurredAt;
@override final  CategoryMeta? category;
@override final  WalletMeta? wallet;
@override@JsonKey() final  bool recurring;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionItemCopyWith<_TransactionItem> get copyWith => __$TransactionItemCopyWithImpl<_TransactionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.recurring, recurring) || other.recurring == recurring));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,note,occurredAt,category,wallet,recurring);

@override
String toString() {
  return 'TransactionItem(id: $id, type: $type, amount: $amount, title: $title, note: $note, occurredAt: $occurredAt, category: $category, wallet: $wallet, recurring: $recurring)';
}


}

/// @nodoc
abstract mixin class _$TransactionItemCopyWith<$Res> implements $TransactionItemCopyWith<$Res> {
  factory _$TransactionItemCopyWith(_TransactionItem value, $Res Function(_TransactionItem) _then) = __$TransactionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, int amount, String title, String? note, DateTime occurredAt, CategoryMeta? category, WalletMeta? wallet, bool recurring
});


@override $CategoryMetaCopyWith<$Res>? get category;@override $WalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class __$TransactionItemCopyWithImpl<$Res>
    implements _$TransactionItemCopyWith<$Res> {
  __$TransactionItemCopyWithImpl(this._self, this._then);

  final _TransactionItem _self;
  final $Res Function(_TransactionItem) _then;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = null,Object? note = freezed,Object? occurredAt = null,Object? category = freezed,Object? wallet = freezed,Object? recurring = null,}) {
  return _then(_TransactionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// @nodoc
mixin _$TransactionPage {

 List<TransactionItem> get items; int get total; int get page; int get limit; int get totalPages;
/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionPageCopyWith<TransactionPage> get copyWith => _$TransactionPageCopyWithImpl<TransactionPage>(this as TransactionPage, _$identity);

  /// Serializes this TransactionPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,limit,totalPages);

@override
String toString() {
  return 'TransactionPage(items: $items, total: $total, page: $page, limit: $limit, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $TransactionPageCopyWith<$Res>  {
  factory $TransactionPageCopyWith(TransactionPage value, $Res Function(TransactionPage) _then) = _$TransactionPageCopyWithImpl;
@useResult
$Res call({
 List<TransactionItem> items, int total, int page, int limit, int totalPages
});




}
/// @nodoc
class _$TransactionPageCopyWithImpl<$Res>
    implements $TransactionPageCopyWith<$Res> {
  _$TransactionPageCopyWithImpl(this._self, this._then);

  final TransactionPage _self;
  final $Res Function(TransactionPage) _then;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TransactionItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionPage].
extension TransactionPagePatterns on TransactionPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionPage value)  $default,){
final _that = this;
switch (_that) {
case _TransactionPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionPage value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransactionItem> items,  int total,  int page,  int limit,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransactionItem> items,  int total,  int page,  int limit,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _TransactionPage():
return $default(_that.items,_that.total,_that.page,_that.limit,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransactionItem> items,  int total,  int page,  int limit,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _TransactionPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionPage implements TransactionPage {
  const _TransactionPage({final  List<TransactionItem> items = const <TransactionItem>[], required this.total, required this.page, required this.limit, required this.totalPages}): _items = items;
  factory _TransactionPage.fromJson(Map<String, dynamic> json) => _$TransactionPageFromJson(json);

 final  List<TransactionItem> _items;
@override@JsonKey() List<TransactionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int limit;
@override final  int totalPages;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionPageCopyWith<_TransactionPage> get copyWith => __$TransactionPageCopyWithImpl<_TransactionPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,limit,totalPages);

@override
String toString() {
  return 'TransactionPage(items: $items, total: $total, page: $page, limit: $limit, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$TransactionPageCopyWith<$Res> implements $TransactionPageCopyWith<$Res> {
  factory _$TransactionPageCopyWith(_TransactionPage value, $Res Function(_TransactionPage) _then) = __$TransactionPageCopyWithImpl;
@override @useResult
$Res call({
 List<TransactionItem> items, int total, int page, int limit, int totalPages
});




}
/// @nodoc
class __$TransactionPageCopyWithImpl<$Res>
    implements _$TransactionPageCopyWith<$Res> {
  __$TransactionPageCopyWithImpl(this._self, this._then);

  final _TransactionPage _self;
  final $Res Function(_TransactionPage) _then;

/// Create a copy of TransactionPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? totalPages = null,}) {
  return _then(_TransactionPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TransactionItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BudgetThresholds {

 int get warningPercent; int get exceededPercent;
/// Create a copy of BudgetThresholds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetThresholdsCopyWith<BudgetThresholds> get copyWith => _$BudgetThresholdsCopyWithImpl<BudgetThresholds>(this as BudgetThresholds, _$identity);

  /// Serializes this BudgetThresholds to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetThresholds&&(identical(other.warningPercent, warningPercent) || other.warningPercent == warningPercent)&&(identical(other.exceededPercent, exceededPercent) || other.exceededPercent == exceededPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warningPercent,exceededPercent);

@override
String toString() {
  return 'BudgetThresholds(warningPercent: $warningPercent, exceededPercent: $exceededPercent)';
}


}

/// @nodoc
abstract mixin class $BudgetThresholdsCopyWith<$Res>  {
  factory $BudgetThresholdsCopyWith(BudgetThresholds value, $Res Function(BudgetThresholds) _then) = _$BudgetThresholdsCopyWithImpl;
@useResult
$Res call({
 int warningPercent, int exceededPercent
});




}
/// @nodoc
class _$BudgetThresholdsCopyWithImpl<$Res>
    implements $BudgetThresholdsCopyWith<$Res> {
  _$BudgetThresholdsCopyWithImpl(this._self, this._then);

  final BudgetThresholds _self;
  final $Res Function(BudgetThresholds) _then;

/// Create a copy of BudgetThresholds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warningPercent = null,Object? exceededPercent = null,}) {
  return _then(_self.copyWith(
warningPercent: null == warningPercent ? _self.warningPercent : warningPercent // ignore: cast_nullable_to_non_nullable
as int,exceededPercent: null == exceededPercent ? _self.exceededPercent : exceededPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetThresholds].
extension BudgetThresholdsPatterns on BudgetThresholds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetThresholds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetThresholds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetThresholds value)  $default,){
final _that = this;
switch (_that) {
case _BudgetThresholds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetThresholds value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetThresholds() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int warningPercent,  int exceededPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetThresholds() when $default != null:
return $default(_that.warningPercent,_that.exceededPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int warningPercent,  int exceededPercent)  $default,) {final _that = this;
switch (_that) {
case _BudgetThresholds():
return $default(_that.warningPercent,_that.exceededPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int warningPercent,  int exceededPercent)?  $default,) {final _that = this;
switch (_that) {
case _BudgetThresholds() when $default != null:
return $default(_that.warningPercent,_that.exceededPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetThresholds implements BudgetThresholds {
  const _BudgetThresholds({this.warningPercent = 80, this.exceededPercent = 100});
  factory _BudgetThresholds.fromJson(Map<String, dynamic> json) => _$BudgetThresholdsFromJson(json);

@override@JsonKey() final  int warningPercent;
@override@JsonKey() final  int exceededPercent;

/// Create a copy of BudgetThresholds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetThresholdsCopyWith<_BudgetThresholds> get copyWith => __$BudgetThresholdsCopyWithImpl<_BudgetThresholds>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetThresholdsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetThresholds&&(identical(other.warningPercent, warningPercent) || other.warningPercent == warningPercent)&&(identical(other.exceededPercent, exceededPercent) || other.exceededPercent == exceededPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warningPercent,exceededPercent);

@override
String toString() {
  return 'BudgetThresholds(warningPercent: $warningPercent, exceededPercent: $exceededPercent)';
}


}

/// @nodoc
abstract mixin class _$BudgetThresholdsCopyWith<$Res> implements $BudgetThresholdsCopyWith<$Res> {
  factory _$BudgetThresholdsCopyWith(_BudgetThresholds value, $Res Function(_BudgetThresholds) _then) = __$BudgetThresholdsCopyWithImpl;
@override @useResult
$Res call({
 int warningPercent, int exceededPercent
});




}
/// @nodoc
class __$BudgetThresholdsCopyWithImpl<$Res>
    implements _$BudgetThresholdsCopyWith<$Res> {
  __$BudgetThresholdsCopyWithImpl(this._self, this._then);

  final _BudgetThresholds _self;
  final $Res Function(_BudgetThresholds) _then;

/// Create a copy of BudgetThresholds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warningPercent = null,Object? exceededPercent = null,}) {
  return _then(_BudgetThresholds(
warningPercent: null == warningPercent ? _self.warningPercent : warningPercent // ignore: cast_nullable_to_non_nullable
as int,exceededPercent: null == exceededPercent ? _self.exceededPercent : exceededPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BudgetOverall {

 String get id; String? get categoryId; String get month; int get limitAmount; int get spent; int get remaining; double get percentage; String get status;
/// Create a copy of BudgetOverall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetOverallCopyWith<BudgetOverall> get copyWith => _$BudgetOverallCopyWithImpl<BudgetOverall>(this as BudgetOverall, _$identity);

  /// Serializes this BudgetOverall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetOverall&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,month,limitAmount,spent,remaining,percentage,status);

@override
String toString() {
  return 'BudgetOverall(id: $id, categoryId: $categoryId, month: $month, limitAmount: $limitAmount, spent: $spent, remaining: $remaining, percentage: $percentage, status: $status)';
}


}

/// @nodoc
abstract mixin class $BudgetOverallCopyWith<$Res>  {
  factory $BudgetOverallCopyWith(BudgetOverall value, $Res Function(BudgetOverall) _then) = _$BudgetOverallCopyWithImpl;
@useResult
$Res call({
 String id, String? categoryId, String month, int limitAmount, int spent, int remaining, double percentage, String status
});




}
/// @nodoc
class _$BudgetOverallCopyWithImpl<$Res>
    implements $BudgetOverallCopyWith<$Res> {
  _$BudgetOverallCopyWithImpl(this._self, this._then);

  final BudgetOverall _self;
  final $Res Function(BudgetOverall) _then;

/// Create a copy of BudgetOverall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = freezed,Object? month = null,Object? limitAmount = null,Object? spent = null,Object? remaining = null,Object? percentage = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetOverall].
extension BudgetOverallPatterns on BudgetOverall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetOverall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetOverall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetOverall value)  $default,){
final _that = this;
switch (_that) {
case _BudgetOverall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetOverall value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetOverall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetOverall() when $default != null:
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status)  $default,) {final _that = this;
switch (_that) {
case _BudgetOverall():
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetOverall() when $default != null:
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetOverall implements BudgetOverall {
  const _BudgetOverall({required this.id, this.categoryId, required this.month, required this.limitAmount, required this.spent, required this.remaining, required this.percentage, required this.status});
  factory _BudgetOverall.fromJson(Map<String, dynamic> json) => _$BudgetOverallFromJson(json);

@override final  String id;
@override final  String? categoryId;
@override final  String month;
@override final  int limitAmount;
@override final  int spent;
@override final  int remaining;
@override final  double percentage;
@override final  String status;

/// Create a copy of BudgetOverall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetOverallCopyWith<_BudgetOverall> get copyWith => __$BudgetOverallCopyWithImpl<_BudgetOverall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetOverallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetOverall&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,month,limitAmount,spent,remaining,percentage,status);

@override
String toString() {
  return 'BudgetOverall(id: $id, categoryId: $categoryId, month: $month, limitAmount: $limitAmount, spent: $spent, remaining: $remaining, percentage: $percentage, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetOverallCopyWith<$Res> implements $BudgetOverallCopyWith<$Res> {
  factory _$BudgetOverallCopyWith(_BudgetOverall value, $Res Function(_BudgetOverall) _then) = __$BudgetOverallCopyWithImpl;
@override @useResult
$Res call({
 String id, String? categoryId, String month, int limitAmount, int spent, int remaining, double percentage, String status
});




}
/// @nodoc
class __$BudgetOverallCopyWithImpl<$Res>
    implements _$BudgetOverallCopyWith<$Res> {
  __$BudgetOverallCopyWithImpl(this._self, this._then);

  final _BudgetOverall _self;
  final $Res Function(_BudgetOverall) _then;

/// Create a copy of BudgetOverall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = freezed,Object? month = null,Object? limitAmount = null,Object? spent = null,Object? remaining = null,Object? percentage = null,Object? status = null,}) {
  return _then(_BudgetOverall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BudgetItem {

 String get id; String get categoryId; String get month; int get limitAmount; int get spent; int get remaining; double get percentage; String get status; CategoryMeta? get category;
/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetItemCopyWith<BudgetItem> get copyWith => _$BudgetItemCopyWithImpl<BudgetItem>(this as BudgetItem, _$identity);

  /// Serializes this BudgetItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,month,limitAmount,spent,remaining,percentage,status,category);

@override
String toString() {
  return 'BudgetItem(id: $id, categoryId: $categoryId, month: $month, limitAmount: $limitAmount, spent: $spent, remaining: $remaining, percentage: $percentage, status: $status, category: $category)';
}


}

/// @nodoc
abstract mixin class $BudgetItemCopyWith<$Res>  {
  factory $BudgetItemCopyWith(BudgetItem value, $Res Function(BudgetItem) _then) = _$BudgetItemCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String month, int limitAmount, int spent, int remaining, double percentage, String status, CategoryMeta? category
});


$CategoryMetaCopyWith<$Res>? get category;

}
/// @nodoc
class _$BudgetItemCopyWithImpl<$Res>
    implements $BudgetItemCopyWith<$Res> {
  _$BudgetItemCopyWithImpl(this._self, this._then);

  final BudgetItem _self;
  final $Res Function(BudgetItem) _then;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? month = null,Object? limitAmount = null,Object? spent = null,Object? remaining = null,Object? percentage = null,Object? status = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,
  ));
}
/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetItem].
extension BudgetItemPatterns on BudgetItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetItem value)  $default,){
final _that = this;
switch (_that) {
case _BudgetItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetItem value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status,  CategoryMeta? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status,  CategoryMeta? category)  $default,) {final _that = this;
switch (_that) {
case _BudgetItem():
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String month,  int limitAmount,  int spent,  int remaining,  double percentage,  String status,  CategoryMeta? category)?  $default,) {final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.month,_that.limitAmount,_that.spent,_that.remaining,_that.percentage,_that.status,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetItem implements BudgetItem {
  const _BudgetItem({required this.id, required this.categoryId, required this.month, required this.limitAmount, required this.spent, required this.remaining, required this.percentage, required this.status, this.category});
  factory _BudgetItem.fromJson(Map<String, dynamic> json) => _$BudgetItemFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  String month;
@override final  int limitAmount;
@override final  int spent;
@override final  int remaining;
@override final  double percentage;
@override final  String status;
@override final  CategoryMeta? category;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetItemCopyWith<_BudgetItem> get copyWith => __$BudgetItemCopyWithImpl<_BudgetItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,month,limitAmount,spent,remaining,percentage,status,category);

@override
String toString() {
  return 'BudgetItem(id: $id, categoryId: $categoryId, month: $month, limitAmount: $limitAmount, spent: $spent, remaining: $remaining, percentage: $percentage, status: $status, category: $category)';
}


}

/// @nodoc
abstract mixin class _$BudgetItemCopyWith<$Res> implements $BudgetItemCopyWith<$Res> {
  factory _$BudgetItemCopyWith(_BudgetItem value, $Res Function(_BudgetItem) _then) = __$BudgetItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String month, int limitAmount, int spent, int remaining, double percentage, String status, CategoryMeta? category
});


@override $CategoryMetaCopyWith<$Res>? get category;

}
/// @nodoc
class __$BudgetItemCopyWithImpl<$Res>
    implements _$BudgetItemCopyWith<$Res> {
  __$BudgetItemCopyWithImpl(this._self, this._then);

  final _BudgetItem _self;
  final $Res Function(_BudgetItem) _then;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? month = null,Object? limitAmount = null,Object? spent = null,Object? remaining = null,Object? percentage = null,Object? status = null,Object? category = freezed,}) {
  return _then(_BudgetItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,
  ));
}

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$BudgetSummary {

 String get month; BudgetThresholds get thresholds; BudgetOverall? get overall; int get totalLimit; int get totalSpent; int get totalRemaining; List<BudgetItem> get items;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);

  /// Serializes this BudgetSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.month, month) || other.month == month)&&(identical(other.thresholds, thresholds) || other.thresholds == thresholds)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.totalLimit, totalLimit) || other.totalLimit == totalLimit)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.totalRemaining, totalRemaining) || other.totalRemaining == totalRemaining)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,thresholds,overall,totalLimit,totalSpent,totalRemaining,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'BudgetSummary(month: $month, thresholds: $thresholds, overall: $overall, totalLimit: $totalLimit, totalSpent: $totalSpent, totalRemaining: $totalRemaining, items: $items)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 String month, BudgetThresholds thresholds, BudgetOverall? overall, int totalLimit, int totalSpent, int totalRemaining, List<BudgetItem> items
});


$BudgetThresholdsCopyWith<$Res> get thresholds;$BudgetOverallCopyWith<$Res>? get overall;

}
/// @nodoc
class _$BudgetSummaryCopyWithImpl<$Res>
    implements $BudgetSummaryCopyWith<$Res> {
  _$BudgetSummaryCopyWithImpl(this._self, this._then);

  final BudgetSummary _self;
  final $Res Function(BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? thresholds = null,Object? overall = freezed,Object? totalLimit = null,Object? totalSpent = null,Object? totalRemaining = null,Object? items = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,thresholds: null == thresholds ? _self.thresholds : thresholds // ignore: cast_nullable_to_non_nullable
as BudgetThresholds,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetOverall?,totalLimit: null == totalLimit ? _self.totalLimit : totalLimit // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,totalRemaining: null == totalRemaining ? _self.totalRemaining : totalRemaining // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetItem>,
  ));
}
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetThresholdsCopyWith<$Res> get thresholds {
  
  return $BudgetThresholdsCopyWith<$Res>(_self.thresholds, (value) {
    return _then(_self.copyWith(thresholds: value));
  });
}/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetOverallCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetOverallCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetSummary].
extension BudgetSummaryPatterns on BudgetSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSummary value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  BudgetThresholds thresholds,  BudgetOverall? overall,  int totalLimit,  int totalSpent,  int totalRemaining,  List<BudgetItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.month,_that.thresholds,_that.overall,_that.totalLimit,_that.totalSpent,_that.totalRemaining,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  BudgetThresholds thresholds,  BudgetOverall? overall,  int totalLimit,  int totalSpent,  int totalRemaining,  List<BudgetItem> items)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.month,_that.thresholds,_that.overall,_that.totalLimit,_that.totalSpent,_that.totalRemaining,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  BudgetThresholds thresholds,  BudgetOverall? overall,  int totalLimit,  int totalSpent,  int totalRemaining,  List<BudgetItem> items)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.month,_that.thresholds,_that.overall,_that.totalLimit,_that.totalSpent,_that.totalRemaining,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetSummary implements BudgetSummary {
  const _BudgetSummary({required this.month, required this.thresholds, this.overall, this.totalLimit = 0, this.totalSpent = 0, this.totalRemaining = 0, final  List<BudgetItem> items = const <BudgetItem>[]}): _items = items;
  factory _BudgetSummary.fromJson(Map<String, dynamic> json) => _$BudgetSummaryFromJson(json);

@override final  String month;
@override final  BudgetThresholds thresholds;
@override final  BudgetOverall? overall;
@override@JsonKey() final  int totalLimit;
@override@JsonKey() final  int totalSpent;
@override@JsonKey() final  int totalRemaining;
 final  List<BudgetItem> _items;
@override@JsonKey() List<BudgetItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.month, month) || other.month == month)&&(identical(other.thresholds, thresholds) || other.thresholds == thresholds)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.totalLimit, totalLimit) || other.totalLimit == totalLimit)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.totalRemaining, totalRemaining) || other.totalRemaining == totalRemaining)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,thresholds,overall,totalLimit,totalSpent,totalRemaining,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'BudgetSummary(month: $month, thresholds: $thresholds, overall: $overall, totalLimit: $totalLimit, totalSpent: $totalSpent, totalRemaining: $totalRemaining, items: $items)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 String month, BudgetThresholds thresholds, BudgetOverall? overall, int totalLimit, int totalSpent, int totalRemaining, List<BudgetItem> items
});


@override $BudgetThresholdsCopyWith<$Res> get thresholds;@override $BudgetOverallCopyWith<$Res>? get overall;

}
/// @nodoc
class __$BudgetSummaryCopyWithImpl<$Res>
    implements _$BudgetSummaryCopyWith<$Res> {
  __$BudgetSummaryCopyWithImpl(this._self, this._then);

  final _BudgetSummary _self;
  final $Res Function(_BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? thresholds = null,Object? overall = freezed,Object? totalLimit = null,Object? totalSpent = null,Object? totalRemaining = null,Object? items = null,}) {
  return _then(_BudgetSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,thresholds: null == thresholds ? _self.thresholds : thresholds // ignore: cast_nullable_to_non_nullable
as BudgetThresholds,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetOverall?,totalLimit: null == totalLimit ? _self.totalLimit : totalLimit // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as int,totalRemaining: null == totalRemaining ? _self.totalRemaining : totalRemaining // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetItem>,
  ));
}

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetThresholdsCopyWith<$Res> get thresholds {
  
  return $BudgetThresholdsCopyWith<$Res>(_self.thresholds, (value) {
    return _then(_self.copyWith(thresholds: value));
  });
}/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetOverallCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetOverallCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// @nodoc
mixin _$QuickTemplateItem {

 String get id; String get label; String get title; int get amount; String get categoryId; String get walletId; String? get note; CategoryMeta? get category; WalletMeta? get wallet;
/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuickTemplateItemCopyWith<QuickTemplateItem> get copyWith => _$QuickTemplateItemCopyWithImpl<QuickTemplateItem>(this as QuickTemplateItem, _$identity);

  /// Serializes this QuickTemplateItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuickTemplateItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.note, note) || other.note == note)&&(identical(other.category, category) || other.category == category)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,title,amount,categoryId,walletId,note,category,wallet);

@override
String toString() {
  return 'QuickTemplateItem(id: $id, label: $label, title: $title, amount: $amount, categoryId: $categoryId, walletId: $walletId, note: $note, category: $category, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class $QuickTemplateItemCopyWith<$Res>  {
  factory $QuickTemplateItemCopyWith(QuickTemplateItem value, $Res Function(QuickTemplateItem) _then) = _$QuickTemplateItemCopyWithImpl;
@useResult
$Res call({
 String id, String label, String title, int amount, String categoryId, String walletId, String? note, CategoryMeta? category, WalletMeta? wallet
});


$CategoryMetaCopyWith<$Res>? get category;$WalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class _$QuickTemplateItemCopyWithImpl<$Res>
    implements $QuickTemplateItemCopyWith<$Res> {
  _$QuickTemplateItemCopyWithImpl(this._self, this._then);

  final QuickTemplateItem _self;
  final $Res Function(QuickTemplateItem) _then;

/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? walletId = null,Object? note = freezed,Object? category = freezed,Object? wallet = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,
  ));
}
/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuickTemplateItem].
extension QuickTemplateItemPatterns on QuickTemplateItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuickTemplateItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuickTemplateItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuickTemplateItem value)  $default,){
final _that = this;
switch (_that) {
case _QuickTemplateItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuickTemplateItem value)?  $default,){
final _that = this;
switch (_that) {
case _QuickTemplateItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String title,  int amount,  String categoryId,  String walletId,  String? note,  CategoryMeta? category,  WalletMeta? wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuickTemplateItem() when $default != null:
return $default(_that.id,_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note,_that.category,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String title,  int amount,  String categoryId,  String walletId,  String? note,  CategoryMeta? category,  WalletMeta? wallet)  $default,) {final _that = this;
switch (_that) {
case _QuickTemplateItem():
return $default(_that.id,_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note,_that.category,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String title,  int amount,  String categoryId,  String walletId,  String? note,  CategoryMeta? category,  WalletMeta? wallet)?  $default,) {final _that = this;
switch (_that) {
case _QuickTemplateItem() when $default != null:
return $default(_that.id,_that.label,_that.title,_that.amount,_that.categoryId,_that.walletId,_that.note,_that.category,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuickTemplateItem implements QuickTemplateItem {
  const _QuickTemplateItem({required this.id, required this.label, required this.title, required this.amount, required this.categoryId, required this.walletId, this.note, this.category, this.wallet});
  factory _QuickTemplateItem.fromJson(Map<String, dynamic> json) => _$QuickTemplateItemFromJson(json);

@override final  String id;
@override final  String label;
@override final  String title;
@override final  int amount;
@override final  String categoryId;
@override final  String walletId;
@override final  String? note;
@override final  CategoryMeta? category;
@override final  WalletMeta? wallet;

/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuickTemplateItemCopyWith<_QuickTemplateItem> get copyWith => __$QuickTemplateItemCopyWithImpl<_QuickTemplateItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuickTemplateItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuickTemplateItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.note, note) || other.note == note)&&(identical(other.category, category) || other.category == category)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,title,amount,categoryId,walletId,note,category,wallet);

@override
String toString() {
  return 'QuickTemplateItem(id: $id, label: $label, title: $title, amount: $amount, categoryId: $categoryId, walletId: $walletId, note: $note, category: $category, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$QuickTemplateItemCopyWith<$Res> implements $QuickTemplateItemCopyWith<$Res> {
  factory _$QuickTemplateItemCopyWith(_QuickTemplateItem value, $Res Function(_QuickTemplateItem) _then) = __$QuickTemplateItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String title, int amount, String categoryId, String walletId, String? note, CategoryMeta? category, WalletMeta? wallet
});


@override $CategoryMetaCopyWith<$Res>? get category;@override $WalletMetaCopyWith<$Res>? get wallet;

}
/// @nodoc
class __$QuickTemplateItemCopyWithImpl<$Res>
    implements _$QuickTemplateItemCopyWith<$Res> {
  __$QuickTemplateItemCopyWithImpl(this._self, this._then);

  final _QuickTemplateItem _self;
  final $Res Function(_QuickTemplateItem) _then;

/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? walletId = null,Object? note = freezed,Object? category = freezed,Object? wallet = freezed,}) {
  return _then(_QuickTemplateItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryMeta?,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletMeta?,
  ));
}

/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryMetaCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryMetaCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of QuickTemplateItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletMetaCopyWith<$Res>? get wallet {
    if (_self.wallet == null) {
    return null;
  }

  return $WalletMetaCopyWith<$Res>(_self.wallet!, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}

// dart format on
