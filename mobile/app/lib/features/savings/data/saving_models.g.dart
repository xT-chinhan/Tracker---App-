// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingWalletMeta _$SavingWalletMetaFromJson(Map<String, dynamic> json) =>
    _SavingWalletMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$SavingWalletMetaToJson(_SavingWalletMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };

_SavingEntryItem _$SavingEntryItemFromJson(Map<String, dynamic> json) =>
    _SavingEntryItem(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: _toInt(json['amount']),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      wallet: json['wallet'] == null
          ? null
          : SavingWalletMeta.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavingEntryItemToJson(_SavingEntryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'walletId': instance.walletId,
      'type': instance.type,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'wallet': instance.wallet,
    };

_SavingGoalItem _$SavingGoalItemFromJson(Map<String, dynamic> json) =>
    _SavingGoalItem(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: _toInt(json['targetAmount']),
      savedAmount: json['savedAmount'] == null
          ? 0
          : _toInt(json['savedAmount']),
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      remaining: json['remaining'] == null ? 0 : _toInt(json['remaining']),
      progress: json['progress'] == null ? 0.0 : _toDouble(json['progress']),
      daysLeft: json['daysLeft'] == null ? 0 : _toInt(json['daysLeft']),
      dailyRequired: json['dailyRequired'] == null
          ? 0
          : _toInt(json['dailyRequired']),
    );

Map<String, dynamic> _$SavingGoalItemToJson(_SavingGoalItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'savedAmount': instance.savedAmount,
      'startDate': instance.startDate.toIso8601String(),
      'targetDate': instance.targetDate.toIso8601String(),
      'icon': instance.icon,
      'color': instance.color,
      'status': instance.status,
      'remaining': instance.remaining,
      'progress': instance.progress,
      'daysLeft': instance.daysLeft,
      'dailyRequired': instance.dailyRequired,
    };

_SavingGoalDetail _$SavingGoalDetailFromJson(Map<String, dynamic> json) =>
    _SavingGoalDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: _toInt(json['targetAmount']),
      savedAmount: json['savedAmount'] == null
          ? 0
          : _toInt(json['savedAmount']),
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      remaining: json['remaining'] == null ? 0 : _toInt(json['remaining']),
      progress: json['progress'] == null ? 0.0 : _toDouble(json['progress']),
      daysLeft: json['daysLeft'] == null ? 0 : _toInt(json['daysLeft']),
      dailyRequired: json['dailyRequired'] == null
          ? 0
          : _toInt(json['dailyRequired']),
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => SavingEntryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SavingEntryItem>[],
    );

Map<String, dynamic> _$SavingGoalDetailToJson(_SavingGoalDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'savedAmount': instance.savedAmount,
      'startDate': instance.startDate.toIso8601String(),
      'targetDate': instance.targetDate.toIso8601String(),
      'icon': instance.icon,
      'color': instance.color,
      'status': instance.status,
      'remaining': instance.remaining,
      'progress': instance.progress,
      'daysLeft': instance.daysLeft,
      'dailyRequired': instance.dailyRequired,
      'entries': instance.entries,
    };

_CreateGoalDto _$CreateGoalDtoFromJson(Map<String, dynamic> json) =>
    _CreateGoalDto(
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toInt(),
      startDate: json['startDate'] as String?,
      targetDate: json['targetDate'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$CreateGoalDtoToJson(_CreateGoalDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'startDate': instance.startDate,
      'targetDate': instance.targetDate,
      'icon': instance.icon,
      'color': instance.color,
    };

_UpdateGoalDto _$UpdateGoalDtoFromJson(Map<String, dynamic> json) =>
    _UpdateGoalDto(
      name: json['name'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toInt(),
      startDate: json['startDate'] as String?,
      targetDate: json['targetDate'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$UpdateGoalDtoToJson(_UpdateGoalDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'startDate': instance.startDate,
      'targetDate': instance.targetDate,
      'icon': instance.icon,
      'color': instance.color,
    };

_DepositDto _$DepositDtoFromJson(Map<String, dynamic> json) => _DepositDto(
  amount: (json['amount'] as num).toInt(),
  walletId: json['walletId'] as String,
  date: json['date'] as String?,
);

Map<String, dynamic> _$DepositDtoToJson(_DepositDto instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'walletId': instance.walletId,
      'date': instance.date,
    };

_WithdrawDto _$WithdrawDtoFromJson(Map<String, dynamic> json) =>
    _WithdrawDto(walletId: json['walletId'] as String);

Map<String, dynamic> _$WithdrawDtoToJson(_WithdrawDto instance) =>
    <String, dynamic>{'walletId': instance.walletId};
