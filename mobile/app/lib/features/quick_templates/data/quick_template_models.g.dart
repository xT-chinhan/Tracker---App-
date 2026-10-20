// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_template_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateQuickTemplateDto _$CreateQuickTemplateDtoFromJson(
  Map<String, dynamic> json,
) => _CreateQuickTemplateDto(
  label: json['label'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toInt(),
  categoryId: json['categoryId'] as String,
  walletId: json['walletId'] as String,
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateQuickTemplateDtoToJson(
  _CreateQuickTemplateDto instance,
) => <String, dynamic>{
  'label': instance.label,
  'title': instance.title,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'walletId': instance.walletId,
  'note': instance.note,
};

_UseQuickTemplateDto _$UseQuickTemplateDtoFromJson(Map<String, dynamic> json) =>
    _UseQuickTemplateDto(
      occurredAt: json['occurredAt'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UseQuickTemplateDtoToJson(
  _UseQuickTemplateDto instance,
) => <String, dynamic>{
  'occurredAt': instance.occurredAt,
  'amount': instance.amount,
};
