// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletItemSummary _$WalletItemSummaryFromJson(Map<String, dynamic> json) =>
    _WalletItemSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isArchived: json['isArchived'] as bool? ?? false,
      balance: (json['balance'] as num).toInt(),
    );

Map<String, dynamic> _$WalletItemSummaryToJson(_WalletItemSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'isArchived': instance.isArchived,
      'balance': instance.balance,
    };

_StatsBalance _$StatsBalanceFromJson(Map<String, dynamic> json) =>
    _StatsBalance(
      balance: (json['balance'] as num).toInt(),
      totalIncome: (json['totalIncome'] as num).toInt(),
      totalExpense: (json['totalExpense'] as num).toInt(),
      savings: (json['savings'] as num).toInt(),
      wallets:
          (json['wallets'] as List<dynamic>?)
              ?.map(
                (e) => WalletItemSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <WalletItemSummary>[],
    );

Map<String, dynamic> _$StatsBalanceToJson(_StatsBalance instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'savings': instance.savings,
      'wallets': instance.wallets,
    };

_StatsSummary _$StatsSummaryFromJson(Map<String, dynamic> json) =>
    _StatsSummary(
      income: (json['income'] as num).toInt(),
      expense: (json['expense'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      incomeCount: (json['incomeCount'] as num?)?.toInt() ?? 0,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num).toInt(),
    );

Map<String, dynamic> _$StatsSummaryToJson(_StatsSummary instance) =>
    <String, dynamic>{
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
      'incomeCount': instance.incomeCount,
      'expenseCount': instance.expenseCount,
      'balance': instance.balance,
    };

_CategoryMeta _$CategoryMetaFromJson(Map<String, dynamic> json) =>
    _CategoryMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$CategoryMetaToJson(_CategoryMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'type': instance.type,
    };

_WalletMeta _$WalletMetaFromJson(Map<String, dynamic> json) => _WalletMeta(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  isArchived: json['isArchived'] as bool? ?? false,
);

Map<String, dynamic> _$WalletMetaToJson(_WalletMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'icon': instance.icon,
      'color': instance.color,
      'isArchived': instance.isArchived,
    };

_TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) =>
    _TransactionItem(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      title: json['title'] as String,
      note: json['note'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      category: json['category'] == null
          ? null
          : CategoryMeta.fromJson(json['category'] as Map<String, dynamic>),
      wallet: json['wallet'] == null
          ? null
          : WalletMeta.fromJson(json['wallet'] as Map<String, dynamic>),
      recurring: json['recurring'] as bool? ?? false,
    );

Map<String, dynamic> _$TransactionItemToJson(_TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'title': instance.title,
      'note': instance.note,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'category': instance.category,
      'wallet': instance.wallet,
      'recurring': instance.recurring,
    };

_TransactionPage _$TransactionPageFromJson(Map<String, dynamic> json) =>
    _TransactionPage(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TransactionItem>[],
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionPageToJson(_TransactionPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

_BudgetThresholds _$BudgetThresholdsFromJson(Map<String, dynamic> json) =>
    _BudgetThresholds(
      warningPercent: (json['warningPercent'] as num?)?.toInt() ?? 80,
      exceededPercent: (json['exceededPercent'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$BudgetThresholdsToJson(_BudgetThresholds instance) =>
    <String, dynamic>{
      'warningPercent': instance.warningPercent,
      'exceededPercent': instance.exceededPercent,
    };

_BudgetOverall _$BudgetOverallFromJson(Map<String, dynamic> json) =>
    _BudgetOverall(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String?,
      month: json['month'] as String,
      limitAmount: (json['limitAmount'] as num).toInt(),
      spent: (json['spent'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$BudgetOverallToJson(_BudgetOverall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'month': instance.month,
      'limitAmount': instance.limitAmount,
      'spent': instance.spent,
      'remaining': instance.remaining,
      'percentage': instance.percentage,
      'status': instance.status,
    };

_BudgetItem _$BudgetItemFromJson(Map<String, dynamic> json) => _BudgetItem(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  month: json['month'] as String,
  limitAmount: (json['limitAmount'] as num).toInt(),
  spent: (json['spent'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  percentage: (json['percentage'] as num).toDouble(),
  status: json['status'] as String,
  category: json['category'] == null
      ? null
      : CategoryMeta.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BudgetItemToJson(_BudgetItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'month': instance.month,
      'limitAmount': instance.limitAmount,
      'spent': instance.spent,
      'remaining': instance.remaining,
      'percentage': instance.percentage,
      'status': instance.status,
      'category': instance.category,
    };

_BudgetSummary _$BudgetSummaryFromJson(Map<String, dynamic> json) =>
    _BudgetSummary(
      month: json['month'] as String,
      thresholds: BudgetThresholds.fromJson(
        json['thresholds'] as Map<String, dynamic>,
      ),
      overall: json['overall'] == null
          ? null
          : BudgetOverall.fromJson(json['overall'] as Map<String, dynamic>),
      totalLimit: (json['totalLimit'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
      totalRemaining: (json['totalRemaining'] as num?)?.toInt() ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BudgetItem>[],
    );

Map<String, dynamic> _$BudgetSummaryToJson(_BudgetSummary instance) =>
    <String, dynamic>{
      'month': instance.month,
      'thresholds': instance.thresholds,
      'overall': instance.overall,
      'totalLimit': instance.totalLimit,
      'totalSpent': instance.totalSpent,
      'totalRemaining': instance.totalRemaining,
      'items': instance.items,
    };

_QuickTemplateItem _$QuickTemplateItemFromJson(Map<String, dynamic> json) =>
    _QuickTemplateItem(
      id: json['id'] as String,
      label: json['label'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as String,
      note: json['note'] as String?,
      category: json['category'] == null
          ? null
          : CategoryMeta.fromJson(json['category'] as Map<String, dynamic>),
      wallet: json['wallet'] == null
          ? null
          : WalletMeta.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuickTemplateItemToJson(_QuickTemplateItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'title': instance.title,
      'amount': instance.amount,
      'categoryId': instance.categoryId,
      'walletId': instance.walletId,
      'note': instance.note,
      'category': instance.category,
      'wallet': instance.wallet,
    };
