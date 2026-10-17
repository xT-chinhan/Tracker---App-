import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_models.freezed.dart';
part 'category_models.g.dart';

@freezed
abstract class CategoryItem with _$CategoryItem {
  const factory CategoryItem({
    required String id,
    required String name,
    required String type,
    String? icon,
    String? color,
    String? userId,
    @Default(false) bool isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CategoryItem;

  factory CategoryItem.fromJson(Map<String, dynamic> json) =>
      _$CategoryItemFromJson(json);
}

@freezed
abstract class CreateCategoryDto with _$CreateCategoryDto {
  const factory CreateCategoryDto({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) = _CreateCategoryDto;

  factory CreateCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoryDtoFromJson(json);
}
