// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicConfig _$PublicConfigFromJson(
  Map<String, dynamic> json,
) => _PublicConfig(
  appName: json['appName'] as String,
  supportEmail: json['supportEmail'] as String?,
  hotline: json['hotline'] as String?,
  termsUrl: json['termsUrl'] as String?,
  privacyUrl: json['privacyUrl'] as String?,
  currency: json['currency'] as String,
  registrationEnabled: json['registrationEnabled'] as bool,
  maintenance: MaintenanceConfig.fromJson(
    json['maintenance'] as Map<String, dynamic>,
  ),
  features: FeatureConfig.fromJson(json['features'] as Map<String, dynamic>),
  ai: AiPublicConfig.fromJson(json['ai'] as Map<String, dynamic>),
  budget: BudgetThresholdConfig.fromJson(
    json['budget'] as Map<String, dynamic>,
  ),
  password: PasswordConfig.fromJson(json['password'] as Map<String, dynamic>),
  otp: OtpConfig.fromJson(json['otp'] as Map<String, dynamic>),
  mobile: MobileConfig.fromJson(json['mobile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublicConfigToJson(_PublicConfig instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'supportEmail': instance.supportEmail,
      'hotline': instance.hotline,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
      'currency': instance.currency,
      'registrationEnabled': instance.registrationEnabled,
      'maintenance': instance.maintenance,
      'features': instance.features,
      'ai': instance.ai,
      'budget': instance.budget,
      'password': instance.password,
      'otp': instance.otp,
      'mobile': instance.mobile,
    };

_MaintenanceConfig _$MaintenanceConfigFromJson(Map<String, dynamic> json) =>
    _MaintenanceConfig(
      enabled: json['enabled'] as bool,
      message: json['message'] as String?,
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
    );

Map<String, dynamic> _$MaintenanceConfigToJson(_MaintenanceConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'message': instance.message,
      'endsAt': instance.endsAt?.toIso8601String(),
    };

_FeatureConfig _$FeatureConfigFromJson(Map<String, dynamic> json) =>
    _FeatureConfig(
      savingGoals: json['savingGoals'] as bool? ?? true,
      recurring: json['recurring'] as bool? ?? true,
      transfers: json['transfers'] as bool? ?? true,
      csvExport: json['csvExport'] as bool? ?? true,
      quickTemplates: json['quickTemplates'] as bool? ?? true,
    );

Map<String, dynamic> _$FeatureConfigToJson(_FeatureConfig instance) =>
    <String, dynamic>{
      'savingGoals': instance.savingGoals,
      'recurring': instance.recurring,
      'transfers': instance.transfers,
      'csvExport': instance.csvExport,
      'quickTemplates': instance.quickTemplates,
    };

_AiPublicConfig _$AiPublicConfigFromJson(Map<String, dynamic> json) =>
    _AiPublicConfig(
      enabled: json['enabled'] as bool,
      dailyMessageLimitPerUser: (json['dailyMessageLimitPerUser'] as num)
          .toInt(),
      maxConversationsPerUser: (json['maxConversationsPerUser'] as num).toInt(),
    );

Map<String, dynamic> _$AiPublicConfigToJson(_AiPublicConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'dailyMessageLimitPerUser': instance.dailyMessageLimitPerUser,
      'maxConversationsPerUser': instance.maxConversationsPerUser,
    };

_BudgetThresholdConfig _$BudgetThresholdConfigFromJson(
  Map<String, dynamic> json,
) => _BudgetThresholdConfig(
  warningPercent: json['warningPercent'] as num,
  exceededPercent: json['exceededPercent'] as num,
);

Map<String, dynamic> _$BudgetThresholdConfigToJson(
  _BudgetThresholdConfig instance,
) => <String, dynamic>{
  'warningPercent': instance.warningPercent,
  'exceededPercent': instance.exceededPercent,
};

_PasswordConfig _$PasswordConfigFromJson(Map<String, dynamic> json) =>
    _PasswordConfig(minLength: (json['minLength'] as num).toInt());

Map<String, dynamic> _$PasswordConfigToJson(_PasswordConfig instance) =>
    <String, dynamic>{'minLength': instance.minLength};

_OtpConfig _$OtpConfigFromJson(Map<String, dynamic> json) => _OtpConfig(
  expiryMinutes: (json['expiryMinutes'] as num).toInt(),
  resendSeconds: (json['resendSeconds'] as num).toInt(),
);

Map<String, dynamic> _$OtpConfigToJson(_OtpConfig instance) =>
    <String, dynamic>{
      'expiryMinutes': instance.expiryMinutes,
      'resendSeconds': instance.resendSeconds,
    };

_MobileConfig _$MobileConfigFromJson(Map<String, dynamic> json) =>
    _MobileConfig(
      android: MobilePlatformConfig.fromJson(
        json['android'] as Map<String, dynamic>,
      ),
      ios: MobilePlatformConfig.fromJson(json['ios'] as Map<String, dynamic>),
      releaseNotes: json['releaseNotes'] as String?,
    );

Map<String, dynamic> _$MobileConfigToJson(_MobileConfig instance) =>
    <String, dynamic>{
      'android': instance.android,
      'ios': instance.ios,
      'releaseNotes': instance.releaseNotes,
    };

_MobilePlatformConfig _$MobilePlatformConfigFromJson(
  Map<String, dynamic> json,
) => _MobilePlatformConfig(
  latestVersion: json['latestVersion'] as String,
  minVersion: json['minVersion'] as String,
  storeUrl: json['storeUrl'] as String?,
);

Map<String, dynamic> _$MobilePlatformConfigToJson(
  _MobilePlatformConfig instance,
) => <String, dynamic>{
  'latestVersion': instance.latestVersion,
  'minVersion': instance.minVersion,
  'storeUrl': instance.storeUrl,
};
