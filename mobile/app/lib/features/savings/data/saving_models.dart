import 'package:freezed_annotation/freezed_annotation.dart';

part 'saving_models.freezed.dart';
part 'saving_models.g.dart';

int _toInt(dynamic v) => (v as num?)?.round() ?? 0;
double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

@freezed
abstract class SavingWalletMeta with _$SavingWalletMeta {
  const factory SavingWalletMeta({
    required String id,
    required String name,
    required String type,
  }) = _SavingWalletMeta;

  factory SavingWalletMeta.fromJson(Map<String, dynamic> json) =>
      _$SavingWalletMetaFromJson(json);
}

@freezed
abstract class SavingEntryItem with _$SavingEntryItem {
  const factory SavingEntryItem({
    required String id,
    required String goalId,
    required String walletId,
    required String type,
    @JsonKey(fromJson: _toInt) required int amount,
    required DateTime date,
    required DateTime createdAt,
    SavingWalletMeta? wallet,
  }) = _SavingEntryItem;

  factory SavingEntryItem.fromJson(Map<String, dynamic> json) =>
      _$SavingEntryItemFromJson(json);
}

@freezed
abstract class SavingGoalItem with _$SavingGoalItem {
  const factory SavingGoalItem({
    required String id,
    required String name,
    @JsonKey(fromJson: _toInt) required int targetAmount,
    @JsonKey(fromJson: _toInt) @Default(0) int savedAmount,
    required DateTime startDate,
    required DateTime targetDate,
    String? icon,
    String? color,
    @Default('ACTIVE') String status,
    @JsonKey(fromJson: _toInt) @Default(0) int remaining,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double progress,
    @JsonKey(fromJson: _toInt) @Default(0) int daysLeft,
    @JsonKey(fromJson: _toInt) @Default(0) int dailyRequired,
  }) = _SavingGoalItem;

  factory SavingGoalItem.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalItemFromJson(json);
}

@freezed
abstract class SavingGoalDetail with _$SavingGoalDetail {
  const factory SavingGoalDetail({
    required String id,
    required String name,
    @JsonKey(fromJson: _toInt) required int targetAmount,
    @JsonKey(fromJson: _toInt) @Default(0) int savedAmount,
    required DateTime startDate,
    required DateTime targetDate,
    String? icon,
    String? color,
    @Default('ACTIVE') String status,
    @JsonKey(fromJson: _toInt) @Default(0) int remaining,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double progress,
    @JsonKey(fromJson: _toInt) @Default(0) int daysLeft,
    @JsonKey(fromJson: _toInt) @Default(0) int dailyRequired,
    @Default(<SavingEntryItem>[]) List<SavingEntryItem> entries,
  }) = _SavingGoalDetail;

  factory SavingGoalDetail.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalDetailFromJson(json);
}

@freezed
abstract class CreateGoalDto with _$CreateGoalDto {
  const factory CreateGoalDto({
    required String name,
    required int targetAmount,
    String? startDate,
    required String targetDate,
    String? icon,
    String? color,
  }) = _CreateGoalDto;

  factory CreateGoalDto.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalDtoFromJson(json);
}

@freezed
abstract class UpdateGoalDto with _$UpdateGoalDto {
  const factory UpdateGoalDto({
    String? name,
    int? targetAmount,
    String? startDate,
    String? targetDate,
    String? icon,
    String? color,
  }) = _UpdateGoalDto;

  factory UpdateGoalDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalDtoFromJson(json);
}

@freezed
abstract class DepositDto with _$DepositDto {
  const factory DepositDto({
    required int amount,
    required String walletId,
    String? date,
  }) = _DepositDto;

  factory DepositDto.fromJson(Map<String, dynamic> json) =>
      _$DepositDtoFromJson(json);
}

@freezed
abstract class WithdrawDto with _$WithdrawDto {
  const factory WithdrawDto({required String walletId}) = _WithdrawDto;

  factory WithdrawDto.fromJson(Map<String, dynamic> json) =>
      _$WithdrawDtoFromJson(json);
}
