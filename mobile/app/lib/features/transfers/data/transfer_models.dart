import 'package:freezed_annotation/freezed_annotation.dart';

import '../../home/data/home_models.dart';

part 'transfer_models.freezed.dart';
part 'transfer_models.g.dart';

@freezed
abstract class CreateTransferDto with _$CreateTransferDto {
  const factory CreateTransferDto({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    String? note,
    String? occurredAt,
  }) = _CreateTransferDto;

  factory CreateTransferDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTransferDtoFromJson(json);
}

@freezed
abstract class TransferItem with _$TransferItem {
  const factory TransferItem({
    required String id,
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required DateTime occurredAt,
    String? note,
    WalletMeta? fromWallet,
    WalletMeta? toWallet,
    DateTime? createdAt,
  }) = _TransferItem;

  factory TransferItem.fromJson(Map<String, dynamic> json) =>
      _$TransferItemFromJson(json);
}
