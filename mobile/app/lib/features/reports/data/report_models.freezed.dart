// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategorySummaryItem {

 String get id; String get name; String? get icon; String? get color;
/// Create a copy of CategorySummaryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySummaryItemCopyWith<CategorySummaryItem> get copyWith => _$CategorySummaryItemCopyWithImpl<CategorySummaryItem>(this as CategorySummaryItem, _$identity);

  /// Serializes this CategorySummaryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySummaryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color);

@override
String toString() {
  return 'CategorySummaryItem(id: $id, name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $CategorySummaryItemCopyWith<$Res>  {
  factory $CategorySummaryItemCopyWith(CategorySummaryItem value, $Res Function(CategorySummaryItem) _then) = _$CategorySummaryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? icon, String? color
});




}
/// @nodoc
class _$CategorySummaryItemCopyWithImpl<$Res>
    implements $CategorySummaryItemCopyWith<$Res> {
  _$CategorySummaryItemCopyWithImpl(this._self, this._then);

  final CategorySummaryItem _self;
  final $Res Function(CategorySummaryItem) _then;

/// Create a copy of CategorySummaryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySummaryItem].
extension CategorySummaryItemPatterns on CategorySummaryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySummaryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySummaryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySummaryItem value)  $default,){
final _that = this;
switch (_that) {
case _CategorySummaryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySummaryItem value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySummaryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySummaryItem() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? icon,  String? color)  $default,) {final _that = this;
switch (_that) {
case _CategorySummaryItem():
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? icon,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _CategorySummaryItem() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategorySummaryItem implements CategorySummaryItem {
  const _CategorySummaryItem({required this.id, required this.name, this.icon, this.color});
  factory _CategorySummaryItem.fromJson(Map<String, dynamic> json) => _$CategorySummaryItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? icon;
@override final  String? color;

/// Create a copy of CategorySummaryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySummaryItemCopyWith<_CategorySummaryItem> get copyWith => __$CategorySummaryItemCopyWithImpl<_CategorySummaryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategorySummaryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySummaryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color);

@override
String toString() {
  return 'CategorySummaryItem(id: $id, name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CategorySummaryItemCopyWith<$Res> implements $CategorySummaryItemCopyWith<$Res> {
  factory _$CategorySummaryItemCopyWith(_CategorySummaryItem value, $Res Function(_CategorySummaryItem) _then) = __$CategorySummaryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? icon, String? color
});




}
/// @nodoc
class __$CategorySummaryItemCopyWithImpl<$Res>
    implements _$CategorySummaryItemCopyWith<$Res> {
  __$CategorySummaryItemCopyWithImpl(this._self, this._then);

  final _CategorySummaryItem _self;
  final $Res Function(_CategorySummaryItem) _then;

/// Create a copy of CategorySummaryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? color = freezed,}) {
  return _then(_CategorySummaryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CategoryReportItem {

 CategorySummaryItem get category;@JsonKey(fromJson: _toInt) int get amount;@JsonKey(fromJson: _toInt) int get count;@JsonKey(fromJson: _toDouble) double get percentage;
/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryReportItemCopyWith<CategoryReportItem> get copyWith => _$CategoryReportItemCopyWithImpl<CategoryReportItem>(this as CategoryReportItem, _$identity);

  /// Serializes this CategoryReportItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryReportItem&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,amount,count,percentage);

@override
String toString() {
  return 'CategoryReportItem(category: $category, amount: $amount, count: $count, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $CategoryReportItemCopyWith<$Res>  {
  factory $CategoryReportItemCopyWith(CategoryReportItem value, $Res Function(CategoryReportItem) _then) = _$CategoryReportItemCopyWithImpl;
@useResult
$Res call({
 CategorySummaryItem category,@JsonKey(fromJson: _toInt) int amount,@JsonKey(fromJson: _toInt) int count,@JsonKey(fromJson: _toDouble) double percentage
});


$CategorySummaryItemCopyWith<$Res> get category;

}
/// @nodoc
class _$CategoryReportItemCopyWithImpl<$Res>
    implements $CategoryReportItemCopyWith<$Res> {
  _$CategoryReportItemCopyWithImpl(this._self, this._then);

  final CategoryReportItem _self;
  final $Res Function(CategoryReportItem) _then;

/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? amount = null,Object? count = null,Object? percentage = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryItem,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryItemCopyWith<$Res> get category {
  
  return $CategorySummaryItemCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryReportItem].
extension CategoryReportItemPatterns on CategoryReportItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryReportItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryReportItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryReportItem value)  $default,){
final _that = this;
switch (_that) {
case _CategoryReportItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryReportItem value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryReportItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategorySummaryItem category, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(fromJson: _toInt)  int count, @JsonKey(fromJson: _toDouble)  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryReportItem() when $default != null:
return $default(_that.category,_that.amount,_that.count,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategorySummaryItem category, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(fromJson: _toInt)  int count, @JsonKey(fromJson: _toDouble)  double percentage)  $default,) {final _that = this;
switch (_that) {
case _CategoryReportItem():
return $default(_that.category,_that.amount,_that.count,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategorySummaryItem category, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(fromJson: _toInt)  int count, @JsonKey(fromJson: _toDouble)  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _CategoryReportItem() when $default != null:
return $default(_that.category,_that.amount,_that.count,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryReportItem implements CategoryReportItem {
  const _CategoryReportItem({required this.category, @JsonKey(fromJson: _toInt) this.amount = 0, @JsonKey(fromJson: _toInt) this.count = 0, @JsonKey(fromJson: _toDouble) this.percentage = 0.0});
  factory _CategoryReportItem.fromJson(Map<String, dynamic> json) => _$CategoryReportItemFromJson(json);

@override final  CategorySummaryItem category;
@override@JsonKey(fromJson: _toInt) final  int amount;
@override@JsonKey(fromJson: _toInt) final  int count;
@override@JsonKey(fromJson: _toDouble) final  double percentage;

/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryReportItemCopyWith<_CategoryReportItem> get copyWith => __$CategoryReportItemCopyWithImpl<_CategoryReportItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryReportItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryReportItem&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.count, count) || other.count == count)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,amount,count,percentage);

@override
String toString() {
  return 'CategoryReportItem(category: $category, amount: $amount, count: $count, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$CategoryReportItemCopyWith<$Res> implements $CategoryReportItemCopyWith<$Res> {
  factory _$CategoryReportItemCopyWith(_CategoryReportItem value, $Res Function(_CategoryReportItem) _then) = __$CategoryReportItemCopyWithImpl;
@override @useResult
$Res call({
 CategorySummaryItem category,@JsonKey(fromJson: _toInt) int amount,@JsonKey(fromJson: _toInt) int count,@JsonKey(fromJson: _toDouble) double percentage
});


@override $CategorySummaryItemCopyWith<$Res> get category;

}
/// @nodoc
class __$CategoryReportItemCopyWithImpl<$Res>
    implements _$CategoryReportItemCopyWith<$Res> {
  __$CategoryReportItemCopyWithImpl(this._self, this._then);

  final _CategoryReportItem _self;
  final $Res Function(_CategoryReportItem) _then;

/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? amount = null,Object? count = null,Object? percentage = null,}) {
  return _then(_CategoryReportItem(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryItem,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of CategoryReportItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryItemCopyWith<$Res> get category {
  
  return $CategorySummaryItemCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$ComparisonMetric {

@JsonKey(fromJson: _toInt) int get current;@JsonKey(fromJson: _toInt) int get previous;@JsonKey(fromJson: _toInt) int get difference;@JsonKey(fromJson: _toNullableDouble) double? get percentageChange; String get trend; String? get categoryName;
/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<ComparisonMetric> get copyWith => _$ComparisonMetricCopyWithImpl<ComparisonMetric>(this as ComparisonMetric, _$identity);

  /// Serializes this ComparisonMetric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonMetric&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.percentageChange, percentageChange) || other.percentageChange == percentageChange)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,previous,difference,percentageChange,trend,categoryName);

@override
String toString() {
  return 'ComparisonMetric(current: $current, previous: $previous, difference: $difference, percentageChange: $percentageChange, trend: $trend, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class $ComparisonMetricCopyWith<$Res>  {
  factory $ComparisonMetricCopyWith(ComparisonMetric value, $Res Function(ComparisonMetric) _then) = _$ComparisonMetricCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int current,@JsonKey(fromJson: _toInt) int previous,@JsonKey(fromJson: _toInt) int difference,@JsonKey(fromJson: _toNullableDouble) double? percentageChange, String trend, String? categoryName
});




}
/// @nodoc
class _$ComparisonMetricCopyWithImpl<$Res>
    implements $ComparisonMetricCopyWith<$Res> {
  _$ComparisonMetricCopyWithImpl(this._self, this._then);

  final ComparisonMetric _self;
  final $Res Function(ComparisonMetric) _then;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? previous = null,Object? difference = null,Object? percentageChange = freezed,Object? trend = null,Object? categoryName = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as int,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int,percentageChange: freezed == percentageChange ? _self.percentageChange : percentageChange // ignore: cast_nullable_to_non_nullable
as double?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonMetric].
extension ComparisonMetricPatterns on ComparisonMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparisonMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparisonMetric value)  $default,){
final _that = this;
switch (_that) {
case _ComparisonMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparisonMetric value)?  $default,){
final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int current, @JsonKey(fromJson: _toInt)  int previous, @JsonKey(fromJson: _toInt)  int difference, @JsonKey(fromJson: _toNullableDouble)  double? percentageChange,  String trend,  String? categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that.current,_that.previous,_that.difference,_that.percentageChange,_that.trend,_that.categoryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int current, @JsonKey(fromJson: _toInt)  int previous, @JsonKey(fromJson: _toInt)  int difference, @JsonKey(fromJson: _toNullableDouble)  double? percentageChange,  String trend,  String? categoryName)  $default,) {final _that = this;
switch (_that) {
case _ComparisonMetric():
return $default(_that.current,_that.previous,_that.difference,_that.percentageChange,_that.trend,_that.categoryName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int current, @JsonKey(fromJson: _toInt)  int previous, @JsonKey(fromJson: _toInt)  int difference, @JsonKey(fromJson: _toNullableDouble)  double? percentageChange,  String trend,  String? categoryName)?  $default,) {final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that.current,_that.previous,_that.difference,_that.percentageChange,_that.trend,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComparisonMetric implements ComparisonMetric {
  const _ComparisonMetric({@JsonKey(fromJson: _toInt) this.current = 0, @JsonKey(fromJson: _toInt) this.previous = 0, @JsonKey(fromJson: _toInt) this.difference = 0, @JsonKey(fromJson: _toNullableDouble) this.percentageChange, this.trend = 'stable', this.categoryName});
  factory _ComparisonMetric.fromJson(Map<String, dynamic> json) => _$ComparisonMetricFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int current;
@override@JsonKey(fromJson: _toInt) final  int previous;
@override@JsonKey(fromJson: _toInt) final  int difference;
@override@JsonKey(fromJson: _toNullableDouble) final  double? percentageChange;
@override@JsonKey() final  String trend;
@override final  String? categoryName;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparisonMetricCopyWith<_ComparisonMetric> get copyWith => __$ComparisonMetricCopyWithImpl<_ComparisonMetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComparisonMetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparisonMetric&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.percentageChange, percentageChange) || other.percentageChange == percentageChange)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,previous,difference,percentageChange,trend,categoryName);

@override
String toString() {
  return 'ComparisonMetric(current: $current, previous: $previous, difference: $difference, percentageChange: $percentageChange, trend: $trend, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$ComparisonMetricCopyWith<$Res> implements $ComparisonMetricCopyWith<$Res> {
  factory _$ComparisonMetricCopyWith(_ComparisonMetric value, $Res Function(_ComparisonMetric) _then) = __$ComparisonMetricCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int current,@JsonKey(fromJson: _toInt) int previous,@JsonKey(fromJson: _toInt) int difference,@JsonKey(fromJson: _toNullableDouble) double? percentageChange, String trend, String? categoryName
});




}
/// @nodoc
class __$ComparisonMetricCopyWithImpl<$Res>
    implements _$ComparisonMetricCopyWith<$Res> {
  __$ComparisonMetricCopyWithImpl(this._self, this._then);

  final _ComparisonMetric _self;
  final $Res Function(_ComparisonMetric) _then;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? previous = null,Object? difference = null,Object? percentageChange = freezed,Object? trend = null,Object? categoryName = freezed,}) {
  return _then(_ComparisonMetric(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as int,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as int,percentageChange: freezed == percentageChange ? _self.percentageChange : percentageChange // ignore: cast_nullable_to_non_nullable
as double?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportComparison {

 String get previousMonth; ComparisonMetric get income; ComparisonMetric get expense;
/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<ReportComparison> get copyWith => _$ReportComparisonCopyWithImpl<ReportComparison>(this as ReportComparison, _$identity);

  /// Serializes this ReportComparison to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportComparison&&(identical(other.previousMonth, previousMonth) || other.previousMonth == previousMonth)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,previousMonth,income,expense);

@override
String toString() {
  return 'ReportComparison(previousMonth: $previousMonth, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $ReportComparisonCopyWith<$Res>  {
  factory $ReportComparisonCopyWith(ReportComparison value, $Res Function(ReportComparison) _then) = _$ReportComparisonCopyWithImpl;
@useResult
$Res call({
 String previousMonth, ComparisonMetric income, ComparisonMetric expense
});


$ComparisonMetricCopyWith<$Res> get income;$ComparisonMetricCopyWith<$Res> get expense;

}
/// @nodoc
class _$ReportComparisonCopyWithImpl<$Res>
    implements $ReportComparisonCopyWith<$Res> {
  _$ReportComparisonCopyWithImpl(this._self, this._then);

  final ReportComparison _self;
  final $Res Function(ReportComparison) _then;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? previousMonth = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
previousMonth: null == previousMonth ? _self.previousMonth : previousMonth // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as ComparisonMetric,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as ComparisonMetric,
  ));
}
/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res> get income {
  
  return $ComparisonMetricCopyWith<$Res>(_self.income, (value) {
    return _then(_self.copyWith(income: value));
  });
}/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res> get expense {
  
  return $ComparisonMetricCopyWith<$Res>(_self.expense, (value) {
    return _then(_self.copyWith(expense: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportComparison].
extension ReportComparisonPatterns on ReportComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportComparison value)  $default,){
final _that = this;
switch (_that) {
case _ReportComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportComparison value)?  $default,){
final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String previousMonth,  ComparisonMetric income,  ComparisonMetric expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
return $default(_that.previousMonth,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String previousMonth,  ComparisonMetric income,  ComparisonMetric expense)  $default,) {final _that = this;
switch (_that) {
case _ReportComparison():
return $default(_that.previousMonth,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String previousMonth,  ComparisonMetric income,  ComparisonMetric expense)?  $default,) {final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
return $default(_that.previousMonth,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportComparison implements ReportComparison {
  const _ReportComparison({required this.previousMonth, required this.income, required this.expense});
  factory _ReportComparison.fromJson(Map<String, dynamic> json) => _$ReportComparisonFromJson(json);

@override final  String previousMonth;
@override final  ComparisonMetric income;
@override final  ComparisonMetric expense;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportComparisonCopyWith<_ReportComparison> get copyWith => __$ReportComparisonCopyWithImpl<_ReportComparison>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportComparisonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportComparison&&(identical(other.previousMonth, previousMonth) || other.previousMonth == previousMonth)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,previousMonth,income,expense);

@override
String toString() {
  return 'ReportComparison(previousMonth: $previousMonth, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$ReportComparisonCopyWith<$Res> implements $ReportComparisonCopyWith<$Res> {
  factory _$ReportComparisonCopyWith(_ReportComparison value, $Res Function(_ReportComparison) _then) = __$ReportComparisonCopyWithImpl;
@override @useResult
$Res call({
 String previousMonth, ComparisonMetric income, ComparisonMetric expense
});


@override $ComparisonMetricCopyWith<$Res> get income;@override $ComparisonMetricCopyWith<$Res> get expense;

}
/// @nodoc
class __$ReportComparisonCopyWithImpl<$Res>
    implements _$ReportComparisonCopyWith<$Res> {
  __$ReportComparisonCopyWithImpl(this._self, this._then);

  final _ReportComparison _self;
  final $Res Function(_ReportComparison) _then;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? previousMonth = null,Object? income = null,Object? expense = null,}) {
  return _then(_ReportComparison(
previousMonth: null == previousMonth ? _self.previousMonth : previousMonth // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as ComparisonMetric,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as ComparisonMetric,
  ));
}

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res> get income {
  
  return $ComparisonMetricCopyWith<$Res>(_self.income, (value) {
    return _then(_self.copyWith(income: value));
  });
}/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res> get expense {
  
  return $ComparisonMetricCopyWith<$Res>(_self.expense, (value) {
    return _then(_self.copyWith(expense: value));
  });
}
}


/// @nodoc
mixin _$ForecastMetric {

@JsonKey(fromJson: _toInt) int get predicted;@JsonKey(fromJson: _toInt) int get average;@JsonKey(fromJson: _toDouble) double get growthRate; String get method;
/// Create a copy of ForecastMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastMetricCopyWith<ForecastMetric> get copyWith => _$ForecastMetricCopyWithImpl<ForecastMetric>(this as ForecastMetric, _$identity);

  /// Serializes this ForecastMetric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForecastMetric&&(identical(other.predicted, predicted) || other.predicted == predicted)&&(identical(other.average, average) || other.average == average)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,predicted,average,growthRate,method);

@override
String toString() {
  return 'ForecastMetric(predicted: $predicted, average: $average, growthRate: $growthRate, method: $method)';
}


}

/// @nodoc
abstract mixin class $ForecastMetricCopyWith<$Res>  {
  factory $ForecastMetricCopyWith(ForecastMetric value, $Res Function(ForecastMetric) _then) = _$ForecastMetricCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int predicted,@JsonKey(fromJson: _toInt) int average,@JsonKey(fromJson: _toDouble) double growthRate, String method
});




}
/// @nodoc
class _$ForecastMetricCopyWithImpl<$Res>
    implements $ForecastMetricCopyWith<$Res> {
  _$ForecastMetricCopyWithImpl(this._self, this._then);

  final ForecastMetric _self;
  final $Res Function(ForecastMetric) _then;

/// Create a copy of ForecastMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? predicted = null,Object? average = null,Object? growthRate = null,Object? method = null,}) {
  return _then(_self.copyWith(
predicted: null == predicted ? _self.predicted : predicted // ignore: cast_nullable_to_non_nullable
as int,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as int,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ForecastMetric].
extension ForecastMetricPatterns on ForecastMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForecastMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForecastMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForecastMetric value)  $default,){
final _that = this;
switch (_that) {
case _ForecastMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForecastMetric value)?  $default,){
final _that = this;
switch (_that) {
case _ForecastMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int predicted, @JsonKey(fromJson: _toInt)  int average, @JsonKey(fromJson: _toDouble)  double growthRate,  String method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForecastMetric() when $default != null:
return $default(_that.predicted,_that.average,_that.growthRate,_that.method);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int predicted, @JsonKey(fromJson: _toInt)  int average, @JsonKey(fromJson: _toDouble)  double growthRate,  String method)  $default,) {final _that = this;
switch (_that) {
case _ForecastMetric():
return $default(_that.predicted,_that.average,_that.growthRate,_that.method);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int predicted, @JsonKey(fromJson: _toInt)  int average, @JsonKey(fromJson: _toDouble)  double growthRate,  String method)?  $default,) {final _that = this;
switch (_that) {
case _ForecastMetric() when $default != null:
return $default(_that.predicted,_that.average,_that.growthRate,_that.method);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForecastMetric implements ForecastMetric {
  const _ForecastMetric({@JsonKey(fromJson: _toInt) this.predicted = 0, @JsonKey(fromJson: _toInt) this.average = 0, @JsonKey(fromJson: _toDouble) this.growthRate = 0.0, this.method = 'simple_average'});
  factory _ForecastMetric.fromJson(Map<String, dynamic> json) => _$ForecastMetricFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int predicted;
@override@JsonKey(fromJson: _toInt) final  int average;
@override@JsonKey(fromJson: _toDouble) final  double growthRate;
@override@JsonKey() final  String method;

/// Create a copy of ForecastMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastMetricCopyWith<_ForecastMetric> get copyWith => __$ForecastMetricCopyWithImpl<_ForecastMetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastMetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForecastMetric&&(identical(other.predicted, predicted) || other.predicted == predicted)&&(identical(other.average, average) || other.average == average)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,predicted,average,growthRate,method);

@override
String toString() {
  return 'ForecastMetric(predicted: $predicted, average: $average, growthRate: $growthRate, method: $method)';
}


}

/// @nodoc
abstract mixin class _$ForecastMetricCopyWith<$Res> implements $ForecastMetricCopyWith<$Res> {
  factory _$ForecastMetricCopyWith(_ForecastMetric value, $Res Function(_ForecastMetric) _then) = __$ForecastMetricCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int predicted,@JsonKey(fromJson: _toInt) int average,@JsonKey(fromJson: _toDouble) double growthRate, String method
});




}
/// @nodoc
class __$ForecastMetricCopyWithImpl<$Res>
    implements _$ForecastMetricCopyWith<$Res> {
  __$ForecastMetricCopyWithImpl(this._self, this._then);

  final _ForecastMetric _self;
  final $Res Function(_ForecastMetric) _then;

/// Create a copy of ForecastMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? predicted = null,Object? average = null,Object? growthRate = null,Object? method = null,}) {
  return _then(_ForecastMetric(
predicted: null == predicted ? _self.predicted : predicted // ignore: cast_nullable_to_non_nullable
as int,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as int,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ForecastData {

 String get month; ForecastMetric get income; ForecastMetric get expense;
/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastDataCopyWith<ForecastData> get copyWith => _$ForecastDataCopyWithImpl<ForecastData>(this as ForecastData, _$identity);

  /// Serializes this ForecastData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForecastData&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,income,expense);

@override
String toString() {
  return 'ForecastData(month: $month, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $ForecastDataCopyWith<$Res>  {
  factory $ForecastDataCopyWith(ForecastData value, $Res Function(ForecastData) _then) = _$ForecastDataCopyWithImpl;
@useResult
$Res call({
 String month, ForecastMetric income, ForecastMetric expense
});


$ForecastMetricCopyWith<$Res> get income;$ForecastMetricCopyWith<$Res> get expense;

}
/// @nodoc
class _$ForecastDataCopyWithImpl<$Res>
    implements $ForecastDataCopyWith<$Res> {
  _$ForecastDataCopyWithImpl(this._self, this._then);

  final ForecastData _self;
  final $Res Function(ForecastData) _then;

/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as ForecastMetric,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as ForecastMetric,
  ));
}
/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastMetricCopyWith<$Res> get income {
  
  return $ForecastMetricCopyWith<$Res>(_self.income, (value) {
    return _then(_self.copyWith(income: value));
  });
}/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastMetricCopyWith<$Res> get expense {
  
  return $ForecastMetricCopyWith<$Res>(_self.expense, (value) {
    return _then(_self.copyWith(expense: value));
  });
}
}


/// Adds pattern-matching-related methods to [ForecastData].
extension ForecastDataPatterns on ForecastData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForecastData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForecastData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForecastData value)  $default,){
final _that = this;
switch (_that) {
case _ForecastData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForecastData value)?  $default,){
final _that = this;
switch (_that) {
case _ForecastData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  ForecastMetric income,  ForecastMetric expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForecastData() when $default != null:
return $default(_that.month,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  ForecastMetric income,  ForecastMetric expense)  $default,) {final _that = this;
switch (_that) {
case _ForecastData():
return $default(_that.month,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  ForecastMetric income,  ForecastMetric expense)?  $default,) {final _that = this;
switch (_that) {
case _ForecastData() when $default != null:
return $default(_that.month,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForecastData implements ForecastData {
  const _ForecastData({required this.month, required this.income, required this.expense});
  factory _ForecastData.fromJson(Map<String, dynamic> json) => _$ForecastDataFromJson(json);

@override final  String month;
@override final  ForecastMetric income;
@override final  ForecastMetric expense;

/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastDataCopyWith<_ForecastData> get copyWith => __$ForecastDataCopyWithImpl<_ForecastData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForecastData&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,income,expense);

@override
String toString() {
  return 'ForecastData(month: $month, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$ForecastDataCopyWith<$Res> implements $ForecastDataCopyWith<$Res> {
  factory _$ForecastDataCopyWith(_ForecastData value, $Res Function(_ForecastData) _then) = __$ForecastDataCopyWithImpl;
@override @useResult
$Res call({
 String month, ForecastMetric income, ForecastMetric expense
});


@override $ForecastMetricCopyWith<$Res> get income;@override $ForecastMetricCopyWith<$Res> get expense;

}
/// @nodoc
class __$ForecastDataCopyWithImpl<$Res>
    implements _$ForecastDataCopyWith<$Res> {
  __$ForecastDataCopyWithImpl(this._self, this._then);

  final _ForecastData _self;
  final $Res Function(_ForecastData) _then;

/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? income = null,Object? expense = null,}) {
  return _then(_ForecastData(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as ForecastMetric,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as ForecastMetric,
  ));
}

/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastMetricCopyWith<$Res> get income {
  
  return $ForecastMetricCopyWith<$Res>(_self.income, (value) {
    return _then(_self.copyWith(income: value));
  });
}/// Create a copy of ForecastData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastMetricCopyWith<$Res> get expense {
  
  return $ForecastMetricCopyWith<$Res>(_self.expense, (value) {
    return _then(_self.copyWith(expense: value));
  });
}
}


/// @nodoc
mixin _$MonthlyTrendItem {

 String get month;@JsonKey(fromJson: _toInt) int get income;@JsonKey(fromJson: _toInt) int get expense;@JsonKey(fromJson: _toInt) int get net;
/// Create a copy of MonthlyTrendItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyTrendItemCopyWith<MonthlyTrendItem> get copyWith => _$MonthlyTrendItemCopyWithImpl<MonthlyTrendItem>(this as MonthlyTrendItem, _$identity);

  /// Serializes this MonthlyTrendItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyTrendItem&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,income,expense,net);

@override
String toString() {
  return 'MonthlyTrendItem(month: $month, income: $income, expense: $expense, net: $net)';
}


}

/// @nodoc
abstract mixin class $MonthlyTrendItemCopyWith<$Res>  {
  factory $MonthlyTrendItemCopyWith(MonthlyTrendItem value, $Res Function(MonthlyTrendItem) _then) = _$MonthlyTrendItemCopyWithImpl;
@useResult
$Res call({
 String month,@JsonKey(fromJson: _toInt) int income,@JsonKey(fromJson: _toInt) int expense,@JsonKey(fromJson: _toInt) int net
});




}
/// @nodoc
class _$MonthlyTrendItemCopyWithImpl<$Res>
    implements $MonthlyTrendItemCopyWith<$Res> {
  _$MonthlyTrendItemCopyWithImpl(this._self, this._then);

  final MonthlyTrendItem _self;
  final $Res Function(MonthlyTrendItem) _then;

/// Create a copy of MonthlyTrendItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? income = null,Object? expense = null,Object? net = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyTrendItem].
extension MonthlyTrendItemPatterns on MonthlyTrendItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyTrendItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyTrendItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyTrendItem value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyTrendItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyTrendItem value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyTrendItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyTrendItem() when $default != null:
return $default(_that.month,_that.income,_that.expense,_that.net);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net)  $default,) {final _that = this;
switch (_that) {
case _MonthlyTrendItem():
return $default(_that.month,_that.income,_that.expense,_that.net);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyTrendItem() when $default != null:
return $default(_that.month,_that.income,_that.expense,_that.net);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyTrendItem implements MonthlyTrendItem {
  const _MonthlyTrendItem({required this.month, @JsonKey(fromJson: _toInt) this.income = 0, @JsonKey(fromJson: _toInt) this.expense = 0, @JsonKey(fromJson: _toInt) this.net = 0});
  factory _MonthlyTrendItem.fromJson(Map<String, dynamic> json) => _$MonthlyTrendItemFromJson(json);

@override final  String month;
@override@JsonKey(fromJson: _toInt) final  int income;
@override@JsonKey(fromJson: _toInt) final  int expense;
@override@JsonKey(fromJson: _toInt) final  int net;

/// Create a copy of MonthlyTrendItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyTrendItemCopyWith<_MonthlyTrendItem> get copyWith => __$MonthlyTrendItemCopyWithImpl<_MonthlyTrendItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyTrendItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyTrendItem&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,income,expense,net);

@override
String toString() {
  return 'MonthlyTrendItem(month: $month, income: $income, expense: $expense, net: $net)';
}


}

/// @nodoc
abstract mixin class _$MonthlyTrendItemCopyWith<$Res> implements $MonthlyTrendItemCopyWith<$Res> {
  factory _$MonthlyTrendItemCopyWith(_MonthlyTrendItem value, $Res Function(_MonthlyTrendItem) _then) = __$MonthlyTrendItemCopyWithImpl;
@override @useResult
$Res call({
 String month,@JsonKey(fromJson: _toInt) int income,@JsonKey(fromJson: _toInt) int expense,@JsonKey(fromJson: _toInt) int net
});




}
/// @nodoc
class __$MonthlyTrendItemCopyWithImpl<$Res>
    implements _$MonthlyTrendItemCopyWith<$Res> {
  __$MonthlyTrendItemCopyWithImpl(this._self, this._then);

  final _MonthlyTrendItem _self;
  final $Res Function(_MonthlyTrendItem) _then;

/// Create a copy of MonthlyTrendItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? income = null,Object? expense = null,Object? net = null,}) {
  return _then(_MonthlyTrendItem(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReportData {

 String get month; String? get walletId;@JsonKey(fromJson: _toInt) int get income;@JsonKey(fromJson: _toInt) int get expense;@JsonKey(fromJson: _toInt) int get net;@JsonKey(fromJson: _toDouble) double get savingRate; ReportComparison get comparison; List<CategoryReportItem> get incomeByCategory; List<CategoryReportItem> get expenseByCategory; ForecastData get forecast; List<MonthlyTrendItem> get history; ComparisonMetric? get topCategoryComparison;
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDataCopyWith<ReportData> get copyWith => _$ReportDataCopyWithImpl<ReportData>(this as ReportData, _$identity);

  /// Serializes this ReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportData&&(identical(other.month, month) || other.month == month)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.savingRate, savingRate) || other.savingRate == savingRate)&&(identical(other.comparison, comparison) || other.comparison == comparison)&&const DeepCollectionEquality().equals(other.incomeByCategory, incomeByCategory)&&const DeepCollectionEquality().equals(other.expenseByCategory, expenseByCategory)&&(identical(other.forecast, forecast) || other.forecast == forecast)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.topCategoryComparison, topCategoryComparison) || other.topCategoryComparison == topCategoryComparison));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,walletId,income,expense,net,savingRate,comparison,const DeepCollectionEquality().hash(incomeByCategory),const DeepCollectionEquality().hash(expenseByCategory),forecast,const DeepCollectionEquality().hash(history),topCategoryComparison);

@override
String toString() {
  return 'ReportData(month: $month, walletId: $walletId, income: $income, expense: $expense, net: $net, savingRate: $savingRate, comparison: $comparison, incomeByCategory: $incomeByCategory, expenseByCategory: $expenseByCategory, forecast: $forecast, history: $history, topCategoryComparison: $topCategoryComparison)';
}


}

/// @nodoc
abstract mixin class $ReportDataCopyWith<$Res>  {
  factory $ReportDataCopyWith(ReportData value, $Res Function(ReportData) _then) = _$ReportDataCopyWithImpl;
@useResult
$Res call({
 String month, String? walletId,@JsonKey(fromJson: _toInt) int income,@JsonKey(fromJson: _toInt) int expense,@JsonKey(fromJson: _toInt) int net,@JsonKey(fromJson: _toDouble) double savingRate, ReportComparison comparison, List<CategoryReportItem> incomeByCategory, List<CategoryReportItem> expenseByCategory, ForecastData forecast, List<MonthlyTrendItem> history, ComparisonMetric? topCategoryComparison
});


$ReportComparisonCopyWith<$Res> get comparison;$ForecastDataCopyWith<$Res> get forecast;$ComparisonMetricCopyWith<$Res>? get topCategoryComparison;

}
/// @nodoc
class _$ReportDataCopyWithImpl<$Res>
    implements $ReportDataCopyWith<$Res> {
  _$ReportDataCopyWithImpl(this._self, this._then);

  final ReportData _self;
  final $Res Function(ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? walletId = freezed,Object? income = null,Object? expense = null,Object? net = null,Object? savingRate = null,Object? comparison = null,Object? incomeByCategory = null,Object? expenseByCategory = null,Object? forecast = null,Object? history = null,Object? topCategoryComparison = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,savingRate: null == savingRate ? _self.savingRate : savingRate // ignore: cast_nullable_to_non_nullable
as double,comparison: null == comparison ? _self.comparison : comparison // ignore: cast_nullable_to_non_nullable
as ReportComparison,incomeByCategory: null == incomeByCategory ? _self.incomeByCategory : incomeByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryReportItem>,expenseByCategory: null == expenseByCategory ? _self.expenseByCategory : expenseByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryReportItem>,forecast: null == forecast ? _self.forecast : forecast // ignore: cast_nullable_to_non_nullable
as ForecastData,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<MonthlyTrendItem>,topCategoryComparison: freezed == topCategoryComparison ? _self.topCategoryComparison : topCategoryComparison // ignore: cast_nullable_to_non_nullable
as ComparisonMetric?,
  ));
}
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<$Res> get comparison {
  
  return $ReportComparisonCopyWith<$Res>(_self.comparison, (value) {
    return _then(_self.copyWith(comparison: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastDataCopyWith<$Res> get forecast {
  
  return $ForecastDataCopyWith<$Res>(_self.forecast, (value) {
    return _then(_self.copyWith(forecast: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res>? get topCategoryComparison {
    if (_self.topCategoryComparison == null) {
    return null;
  }

  return $ComparisonMetricCopyWith<$Res>(_self.topCategoryComparison!, (value) {
    return _then(_self.copyWith(topCategoryComparison: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportData].
extension ReportDataPatterns on ReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportData value)  $default,){
final _that = this;
switch (_that) {
case _ReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportData value)?  $default,){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  String? walletId, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net, @JsonKey(fromJson: _toDouble)  double savingRate,  ReportComparison comparison,  List<CategoryReportItem> incomeByCategory,  List<CategoryReportItem> expenseByCategory,  ForecastData forecast,  List<MonthlyTrendItem> history,  ComparisonMetric? topCategoryComparison)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.month,_that.walletId,_that.income,_that.expense,_that.net,_that.savingRate,_that.comparison,_that.incomeByCategory,_that.expenseByCategory,_that.forecast,_that.history,_that.topCategoryComparison);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  String? walletId, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net, @JsonKey(fromJson: _toDouble)  double savingRate,  ReportComparison comparison,  List<CategoryReportItem> incomeByCategory,  List<CategoryReportItem> expenseByCategory,  ForecastData forecast,  List<MonthlyTrendItem> history,  ComparisonMetric? topCategoryComparison)  $default,) {final _that = this;
switch (_that) {
case _ReportData():
return $default(_that.month,_that.walletId,_that.income,_that.expense,_that.net,_that.savingRate,_that.comparison,_that.incomeByCategory,_that.expenseByCategory,_that.forecast,_that.history,_that.topCategoryComparison);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  String? walletId, @JsonKey(fromJson: _toInt)  int income, @JsonKey(fromJson: _toInt)  int expense, @JsonKey(fromJson: _toInt)  int net, @JsonKey(fromJson: _toDouble)  double savingRate,  ReportComparison comparison,  List<CategoryReportItem> incomeByCategory,  List<CategoryReportItem> expenseByCategory,  ForecastData forecast,  List<MonthlyTrendItem> history,  ComparisonMetric? topCategoryComparison)?  $default,) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.month,_that.walletId,_that.income,_that.expense,_that.net,_that.savingRate,_that.comparison,_that.incomeByCategory,_that.expenseByCategory,_that.forecast,_that.history,_that.topCategoryComparison);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportData implements ReportData {
  const _ReportData({required this.month, this.walletId, @JsonKey(fromJson: _toInt) this.income = 0, @JsonKey(fromJson: _toInt) this.expense = 0, @JsonKey(fromJson: _toInt) this.net = 0, @JsonKey(fromJson: _toDouble) this.savingRate = 0.0, required this.comparison, final  List<CategoryReportItem> incomeByCategory = const <CategoryReportItem>[], final  List<CategoryReportItem> expenseByCategory = const <CategoryReportItem>[], required this.forecast, final  List<MonthlyTrendItem> history = const <MonthlyTrendItem>[], this.topCategoryComparison}): _incomeByCategory = incomeByCategory,_expenseByCategory = expenseByCategory,_history = history;
  factory _ReportData.fromJson(Map<String, dynamic> json) => _$ReportDataFromJson(json);

@override final  String month;
@override final  String? walletId;
@override@JsonKey(fromJson: _toInt) final  int income;
@override@JsonKey(fromJson: _toInt) final  int expense;
@override@JsonKey(fromJson: _toInt) final  int net;
@override@JsonKey(fromJson: _toDouble) final  double savingRate;
@override final  ReportComparison comparison;
 final  List<CategoryReportItem> _incomeByCategory;
@override@JsonKey() List<CategoryReportItem> get incomeByCategory {
  if (_incomeByCategory is EqualUnmodifiableListView) return _incomeByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incomeByCategory);
}

 final  List<CategoryReportItem> _expenseByCategory;
@override@JsonKey() List<CategoryReportItem> get expenseByCategory {
  if (_expenseByCategory is EqualUnmodifiableListView) return _expenseByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenseByCategory);
}

@override final  ForecastData forecast;
 final  List<MonthlyTrendItem> _history;
@override@JsonKey() List<MonthlyTrendItem> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  ComparisonMetric? topCategoryComparison;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDataCopyWith<_ReportData> get copyWith => __$ReportDataCopyWithImpl<_ReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportData&&(identical(other.month, month) || other.month == month)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.savingRate, savingRate) || other.savingRate == savingRate)&&(identical(other.comparison, comparison) || other.comparison == comparison)&&const DeepCollectionEquality().equals(other._incomeByCategory, _incomeByCategory)&&const DeepCollectionEquality().equals(other._expenseByCategory, _expenseByCategory)&&(identical(other.forecast, forecast) || other.forecast == forecast)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.topCategoryComparison, topCategoryComparison) || other.topCategoryComparison == topCategoryComparison));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,walletId,income,expense,net,savingRate,comparison,const DeepCollectionEquality().hash(_incomeByCategory),const DeepCollectionEquality().hash(_expenseByCategory),forecast,const DeepCollectionEquality().hash(_history),topCategoryComparison);

@override
String toString() {
  return 'ReportData(month: $month, walletId: $walletId, income: $income, expense: $expense, net: $net, savingRate: $savingRate, comparison: $comparison, incomeByCategory: $incomeByCategory, expenseByCategory: $expenseByCategory, forecast: $forecast, history: $history, topCategoryComparison: $topCategoryComparison)';
}


}

/// @nodoc
abstract mixin class _$ReportDataCopyWith<$Res> implements $ReportDataCopyWith<$Res> {
  factory _$ReportDataCopyWith(_ReportData value, $Res Function(_ReportData) _then) = __$ReportDataCopyWithImpl;
@override @useResult
$Res call({
 String month, String? walletId,@JsonKey(fromJson: _toInt) int income,@JsonKey(fromJson: _toInt) int expense,@JsonKey(fromJson: _toInt) int net,@JsonKey(fromJson: _toDouble) double savingRate, ReportComparison comparison, List<CategoryReportItem> incomeByCategory, List<CategoryReportItem> expenseByCategory, ForecastData forecast, List<MonthlyTrendItem> history, ComparisonMetric? topCategoryComparison
});


@override $ReportComparisonCopyWith<$Res> get comparison;@override $ForecastDataCopyWith<$Res> get forecast;@override $ComparisonMetricCopyWith<$Res>? get topCategoryComparison;

}
/// @nodoc
class __$ReportDataCopyWithImpl<$Res>
    implements _$ReportDataCopyWith<$Res> {
  __$ReportDataCopyWithImpl(this._self, this._then);

  final _ReportData _self;
  final $Res Function(_ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? walletId = freezed,Object? income = null,Object? expense = null,Object? net = null,Object? savingRate = null,Object? comparison = null,Object? incomeByCategory = null,Object? expenseByCategory = null,Object? forecast = null,Object? history = null,Object? topCategoryComparison = freezed,}) {
  return _then(_ReportData(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,savingRate: null == savingRate ? _self.savingRate : savingRate // ignore: cast_nullable_to_non_nullable
as double,comparison: null == comparison ? _self.comparison : comparison // ignore: cast_nullable_to_non_nullable
as ReportComparison,incomeByCategory: null == incomeByCategory ? _self._incomeByCategory : incomeByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryReportItem>,expenseByCategory: null == expenseByCategory ? _self._expenseByCategory : expenseByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryReportItem>,forecast: null == forecast ? _self.forecast : forecast // ignore: cast_nullable_to_non_nullable
as ForecastData,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<MonthlyTrendItem>,topCategoryComparison: freezed == topCategoryComparison ? _self.topCategoryComparison : topCategoryComparison // ignore: cast_nullable_to_non_nullable
as ComparisonMetric?,
  ));
}

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<$Res> get comparison {
  
  return $ReportComparisonCopyWith<$Res>(_self.comparison, (value) {
    return _then(_self.copyWith(comparison: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ForecastDataCopyWith<$Res> get forecast {
  
  return $ForecastDataCopyWith<$Res>(_self.forecast, (value) {
    return _then(_self.copyWith(forecast: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<$Res>? get topCategoryComparison {
    if (_self.topCategoryComparison == null) {
    return null;
  }

  return $ComparisonMetricCopyWith<$Res>(_self.topCategoryComparison!, (value) {
    return _then(_self.copyWith(topCategoryComparison: value));
  });
}
}

// dart format on
