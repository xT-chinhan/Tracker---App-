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
