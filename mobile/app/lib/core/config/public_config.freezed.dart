// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicConfig {

 String get appName; String? get supportEmail; String? get hotline; String? get termsUrl; String? get privacyUrl; String get currency; bool get registrationEnabled; MaintenanceConfig get maintenance; FeatureConfig get features; AiPublicConfig get ai; BudgetThresholdConfig get budget; PasswordConfig get password; OtpConfig get otp; MobileConfig get mobile;
/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicConfigCopyWith<PublicConfig> get copyWith => _$PublicConfigCopyWithImpl<PublicConfig>(this as PublicConfig, _$identity);

  /// Serializes this PublicConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.hotline, hotline) || other.hotline == hotline)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.registrationEnabled, registrationEnabled) || other.registrationEnabled == registrationEnabled)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&(identical(other.features, features) || other.features == features)&&(identical(other.ai, ai) || other.ai == ai)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.password, password) || other.password == password)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.mobile, mobile) || other.mobile == mobile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,supportEmail,hotline,termsUrl,privacyUrl,currency,registrationEnabled,maintenance,features,ai,budget,password,otp,mobile);

@override
String toString() {
  return 'PublicConfig(appName: $appName, supportEmail: $supportEmail, hotline: $hotline, termsUrl: $termsUrl, privacyUrl: $privacyUrl, currency: $currency, registrationEnabled: $registrationEnabled, maintenance: $maintenance, features: $features, ai: $ai, budget: $budget, password: $password, otp: $otp, mobile: $mobile)';
}


}

/// @nodoc
abstract mixin class $PublicConfigCopyWith<$Res>  {
  factory $PublicConfigCopyWith(PublicConfig value, $Res Function(PublicConfig) _then) = _$PublicConfigCopyWithImpl;
@useResult
$Res call({
 String appName, String? supportEmail, String? hotline, String? termsUrl, String? privacyUrl, String currency, bool registrationEnabled, MaintenanceConfig maintenance, FeatureConfig features, AiPublicConfig ai, BudgetThresholdConfig budget, PasswordConfig password, OtpConfig otp, MobileConfig mobile
});


$MaintenanceConfigCopyWith<$Res> get maintenance;$FeatureConfigCopyWith<$Res> get features;$AiPublicConfigCopyWith<$Res> get ai;$BudgetThresholdConfigCopyWith<$Res> get budget;$PasswordConfigCopyWith<$Res> get password;$OtpConfigCopyWith<$Res> get otp;$MobileConfigCopyWith<$Res> get mobile;

}
/// @nodoc
class _$PublicConfigCopyWithImpl<$Res>
    implements $PublicConfigCopyWith<$Res> {
  _$PublicConfigCopyWithImpl(this._self, this._then);

  final PublicConfig _self;
  final $Res Function(PublicConfig) _then;

/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appName = null,Object? supportEmail = freezed,Object? hotline = freezed,Object? termsUrl = freezed,Object? privacyUrl = freezed,Object? currency = null,Object? registrationEnabled = null,Object? maintenance = null,Object? features = null,Object? ai = null,Object? budget = null,Object? password = null,Object? otp = null,Object? mobile = null,}) {
  return _then(_self.copyWith(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,supportEmail: freezed == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String?,hotline: freezed == hotline ? _self.hotline : hotline // ignore: cast_nullable_to_non_nullable
as String?,termsUrl: freezed == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String?,privacyUrl: freezed == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,registrationEnabled: null == registrationEnabled ? _self.registrationEnabled : registrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as MaintenanceConfig,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as FeatureConfig,ai: null == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as AiPublicConfig,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as BudgetThresholdConfig,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as PasswordConfig,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as OtpConfig,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as MobileConfig,
  ));
}
/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaintenanceConfigCopyWith<$Res> get maintenance {
  
  return $MaintenanceConfigCopyWith<$Res>(_self.maintenance, (value) {
    return _then(_self.copyWith(maintenance: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureConfigCopyWith<$Res> get features {
  
  return $FeatureConfigCopyWith<$Res>(_self.features, (value) {
    return _then(_self.copyWith(features: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiPublicConfigCopyWith<$Res> get ai {
  
  return $AiPublicConfigCopyWith<$Res>(_self.ai, (value) {
    return _then(_self.copyWith(ai: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetThresholdConfigCopyWith<$Res> get budget {
  
  return $BudgetThresholdConfigCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PasswordConfigCopyWith<$Res> get password {
  
  return $PasswordConfigCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OtpConfigCopyWith<$Res> get otp {
  
  return $OtpConfigCopyWith<$Res>(_self.otp, (value) {
    return _then(_self.copyWith(otp: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobileConfigCopyWith<$Res> get mobile {
  
  return $MobileConfigCopyWith<$Res>(_self.mobile, (value) {
    return _then(_self.copyWith(mobile: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicConfig].
extension PublicConfigPatterns on PublicConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicConfig value)  $default,){
final _that = this;
switch (_that) {
case _PublicConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PublicConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appName,  String? supportEmail,  String? hotline,  String? termsUrl,  String? privacyUrl,  String currency,  bool registrationEnabled,  MaintenanceConfig maintenance,  FeatureConfig features,  AiPublicConfig ai,  BudgetThresholdConfig budget,  PasswordConfig password,  OtpConfig otp,  MobileConfig mobile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicConfig() when $default != null:
return $default(_that.appName,_that.supportEmail,_that.hotline,_that.termsUrl,_that.privacyUrl,_that.currency,_that.registrationEnabled,_that.maintenance,_that.features,_that.ai,_that.budget,_that.password,_that.otp,_that.mobile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appName,  String? supportEmail,  String? hotline,  String? termsUrl,  String? privacyUrl,  String currency,  bool registrationEnabled,  MaintenanceConfig maintenance,  FeatureConfig features,  AiPublicConfig ai,  BudgetThresholdConfig budget,  PasswordConfig password,  OtpConfig otp,  MobileConfig mobile)  $default,) {final _that = this;
switch (_that) {
case _PublicConfig():
return $default(_that.appName,_that.supportEmail,_that.hotline,_that.termsUrl,_that.privacyUrl,_that.currency,_that.registrationEnabled,_that.maintenance,_that.features,_that.ai,_that.budget,_that.password,_that.otp,_that.mobile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appName,  String? supportEmail,  String? hotline,  String? termsUrl,  String? privacyUrl,  String currency,  bool registrationEnabled,  MaintenanceConfig maintenance,  FeatureConfig features,  AiPublicConfig ai,  BudgetThresholdConfig budget,  PasswordConfig password,  OtpConfig otp,  MobileConfig mobile)?  $default,) {final _that = this;
switch (_that) {
case _PublicConfig() when $default != null:
return $default(_that.appName,_that.supportEmail,_that.hotline,_that.termsUrl,_that.privacyUrl,_that.currency,_that.registrationEnabled,_that.maintenance,_that.features,_that.ai,_that.budget,_that.password,_that.otp,_that.mobile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicConfig implements PublicConfig {
  const _PublicConfig({required this.appName, this.supportEmail, this.hotline, this.termsUrl, this.privacyUrl, required this.currency, required this.registrationEnabled, required this.maintenance, required this.features, required this.ai, required this.budget, required this.password, required this.otp, required this.mobile});
  factory _PublicConfig.fromJson(Map<String, dynamic> json) => _$PublicConfigFromJson(json);

@override final  String appName;
@override final  String? supportEmail;
@override final  String? hotline;
@override final  String? termsUrl;
@override final  String? privacyUrl;
@override final  String currency;
@override final  bool registrationEnabled;
@override final  MaintenanceConfig maintenance;
@override final  FeatureConfig features;
@override final  AiPublicConfig ai;
@override final  BudgetThresholdConfig budget;
@override final  PasswordConfig password;
@override final  OtpConfig otp;
@override final  MobileConfig mobile;

/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicConfigCopyWith<_PublicConfig> get copyWith => __$PublicConfigCopyWithImpl<_PublicConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicConfig&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.hotline, hotline) || other.hotline == hotline)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.registrationEnabled, registrationEnabled) || other.registrationEnabled == registrationEnabled)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&(identical(other.features, features) || other.features == features)&&(identical(other.ai, ai) || other.ai == ai)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.password, password) || other.password == password)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.mobile, mobile) || other.mobile == mobile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,supportEmail,hotline,termsUrl,privacyUrl,currency,registrationEnabled,maintenance,features,ai,budget,password,otp,mobile);

@override
String toString() {
  return 'PublicConfig(appName: $appName, supportEmail: $supportEmail, hotline: $hotline, termsUrl: $termsUrl, privacyUrl: $privacyUrl, currency: $currency, registrationEnabled: $registrationEnabled, maintenance: $maintenance, features: $features, ai: $ai, budget: $budget, password: $password, otp: $otp, mobile: $mobile)';
}


}

/// @nodoc
abstract mixin class _$PublicConfigCopyWith<$Res> implements $PublicConfigCopyWith<$Res> {
  factory _$PublicConfigCopyWith(_PublicConfig value, $Res Function(_PublicConfig) _then) = __$PublicConfigCopyWithImpl;
@override @useResult
$Res call({
 String appName, String? supportEmail, String? hotline, String? termsUrl, String? privacyUrl, String currency, bool registrationEnabled, MaintenanceConfig maintenance, FeatureConfig features, AiPublicConfig ai, BudgetThresholdConfig budget, PasswordConfig password, OtpConfig otp, MobileConfig mobile
});


@override $MaintenanceConfigCopyWith<$Res> get maintenance;@override $FeatureConfigCopyWith<$Res> get features;@override $AiPublicConfigCopyWith<$Res> get ai;@override $BudgetThresholdConfigCopyWith<$Res> get budget;@override $PasswordConfigCopyWith<$Res> get password;@override $OtpConfigCopyWith<$Res> get otp;@override $MobileConfigCopyWith<$Res> get mobile;

}
/// @nodoc
class __$PublicConfigCopyWithImpl<$Res>
    implements _$PublicConfigCopyWith<$Res> {
  __$PublicConfigCopyWithImpl(this._self, this._then);

  final _PublicConfig _self;
  final $Res Function(_PublicConfig) _then;

/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appName = null,Object? supportEmail = freezed,Object? hotline = freezed,Object? termsUrl = freezed,Object? privacyUrl = freezed,Object? currency = null,Object? registrationEnabled = null,Object? maintenance = null,Object? features = null,Object? ai = null,Object? budget = null,Object? password = null,Object? otp = null,Object? mobile = null,}) {
  return _then(_PublicConfig(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,supportEmail: freezed == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String?,hotline: freezed == hotline ? _self.hotline : hotline // ignore: cast_nullable_to_non_nullable
as String?,termsUrl: freezed == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String?,privacyUrl: freezed == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,registrationEnabled: null == registrationEnabled ? _self.registrationEnabled : registrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as MaintenanceConfig,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as FeatureConfig,ai: null == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as AiPublicConfig,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as BudgetThresholdConfig,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as PasswordConfig,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as OtpConfig,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as MobileConfig,
  ));
}

/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaintenanceConfigCopyWith<$Res> get maintenance {
  
  return $MaintenanceConfigCopyWith<$Res>(_self.maintenance, (value) {
    return _then(_self.copyWith(maintenance: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureConfigCopyWith<$Res> get features {
  
  return $FeatureConfigCopyWith<$Res>(_self.features, (value) {
    return _then(_self.copyWith(features: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiPublicConfigCopyWith<$Res> get ai {
  
  return $AiPublicConfigCopyWith<$Res>(_self.ai, (value) {
    return _then(_self.copyWith(ai: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetThresholdConfigCopyWith<$Res> get budget {
  
  return $BudgetThresholdConfigCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PasswordConfigCopyWith<$Res> get password {
  
  return $PasswordConfigCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OtpConfigCopyWith<$Res> get otp {
  
  return $OtpConfigCopyWith<$Res>(_self.otp, (value) {
    return _then(_self.copyWith(otp: value));
  });
}/// Create a copy of PublicConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobileConfigCopyWith<$Res> get mobile {
  
  return $MobileConfigCopyWith<$Res>(_self.mobile, (value) {
    return _then(_self.copyWith(mobile: value));
  });
}
}


/// @nodoc
mixin _$MaintenanceConfig {

 bool get enabled; String? get message; DateTime? get endsAt;
/// Create a copy of MaintenanceConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceConfigCopyWith<MaintenanceConfig> get copyWith => _$MaintenanceConfigCopyWithImpl<MaintenanceConfig>(this as MaintenanceConfig, _$identity);

  /// Serializes this MaintenanceConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.message, message) || other.message == message)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,message,endsAt);

@override
String toString() {
  return 'MaintenanceConfig(enabled: $enabled, message: $message, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $MaintenanceConfigCopyWith<$Res>  {
  factory $MaintenanceConfigCopyWith(MaintenanceConfig value, $Res Function(MaintenanceConfig) _then) = _$MaintenanceConfigCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? message, DateTime? endsAt
});




}
/// @nodoc
class _$MaintenanceConfigCopyWithImpl<$Res>
    implements $MaintenanceConfigCopyWith<$Res> {
  _$MaintenanceConfigCopyWithImpl(this._self, this._then);

  final MaintenanceConfig _self;
  final $Res Function(MaintenanceConfig) _then;

/// Create a copy of MaintenanceConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? message = freezed,Object? endsAt = freezed,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceConfig].
extension MaintenanceConfigPatterns on MaintenanceConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceConfig value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? message,  DateTime? endsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceConfig() when $default != null:
return $default(_that.enabled,_that.message,_that.endsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? message,  DateTime? endsAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceConfig():
return $default(_that.enabled,_that.message,_that.endsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? message,  DateTime? endsAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceConfig() when $default != null:
return $default(_that.enabled,_that.message,_that.endsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceConfig implements MaintenanceConfig {
  const _MaintenanceConfig({required this.enabled, this.message, this.endsAt});
  factory _MaintenanceConfig.fromJson(Map<String, dynamic> json) => _$MaintenanceConfigFromJson(json);

@override final  bool enabled;
@override final  String? message;
@override final  DateTime? endsAt;

/// Create a copy of MaintenanceConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceConfigCopyWith<_MaintenanceConfig> get copyWith => __$MaintenanceConfigCopyWithImpl<_MaintenanceConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.message, message) || other.message == message)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,message,endsAt);

@override
String toString() {
  return 'MaintenanceConfig(enabled: $enabled, message: $message, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceConfigCopyWith<$Res> implements $MaintenanceConfigCopyWith<$Res> {
  factory _$MaintenanceConfigCopyWith(_MaintenanceConfig value, $Res Function(_MaintenanceConfig) _then) = __$MaintenanceConfigCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? message, DateTime? endsAt
});




}
/// @nodoc
class __$MaintenanceConfigCopyWithImpl<$Res>
    implements _$MaintenanceConfigCopyWith<$Res> {
  __$MaintenanceConfigCopyWithImpl(this._self, this._then);

  final _MaintenanceConfig _self;
  final $Res Function(_MaintenanceConfig) _then;

/// Create a copy of MaintenanceConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? message = freezed,Object? endsAt = freezed,}) {
  return _then(_MaintenanceConfig(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FeatureConfig {

 bool get savingGoals; bool get recurring; bool get transfers; bool get csvExport; bool get quickTemplates;
/// Create a copy of FeatureConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureConfigCopyWith<FeatureConfig> get copyWith => _$FeatureConfigCopyWithImpl<FeatureConfig>(this as FeatureConfig, _$identity);

  /// Serializes this FeatureConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureConfig&&(identical(other.savingGoals, savingGoals) || other.savingGoals == savingGoals)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.csvExport, csvExport) || other.csvExport == csvExport)&&(identical(other.quickTemplates, quickTemplates) || other.quickTemplates == quickTemplates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,savingGoals,recurring,transfers,csvExport,quickTemplates);

@override
String toString() {
  return 'FeatureConfig(savingGoals: $savingGoals, recurring: $recurring, transfers: $transfers, csvExport: $csvExport, quickTemplates: $quickTemplates)';
}


}

/// @nodoc
abstract mixin class $FeatureConfigCopyWith<$Res>  {
  factory $FeatureConfigCopyWith(FeatureConfig value, $Res Function(FeatureConfig) _then) = _$FeatureConfigCopyWithImpl;
@useResult
$Res call({
 bool savingGoals, bool recurring, bool transfers, bool csvExport, bool quickTemplates
});




}
/// @nodoc
class _$FeatureConfigCopyWithImpl<$Res>
    implements $FeatureConfigCopyWith<$Res> {
  _$FeatureConfigCopyWithImpl(this._self, this._then);

  final FeatureConfig _self;
  final $Res Function(FeatureConfig) _then;

/// Create a copy of FeatureConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savingGoals = null,Object? recurring = null,Object? transfers = null,Object? csvExport = null,Object? quickTemplates = null,}) {
  return _then(_self.copyWith(
savingGoals: null == savingGoals ? _self.savingGoals : savingGoals // ignore: cast_nullable_to_non_nullable
as bool,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as bool,csvExport: null == csvExport ? _self.csvExport : csvExport // ignore: cast_nullable_to_non_nullable
as bool,quickTemplates: null == quickTemplates ? _self.quickTemplates : quickTemplates // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureConfig].
extension FeatureConfigPatterns on FeatureConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureConfig value)  $default,){
final _that = this;
switch (_that) {
case _FeatureConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureConfig value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool savingGoals,  bool recurring,  bool transfers,  bool csvExport,  bool quickTemplates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureConfig() when $default != null:
return $default(_that.savingGoals,_that.recurring,_that.transfers,_that.csvExport,_that.quickTemplates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool savingGoals,  bool recurring,  bool transfers,  bool csvExport,  bool quickTemplates)  $default,) {final _that = this;
switch (_that) {
case _FeatureConfig():
return $default(_that.savingGoals,_that.recurring,_that.transfers,_that.csvExport,_that.quickTemplates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool savingGoals,  bool recurring,  bool transfers,  bool csvExport,  bool quickTemplates)?  $default,) {final _that = this;
switch (_that) {
case _FeatureConfig() when $default != null:
return $default(_that.savingGoals,_that.recurring,_that.transfers,_that.csvExport,_that.quickTemplates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureConfig implements FeatureConfig {
  const _FeatureConfig({this.savingGoals = true, this.recurring = true, this.transfers = true, this.csvExport = true, this.quickTemplates = true});
  factory _FeatureConfig.fromJson(Map<String, dynamic> json) => _$FeatureConfigFromJson(json);

@override@JsonKey() final  bool savingGoals;
@override@JsonKey() final  bool recurring;
@override@JsonKey() final  bool transfers;
@override@JsonKey() final  bool csvExport;
@override@JsonKey() final  bool quickTemplates;

/// Create a copy of FeatureConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureConfigCopyWith<_FeatureConfig> get copyWith => __$FeatureConfigCopyWithImpl<_FeatureConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureConfig&&(identical(other.savingGoals, savingGoals) || other.savingGoals == savingGoals)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.csvExport, csvExport) || other.csvExport == csvExport)&&(identical(other.quickTemplates, quickTemplates) || other.quickTemplates == quickTemplates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,savingGoals,recurring,transfers,csvExport,quickTemplates);

@override
String toString() {
  return 'FeatureConfig(savingGoals: $savingGoals, recurring: $recurring, transfers: $transfers, csvExport: $csvExport, quickTemplates: $quickTemplates)';
}


}

/// @nodoc
abstract mixin class _$FeatureConfigCopyWith<$Res> implements $FeatureConfigCopyWith<$Res> {
  factory _$FeatureConfigCopyWith(_FeatureConfig value, $Res Function(_FeatureConfig) _then) = __$FeatureConfigCopyWithImpl;
@override @useResult
$Res call({
 bool savingGoals, bool recurring, bool transfers, bool csvExport, bool quickTemplates
});




}
/// @nodoc
class __$FeatureConfigCopyWithImpl<$Res>
    implements _$FeatureConfigCopyWith<$Res> {
  __$FeatureConfigCopyWithImpl(this._self, this._then);

  final _FeatureConfig _self;
  final $Res Function(_FeatureConfig) _then;

/// Create a copy of FeatureConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savingGoals = null,Object? recurring = null,Object? transfers = null,Object? csvExport = null,Object? quickTemplates = null,}) {
  return _then(_FeatureConfig(
savingGoals: null == savingGoals ? _self.savingGoals : savingGoals // ignore: cast_nullable_to_non_nullable
as bool,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as bool,csvExport: null == csvExport ? _self.csvExport : csvExport // ignore: cast_nullable_to_non_nullable
as bool,quickTemplates: null == quickTemplates ? _self.quickTemplates : quickTemplates // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AiPublicConfig {

 bool get enabled; int get dailyMessageLimitPerUser; int get maxConversationsPerUser;
/// Create a copy of AiPublicConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiPublicConfigCopyWith<AiPublicConfig> get copyWith => _$AiPublicConfigCopyWithImpl<AiPublicConfig>(this as AiPublicConfig, _$identity);

  /// Serializes this AiPublicConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiPublicConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.dailyMessageLimitPerUser, dailyMessageLimitPerUser) || other.dailyMessageLimitPerUser == dailyMessageLimitPerUser)&&(identical(other.maxConversationsPerUser, maxConversationsPerUser) || other.maxConversationsPerUser == maxConversationsPerUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,dailyMessageLimitPerUser,maxConversationsPerUser);

@override
String toString() {
  return 'AiPublicConfig(enabled: $enabled, dailyMessageLimitPerUser: $dailyMessageLimitPerUser, maxConversationsPerUser: $maxConversationsPerUser)';
}


}

/// @nodoc
abstract mixin class $AiPublicConfigCopyWith<$Res>  {
  factory $AiPublicConfigCopyWith(AiPublicConfig value, $Res Function(AiPublicConfig) _then) = _$AiPublicConfigCopyWithImpl;
@useResult
$Res call({
 bool enabled, int dailyMessageLimitPerUser, int maxConversationsPerUser
});




}
/// @nodoc
class _$AiPublicConfigCopyWithImpl<$Res>
    implements $AiPublicConfigCopyWith<$Res> {
  _$AiPublicConfigCopyWithImpl(this._self, this._then);

  final AiPublicConfig _self;
  final $Res Function(AiPublicConfig) _then;

/// Create a copy of AiPublicConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? dailyMessageLimitPerUser = null,Object? maxConversationsPerUser = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,dailyMessageLimitPerUser: null == dailyMessageLimitPerUser ? _self.dailyMessageLimitPerUser : dailyMessageLimitPerUser // ignore: cast_nullable_to_non_nullable
as int,maxConversationsPerUser: null == maxConversationsPerUser ? _self.maxConversationsPerUser : maxConversationsPerUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiPublicConfig].
extension AiPublicConfigPatterns on AiPublicConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiPublicConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiPublicConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiPublicConfig value)  $default,){
final _that = this;
switch (_that) {
case _AiPublicConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiPublicConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AiPublicConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int dailyMessageLimitPerUser,  int maxConversationsPerUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiPublicConfig() when $default != null:
return $default(_that.enabled,_that.dailyMessageLimitPerUser,_that.maxConversationsPerUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int dailyMessageLimitPerUser,  int maxConversationsPerUser)  $default,) {final _that = this;
switch (_that) {
case _AiPublicConfig():
return $default(_that.enabled,_that.dailyMessageLimitPerUser,_that.maxConversationsPerUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int dailyMessageLimitPerUser,  int maxConversationsPerUser)?  $default,) {final _that = this;
switch (_that) {
case _AiPublicConfig() when $default != null:
return $default(_that.enabled,_that.dailyMessageLimitPerUser,_that.maxConversationsPerUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiPublicConfig implements AiPublicConfig {
  const _AiPublicConfig({required this.enabled, required this.dailyMessageLimitPerUser, required this.maxConversationsPerUser});
  factory _AiPublicConfig.fromJson(Map<String, dynamic> json) => _$AiPublicConfigFromJson(json);

@override final  bool enabled;
@override final  int dailyMessageLimitPerUser;
@override final  int maxConversationsPerUser;

/// Create a copy of AiPublicConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiPublicConfigCopyWith<_AiPublicConfig> get copyWith => __$AiPublicConfigCopyWithImpl<_AiPublicConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiPublicConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiPublicConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.dailyMessageLimitPerUser, dailyMessageLimitPerUser) || other.dailyMessageLimitPerUser == dailyMessageLimitPerUser)&&(identical(other.maxConversationsPerUser, maxConversationsPerUser) || other.maxConversationsPerUser == maxConversationsPerUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,dailyMessageLimitPerUser,maxConversationsPerUser);

@override
String toString() {
  return 'AiPublicConfig(enabled: $enabled, dailyMessageLimitPerUser: $dailyMessageLimitPerUser, maxConversationsPerUser: $maxConversationsPerUser)';
}


}

/// @nodoc
abstract mixin class _$AiPublicConfigCopyWith<$Res> implements $AiPublicConfigCopyWith<$Res> {
  factory _$AiPublicConfigCopyWith(_AiPublicConfig value, $Res Function(_AiPublicConfig) _then) = __$AiPublicConfigCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int dailyMessageLimitPerUser, int maxConversationsPerUser
});




}
/// @nodoc
class __$AiPublicConfigCopyWithImpl<$Res>
    implements _$AiPublicConfigCopyWith<$Res> {
  __$AiPublicConfigCopyWithImpl(this._self, this._then);

  final _AiPublicConfig _self;
  final $Res Function(_AiPublicConfig) _then;

/// Create a copy of AiPublicConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? dailyMessageLimitPerUser = null,Object? maxConversationsPerUser = null,}) {
  return _then(_AiPublicConfig(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,dailyMessageLimitPerUser: null == dailyMessageLimitPerUser ? _self.dailyMessageLimitPerUser : dailyMessageLimitPerUser // ignore: cast_nullable_to_non_nullable
as int,maxConversationsPerUser: null == maxConversationsPerUser ? _self.maxConversationsPerUser : maxConversationsPerUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BudgetThresholdConfig {

 num get warningPercent; num get exceededPercent;
/// Create a copy of BudgetThresholdConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetThresholdConfigCopyWith<BudgetThresholdConfig> get copyWith => _$BudgetThresholdConfigCopyWithImpl<BudgetThresholdConfig>(this as BudgetThresholdConfig, _$identity);

  /// Serializes this BudgetThresholdConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetThresholdConfig&&(identical(other.warningPercent, warningPercent) || other.warningPercent == warningPercent)&&(identical(other.exceededPercent, exceededPercent) || other.exceededPercent == exceededPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warningPercent,exceededPercent);

@override
String toString() {
  return 'BudgetThresholdConfig(warningPercent: $warningPercent, exceededPercent: $exceededPercent)';
}


}

/// @nodoc
abstract mixin class $BudgetThresholdConfigCopyWith<$Res>  {
  factory $BudgetThresholdConfigCopyWith(BudgetThresholdConfig value, $Res Function(BudgetThresholdConfig) _then) = _$BudgetThresholdConfigCopyWithImpl;
@useResult
$Res call({
 num warningPercent, num exceededPercent
});




}
/// @nodoc
class _$BudgetThresholdConfigCopyWithImpl<$Res>
    implements $BudgetThresholdConfigCopyWith<$Res> {
  _$BudgetThresholdConfigCopyWithImpl(this._self, this._then);

  final BudgetThresholdConfig _self;
  final $Res Function(BudgetThresholdConfig) _then;

/// Create a copy of BudgetThresholdConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warningPercent = null,Object? exceededPercent = null,}) {
  return _then(_self.copyWith(
warningPercent: null == warningPercent ? _self.warningPercent : warningPercent // ignore: cast_nullable_to_non_nullable
as num,exceededPercent: null == exceededPercent ? _self.exceededPercent : exceededPercent // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetThresholdConfig].
extension BudgetThresholdConfigPatterns on BudgetThresholdConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetThresholdConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetThresholdConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetThresholdConfig value)  $default,){
final _that = this;
switch (_that) {
case _BudgetThresholdConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetThresholdConfig value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetThresholdConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num warningPercent,  num exceededPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetThresholdConfig() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num warningPercent,  num exceededPercent)  $default,) {final _that = this;
switch (_that) {
case _BudgetThresholdConfig():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num warningPercent,  num exceededPercent)?  $default,) {final _that = this;
switch (_that) {
case _BudgetThresholdConfig() when $default != null:
return $default(_that.warningPercent,_that.exceededPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetThresholdConfig implements BudgetThresholdConfig {
  const _BudgetThresholdConfig({required this.warningPercent, required this.exceededPercent});
  factory _BudgetThresholdConfig.fromJson(Map<String, dynamic> json) => _$BudgetThresholdConfigFromJson(json);

@override final  num warningPercent;
@override final  num exceededPercent;

/// Create a copy of BudgetThresholdConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetThresholdConfigCopyWith<_BudgetThresholdConfig> get copyWith => __$BudgetThresholdConfigCopyWithImpl<_BudgetThresholdConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetThresholdConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetThresholdConfig&&(identical(other.warningPercent, warningPercent) || other.warningPercent == warningPercent)&&(identical(other.exceededPercent, exceededPercent) || other.exceededPercent == exceededPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,warningPercent,exceededPercent);

@override
String toString() {
  return 'BudgetThresholdConfig(warningPercent: $warningPercent, exceededPercent: $exceededPercent)';
}


}

/// @nodoc
abstract mixin class _$BudgetThresholdConfigCopyWith<$Res> implements $BudgetThresholdConfigCopyWith<$Res> {
  factory _$BudgetThresholdConfigCopyWith(_BudgetThresholdConfig value, $Res Function(_BudgetThresholdConfig) _then) = __$BudgetThresholdConfigCopyWithImpl;
@override @useResult
$Res call({
 num warningPercent, num exceededPercent
});




}
/// @nodoc
class __$BudgetThresholdConfigCopyWithImpl<$Res>
    implements _$BudgetThresholdConfigCopyWith<$Res> {
  __$BudgetThresholdConfigCopyWithImpl(this._self, this._then);

  final _BudgetThresholdConfig _self;
  final $Res Function(_BudgetThresholdConfig) _then;

/// Create a copy of BudgetThresholdConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warningPercent = null,Object? exceededPercent = null,}) {
  return _then(_BudgetThresholdConfig(
warningPercent: null == warningPercent ? _self.warningPercent : warningPercent // ignore: cast_nullable_to_non_nullable
as num,exceededPercent: null == exceededPercent ? _self.exceededPercent : exceededPercent // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$PasswordConfig {

 int get minLength;
/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordConfigCopyWith<PasswordConfig> get copyWith => _$PasswordConfigCopyWithImpl<PasswordConfig>(this as PasswordConfig, _$identity);

  /// Serializes this PasswordConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordConfig&&(identical(other.minLength, minLength) || other.minLength == minLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minLength);

@override
String toString() {
  return 'PasswordConfig(minLength: $minLength)';
}


}

/// @nodoc
abstract mixin class $PasswordConfigCopyWith<$Res>  {
  factory $PasswordConfigCopyWith(PasswordConfig value, $Res Function(PasswordConfig) _then) = _$PasswordConfigCopyWithImpl;
@useResult
$Res call({
 int minLength
});




}
/// @nodoc
class _$PasswordConfigCopyWithImpl<$Res>
    implements $PasswordConfigCopyWith<$Res> {
  _$PasswordConfigCopyWithImpl(this._self, this._then);

  final PasswordConfig _self;
  final $Res Function(PasswordConfig) _then;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minLength = null,}) {
  return _then(_self.copyWith(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordConfig].
extension PasswordConfigPatterns on PasswordConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordConfig value)  $default,){
final _that = this;
switch (_that) {
case _PasswordConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minLength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
return $default(_that.minLength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minLength)  $default,) {final _that = this;
switch (_that) {
case _PasswordConfig():
return $default(_that.minLength);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minLength)?  $default,) {final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
return $default(_that.minLength);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordConfig implements PasswordConfig {
  const _PasswordConfig({required this.minLength});
  factory _PasswordConfig.fromJson(Map<String, dynamic> json) => _$PasswordConfigFromJson(json);

@override final  int minLength;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordConfigCopyWith<_PasswordConfig> get copyWith => __$PasswordConfigCopyWithImpl<_PasswordConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordConfig&&(identical(other.minLength, minLength) || other.minLength == minLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minLength);

@override
String toString() {
  return 'PasswordConfig(minLength: $minLength)';
}


}

/// @nodoc
abstract mixin class _$PasswordConfigCopyWith<$Res> implements $PasswordConfigCopyWith<$Res> {
  factory _$PasswordConfigCopyWith(_PasswordConfig value, $Res Function(_PasswordConfig) _then) = __$PasswordConfigCopyWithImpl;
@override @useResult
$Res call({
 int minLength
});




}
/// @nodoc
class __$PasswordConfigCopyWithImpl<$Res>
    implements _$PasswordConfigCopyWith<$Res> {
  __$PasswordConfigCopyWithImpl(this._self, this._then);

  final _PasswordConfig _self;
  final $Res Function(_PasswordConfig) _then;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minLength = null,}) {
  return _then(_PasswordConfig(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OtpConfig {

 int get expiryMinutes; int get resendSeconds;
/// Create a copy of OtpConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpConfigCopyWith<OtpConfig> get copyWith => _$OtpConfigCopyWithImpl<OtpConfig>(this as OtpConfig, _$identity);

  /// Serializes this OtpConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpConfig&&(identical(other.expiryMinutes, expiryMinutes) || other.expiryMinutes == expiryMinutes)&&(identical(other.resendSeconds, resendSeconds) || other.resendSeconds == resendSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiryMinutes,resendSeconds);

@override
String toString() {
  return 'OtpConfig(expiryMinutes: $expiryMinutes, resendSeconds: $resendSeconds)';
}


}

/// @nodoc
abstract mixin class $OtpConfigCopyWith<$Res>  {
  factory $OtpConfigCopyWith(OtpConfig value, $Res Function(OtpConfig) _then) = _$OtpConfigCopyWithImpl;
@useResult
$Res call({
 int expiryMinutes, int resendSeconds
});




}
/// @nodoc
class _$OtpConfigCopyWithImpl<$Res>
    implements $OtpConfigCopyWith<$Res> {
  _$OtpConfigCopyWithImpl(this._self, this._then);

  final OtpConfig _self;
  final $Res Function(OtpConfig) _then;

/// Create a copy of OtpConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expiryMinutes = null,Object? resendSeconds = null,}) {
  return _then(_self.copyWith(
expiryMinutes: null == expiryMinutes ? _self.expiryMinutes : expiryMinutes // ignore: cast_nullable_to_non_nullable
as int,resendSeconds: null == resendSeconds ? _self.resendSeconds : resendSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpConfig].
extension OtpConfigPatterns on OtpConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpConfig value)  $default,){
final _that = this;
switch (_that) {
case _OtpConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpConfig value)?  $default,){
final _that = this;
switch (_that) {
case _OtpConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int expiryMinutes,  int resendSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpConfig() when $default != null:
return $default(_that.expiryMinutes,_that.resendSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int expiryMinutes,  int resendSeconds)  $default,) {final _that = this;
switch (_that) {
case _OtpConfig():
return $default(_that.expiryMinutes,_that.resendSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int expiryMinutes,  int resendSeconds)?  $default,) {final _that = this;
switch (_that) {
case _OtpConfig() when $default != null:
return $default(_that.expiryMinutes,_that.resendSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpConfig implements OtpConfig {
  const _OtpConfig({required this.expiryMinutes, required this.resendSeconds});
  factory _OtpConfig.fromJson(Map<String, dynamic> json) => _$OtpConfigFromJson(json);

@override final  int expiryMinutes;
@override final  int resendSeconds;

/// Create a copy of OtpConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpConfigCopyWith<_OtpConfig> get copyWith => __$OtpConfigCopyWithImpl<_OtpConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpConfig&&(identical(other.expiryMinutes, expiryMinutes) || other.expiryMinutes == expiryMinutes)&&(identical(other.resendSeconds, resendSeconds) || other.resendSeconds == resendSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiryMinutes,resendSeconds);

@override
String toString() {
  return 'OtpConfig(expiryMinutes: $expiryMinutes, resendSeconds: $resendSeconds)';
}


}

/// @nodoc
abstract mixin class _$OtpConfigCopyWith<$Res> implements $OtpConfigCopyWith<$Res> {
  factory _$OtpConfigCopyWith(_OtpConfig value, $Res Function(_OtpConfig) _then) = __$OtpConfigCopyWithImpl;
@override @useResult
$Res call({
 int expiryMinutes, int resendSeconds
});




}
/// @nodoc
class __$OtpConfigCopyWithImpl<$Res>
    implements _$OtpConfigCopyWith<$Res> {
  __$OtpConfigCopyWithImpl(this._self, this._then);

  final _OtpConfig _self;
  final $Res Function(_OtpConfig) _then;

/// Create a copy of OtpConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expiryMinutes = null,Object? resendSeconds = null,}) {
  return _then(_OtpConfig(
expiryMinutes: null == expiryMinutes ? _self.expiryMinutes : expiryMinutes // ignore: cast_nullable_to_non_nullable
as int,resendSeconds: null == resendSeconds ? _self.resendSeconds : resendSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MobileConfig {

 MobilePlatformConfig get android; MobilePlatformConfig get ios; String? get releaseNotes;
/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MobileConfigCopyWith<MobileConfig> get copyWith => _$MobileConfigCopyWithImpl<MobileConfig>(this as MobileConfig, _$identity);

  /// Serializes this MobileConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MobileConfig&&(identical(other.android, android) || other.android == android)&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,android,ios,releaseNotes);

@override
String toString() {
  return 'MobileConfig(android: $android, ios: $ios, releaseNotes: $releaseNotes)';
}


}

/// @nodoc
abstract mixin class $MobileConfigCopyWith<$Res>  {
  factory $MobileConfigCopyWith(MobileConfig value, $Res Function(MobileConfig) _then) = _$MobileConfigCopyWithImpl;
@useResult
$Res call({
 MobilePlatformConfig android, MobilePlatformConfig ios, String? releaseNotes
});


$MobilePlatformConfigCopyWith<$Res> get android;$MobilePlatformConfigCopyWith<$Res> get ios;

}
/// @nodoc
class _$MobileConfigCopyWithImpl<$Res>
    implements $MobileConfigCopyWith<$Res> {
  _$MobileConfigCopyWithImpl(this._self, this._then);

  final MobileConfig _self;
  final $Res Function(MobileConfig) _then;

/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? android = null,Object? ios = null,Object? releaseNotes = freezed,}) {
  return _then(_self.copyWith(
android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as MobilePlatformConfig,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as MobilePlatformConfig,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobilePlatformConfigCopyWith<$Res> get android {
  
  return $MobilePlatformConfigCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobilePlatformConfigCopyWith<$Res> get ios {
  
  return $MobilePlatformConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}


/// Adds pattern-matching-related methods to [MobileConfig].
extension MobileConfigPatterns on MobileConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MobileConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MobileConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MobileConfig value)  $default,){
final _that = this;
switch (_that) {
case _MobileConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MobileConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MobileConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MobilePlatformConfig android,  MobilePlatformConfig ios,  String? releaseNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MobileConfig() when $default != null:
return $default(_that.android,_that.ios,_that.releaseNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MobilePlatformConfig android,  MobilePlatformConfig ios,  String? releaseNotes)  $default,) {final _that = this;
switch (_that) {
case _MobileConfig():
return $default(_that.android,_that.ios,_that.releaseNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MobilePlatformConfig android,  MobilePlatformConfig ios,  String? releaseNotes)?  $default,) {final _that = this;
switch (_that) {
case _MobileConfig() when $default != null:
return $default(_that.android,_that.ios,_that.releaseNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MobileConfig implements MobileConfig {
  const _MobileConfig({required this.android, required this.ios, this.releaseNotes});
  factory _MobileConfig.fromJson(Map<String, dynamic> json) => _$MobileConfigFromJson(json);

@override final  MobilePlatformConfig android;
@override final  MobilePlatformConfig ios;
@override final  String? releaseNotes;

/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MobileConfigCopyWith<_MobileConfig> get copyWith => __$MobileConfigCopyWithImpl<_MobileConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MobileConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MobileConfig&&(identical(other.android, android) || other.android == android)&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,android,ios,releaseNotes);

@override
String toString() {
  return 'MobileConfig(android: $android, ios: $ios, releaseNotes: $releaseNotes)';
}


}

/// @nodoc
abstract mixin class _$MobileConfigCopyWith<$Res> implements $MobileConfigCopyWith<$Res> {
  factory _$MobileConfigCopyWith(_MobileConfig value, $Res Function(_MobileConfig) _then) = __$MobileConfigCopyWithImpl;
@override @useResult
$Res call({
 MobilePlatformConfig android, MobilePlatformConfig ios, String? releaseNotes
});


@override $MobilePlatformConfigCopyWith<$Res> get android;@override $MobilePlatformConfigCopyWith<$Res> get ios;

}
/// @nodoc
class __$MobileConfigCopyWithImpl<$Res>
    implements _$MobileConfigCopyWith<$Res> {
  __$MobileConfigCopyWithImpl(this._self, this._then);

  final _MobileConfig _self;
  final $Res Function(_MobileConfig) _then;

/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? android = null,Object? ios = null,Object? releaseNotes = freezed,}) {
  return _then(_MobileConfig(
android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as MobilePlatformConfig,ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as MobilePlatformConfig,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobilePlatformConfigCopyWith<$Res> get android {
  
  return $MobilePlatformConfigCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}/// Create a copy of MobileConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MobilePlatformConfigCopyWith<$Res> get ios {
  
  return $MobilePlatformConfigCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}
}


/// @nodoc
mixin _$MobilePlatformConfig {

 String get latestVersion; String get minVersion; String? get storeUrl;
/// Create a copy of MobilePlatformConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MobilePlatformConfigCopyWith<MobilePlatformConfig> get copyWith => _$MobilePlatformConfigCopyWithImpl<MobilePlatformConfig>(this as MobilePlatformConfig, _$identity);

  /// Serializes this MobilePlatformConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MobilePlatformConfig&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestVersion,minVersion,storeUrl);

@override
String toString() {
  return 'MobilePlatformConfig(latestVersion: $latestVersion, minVersion: $minVersion, storeUrl: $storeUrl)';
}


}

/// @nodoc
abstract mixin class $MobilePlatformConfigCopyWith<$Res>  {
  factory $MobilePlatformConfigCopyWith(MobilePlatformConfig value, $Res Function(MobilePlatformConfig) _then) = _$MobilePlatformConfigCopyWithImpl;
@useResult
$Res call({
 String latestVersion, String minVersion, String? storeUrl
});




}
/// @nodoc
class _$MobilePlatformConfigCopyWithImpl<$Res>
    implements $MobilePlatformConfigCopyWith<$Res> {
  _$MobilePlatformConfigCopyWithImpl(this._self, this._then);

  final MobilePlatformConfig _self;
  final $Res Function(MobilePlatformConfig) _then;

/// Create a copy of MobilePlatformConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latestVersion = null,Object? minVersion = null,Object? storeUrl = freezed,}) {
  return _then(_self.copyWith(
latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MobilePlatformConfig].
extension MobilePlatformConfigPatterns on MobilePlatformConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MobilePlatformConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MobilePlatformConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MobilePlatformConfig value)  $default,){
final _that = this;
switch (_that) {
case _MobilePlatformConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MobilePlatformConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MobilePlatformConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String latestVersion,  String minVersion,  String? storeUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MobilePlatformConfig() when $default != null:
return $default(_that.latestVersion,_that.minVersion,_that.storeUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String latestVersion,  String minVersion,  String? storeUrl)  $default,) {final _that = this;
switch (_that) {
case _MobilePlatformConfig():
return $default(_that.latestVersion,_that.minVersion,_that.storeUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String latestVersion,  String minVersion,  String? storeUrl)?  $default,) {final _that = this;
switch (_that) {
case _MobilePlatformConfig() when $default != null:
return $default(_that.latestVersion,_that.minVersion,_that.storeUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MobilePlatformConfig implements MobilePlatformConfig {
  const _MobilePlatformConfig({required this.latestVersion, required this.minVersion, this.storeUrl});
  factory _MobilePlatformConfig.fromJson(Map<String, dynamic> json) => _$MobilePlatformConfigFromJson(json);

@override final  String latestVersion;
@override final  String minVersion;
@override final  String? storeUrl;

/// Create a copy of MobilePlatformConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MobilePlatformConfigCopyWith<_MobilePlatformConfig> get copyWith => __$MobilePlatformConfigCopyWithImpl<_MobilePlatformConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MobilePlatformConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MobilePlatformConfig&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestVersion,minVersion,storeUrl);

@override
String toString() {
  return 'MobilePlatformConfig(latestVersion: $latestVersion, minVersion: $minVersion, storeUrl: $storeUrl)';
}


}

/// @nodoc
abstract mixin class _$MobilePlatformConfigCopyWith<$Res> implements $MobilePlatformConfigCopyWith<$Res> {
  factory _$MobilePlatformConfigCopyWith(_MobilePlatformConfig value, $Res Function(_MobilePlatformConfig) _then) = __$MobilePlatformConfigCopyWithImpl;
@override @useResult
$Res call({
 String latestVersion, String minVersion, String? storeUrl
});




}
/// @nodoc
class __$MobilePlatformConfigCopyWithImpl<$Res>
    implements _$MobilePlatformConfigCopyWith<$Res> {
  __$MobilePlatformConfigCopyWithImpl(this._self, this._then);

  final _MobilePlatformConfig _self;
  final $Res Function(_MobilePlatformConfig) _then;

/// Create a copy of MobilePlatformConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latestVersion = null,Object? minVersion = null,Object? storeUrl = freezed,}) {
  return _then(_MobilePlatformConfig(
latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
