// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTransferDto _$CreateTransferDtoFromJson(Map<String, dynamic> json) =>
    _CreateTransferDto(
      fromWalletId: json['fromWalletId'] as String,
      toWalletId: json['toWalletId'] as String,
      amount: (json['amount'] as num).toInt(),
      note: json['note'] as String?,
      occurredAt: json['occurredAt'] as String?,
    );

Map<String, dynamic> _$CreateTransferDtoToJson(_CreateTransferDto instance) =>
    <String, dynamic>{
      'fromWalletId': instance.fromWalletId,
      'toWalletId': instance.toWalletId,
      'amount': instance.amount,
      'note': instance.note,
      'occurredAt': instance.occurredAt,
    };

_TransferItem _$TransferItemFromJson(Map<String, dynamic> json) =>
    _TransferItem(
      id: json['id'] as String,
      fromWalletId: json['fromWalletId'] as String,
      toWalletId: json['toWalletId'] as String,
      amount: (json['amount'] as num).toInt(),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      note: json['note'] as String?,
      fromWallet: json['fromWallet'] == null
          ? null
          : WalletMeta.fromJson(json['fromWallet'] as Map<String, dynamic>),
      toWallet: json['toWallet'] == null
          ? null
          : WalletMeta.fromJson(json['toWallet'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransferItemToJson(_TransferItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromWalletId': instance.fromWalletId,
      'toWalletId': instance.toWalletId,
      'amount': instance.amount,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'note': instance.note,
      'fromWallet': instance.fromWallet,
      'toWallet': instance.toWallet,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
