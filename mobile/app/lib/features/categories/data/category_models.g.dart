// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) =>
    _CategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      userId: json['userId'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CategoryItemToJson(_CategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'icon': instance.icon,
      'color': instance.color,
      'userId': instance.userId,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_CreateCategoryDto _$CreateCategoryDtoFromJson(Map<String, dynamic> json) =>
    _CreateCategoryDto(
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$CreateCategoryDtoToJson(_CreateCategoryDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'icon': instance.icon,
      'color': instance.color,
    };
