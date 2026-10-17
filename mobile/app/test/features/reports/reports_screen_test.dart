import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/reports/data/report_models.dart';
import 'package:app/features/reports/data/report_repository.dart';
import 'package:app/features/reports/presentation/reports_screen.dart';
import '../../helpers/fixtures.dart';

ReportData mockReportData() {
  return const ReportData(
    month: '2026-09',
    income: 23500000,
    expense: 8680000,
    net: 14820000,
    savingRate: 63.1,
    comparison: ReportComparison(
      previousMonth: '2026-08',
      income: ComparisonMetric(
        current: 23500000,
        previous: 24200000,
        difference: -700000,
        percentageChange: -3.0,
        trend: 'decrease',
      ),
      expense: ComparisonMetric(
        current: 8680000,
        previous: 9860000,
        difference: -1180000,
        percentageChange: -12.0,
        trend: 'decrease',
      ),
    ),
    expenseByCategory: [
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-1',
          name: 'Ăn uống',
          icon: 'utensils',
          color: '#2a78d6',
        ),
        amount: 3120000,
        count: 15,
        percentage: 36.0,
      ),
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-2',
          name: 'Nhà ở',
          icon: 'house',
          color: '#eb6834',
        ),
        amount: 2500000,
        count: 2,
        percentage: 29.0,
      ),
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-3',
          name: 'Mua sắm',
          icon: 'shopping-cart',
          color: '#1baf7a',
        ),
        amount: 1380000,
        count: 5,
        percentage: 16.0,
      ),
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-4',
          name: 'Di chuyển',
          icon: 'car',
          color: '#eda100',
        ),
        amount: 820000,
        count: 8,
        percentage: 9.0,
      ),
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-5',
          name: 'Khác',
          icon: 'receipt',
          color: '#e87ba4',
        ),
        amount: 860000,
        count: 4,
        percentage: 10.0,
      ),
    ],
    forecast: ForecastData(
      month: '2026-10',
      income: ForecastMetric(
        predicted: 23000000,
        average: 23000000,
        growthRate: 0.0,
        method: 'simple_average',
      ),
      expense: ForecastMetric(
        predicted: 10000000,
        average: 9600000,
        growthRate: 4.2,
        method: 'weighted_average',
      ),
    ),
    history: [
      MonthlyTrendItem(month: '2026-04', income: 22000000, expense: 9200000, net: 12800000),
      MonthlyTrendItem(month: '2026-05', income: 22000000, expense: 8950000, net: 13050000),
      MonthlyTrendItem(month: '2026-06', income: 23500000, expense: 10400000, net: 13100000),
      MonthlyTrendItem(month: '2026-07', income: 22000000, expense: 9750000, net: 12250000),
      MonthlyTrendItem(month: '2026-08', income: 24200000, expense: 9860000, net: 14340000),
      MonthlyTrendItem(month: '2026-09', income: 23500000, expense: 8680000, net: 14820000),
    ],
    topCategoryComparison: ComparisonMetric(
      current: 1380000,
      previous: 920000,
      difference: 460000,
      percentageChange: 50.0,
      trend: 'increase',
      categoryName: 'Mua sắm',
    ),
  );
}

class FakeReportRepository extends ReportRepository {
  FakeReportRepository({this.data}) : super(Dio());

  final ReportData? data;
  int getReportCalls = 0;
  int exportCalls = 0;

  @override
  Future<ReportData> getReport({
    String? month,
    String? walletId,
    int observationMonths = 6,
  }) async {
    getReportCalls++;
    return data ?? mockReportData();
  }

  @override
  Future<List<CategoryReportItem>> getByCategory({
    String? month,
    String? walletId,
    String type = 'EXPENSE',
  }) async {
    return const [
      CategoryReportItem(
        category: CategorySummaryItem(
          id: 'cat-1',
          name: 'Ăn uống',
        ),
        amount: 2080000,
        count: 10,
        percentage: 25.0,
      ),
    ];
  }

  @override
  Future<List<MonthlyTrendItem>> getTrend({
    String? month,
    String? walletId,
    int months = 6,
  }) async {
    return data?.history ?? mockReportData().history;
  }

  @override
  Future<String> exportCsv({String? month, String? walletId}) async {
    exportCalls++;
    return 'Ngày,Loại,Danh mục,Ví,Tiêu đề,Ghi chú,Số tiền\n2026-09-01 12:00,Chi,Ăn uống,Tiền mặt,Ăn trưa,,50000\n';
  }
}

void main() {
  Widget buildTestableWidget({
    required FakeReportRepository repo,
  }) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        reportRepositoryProvider.overrideWithValue(repo),
        appSessionProvider.overrideWith((ref) => session),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ReportsScreen(),
      ),
    );
  }

  testWidgets(
    'ReportsScreen hiển thị tổng quan thu chi, danh mục, xu hướng, so sánh và dự báo',
    (tester) async {
      final repo = FakeReportRepository();

      await tester.binding.setSurfaceSize(const Size(430, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Báo cáo'), findsOneWidget);

      // Card 1: Chênh lệch thu chi
      expect(find.text('Chênh lệch thu chi'), findsOneWidget);
      expect(find.text('+14.820.000đ'), findsOneWidget);
      expect(find.text('Thu nhập'), findsWidgets);
      expect(find.text('23.500.000đ'), findsWidgets);
      expect(find.text('Chi tiêu'), findsWidgets);
      expect(find.text('8.680.000đ'), findsWidgets);

      // Card 2: Chi theo danh mục
      expect(find.text('Chi theo danh mục'), findsOneWidget);
      expect(find.text('5 nhóm'), findsOneWidget);
      expect(find.text('Tổng chi'), findsOneWidget);
      expect(find.text('Lớn nhất'), findsOneWidget);
      expect(find.text('Ăn uống · 36%'), findsOneWidget);
      expect(find.text('Ăn uống'), findsWidgets);
      expect(find.text('Nhà ở'), findsOneWidget);
      expect(find.text('Mua sắm'), findsWidgets);
      expect(find.text('Di chuyển'), findsOneWidget);
      expect(find.text('Khác'), findsOneWidget);

      // Card 3: Thu chi 6 tháng
      expect(find.text('Thu chi 6 tháng'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Chi'), findsOneWidget);

      // Card 4: So với tháng trước
      expect(find.text('So với tháng 08'), findsOneWidget);
      expect(find.text('12%'), findsOneWidget);
      expect(find.text('3%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      // Card 5: Dự báo
      expect(find.text('Dự báo'), findsOneWidget);
      expect(find.text('≈ 10.000.000đ'), findsOneWidget);
      expect(find.text('TB có trọng số'), findsOneWidget);
    },
  );

  testWidgets(
    'ReportsScreen xuất CSV thành công và mở bottom sheet xác nhận',
    (tester) async {
      final repo = FakeReportRepository();

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      final exportButton = find.byIcon(LucideIcons.download);
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      expect(repo.exportCalls, 1);
      expect(find.text('Xuất file CSV thành công'), findsOneWidget);
      expect(find.text('Sao chép nội dung CSV'), findsOneWidget);
    },
  );

  testWidgets(
    'ReportsScreen chuyển tháng qua lại tải lại báo cáo',
    (tester) async {
      final repo = FakeReportRepository();

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      final initialCalls = repo.getReportCalls;

      // Tap chevron left (tháng trước)
      final prevBtn = find.byTooltip('Tháng trước');
      expect(prevBtn, findsOneWidget);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      expect(repo.getReportCalls, greaterThan(initialCalls));

      // Tap chevron right (tháng sau)
      final nextBtn = find.byTooltip('Tháng sau');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(repo.getReportCalls, greaterThan(initialCalls + 1));
    },
  );
}
