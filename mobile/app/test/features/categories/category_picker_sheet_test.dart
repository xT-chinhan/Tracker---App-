import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/categories/application/categories_service.dart';
import 'package:app/features/categories/data/category_models.dart';
import 'package:app/features/categories/presentation/category_picker_sheet.dart';
import 'package:app/features/transactions/presentation/transaction_entry_screen.dart';
import '../../helpers/fixtures.dart';

void main() {
  final testExpenseCategories = [
    categoryItemFixture(id: 'cat-1', name: 'Ăn uống', type: 'EXPENSE'),
    categoryItemFixture(id: 'cat-2', name: 'Di chuyển', type: 'EXPENSE'),
  ];
  final testIncomeCategories = [
    categoryItemFixture(id: 'cat-inc', name: 'Tiền lương', type: 'INCOME'),
  ];

  Widget buildSheet({
    TransactionType initialType = TransactionType.expense,
    ValueChanged<CategoryItem>? onSelect,
  }) {
    return ProviderScope(
      overrides: [
        categoriesProvider(
          'EXPENSE',
        ).overrideWith((ref) async => testExpenseCategories),
        categoriesProvider(
          'INCOME',
        ).overrideWith((ref) async => testIncomeCategories),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CategoryPickerSheet(
            initialType: initialType,
            onSelect: onSelect ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'CategoryPickerSheet hiển thị danh mục theo loại và hỗ trợ chuyển đổi',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      CategoryItem? selected;
      await tester.pumpWidget(buildSheet(onSelect: (cat) => selected = cat));
      await tester.pumpAndSettle();

      expect(find.text('Chọn danh mục'), findsOneWidget);
      expect(find.text('Khoản chi'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('Di chuyển'), findsOneWidget);
      expect(find.text('Thêm mới'), findsOneWidget);

      // Tap category "Ăn uống"
      await tester.tap(find.text('Ăn uống'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'cat-1');
    },
  );

  testWidgets(
    'CategoryPickerSheet chuyển sang tab Thu nhập hiển thị danh mục thu nhập',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      // Switch to income tab
      await tester.tap(find.text('Thu nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Tiền lương'), findsOneWidget);
    },
  );
}
