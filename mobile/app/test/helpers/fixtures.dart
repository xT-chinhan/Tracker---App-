import 'package:app/core/config/public_config.dart';
import 'package:app/features/auth/data/auth_models.dart';

PublicConfig publicConfigFixture({
  bool maintenance = false,
  bool registrationEnabled = true,
  String latestVersion = '1.0.0',
  String minVersion = '1.0.0',
}) => PublicConfig(
  appName: 'Thu Chi',
  currency: 'VND',
  registrationEnabled: registrationEnabled,
  maintenance: MaintenanceConfig(
    enabled: maintenance,
    message: maintenance ? 'Đang bảo trì' : null,
  ),
  features: const FeatureConfig(),
  ai: const AiPublicConfig(
    enabled: true,
    dailyMessageLimitPerUser: 30,
    maxConversationsPerUser: 50,
  ),
  budget: const BudgetThresholdConfig(warningPercent: 80, exceededPercent: 100),
  password: const PasswordConfig(minLength: 6),
  otp: const OtpConfig(expiryMinutes: 10, resendSeconds: 60),
  mobile: MobileConfig(
    android: MobilePlatformConfig(
      latestVersion: latestVersion,
      minVersion: minVersion,
      storeUrl: 'https://example.com/android',
    ),
    ios: MobilePlatformConfig(
      latestVersion: latestVersion,
      minVersion: minVersion,
      storeUrl: 'https://example.com/ios',
    ),
  ),
);

AppUser userFixture() {
  final now = DateTime.utc(2026, 1, 1);
  return AppUser(
    id: 'user-1',
    email: 'tester@example.com',
    name: 'Tester',
    role: UserRole.user,
    status: UserStatus.active,
    createdAt: now,
    updatedAt: now,
  );
}
