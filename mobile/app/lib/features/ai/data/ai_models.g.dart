// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiConversationItem _$AiConversationItemFromJson(Map<String, dynamic> json) =>
    _AiConversationItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      archived: json['archived'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      scope: json['scope'] as String?,
      messageCount: json['messageCount'] == null
          ? 0
          : _toInt(json['messageCount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AiConversationItemToJson(_AiConversationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'archived': instance.archived,
      'pinned': instance.pinned,
      'scope': instance.scope,
      'messageCount': instance.messageCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_AiConversationPage _$AiConversationPageFromJson(Map<String, dynamic> json) =>
    _AiConversationPage(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => AiConversationItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <AiConversationItem>[],
      total: json['total'] == null ? 0 : _toInt(json['total']),
      page: json['page'] == null ? 1 : _toInt(json['page']),
      limit: json['limit'] == null ? 20 : _toInt(json['limit']),
    );

Map<String, dynamic> _$AiConversationPageToJson(_AiConversationPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };

_AiDraftItem _$AiDraftItemFromJson(Map<String, dynamic> json) => _AiDraftItem(
  id: json['id'] as String,
  messageId: json['messageId'] as String,
  skill: json['skill'] as String,
  kind: json['kind'] as String,
  status: json['status'] as String? ?? 'PROPOSED',
  payload: json['payload'] as Map<String, dynamic>?,
  finalPayload: json['finalPayload'] as Map<String, dynamic>?,
  result: json['result'],
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AiDraftItemToJson(_AiDraftItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'skill': instance.skill,
      'kind': instance.kind,
      'status': instance.status,
      'payload': instance.payload,
      'finalPayload': instance.finalPayload,
      'result': instance.result,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_AiMessageTokens _$AiMessageTokensFromJson(Map<String, dynamic> json) =>
    _AiMessageTokens(
      prompt: json['prompt'] == null ? 0 : _toInt(json['prompt']),
      eval: json['eval'] == null ? 0 : _toInt(json['eval']),
    );

Map<String, dynamic> _$AiMessageTokensToJson(_AiMessageTokens instance) =>
    <String, dynamic>{'prompt': instance.prompt, 'eval': instance.eval};

_AiMessageItem _$AiMessageItemFromJson(Map<String, dynamic> json) =>
    _AiMessageItem(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      skill: json['skill'] as String?,
      routeBy: json['routeBy'] as String?,
      status: json['status'] as String?,
      latencyMs: (json['latencyMs'] as num?)?.toInt(),
      tokens: json['tokens'] == null
          ? null
          : AiMessageTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      followUps:
          (json['followUps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
      draft: json['draft'] == null
          ? null
          : AiDraftItem.fromJson(json['draft'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AiMessageItemToJson(_AiMessageItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': instance.role,
      'content': instance.content,
      'skill': instance.skill,
      'routeBy': instance.routeBy,
      'status': instance.status,
      'latencyMs': instance.latencyMs,
      'tokens': instance.tokens,
      'followUps': instance.followUps,
      'createdAt': instance.createdAt.toIso8601String(),
      'draft': instance.draft,
    };

_AiConversationDetail _$AiConversationDetailFromJson(
  Map<String, dynamic> json,
) => _AiConversationDetail(
  id: json['id'] as String,
  title: json['title'] as String?,
  archived: json['archived'] as bool? ?? false,
  pinned: json['pinned'] as bool? ?? false,
  scope: json['scope'] as String?,
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => AiMessageItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AiMessageItem>[],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AiConversationDetailToJson(
  _AiConversationDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'archived': instance.archived,
  'pinned': instance.pinned,
  'scope': instance.scope,
  'messages': instance.messages,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_CreateConversationResponse _$CreateConversationResponseFromJson(
  Map<String, dynamic> json,
) => _CreateConversationResponse(
  id: json['id'] as String,
  title: json['title'] as String?,
  archived: json['archived'] as bool? ?? false,
  pinned: json['pinned'] as bool? ?? false,
  scope: json['scope'] as String?,
  autoArchived: json['autoArchived'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CreateConversationResponseToJson(
  _CreateConversationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'archived': instance.archived,
  'pinned': instance.pinned,
  'scope': instance.scope,
  'autoArchived': instance.autoArchived,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_PostMessageResponse _$PostMessageResponseFromJson(Map<String, dynamic> json) =>
    _PostMessageResponse(
      userMessage: AiMessageItem.fromJson(
        json['userMessage'] as Map<String, dynamic>,
      ),
      message: AiMessageItem.fromJson(json['message'] as Map<String, dynamic>),
      draft: json['draft'] == null
          ? null
          : AiDraftItem.fromJson(json['draft'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostMessageResponseToJson(
  _PostMessageResponse instance,
) => <String, dynamic>{
  'userMessage': instance.userMessage,
  'message': instance.message,
  'draft': instance.draft,
};

_ConfirmDraftResponse _$ConfirmDraftResponseFromJson(
  Map<String, dynamic> json,
) => _ConfirmDraftResponse(
  draft: json['draft'] == null
      ? null
      : AiDraftItem.fromJson(json['draft'] as Map<String, dynamic>),
  result: json['result'],
  idempotent: json['idempotent'] as bool? ?? false,
);

Map<String, dynamic> _$ConfirmDraftResponseToJson(
  _ConfirmDraftResponse instance,
) => <String, dynamic>{
  'draft': instance.draft,
  'result': instance.result,
  'idempotent': instance.idempotent,
};

_AiUsage _$AiUsageFromJson(Map<String, dynamic> json) => _AiUsage(
  messagesToday: json['messagesToday'] == null
      ? 0
      : _toInt(json['messagesToday']),
  dailyMessageLimit: json['dailyMessageLimit'] == null
      ? 30
      : _toInt(json['dailyMessageLimit']),
  activeConversations: json['activeConversations'] == null
      ? 0
      : _toInt(json['activeConversations']),
  maxConversations: json['maxConversations'] == null
      ? 50
      : _toInt(json['maxConversations']),
  ocrToday: json['ocrToday'] == null ? 0 : _toInt(json['ocrToday']),
  ocrDailyLimit: json['ocrDailyLimit'] == null
      ? 20
      : _toInt(json['ocrDailyLimit']),
  resetAt: json['resetAt'] == null
      ? null
      : DateTime.parse(json['resetAt'] as String),
);

Map<String, dynamic> _$AiUsageToJson(_AiUsage instance) => <String, dynamic>{
  'messagesToday': instance.messagesToday,
  'dailyMessageLimit': instance.dailyMessageLimit,
  'activeConversations': instance.activeConversations,
  'maxConversations': instance.maxConversations,
  'ocrToday': instance.ocrToday,
  'ocrDailyLimit': instance.ocrDailyLimit,
  'resetAt': instance.resetAt?.toIso8601String(),
};

_AiSettings _$AiSettingsFromJson(Map<String, dynamic> json) => _AiSettings(
  shareExamples: json['shareExamples'] as bool? ?? false,
  consentedAt: json['consentedAt'] == null
      ? null
      : DateTime.parse(json['consentedAt'] as String),
  asked: json['asked'] as bool? ?? false,
);

Map<String, dynamic> _$AiSettingsToJson(_AiSettings instance) =>
    <String, dynamic>{
      'shareExamples': instance.shareExamples,
      'consentedAt': instance.consentedAt?.toIso8601String(),
      'asked': instance.asked,
    };

_AiMemoryItem _$AiMemoryItemFromJson(Map<String, dynamic> json) =>
    _AiMemoryItem(
      id: json['id'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      confidence: _toNullableDouble(json['confidence']),
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AiMemoryItemToJson(_AiMemoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'confidence': instance.confidence,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_AiSkillItem _$AiSkillItemFromJson(Map<String, dynamic> json) => _AiSkillItem(
  name: json['name'] as String,
  label: json['label'] as String?,
  description: json['description'] as String?,
  scope: json['scope'] as String?,
);

Map<String, dynamic> _$AiSkillItemToJson(_AiSkillItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'label': instance.label,
      'description': instance.description,
      'scope': instance.scope,
    };
