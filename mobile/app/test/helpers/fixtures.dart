import 'package:app/core/config/public_config.dart';
import 'package:app/features/auth/data/auth_models.dart';
import 'package:app/features/categories/data/category_models.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/notifications/data/notification_models.dart';
import 'package:app/features/wallets/data/wallet_models.dart';

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

StatsBalance statsBalanceFixture({int balance = 26022000}) => StatsBalance(
  balance: balance,
  totalIncome: 22000000,
  totalExpense: 8680000,
  savings: 5000000,
  wallets: [
    WalletItemSummary(
      id: 'w-1',
      name: 'Tiền mặt',
      type: 'CASH',
      balance: 1022000,
    ),
    WalletItemSummary(
      id: 'w-2',
      name: 'MB Bank',
      type: 'BANK',
      balance: 25000000,
    ),
  ],
);

StatsSummary statsSummaryFixture({int expense = 120000}) => StatsSummary(
  income: 0,
  expense: expense,
  net: -expense,
  incomeCount: 0,
  expenseCount: 2,
  balance: 26022000,
);

BudgetSummary budgetSummaryFixture({
  int limit = 14000000,
  int spent = 8680000,
}) => BudgetSummary(
  month: '2026-09',
  thresholds: BudgetThresholds(warningPercent: 80, exceededPercent: 100),
  overall: BudgetOverall(
    id: 'b-overall',
    month: '2026-09',
    limitAmount: limit,
    spent: spent,
    remaining: limit - spent,
    percentage: (spent / limit) * 100,
    status: spent >= limit ? 'exceeded' : 'ok',
  ),
  totalLimit: limit,
  totalSpent: spent,
  totalRemaining: limit - spent,
);

TransactionItem transactionItemFixture({
  String id = 'tx-1',
  String title = 'Cơm trưa văn phòng',
  int amount = 55000,
  String type = 'EXPENSE',
}) => TransactionItem(
  id: id,
  type: type,
  amount: amount,
  title: title,
  occurredAt: DateTime.utc(2026, 9, 22, 12, 10),
  category: CategoryMeta(
    id: 'cat-1',
    name: 'Ăn uống',
    icon: 'utensils',
    color: '#EB6834',
  ),
  wallet: WalletMeta(id: 'w-1', name: 'Tiền mặt', type: 'CASH'),
);

QuickTemplateItem quickTemplateItemFixture({
  String id = 'qt-1',
  String label = 'Cà phê',
  int amount = 45000,
}) => QuickTemplateItem(
  id: id,
  label: label,
  title: 'Cà phê sáng',
  amount: amount,
  categoryId: 'cat-1',
  walletId: 'w-1',
  category: CategoryMeta(id: 'cat-1', name: 'Ăn uống', icon: 'coffee'),
);

NotificationItem notificationItemFixture({
  String id = 'notif-1',
  String title = 'Ăn uống đã dùng 89% ngân sách',
  String body = 'Đã chi 3.120.000đ / 3.500.000đ',
  String type = 'BUDGET_WARNING',
  DateTime? readAt,
}) => NotificationItem(
  id: id,
  type: type,
  title: title,
  body: body,
  readAt: readAt,
  createdAt: DateTime.now(),
);

CategoryItem categoryItemFixture({
  String id = 'cat-1',
  String name = 'Ăn uống',
  String type = 'EXPENSE',
  String icon = 'utensils',
  String color = '#EB6834',
}) => CategoryItem(id: id, name: name, type: type, icon: icon, color: color);

WalletItem walletItemFixture({
  String id = 'w-1',
  String name = 'Tiền mặt',
  String type = 'CASH',
  int balance = 1000000,
  int initialBalance = 1000000,
  String icon = 'wallet',
  String color = '#10B981',
}) => WalletItem(
  id: id,
  name: name,
  type: type,
  balance: balance,
  initialBalance: initialBalance,
  icon: icon,
  color: color,
);

TransactionPage transactionPageFixture({
  List<TransactionItem> items = const [],
  int total = 0,
  int page = 1,
  int limit = 20,
  int totalPages = 1,
}) => TransactionPage(
  items: items,
  total: total,
  page: page,
  limit: limit,
  totalPages: totalPages,
);
