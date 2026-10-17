// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringWalletMeta _$RecurringWalletMetaFromJson(Map<String, dynamic> json) =>
    _RecurringWalletMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$RecurringWalletMetaToJson(
  _RecurringWalletMeta instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'isArchived': instance.isArchived,
};

_RecurringCategoryMeta _$RecurringCategoryMetaFromJson(
  Map<String, dynamic> json,
) => _RecurringCategoryMeta(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  isArchived: json['isArchived'] as bool? ?? false,
);

Map<String, dynamic> _$RecurringCategoryMetaToJson(
  _RecurringCategoryMeta instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'icon': instance.icon,
  'color': instance.color,
  'isArchived': instance.isArchived,
};

_RecurringCount _$RecurringCountFromJson(Map<String, dynamic> json) =>
    _RecurringCount(
      transactions: json['transactions'] == null
          ? 0
          : _toInt(json['transactions']),
    );

Map<String, dynamic> _$RecurringCountToJson(_RecurringCount instance) =>
    <String, dynamic>{'transactions': instance.transactions};

_RecurringRuleItem _$RecurringRuleItemFromJson(Map<String, dynamic> json) =>
    _RecurringRuleItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      categoryId: json['categoryId'] as String,
      amount: _toInt(json['amount']),
      title: json['title'] as String,
      note: json['note'] as String?,
      frequency: json['frequency'] as String,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      anchorDay: (json['anchorDay'] as num?)?.toInt() ?? 1,
      nextRunAt: DateTime.parse(json['nextRunAt'] as String),
      lastRunAt: json['lastRunAt'] == null
          ? null
          : DateTime.parse(json['lastRunAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      wallet: json['wallet'] == null
          ? null
          : RecurringWalletMeta.fromJson(
              json['wallet'] as Map<String, dynamic>,
            ),
      category: json['category'] == null
          ? null
          : RecurringCategoryMeta.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
      count: json['_count'] == null
          ? null
          : RecurringCount.fromJson(json['_count'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecurringRuleItemToJson(_RecurringRuleItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'walletId': instance.walletId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'title': instance.title,
      'note': instance.note,
      'frequency': instance.frequency,
      'interval': instance.interval,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'anchorDay': instance.anchorDay,
      'nextRunAt': instance.nextRunAt.toIso8601String(),
      'lastRunAt': instance.lastRunAt?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'wallet': instance.wallet,
      'category': instance.category,
      '_count': instance.count,
    };

_CreateRecurringDto _$CreateRecurringDtoFromJson(Map<String, dynamic> json) =>
    _CreateRecurringDto(
      walletId: json['walletId'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toInt(),
      title: json['title'] as String,
      note: json['note'] as String?,
      frequency: json['frequency'] as String,
      interval: (json['interval'] as num?)?.toInt(),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$CreateRecurringDtoToJson(_CreateRecurringDto instance) =>
    <String, dynamic>{
      'walletId': instance.walletId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'title': instance.title,
      'note': instance.note,
      'frequency': instance.frequency,
      'interval': instance.interval,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };

_UpdateRecurringDto _$UpdateRecurringDtoFromJson(Map<String, dynamic> json) =>
    _UpdateRecurringDto(
      walletId: json['walletId'] as String?,
      categoryId: json['categoryId'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      title: json['title'] as String?,
      note: json['note'] as String?,
      frequency: json['frequency'] as String?,
      interval: (json['interval'] as num?)?.toInt(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$UpdateRecurringDtoToJson(_UpdateRecurringDto instance) =>
    <String, dynamic>{
      'walletId': instance.walletId,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'title': instance.title,
      'note': instance.note,
      'frequency': instance.frequency,
      'interval': instance.interval,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };

_RecurringPreviewItem _$RecurringPreviewItemFromJson(
  Map<String, dynamic> json,
) => _RecurringPreviewItem(
  scheduledFor: DateTime.parse(json['scheduledFor'] as String),
  date: json['date'] as String,
);

Map<String, dynamic> _$RecurringPreviewItemToJson(
  _RecurringPreviewItem instance,
) => <String, dynamic>{
  'scheduledFor': instance.scheduledFor.toIso8601String(),
  'date': instance.date,
};

_RecurringPreviewResponse _$RecurringPreviewResponseFromJson(
  Map<String, dynamic> json,
) => _RecurringPreviewResponse(
  ruleId: json['ruleId'] as String,
  isActive: json['isActive'] as bool? ?? true,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RecurringPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecurringPreviewItem>[],
);

Map<String, dynamic> _$RecurringPreviewResponseToJson(
  _RecurringPreviewResponse instance,
) => <String, dynamic>{
  'ruleId': instance.ruleId,
  'isActive': instance.isActive,
  'items': instance.items,
};
