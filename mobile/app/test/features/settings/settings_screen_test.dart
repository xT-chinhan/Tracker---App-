import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/network/network_providers.dart';
import 'package:app/core/storage/token_store.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/auth/data/auth_models.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/categories/data/category_models.dart';
import 'package:app/features/categories/data/category_repository.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/notifications/data/notification_models.dart';
import 'package:app/features/notifications/data/notification_repository.dart';
import 'package:app/features/quick_templates/data/quick_template_models.dart';
import 'package:app/features/quick_templates/data/quick_template_repository.dart';
import 'package:app/features/recurring/data/recurring_models.dart';
import 'package:app/features/recurring/data/recurring_repository.dart';
import 'package:app/features/reports/data/report_repository.dart';
import 'package:app/features/savings/data/saving_models.dart';
import 'package:app/features/savings/data/saving_repository.dart';
import 'package:app/features/settings/presentation/change_password_sheet.dart';
import 'package:app/features/settings/presentation/delete_account_sheet.dart';
import 'package:app/features/settings/presentation/edit_profile_sheet.dart';
import 'package:app/features/settings/presentation/logout_dialog.dart';
import 'package:app/features/settings/presentation/settings_screen.dart';
import 'package:app/features/wallets/data/wallet_models.dart';
import 'package:app/features/wallets/data/wallet_repository.dart';
import '../../helpers/fixtures.dart';

class FakeAuthRepository implements AuthRepository {
  String? updatedName;
  String? changedCurrentPassword;
  String? changedNewPassword;
  String? deletedPassword;
  int logoutAllCalls = 0;

  @override
  Future<AppUser> me() async => userFixture();

  @override
  Future<AppUser> updateProfile({required String name}) async {
    updatedName = name;
    return userFixture().copyWith(name: name);
  }

  @override
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changedCurrentPassword = currentPassword;
    changedNewPassword = newPassword;
    return AuthResult(accessToken: 'new-token-123', user: userFixture());
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    deletedPassword = password;
  }

  @override
  Future<void> logoutAll() async {
    logoutAllCalls++;
  }

  @override
  Future<AuthResult> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) => throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => throw UnimplementedError();
}

class FakeWalletRepository implements WalletRepository {
  @override
  Future<WalletListResponse> getWallets() async => const WalletListResponse(
    totalBalance: 26022000,
    items: [
      WalletItem(id: 'w-1', name: 'MB Bank', type: 'BANK', balance: 18672000),
      WalletItem(
        id: 'w-2',
        name: 'Techcombank',
        type: 'BANK',
        balance: 4000000,
      ),
      WalletItem(id: 'w-3', name: 'Tiền mặt', type: 'CASH', balance: 1850000),
      WalletItem(id: 'w-4', name: 'MoMo', type: 'EWALLET', balance: 1500000),
    ],
  );

  @override
  Future<WalletItem> getWallet(String id) async => throw UnimplementedError();
  @override
  Future<WalletItem> createWallet(CreateWalletDto dto) async =>
      throw UnimplementedError();
  @override
  Future<WalletItem> updateWallet(String id, UpdateWalletDto dto) async =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> deleteWallet(String id) async =>
      throw UnimplementedError();
  @override
  Future<WalletItem> restoreWallet(String id) async =>
      throw UnimplementedError();
}

class FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryItem>> getCategories({String? type}) async =>
      List.generate(
        16,
        (i) => CategoryItem(
          id: 'cat-$i',
          name: 'Danh mục $i',
          type: 'EXPENSE',
          icon: 'utensils',
          color: '#2a78d6',
        ),
      );

  @override
  Future<CategoryItem> createCategory(CreateCategoryDto dto) async =>
      throw UnimplementedError();
  @override
  Future<CategoryItem> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? color,
  }) async => throw UnimplementedError();
  @override
  Future<void> deleteCategory(String id) async => throw UnimplementedError();
}

class FakeRecurringRepository implements RecurringRepository {
  @override
  Future<List<RecurringRuleItem>> getRules({String? status}) async =>
      List.generate(
        5,
        (i) => RecurringRuleItem(
          id: 'rule-$i',
          userId: 'u-1',
          walletId: 'w-1',
          categoryId: 'c-1',
          title: 'Quy tắc $i',
          amount: 500000,
          frequency: 'MONTHLY',
          startDate: DateTime(2026, 1, 1),
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          wallet: const RecurringWalletMeta(
            id: 'w-1',
            name: 'MB Bank',
            type: 'BANK',
          ),
          category: const RecurringCategoryMeta(
            id: 'c-1',
            name: 'Ăn uống',
            type: 'EXPENSE',
            icon: 'utensils',
            color: '#2a78d6',
          ),
          nextRunAt: DateTime(2026, 10, 1),
        ),
      );

  @override
  Future<RecurringRuleItem> getRule(String id) async =>
      throw UnimplementedError();
  @override
  Future<RecurringRuleItem> createRule(CreateRecurringDto dto) async =>
      throw UnimplementedError();
  @override
  Future<RecurringRuleItem> updateRule(
    String id,
    UpdateRecurringDto dto,
  ) async => throw UnimplementedError();
  @override
  Future<void> deleteRule(String id) async => throw UnimplementedError();
  @override
  Future<RecurringRuleItem> pauseRule(String id) async =>
      throw UnimplementedError();
  @override
  Future<RecurringRuleItem> resumeRule(String id) async =>
      throw UnimplementedError();
  @override
  Future<RecurringPreviewResponse> preview(String id, {int count = 5}) async =>
      throw UnimplementedError();
}

class FakeSavingRepository implements SavingRepository {
  @override
  Future<List<SavingGoalItem>> getGoals({String? status}) async =>
      List.generate(
        3,
        (i) => SavingGoalItem(
          id: 'goal-$i',
          name: 'Mục tiêu $i',
          targetAmount: 10000000,
          savedAmount: 3000000,
          startDate: DateTime(2026, 1, 1),
          targetDate: DateTime(2026, 12, 31),
          icon: 'car',
          color: '#eb6834',
        ),
      );

  @override
  Future<SavingGoalDetail> getGoal(String id) async =>
      throw UnimplementedError();
  @override
  Future<SavingGoalItem> createGoal(CreateGoalDto dto) async =>
      throw UnimplementedError();
  @override
  Future<SavingGoalItem> updateGoal(String id, UpdateGoalDto dto) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteGoal(String id) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> deposit(String id, DepositDto dto) async =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> withdraw(String id, WithdrawDto dto) async =>
      throw UnimplementedError();
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<NotificationPage> list({
    int page = 1,
    int limit = 20,
    bool? unread,
    String? category,
  }) async => NotificationPage(
    total: 2,
    page: 1,
    limit: 20,
    totalPages: 1,
    items: [
      NotificationItem(
        id: 'n-1',
        title: 'Thông báo 1',
        body: 'Nội dung 1',
        type: 'SYSTEM',
        createdAt: DateTime(2026, 9, 18, 10),
      ),
      NotificationItem(
        id: 'n-2',
        title: 'Thông báo 2',
        body: 'Nội dung 2',
        type: 'BUDGET_WARNING',
        createdAt: DateTime(2026, 9, 18, 10),
      ),
    ],
  );

  @override
  Future<int> getUnreadCount() async => 2;
  @override
  Future<NotificationItem> markRead(String id) async =>
      throw UnimplementedError();
  @override
  Future<UnreadSummary> getUnreadSummary() async =>
      const UnreadSummary(count: 2, byCategory: {'system': 1, 'budget': 1});
  @override
  Future<int> markReadAll({String? category}) async => 2;
}

class FakeQuickTemplateRepository implements QuickTemplateRepository {
  @override
  Future<List<QuickTemplateItem>> getQuickTemplates() async => List.generate(
    4,
    (i) => QuickTemplateItem(
      id: 'qt-$i',
      label: 'Mẫu $i',
      title: 'Chi $i',
      amount: 50000,
      categoryId: 'cat-1',
      walletId: 'w-1',
    ),
  );

  @override
  Future<QuickTemplateItem> createQuickTemplate(
    CreateQuickTemplateDto dto,
  ) async => throw UnimplementedError();
  @override
  Future<TransactionItem> useQuickTemplate(
    String id, {
    UseQuickTemplateDto? dto,
  }) async => throw UnimplementedError();
  @override
  Future<void> deleteQuickTemplate(String id) async =>
      throw UnimplementedError();
}

class FakeReportRepository extends ReportRepository {
  FakeReportRepository() : super(Dio());
  int exportCsvCalls = 0;

  @override
  Future<String> exportCsv({String? month, String? walletId}) async {
    exportCsvCalls++;
    return 'Ngày,Loại,Danh mục,Số tiền,Ví,Ghi chú\n2026-09-18,Chi,Ăn uống,50000,MB Bank,Cơm trưa';
  }
}

class FakeHomeRepository implements HomeRepository {
  @override
  Future<StatsBalance> getBalance() async => statsBalanceFixture();

  @override
  Future<StatsSummary> getSummary({
    String? month,
    String? from,
    String? to,
    String? walletId,
  }) async => const StatsSummary(
    income: 23500000,
    expense: 8680000,
    net: 14820000,
    balance: 26022000,
  );

  @override
  Future<BudgetSummary> getBudgets(String month) async =>
      budgetSummaryFixture(limit: 14000000, spent: 8680000);

  @override
  Future<TransactionPage> getRecentTransactions({int limit = 5}) async =>
      transactionPageFixture();

  @override
  Future<List<QuickTemplateItem>> getQuickTemplates() async => [];

  @override
  Future<TransactionItem> useQuickTemplate(String id) async =>
      transactionItemFixture();
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore([this.token]);
  String? token;
  bool cleared = false;

  @override
  Future<void> clear() async {
    token = null;
    cleared = true;
  }

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;
}

void main() {
  Widget buildSettingsScreen({
    required FakeAuthRepository authRepo,
    required _MemoryTokenStore tokenStore,
    required AppSessionController session,
    FakeReportRepository? reportRepo,
  }) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        tokenStoreProvider.overrideWithValue(tokenStore),
        appSessionProvider.overrideWith((ref) => session),
        walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
        recurringRepositoryProvider.overrideWithValue(
          FakeRecurringRepository(),
        ),
        savingRepositoryProvider.overrideWithValue(FakeSavingRepository()),
        notificationRepositoryProvider.overrideWithValue(
          FakeNotificationRepository(),
        ),
        quickTemplateRepositoryProvider.overrideWithValue(
          FakeQuickTemplateRepository(),
        ),
        reportRepositoryProvider.overrideWithValue(
          reportRepo ?? FakeReportRepository(),
        ),
        appVersionProvider.overrideWith((ref) => Future.value('1.0.0 (42)')),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SettingsScreen()),
    );
  }

  testWidgets(
    'SettingsScreen hiển thị thông tin người dùng, các nhóm quản lý tiền, nhập liệu, ứng dụng khớp mockup 20 & 20b',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authRepo = FakeAuthRepository();
      final tokenStore = _MemoryTokenStore('test-token');
      final session = AppSessionController();
      session.authenticate(
        value: userFixture().copyWith(
          name: 'Nguyễn Minh Anh',
          email: 'minhanh.nguyen@gmail.com',
        ),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        buildSettingsScreen(
          authRepo: authRepo,
          tokenStore: tokenStore,
          session: session,
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề
      expect(find.text('Cài đặt'), findsOneWidget);

      // Thẻ người dùng
      expect(find.text('MA'), findsOneWidget);
      expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
      expect(find.text('minhanh.nguyen@gmail.com'), findsOneWidget);
      expect(find.text('Sửa'), findsOneWidget);

      // Nhóm Quản lý tiền
      expect(find.text('Quản lý tiền'), findsOneWidget);
      expect(find.text('Ví'), findsOneWidget);
      expect(find.text('26.022.000đ'), findsOneWidget);
      expect(find.text('Ngân sách'), findsOneWidget);
      expect(find.text('Đã dùng 62%'), findsOneWidget);
      expect(find.text('Mục tiêu tiết kiệm'), findsOneWidget);
      expect(find.text('3 mục tiêu'), findsOneWidget);
      expect(find.text('Giao dịch định kỳ'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Nhóm Nhập liệu
      expect(find.text('Nhập liệu'), findsOneWidget);
      expect(find.text('Danh mục'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.text('Mẫu nhập nhanh'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      // Nhóm Ứng dụng
      expect(find.text('Ứng dụng'), findsOneWidget);
      expect(find.text('Thông báo'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // badge số 2
      expect(find.text('Xuất dữ liệu CSV'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);

      // Đăng xuất & Xóa tài khoản
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Xóa tài khoản'), findsOneWidget);

      // Phiên bản app
      expect(find.text('TrackerX · phiên bản 1.0.0 (42)'), findsOneWidget);
    },
  );

  testWidgets('EditProfileSheet cho phép cập nhật tên người dùng', (
    tester,
  ) async {
    final authRepo = FakeAuthRepository();
    final tokenStore = _MemoryTokenStore('test-token');
    final session = AppSessionController();
    session.authenticate(
      value: userFixture().copyWith(name: 'Minh Anh', email: 'ma@example.com'),
      publicConfig: publicConfigFixture(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          tokenStoreProvider.overrideWithValue(tokenStore),
          appSessionProvider.overrideWith((ref) => session),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: EditProfileSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa thông tin'), findsOneWidget);
    expect(find.text('Minh Anh'), findsOneWidget);

    // Thay đổi tên
    await tester.enterText(find.byType(TextField).first, 'Nguyễn Minh Anh');
    await tester.pumpAndSettle();

    // Bấm lưu
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();

    expect(authRepo.updatedName, 'Nguyễn Minh Anh');
    expect(session.user?.name, 'Nguyễn Minh Anh');
  });

  testWidgets(
    'ChangePasswordSheet kiểm tra độ dài và đổi mật khẩu thành công',
    (tester) async {
      final authRepo = FakeAuthRepository();
      final tokenStore = _MemoryTokenStore('old-token');
      final session = AppSessionController();
      session.authenticate(
        value: userFixture(),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            tokenStoreProvider.overrideWithValue(tokenStore),
            appSessionProvider.overrideWith((ref) => session),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: ChangePasswordSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đổi mật khẩu'), findsAtLeastNWidgets(1));

      // Nhập mật khẩu hiện tại, mới và xác nhận
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'oldpass123');
      await tester.enterText(textFields.at(1), 'newpass123');
      await tester.enterText(textFields.at(2), 'newpass123');
      await tester.pumpAndSettle();

      // Bấm nút Đổi mật khẩu
      await tester.tap(find.widgetWithText(FilledButton, 'Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(authRepo.changedCurrentPassword, 'oldpass123');
      expect(authRepo.changedNewPassword, 'newpass123');
      expect(tokenStore.token, 'new-token-123');
    },
  );

  testWidgets(
    'DeleteAccountSheet hiển thị đúng mockup 21 và xóa tài khoản thành công',
    (tester) async {
      final authRepo = FakeAuthRepository();
      final tokenStore = _MemoryTokenStore('token');
      final session = AppSessionController();
      session.authenticate(
        value: userFixture(),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            tokenStoreProvider.overrideWithValue(tokenStore),
            appSessionProvider.overrideWith((ref) => session),
            walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
            savingRepositoryProvider.overrideWithValue(FakeSavingRepository()),
            reportRepositoryProvider.overrideWithValue(FakeReportRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: DeleteAccountSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xóa tài khoản?'), findsOneWidget);
      expect(find.text('Muốn giữ lại dữ liệu?'), findsOneWidget);
      expect(find.text('Xuất CSV'), findsOneWidget);
      expect(find.text('Nhập mật khẩu để xác nhận'), findsOneWidget);
      expect(find.text('Xóa vĩnh viễn'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);

      // Nhập mật khẩu
      await tester.enterText(find.byType(TextField), 'password123');
      await tester.pumpAndSettle();

      // Bấm Xóa vĩnh viễn
      await tester.tap(find.text('Xóa vĩnh viễn'));
      await tester.pumpAndSettle();

      expect(authRepo.deletedPassword, 'password123');
      expect(tokenStore.cleared, isTrue);
      expect(session.status, AppSessionStatus.unauthenticated);
    },
  );

  testWidgets(
    'LogoutSheet hỗ trợ đăng xuất thiết bị này và đăng xuất mọi thiết bị',
    (tester) async {
      final authRepo = FakeAuthRepository();
      final tokenStore = _MemoryTokenStore('token');
      final session = AppSessionController();
      session.authenticate(
        value: userFixture(),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            tokenStoreProvider.overrideWithValue(tokenStore),
            appSessionProvider.overrideWith((ref) => session),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: LogoutSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Đăng xuất thiết bị này'), findsOneWidget);
      expect(find.text('Đăng xuất mọi thiết bị'), findsOneWidget);

      // Bấm đăng xuất mọi thiết bị
      await tester.tap(find.text('Đăng xuất mọi thiết bị'));
      await tester.pumpAndSettle();

      expect(authRepo.logoutAllCalls, 1);
      expect(tokenStore.cleared, isTrue);
      expect(session.status, AppSessionStatus.unauthenticated);
    },
  );
}
