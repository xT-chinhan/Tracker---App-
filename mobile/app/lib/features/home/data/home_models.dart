import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_models.freezed.dart';
part 'home_models.g.dart';

@freezed
abstract class WalletItemSummary with _$WalletItemSummary {
  const factory WalletItemSummary({
    required String id,
    required String name,
    required String type,
    @Default(false) bool isArchived,
    required int balance,
  }) = _WalletItemSummary;

  factory WalletItemSummary.fromJson(Map<String, dynamic> json) =>
      _$WalletItemSummaryFromJson(json);
}

@freezed
abstract class StatsBalance with _$StatsBalance {
  const factory StatsBalance({
    required int balance,
    required int totalIncome,
    required int totalExpense,
    required int savings,
    @Default(<WalletItemSummary>[]) List<WalletItemSummary> wallets,
  }) = _StatsBalance;

  factory StatsBalance.fromJson(Map<String, dynamic> json) =>
      _$StatsBalanceFromJson(json);
}

@freezed
abstract class StatsSummary with _$StatsSummary {
  const factory StatsSummary({
    required int income,
    required int expense,
    required int net,
    @Default(0) int incomeCount,
    @Default(0) int expenseCount,
    required int balance,
  }) = _StatsSummary;

  factory StatsSummary.fromJson(Map<String, dynamic> json) =>
      _$StatsSummaryFromJson(json);
}

@freezed
abstract class CategoryMeta with _$CategoryMeta {
  const factory CategoryMeta({
    required String id,
    required String name,
    String? icon,
    String? color,
    String? type,
  }) = _CategoryMeta;

  factory CategoryMeta.fromJson(Map<String, dynamic> json) =>
      _$CategoryMetaFromJson(json);
}

@freezed
abstract class WalletMeta with _$WalletMeta {
  const factory WalletMeta({
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    @Default(false) bool isArchived,
  }) = _WalletMeta;

  factory WalletMeta.fromJson(Map<String, dynamic> json) =>
      _$WalletMetaFromJson(json);
}

@freezed
abstract class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required String id,
    required String type,
    required int amount,
    required String title,
    String? note,
    required DateTime occurredAt,
    CategoryMeta? category,
    WalletMeta? wallet,
    @Default(false) bool recurring,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
}

@freezed
abstract class TransactionPage with _$TransactionPage {
  const factory TransactionPage({
    @Default(<TransactionItem>[]) List<TransactionItem> items,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _TransactionPage;

  factory TransactionPage.fromJson(Map<String, dynamic> json) =>
      _$TransactionPageFromJson(json);
}

@freezed
abstract class BudgetThresholds with _$BudgetThresholds {
  const factory BudgetThresholds({
    @Default(80) int warningPercent,
    @Default(100) int exceededPercent,
  }) = _BudgetThresholds;

  factory BudgetThresholds.fromJson(Map<String, dynamic> json) =>
      _$BudgetThresholdsFromJson(json);
}

@freezed
abstract class BudgetOverall with _$BudgetOverall {
  const factory BudgetOverall({
    required String id,
    String? categoryId,
    required String month,
    required int limitAmount,
    required int spent,
    required int remaining,
    required double percentage,
    required String status,
  }) = _BudgetOverall;

  factory BudgetOverall.fromJson(Map<String, dynamic> json) =>
      _$BudgetOverallFromJson(json);
}

@freezed
abstract class BudgetItem with _$BudgetItem {
  const factory BudgetItem({
    required String id,
    required String categoryId,
    required String month,
    required int limitAmount,
    required int spent,
    required int remaining,
    required double percentage,
    required String status,
    CategoryMeta? category,
  }) = _BudgetItem;

  factory BudgetItem.fromJson(Map<String, dynamic> json) =>
      _$BudgetItemFromJson(json);
}

@freezed
abstract class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    required String month,
    required BudgetThresholds thresholds,
    BudgetOverall? overall,
    @Default(0) int totalLimit,
    @Default(0) int totalSpent,
    @Default(0) int totalRemaining,
    @Default(<BudgetItem>[]) List<BudgetItem> items,
  }) = _BudgetSummary;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryFromJson(json);
}

@freezed
abstract class QuickTemplateItem with _$QuickTemplateItem {
  const factory QuickTemplateItem({
    required String id,
    required String label,
    required String title,
    required int amount,
    required String categoryId,
    required String walletId,
    String? note,
    CategoryMeta? category,
    WalletMeta? wallet,
  }) = _QuickTemplateItem;

  factory QuickTemplateItem.fromJson(Map<String, dynamic> json) =>
      _$QuickTemplateItemFromJson(json);
}
