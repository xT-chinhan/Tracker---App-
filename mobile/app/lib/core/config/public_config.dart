import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_config.freezed.dart';
part 'public_config.g.dart';

@freezed
abstract class PublicConfig with _$PublicConfig {
  const factory PublicConfig({
    required String appName,
    String? supportEmail,
    String? hotline,
    String? termsUrl,
    String? privacyUrl,
    required String currency,
    required bool registrationEnabled,
    @Default(PhoneOtpPublicConfig()) PhoneOtpPublicConfig phoneOtp,
    required MaintenanceConfig maintenance,
    required FeatureConfig features,
    required AiPublicConfig ai,
    required BudgetThresholdConfig budget,
    required PasswordConfig password,
    required OtpConfig otp,
    required MobileConfig mobile,
  }) = _PublicConfig;

  factory PublicConfig.fromJson(Map<String, dynamic> json) =>
      _$PublicConfigFromJson(json);
}

/// Số điện thoại (gắn số, quên mật khẩu qua SĐT). Tắt = ẩn dòng Cài đặt › Số điện thoại và cách "Qua số điện thoại".
@freezed
abstract class PhoneOtpPublicConfig with _$PhoneOtpPublicConfig {
  const factory PhoneOtpPublicConfig({
    @Default(false) bool enabled,
    @Default(5) int codeMinutes,
  }) = _PhoneOtpPublicConfig;

  factory PhoneOtpPublicConfig.fromJson(Map<String, dynamic> json) =>
      _$PhoneOtpPublicConfigFromJson(json);
}

@freezed
abstract class MaintenanceConfig with _$MaintenanceConfig {
  const factory MaintenanceConfig({
    required bool enabled,
    String? message,
    DateTime? endsAt,
  }) = _MaintenanceConfig;

  factory MaintenanceConfig.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceConfigFromJson(json);
}

@freezed
abstract class FeatureConfig with _$FeatureConfig {
  const factory FeatureConfig({
    @Default(true) bool savingGoals,
    @Default(true) bool recurring,
    @Default(true) bool transfers,
    @Default(true) bool csvExport,
    @Default(true) bool quickTemplates,
    // Chỉ Android: ghi từ thông báo ngân hàng (admin › Cấu hình › Nghiệp vụ). Thiếu trường = tắt.
    @Default(false) bool bankNotifications,
  }) = _FeatureConfig;

  factory FeatureConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureConfigFromJson(json);
}

@freezed
abstract class AiPublicConfig with _$AiPublicConfig {
  const factory AiPublicConfig({
    required bool enabled,
    required int dailyMessageLimitPerUser,
    required int maxConversationsPerUser,
    @Default(AiOcrPublicConfig()) AiOcrPublicConfig ocr,
  }) = _AiPublicConfig;

  factory AiPublicConfig.fromJson(Map<String, dynamic> json) =>
      _$AiPublicConfigFromJson(json);
}

/// Quét hóa đơn: ẩn lối vào khi tắt; app thu nhỏ ảnh theo [maxSide] trước khi gửi.
@freezed
abstract class AiOcrPublicConfig with _$AiOcrPublicConfig {
  const factory AiOcrPublicConfig({
    @Default(false) bool enabled,
    @Default(20) int dailyLimitPerUser,
    @Default(768) int maxSide,
  }) = _AiOcrPublicConfig;

  factory AiOcrPublicConfig.fromJson(Map<String, dynamic> json) =>
      _$AiOcrPublicConfigFromJson(json);
}

@freezed
abstract class BudgetThresholdConfig with _$BudgetThresholdConfig {
  const factory BudgetThresholdConfig({
    required num warningPercent,
    required num exceededPercent,
  }) = _BudgetThresholdConfig;

  factory BudgetThresholdConfig.fromJson(Map<String, dynamic> json) =>
      _$BudgetThresholdConfigFromJson(json);
}

@freezed
abstract class PasswordConfig with _$PasswordConfig {
  const factory PasswordConfig({required int minLength}) = _PasswordConfig;

  factory PasswordConfig.fromJson(Map<String, dynamic> json) =>
      _$PasswordConfigFromJson(json);
}

@freezed
abstract class OtpConfig with _$OtpConfig {
  const factory OtpConfig({
    required int expiryMinutes,
    required int resendSeconds,
  }) = _OtpConfig;

  factory OtpConfig.fromJson(Map<String, dynamic> json) =>
      _$OtpConfigFromJson(json);
}

@freezed
abstract class MobileConfig with _$MobileConfig {
  const factory MobileConfig({
    required MobilePlatformConfig android,
    required MobilePlatformConfig ios,
    String? releaseNotes,
  }) = _MobileConfig;

  factory MobileConfig.fromJson(Map<String, dynamic> json) =>
      _$MobileConfigFromJson(json);
}

@freezed
abstract class MobilePlatformConfig with _$MobilePlatformConfig {
  const factory MobilePlatformConfig({
    required String latestVersion,
    required String minVersion,
    String? storeUrl,
  }) = _MobilePlatformConfig;

  factory MobilePlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$MobilePlatformConfigFromJson(json);
}
