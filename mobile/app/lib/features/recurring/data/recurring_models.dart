import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_models.freezed.dart';
part 'recurring_models.g.dart';

int _toInt(dynamic v) => (v as num?)?.round() ?? 0;

@freezed
abstract class RecurringWalletMeta with _$RecurringWalletMeta {
  const factory RecurringWalletMeta({
    required String id,
    required String name,
    required String type,
    @Default(false) bool isArchived,
  }) = _RecurringWalletMeta;

  factory RecurringWalletMeta.fromJson(Map<String, dynamic> json) =>
      _$RecurringWalletMetaFromJson(json);
}

@freezed
abstract class RecurringCategoryMeta with _$RecurringCategoryMeta {
  const factory RecurringCategoryMeta({
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    @Default(false) bool isArchived,
  }) = _RecurringCategoryMeta;

  factory RecurringCategoryMeta.fromJson(Map<String, dynamic> json) =>
      _$RecurringCategoryMetaFromJson(json);
}

@freezed
abstract class RecurringCount with _$RecurringCount {
  const factory RecurringCount({
    @JsonKey(fromJson: _toInt) @Default(0) int transactions,
  }) = _RecurringCount;

  factory RecurringCount.fromJson(Map<String, dynamic> json) =>
      _$RecurringCountFromJson(json);
}

@freezed
abstract class RecurringRuleItem with _$RecurringRuleItem {
  const factory RecurringRuleItem({
    required String id,
    required String userId,
    required String walletId,
    required String categoryId,
    @JsonKey(fromJson: _toInt) required int amount,
    required String title,
    String? note,
    required String frequency,
    @Default(1) int interval,
    required DateTime startDate,
    DateTime? endDate,
    @Default(1) int anchorDay,
    required DateTime nextRunAt,
    DateTime? lastRunAt,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    RecurringWalletMeta? wallet,
    RecurringCategoryMeta? category,
    @JsonKey(name: '_count') RecurringCount? count,
  }) = _RecurringRuleItem;

  factory RecurringRuleItem.fromJson(Map<String, dynamic> json) =>
      _$RecurringRuleItemFromJson(json);
}

@freezed
abstract class CreateRecurringDto with _$CreateRecurringDto {
  const factory CreateRecurringDto({
    required String walletId,
    required String categoryId,
    required int amount,
    required String title,
    String? note,
    required String frequency,
    int? interval,
    required String startDate,
    String? endDate,
  }) = _CreateRecurringDto;

  factory CreateRecurringDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRecurringDtoFromJson(json);
}

@freezed
abstract class UpdateRecurringDto with _$UpdateRecurringDto {
  const factory UpdateRecurringDto({
    String? walletId,
    String? categoryId,
    int? amount,
    String? title,
    String? note,
    String? frequency,
    int? interval,
    String? startDate,
    String? endDate,
  }) = _UpdateRecurringDto;

  factory UpdateRecurringDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateRecurringDtoFromJson(json);
}

@freezed
abstract class RecurringPreviewItem with _$RecurringPreviewItem {
  const factory RecurringPreviewItem({
    required DateTime scheduledFor,
    required String date,
  }) = _RecurringPreviewItem;

  factory RecurringPreviewItem.fromJson(Map<String, dynamic> json) =>
      _$RecurringPreviewItemFromJson(json);
}

@freezed
abstract class RecurringPreviewResponse with _$RecurringPreviewResponse {
  const factory RecurringPreviewResponse({
    required String ruleId,
    @Default(true) bool isActive,
    @Default(<RecurringPreviewItem>[]) List<RecurringPreviewItem> items,
  }) = _RecurringPreviewResponse;

  factory RecurringPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$RecurringPreviewResponseFromJson(json);
}
