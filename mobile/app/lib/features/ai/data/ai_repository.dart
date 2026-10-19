import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'ai_models.dart';

sealed class AiStreamEvent {
  const AiStreamEvent();
}

class AiStreamUserEvent extends AiStreamEvent {
  const AiStreamUserEvent(this.userMessage);
  final AiMessageItem userMessage;
}

class AiStreamRouteEvent extends AiStreamEvent {
  const AiStreamRouteEvent({required this.skill, this.by});
  final String skill;
  final String? by;
}

class AiStreamDeltaEvent extends AiStreamEvent {
  const AiStreamDeltaEvent(this.text);
  final String text;
}

class AiStreamDoneEvent extends AiStreamEvent {
  const AiStreamDoneEvent({required this.message, this.draft});
  final AiMessageItem message;
  final AiDraftItem? draft;
}

class AiStreamErrorEvent extends AiStreamEvent {
  const AiStreamErrorEvent(this.message);
  final String message;
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  Future<AiConversationPage> listConversations({
    bool? archived,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'ai/conversations',
      queryParameters: {'archived': ?archived, 'page': page, 'limit': limit},
    );
    return AiConversationPage.fromJson(res.data!);
  }

  Future<CreateConversationResponse> createConversation({String? title}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'ai/conversations',
      data: {if (title != null && title.isNotEmpty) 'title': title},
    );
    return CreateConversationResponse.fromJson(res.data!);
  }

  Future<AiConversationDetail> getConversation(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('ai/conversations/$id');
    return AiConversationDetail.fromJson(res.data!);
  }

  Future<AiConversationItem> updateConversation(
    String id, {
    String? title,
    bool? archived,
    bool? pinned,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      'ai/conversations/$id',
      data: {'title': ?title, 'archived': ?archived, 'pinned': ?pinned},
    );
    return AiConversationItem.fromJson(res.data!);
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete<void>('ai/conversations/$id');
  }

  Future<PostMessageResponse> postMessage(
    String conversationId,
    String text,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'ai/conversations/$conversationId/messages',
      data: {'text': text},
    );
    return PostMessageResponse.fromJson(res.data!);
  }

  Stream<AiStreamEvent> streamMessage(
    String conversationId,
    String text, {
    CancelToken? cancelToken,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      'ai/conversations/$conversationId/messages/stream',
      data: {'text': text},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
      cancelToken: cancelToken,
    );

    final stream = response.data?.stream;
    if (stream == null) return;

    String currentEvent = 'message';
    final buffer = StringBuffer();

    await for (final line
        in stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        final dataStr = buffer.toString();
        buffer.clear();
        if (dataStr.isNotEmpty) {
          try {
            final json = jsonDecode(dataStr) as Map<String, dynamic>;
            switch (currentEvent) {
              case 'user':
                yield AiStreamUserEvent(AiMessageItem.fromJson(json));
                break;
              case 'route':
                yield AiStreamRouteEvent(
                  skill: json['skill'] as String? ?? '',
                  by: json['by'] as String?,
                );
                break;
              case 'delta':
                yield AiStreamDeltaEvent(json['text'] as String? ?? '');
                break;
              case 'done':
                yield AiStreamDoneEvent(
                  message: AiMessageItem.fromJson(
                    json['message'] as Map<String, dynamic>,
                  ),
                  draft: json['draft'] != null
                      ? AiDraftItem.fromJson(
                          json['draft'] as Map<String, dynamic>,
                        )
                      : null,
                );
                break;
              case 'error':
                yield AiStreamErrorEvent(
                  json['message'] as String? ?? 'Lỗi không xác định',
                );
                break;
            }
          } catch (_) {}
        }
        currentEvent = 'message';
        continue;
      }

      if (trimmed.startsWith('event:')) {
        currentEvent = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('data:')) {
        final chunk = trimmed.substring(5).trim();
        buffer.write(chunk);
      }
    }
  }

  Future<ConfirmDraftResponse> confirmDraft(
    String draftId, {
    Map<String, dynamic>? payload,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'ai/drafts/$draftId/confirm',
      data: {'payload': ?payload},
    );
    return ConfirmDraftResponse.fromJson(res.data!);
  }

  /// Gửi ảnh hóa đơn / chuyển khoản (multipart `image`). Trả JSON thô: message, draft, ocr.
  Future<Map<String, dynamic>> postImage(
    String conversationId,
    List<int> bytes,
    String filename,
  ) async {
    final lower = filename.toLowerCase();
    final subtype = lower.endsWith('.png')
        ? 'png'
        : lower.endsWith('.webp')
        ? 'webp'
        : 'jpeg';
    final form = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType('image', subtype),
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      'ai/conversations/$conversationId/images',
      data: form,
      options: Options(receiveTimeout: const Duration(seconds: 150)),
    );
    return res.data!;
  }

  Future<void> cancelDraft(String draftId) async {
    await _dio.post<void>('ai/drafts/$draftId/cancel');
  }

  Future<void> feedback(
    String messageId, {
    required int rating,
    String? comment,
  }) async {
    await _dio.post<void>(
      'ai/messages/$messageId/feedback',
      data: {'rating': rating, 'comment': ?comment},
    );
  }

  Future<PostMessageResponse> reroute(
    String messageId, {
    required String skill,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'ai/messages/$messageId/reroute',
      data: {'skill': skill},
    );
    return PostMessageResponse.fromJson(res.data!);
  }

  Future<List<AiSkillItem>> getSkills() async {
    final res = await _dio.get<List<dynamic>>('ai/skills');
    return res.data!
        .map((e) => AiSkillItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AiUsage> getUsage() async {
    final res = await _dio.get<Map<String, dynamic>>('ai/usage');
    return AiUsage.fromJson(res.data!);
  }

  Future<List<AiMemoryItem>> getMemory() async {
    final res = await _dio.get<List<dynamic>>('ai/memory');
    return res.data!
        .map((e) => AiMemoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMemory(String id) async {
    await _dio.delete<void>('ai/memory/$id');
  }

  Future<AiSettings> getSettings() async {
    final res = await _dio.get<Map<String, dynamic>>('ai/settings');
    return AiSettings.fromJson(res.data!);
  }

  Future<AiSettings> updateSettings({required bool shareExamples}) async {
    final res = await _dio.put<Map<String, dynamic>>(
      'ai/settings',
      data: {'shareExamples': shareExamples},
    );
    return AiSettings.fromJson(res.data!);
  }
}
