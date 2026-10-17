// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletItem _$WalletItemFromJson(Map<String, dynamic> json) => _WalletItem(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  initialBalance: (json['initialBalance'] as num?)?.toInt() ?? 0,
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  isArchived: json['isArchived'] as bool? ?? false,
  userId: json['userId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WalletItemToJson(_WalletItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'initialBalance': instance.initialBalance,
      'balance': instance.balance,
      'icon': instance.icon,
      'color': instance.color,
      'isArchived': instance.isArchived,
      'userId': instance.userId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_WalletListResponse _$WalletListResponseFromJson(Map<String, dynamic> json) =>
    _WalletListResponse(
      totalBalance: (json['totalBalance'] as num?)?.toInt() ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => WalletItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WalletItem>[],
    );

Map<String, dynamic> _$WalletListResponseToJson(_WalletListResponse instance) =>
    <String, dynamic>{
      'totalBalance': instance.totalBalance,
      'items': instance.items,
    };
