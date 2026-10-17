import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/home/data/home_models.dart';

void main() {
  group('Home Models', () {
    test('StatsBalance deserialization from JSON', () {
      final json = {
        'balance': 26022000,
        'totalIncome': 22000000,
        'totalExpense': 8680000,
        'savings': 5000000,
        'wallets': [
          {
            'id': 'w-1',
            'name': 'Tiền mặt',
            'type': 'CASH',
            'isArchived': false,
            'balance': 1022000,
          },
        ],
      };

      final model = StatsBalance.fromJson(json);
      expect(model.balance, 26022000);
      expect(model.wallets.length, 1);
      expect(model.wallets.first.name, 'Tiền mặt');
    });

    test('BudgetSummary deserialization with overall and items', () {
      final json = {
        'month': '2026-09',
        'thresholds': {'warningPercent': 80, 'exceededPercent': 100},
        'overall': {
          'id': 'b-overall',
          'month': '2026-09',
          'limitAmount': 14000000,
          'spent': 8680000,
          'remaining': 5320000,
          'percentage': 62.0,
          'status': 'ok',
        },
        'totalLimit': 14000000,
        'totalSpent': 8680000,
        'totalRemaining': 5320000,
        'items': [],
      };

      final model = BudgetSummary.fromJson(json);
      expect(model.overall?.limitAmount, 14000000);
      expect(model.overall?.percentage, 62.0);
      expect(model.overall?.status, 'ok');
      expect(model.thresholds.warningPercent, 80);
    });

    test(
      'TransactionItem deserialization with category and wallet metadata',
      () {
        final json = {
          'id': 'tx-123',
          'type': 'EXPENSE',
          'amount': 55000,
          'title': 'Cơm trưa văn phòng',
          'occurredAt': '2026-09-22T12:10:00.000Z',
          'category': {
            'id': 'cat-1',
            'name': 'Ăn uống',
            'icon': 'utensils',
            'color': '#EB6834',
          },
          'wallet': {
            'id': 'w-1',
            'name': 'Tiền mặt',
            'type': 'CASH',
            'isArchived': false,
          },
          'recurring': false,
        };

        final model = TransactionItem.fromJson(json);
        expect(model.title, 'Cơm trưa văn phòng');
        expect(model.amount, 55000);
        expect(model.type, 'EXPENSE');
        expect(model.category?.name, 'Ăn uống');
        expect(model.wallet?.name, 'Tiền mặt');
      },
    );

    test('QuickTemplateItem deserialization', () {
      final json = {
        'id': 'qt-1',
        'label': 'Cà phê',
        'title': 'Cà phê sáng',
        'amount': 45000,
        'categoryId': 'cat-1',
        'walletId': 'w-1',
      };

      final model = QuickTemplateItem.fromJson(json);
      expect(model.label, 'Cà phê');
      expect(model.amount, 45000);
    });
  });
}
