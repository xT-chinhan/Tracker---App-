// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategorySummaryItem _$CategorySummaryItemFromJson(Map<String, dynamic> json) =>
    _CategorySummaryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$CategorySummaryItemToJson(
  _CategorySummaryItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'color': instance.color,
};

_CategoryReportItem _$CategoryReportItemFromJson(Map<String, dynamic> json) =>
    _CategoryReportItem(
      category: CategorySummaryItem.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      amount: json['amount'] == null ? 0 : _toInt(json['amount']),
      count: json['count'] == null ? 0 : _toInt(json['count']),
      percentage: json['percentage'] == null
          ? 0.0
          : _toDouble(json['percentage']),
    );

Map<String, dynamic> _$CategoryReportItemToJson(_CategoryReportItem instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'count': instance.count,
      'percentage': instance.percentage,
    };

_ComparisonMetric _$ComparisonMetricFromJson(Map<String, dynamic> json) =>
    _ComparisonMetric(
      current: json['current'] == null ? 0 : _toInt(json['current']),
      previous: json['previous'] == null ? 0 : _toInt(json['previous']),
      difference: json['difference'] == null ? 0 : _toInt(json['difference']),
      percentageChange: _toNullableDouble(json['percentageChange']),
      trend: json['trend'] as String? ?? 'stable',
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$ComparisonMetricToJson(_ComparisonMetric instance) =>
    <String, dynamic>{
      'current': instance.current,
      'previous': instance.previous,
      'difference': instance.difference,
      'percentageChange': instance.percentageChange,
      'trend': instance.trend,
      'categoryName': instance.categoryName,
    };

_ReportComparison _$ReportComparisonFromJson(Map<String, dynamic> json) =>
    _ReportComparison(
      previousMonth: json['previousMonth'] as String,
      income: ComparisonMetric.fromJson(json['income'] as Map<String, dynamic>),
      expense: ComparisonMetric.fromJson(
        json['expense'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ReportComparisonToJson(_ReportComparison instance) =>
    <String, dynamic>{
      'previousMonth': instance.previousMonth,
      'income': instance.income,
      'expense': instance.expense,
    };

_ForecastMetric _$ForecastMetricFromJson(Map<String, dynamic> json) =>
    _ForecastMetric(
      predicted: json['predicted'] == null ? 0 : _toInt(json['predicted']),
      average: json['average'] == null ? 0 : _toInt(json['average']),
      growthRate: json['growthRate'] == null
          ? 0.0
          : _toDouble(json['growthRate']),
      method: json['method'] as String? ?? 'simple_average',
    );

Map<String, dynamic> _$ForecastMetricToJson(_ForecastMetric instance) =>
    <String, dynamic>{
      'predicted': instance.predicted,
      'average': instance.average,
      'growthRate': instance.growthRate,
      'method': instance.method,
    };

_ForecastData _$ForecastDataFromJson(Map<String, dynamic> json) =>
    _ForecastData(
      month: json['month'] as String,
      income: ForecastMetric.fromJson(json['income'] as Map<String, dynamic>),
      expense: ForecastMetric.fromJson(json['expense'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastDataToJson(_ForecastData instance) =>
    <String, dynamic>{
      'month': instance.month,
      'income': instance.income,
      'expense': instance.expense,
    };

_MonthlyTrendItem _$MonthlyTrendItemFromJson(Map<String, dynamic> json) =>
    _MonthlyTrendItem(
      month: json['month'] as String,
      income: json['income'] == null ? 0 : _toInt(json['income']),
      expense: json['expense'] == null ? 0 : _toInt(json['expense']),
      net: json['net'] == null ? 0 : _toInt(json['net']),
    );

Map<String, dynamic> _$MonthlyTrendItemToJson(_MonthlyTrendItem instance) =>
    <String, dynamic>{
      'month': instance.month,
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
    };

_ReportData _$ReportDataFromJson(Map<String, dynamic> json) => _ReportData(
  month: json['month'] as String,
  walletId: json['walletId'] as String?,
  income: json['income'] == null ? 0 : _toInt(json['income']),
  expense: json['expense'] == null ? 0 : _toInt(json['expense']),
  net: json['net'] == null ? 0 : _toInt(json['net']),
  savingRate: json['savingRate'] == null ? 0.0 : _toDouble(json['savingRate']),
  comparison: ReportComparison.fromJson(
    json['comparison'] as Map<String, dynamic>,
  ),
  incomeByCategory:
      (json['incomeByCategory'] as List<dynamic>?)
          ?.map((e) => CategoryReportItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryReportItem>[],
  expenseByCategory:
      (json['expenseByCategory'] as List<dynamic>?)
          ?.map((e) => CategoryReportItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryReportItem>[],
  forecast: ForecastData.fromJson(json['forecast'] as Map<String, dynamic>),
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => MonthlyTrendItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MonthlyTrendItem>[],
  topCategoryComparison: json['topCategoryComparison'] == null
      ? null
      : ComparisonMetric.fromJson(
          json['topCategoryComparison'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ReportDataToJson(_ReportData instance) =>
    <String, dynamic>{
      'month': instance.month,
      'walletId': instance.walletId,
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
      'savingRate': instance.savingRate,
      'comparison': instance.comparison,
      'incomeByCategory': instance.incomeByCategory,
      'expenseByCategory': instance.expenseByCategory,
      'forecast': instance.forecast,
      'history': instance.history,
      'topCategoryComparison': instance.topCategoryComparison,
    };
