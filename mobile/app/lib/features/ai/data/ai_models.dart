import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_models.freezed.dart';
part 'ai_models.g.dart';

int _toInt(dynamic v) => (v as num?)?.round() ?? 0;
double? _toNullableDouble(dynamic v) => (v as num?)?.toDouble();

@freezed
abstract class AiConversationItem with _$AiConversationItem {
  const factory AiConversationItem({
    required String id,
    String? title,
    @Default(false) bool archived,
    @Default(false) bool pinned,
    String? scope,
    @JsonKey(fromJson: _toInt) @Default(0) int messageCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AiConversationItem;

  factory AiConversationItem.fromJson(Map<String, dynamic> json) =>
      _$AiConversationItemFromJson(json);
}

@freezed
abstract class AiConversationPage with _$AiConversationPage {
  const factory AiConversationPage({
    @Default(<AiConversationItem>[]) List<AiConversationItem> items,
    @JsonKey(fromJson: _toInt) @Default(0) int total,
    @JsonKey(fromJson: _toInt) @Default(1) int page,
    @JsonKey(fromJson: _toInt) @Default(20) int limit,
  }) = _AiConversationPage;

  factory AiConversationPage.fromJson(Map<String, dynamic> json) =>
      _$AiConversationPageFromJson(json);
}

@freezed
abstract class AiDraftItem with _$AiDraftItem {
  const factory AiDraftItem({
    required String id,
    required String messageId,
    required String skill,
    required String kind,
    @Default('PROPOSED') String status,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? finalPayload,
    dynamic result,
    DateTime? resolvedAt,
    required DateTime createdAt,
  }) = _AiDraftItem;

  factory AiDraftItem.fromJson(Map<String, dynamic> json) =>
      _$AiDraftItemFromJson(json);
}

@freezed
abstract class AiMessageTokens with _$AiMessageTokens {
  const factory AiMessageTokens({
    @JsonKey(fromJson: _toInt) @Default(0) int prompt,
    @JsonKey(fromJson: _toInt) @Default(0) int eval,
  }) = _AiMessageTokens;

  factory AiMessageTokens.fromJson(Map<String, dynamic> json) =>
      _$AiMessageTokensFromJson(json);
}

@freezed
abstract class AiMessageItem with _$AiMessageItem {
  const factory AiMessageItem({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    String? skill,
    String? routeBy,
    String? status,
    int? latencyMs,
    AiMessageTokens? tokens,
    @Default(<String>[]) List<String> followUps,
    required DateTime createdAt,
    AiDraftItem? draft,
  }) = _AiMessageItem;

  factory AiMessageItem.fromJson(Map<String, dynamic> json) =>
      _$AiMessageItemFromJson(json);
}

@freezed
abstract class AiConversationDetail with _$AiConversationDetail {
  const factory AiConversationDetail({
    required String id,
    String? title,
    @Default(false) bool archived,
    @Default(false) bool pinned,
    String? scope,
    @Default(<AiMessageItem>[]) List<AiMessageItem> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AiConversationDetail;

  factory AiConversationDetail.fromJson(Map<String, dynamic> json) =>
      _$AiConversationDetailFromJson(json);
}

@freezed
abstract class CreateConversationResponse with _$CreateConversationResponse {
  const factory CreateConversationResponse({
    required String id,
    String? title,
    @Default(false) bool archived,
    @Default(false) bool pinned,
    String? scope,
    Map<String, dynamic>? autoArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CreateConversationResponse;

  factory CreateConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationResponseFromJson(json);
}

@freezed
abstract class PostMessageResponse with _$PostMessageResponse {
  const factory PostMessageResponse({
    required AiMessageItem userMessage,
    required AiMessageItem message,
    AiDraftItem? draft,
  }) = _PostMessageResponse;

  factory PostMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$PostMessageResponseFromJson(json);
}

@freezed
abstract class ConfirmDraftResponse with _$ConfirmDraftResponse {
  const factory ConfirmDraftResponse({
    AiDraftItem? draft,
    dynamic result,
    @Default(false) bool idempotent,
  }) = _ConfirmDraftResponse;

  factory ConfirmDraftResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfirmDraftResponseFromJson(json);
}

@freezed
abstract class AiUsage with _$AiUsage {
  const factory AiUsage({
    @JsonKey(fromJson: _toInt) @Default(0) int messagesToday,
    @JsonKey(fromJson: _toInt) @Default(30) int dailyMessageLimit,
    @JsonKey(fromJson: _toInt) @Default(0) int activeConversations,
    @JsonKey(fromJson: _toInt) @Default(50) int maxConversations,
    DateTime? resetAt,
  }) = _AiUsage;

  factory AiUsage.fromJson(Map<String, dynamic> json) =>
      _$AiUsageFromJson(json);
}

@freezed
abstract class AiSettings with _$AiSettings {
  const factory AiSettings({
    @Default(false) bool shareExamples,
    DateTime? consentedAt,
    @Default(false) bool asked,
  }) = _AiSettings;

  factory AiSettings.fromJson(Map<String, dynamic> json) =>
      _$AiSettingsFromJson(json);
}

@freezed
abstract class AiMemoryItem with _$AiMemoryItem {
  const factory AiMemoryItem({
    required String id,
    required String key,
    required String value,
    @JsonKey(fromJson: _toNullableDouble) double? confidence,
    String? source,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AiMemoryItem;

  factory AiMemoryItem.fromJson(Map<String, dynamic> json) =>
      _$AiMemoryItemFromJson(json);
}

@freezed
abstract class AiSkillItem with _$AiSkillItem {
  const factory AiSkillItem({
    required String name,
    String? label,
    String? description,
    String? scope,
  }) = _AiSkillItem;

  factory AiSkillItem.fromJson(Map<String, dynamic> json) =>
      _$AiSkillItemFromJson(json);
}
