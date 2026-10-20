import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

int _toInt(dynamic v) => (v as num?)?.round() ?? 0;
double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
double? _toNullableDouble(dynamic v) => (v as num?)?.toDouble();

@freezed
abstract class CategorySummaryItem with _$CategorySummaryItem {
  const factory CategorySummaryItem({
    required String id,
    required String name,
    String? icon,
    String? color,
  }) = _CategorySummaryItem;

  factory CategorySummaryItem.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryItemFromJson(json);
}

@freezed
abstract class CategoryReportItem with _$CategoryReportItem {
  const factory CategoryReportItem({
    required CategorySummaryItem category,
    @JsonKey(fromJson: _toInt) @Default(0) int amount,
    @JsonKey(fromJson: _toInt) @Default(0) int count,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double percentage,
  }) = _CategoryReportItem;

  factory CategoryReportItem.fromJson(Map<String, dynamic> json) =>
      _$CategoryReportItemFromJson(json);
}

@freezed
abstract class ComparisonMetric with _$ComparisonMetric {
  const factory ComparisonMetric({
    @JsonKey(fromJson: _toInt) @Default(0) int current,
    @JsonKey(fromJson: _toInt) @Default(0) int previous,
    @JsonKey(fromJson: _toInt) @Default(0) int difference,
    @JsonKey(fromJson: _toNullableDouble) double? percentageChange,
    @Default('stable') String trend,
    String? categoryName,
  }) = _ComparisonMetric;

  factory ComparisonMetric.fromJson(Map<String, dynamic> json) =>
      _$ComparisonMetricFromJson(json);
}

@freezed
abstract class ReportComparison with _$ReportComparison {
  const factory ReportComparison({
    required String previousMonth,
    required ComparisonMetric income,
    required ComparisonMetric expense,
  }) = _ReportComparison;

  factory ReportComparison.fromJson(Map<String, dynamic> json) =>
      _$ReportComparisonFromJson(json);
}

@freezed
abstract class ForecastMetric with _$ForecastMetric {
  const factory ForecastMetric({
    @JsonKey(fromJson: _toInt) @Default(0) int predicted,
    @JsonKey(fromJson: _toInt) @Default(0) int average,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double growthRate,
    @Default('simple_average') String method,
  }) = _ForecastMetric;

  factory ForecastMetric.fromJson(Map<String, dynamic> json) =>
      _$ForecastMetricFromJson(json);
}

@freezed
abstract class ForecastData with _$ForecastData {
  const factory ForecastData({
    required String month,
    required ForecastMetric income,
    required ForecastMetric expense,
  }) = _ForecastData;

  factory ForecastData.fromJson(Map<String, dynamic> json) =>
      _$ForecastDataFromJson(json);
}

@freezed
abstract class MonthlyTrendItem with _$MonthlyTrendItem {
  const factory MonthlyTrendItem({
    required String month,
    @JsonKey(fromJson: _toInt) @Default(0) int income,
    @JsonKey(fromJson: _toInt) @Default(0) int expense,
    @JsonKey(fromJson: _toInt) @Default(0) int net,
  }) = _MonthlyTrendItem;

  factory MonthlyTrendItem.fromJson(Map<String, dynamic> json) =>
      _$MonthlyTrendItemFromJson(json);
}

@freezed
abstract class ReportData with _$ReportData {
  const factory ReportData({
    required String month,
    String? walletId,
    @JsonKey(fromJson: _toInt) @Default(0) int income,
    @JsonKey(fromJson: _toInt) @Default(0) int expense,
    @JsonKey(fromJson: _toInt) @Default(0) int net,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double savingRate,
    required ReportComparison comparison,
    @Default(<CategoryReportItem>[]) List<CategoryReportItem> incomeByCategory,
    @Default(<CategoryReportItem>[]) List<CategoryReportItem> expenseByCategory,
    required ForecastData forecast,
    @Default(<MonthlyTrendItem>[]) List<MonthlyTrendItem> history,
    ComparisonMetric? topCategoryComparison,
  }) = _ReportData;

  factory ReportData.fromJson(Map<String, dynamic> json) =>
      _$ReportDataFromJson(json);
}
