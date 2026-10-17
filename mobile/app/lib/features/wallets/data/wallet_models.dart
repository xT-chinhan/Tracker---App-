import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_models.freezed.dart';
part 'wallet_models.g.dart';

@freezed
abstract class WalletItem with _$WalletItem {
  const factory WalletItem({
    required String id,
    required String name,
    required String type,
    @Default(0) int initialBalance,
    @Default(0) int balance,
    String? icon,
    String? color,
    @Default(false) bool isArchived,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletItem;

  factory WalletItem.fromJson(Map<String, dynamic> json) =>
      _$WalletItemFromJson(json);
}

@freezed
abstract class WalletListResponse with _$WalletListResponse {
  const factory WalletListResponse({
    @Default(0) int totalBalance,
    @Default(<WalletItem>[]) List<WalletItem> items,
  }) = _WalletListResponse;

  factory WalletListResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletListResponseFromJson(json);
}

@freezed
abstract class CreateWalletDto with _$CreateWalletDto {
  const factory CreateWalletDto({
    required String name,
    required String type,
    int? initialBalance,
    String? icon,
    String? color,
  }) = _CreateWalletDto;

  factory CreateWalletDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWalletDtoFromJson(json);
}

@freezed
abstract class UpdateWalletDto with _$UpdateWalletDto {
  const factory UpdateWalletDto({
    String? name,
    String? type,
    int? initialBalance,
    String? icon,
    String? color,
  }) = _UpdateWalletDto;

  factory UpdateWalletDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateWalletDtoFromJson(json);
}
