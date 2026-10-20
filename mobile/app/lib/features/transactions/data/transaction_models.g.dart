// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTransactionDto _$CreateTransactionDtoFromJson(
  Map<String, dynamic> json,
) => _CreateTransactionDto(
  categoryId: json['categoryId'] as String,
  walletId: json['walletId'] as String,
  amount: (json['amount'] as num).toInt(),
  title: json['title'] as String,
  note: json['note'] as String?,
  occurredAt: json['occurredAt'] as String?,
);

Map<String, dynamic> _$CreateTransactionDtoToJson(
  _CreateTransactionDto instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'walletId': instance.walletId,
  'amount': instance.amount,
  'title': instance.title,
  'note': instance.note,
  'occurredAt': instance.occurredAt,
};

_UpdateTransactionDto _$UpdateTransactionDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateTransactionDto(
  categoryId: json['categoryId'] as String?,
  walletId: json['walletId'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
  title: json['title'] as String?,
  note: json['note'] as String?,
  occurredAt: json['occurredAt'] as String?,
);

Map<String, dynamic> _$UpdateTransactionDtoToJson(
  _UpdateTransactionDto instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'walletId': instance.walletId,
  'amount': instance.amount,
  'title': instance.title,
  'note': instance.note,
  'occurredAt': instance.occurredAt,
};
