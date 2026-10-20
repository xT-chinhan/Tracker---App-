import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_template_models.freezed.dart';
part 'quick_template_models.g.dart';

@freezed
abstract class CreateQuickTemplateDto with _$CreateQuickTemplateDto {
  const factory CreateQuickTemplateDto({
    required String label,
    required String title,
    required int amount,
    required String categoryId,
    required String walletId,
    String? note,
  }) = _CreateQuickTemplateDto;

  factory CreateQuickTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$CreateQuickTemplateDtoFromJson(json);
}

@freezed
abstract class UseQuickTemplateDto with _$UseQuickTemplateDto {
  const factory UseQuickTemplateDto({String? occurredAt, int? amount}) =
      _UseQuickTemplateDto;

  factory UseQuickTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$UseQuickTemplateDtoFromJson(json);
}
