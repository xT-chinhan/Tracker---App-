import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_models.freezed.dart';
part 'transaction_models.g.dart';

@freezed
abstract class CreateTransactionDto with _$CreateTransactionDto {
  const factory CreateTransactionDto({
    required String categoryId,
    required String walletId,
    required int amount,
    required String title,
    String? note,
    String? occurredAt,
  }) = _CreateTransactionDto;

  factory CreateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionDtoFromJson(json);
}

@freezed
abstract class UpdateTransactionDto with _$UpdateTransactionDto {
  const factory UpdateTransactionDto({
    String? categoryId,
    String? walletId,
    int? amount,
    String? title,
    String? note,
    String? occurredAt,
  }) = _UpdateTransactionDto;

  factory UpdateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionDtoFromJson(json);
}
