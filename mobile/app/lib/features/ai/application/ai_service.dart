import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction_repository.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';

class AiIntroDismissedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setDismissed(bool value) => state = value;
}

final aiIntroDismissedProvider =
    NotifierProvider<AiIntroDismissedNotifier, bool>(
      AiIntroDismissedNotifier.new,
    );

final aiConversationsProvider = FutureProvider.family<AiConversationPage, bool>(
  (ref, archived) async {
    final repo = ref.watch(aiRepositoryProvider);
    return repo.listConversations(archived: archived, limit: 50);
  },
);

final aiUsageProvider = FutureProvider<AiUsage>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getUsage();
});

final aiMemoryProvider = FutureProvider<List<AiMemoryItem>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getMemory();
});

final aiSkillsProvider = FutureProvider<List<AiSkillItem>>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getSkills();
});

class AiSettingsController extends AsyncNotifier<AiSettings> {
  @override
  FutureOr<AiSettings> build() {
    return ref.watch(aiRepositoryProvider).getSettings();
  }

  Future<void> updateShareExamples(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(aiRepositoryProvider);
      return repo.updateSettings(shareExamples: value);
    });
  }
}

final aiSettingsControllerProvider =
    AsyncNotifierProvider<AiSettingsController, AiSettings>(
      AiSettingsController.new,
    );

class AiChatState {
  const AiChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.currentRoute,
    this.streamingDelta = '',
    this.error,
    this.isQuotaReached = false,
    this.isMaintenance = false,
    this.lastSavedTransactionIds = const [],
    this.lastSavedDraftInfo,
  });

  final AiConversationDetail? conversation;
  final List<AiMessageItem> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? currentRoute;
  final String streamingDelta;
  final String? error;
  final bool isQuotaReached;
  final bool isMaintenance;
  final List<String> lastSavedTransactionIds;
  final String? lastSavedDraftInfo;

  AiChatState copyWith({
    AiConversationDetail? conversation,
    List<AiMessageItem>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? currentRoute,
    String? streamingDelta,
    String? error,
    bool? isQuotaReached,
    bool? isMaintenance,
    List<String>? lastSavedTransactionIds,
    String? lastSavedDraftInfo,
  }) {
    return AiChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      currentRoute: currentRoute ?? this.currentRoute,
      streamingDelta: streamingDelta ?? this.streamingDelta,
      error: error,
      isQuotaReached: isQuotaReached ?? this.isQuotaReached,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      lastSavedTransactionIds:
          lastSavedTransactionIds ?? this.lastSavedTransactionIds,
      lastSavedDraftInfo: lastSavedDraftInfo ?? this.lastSavedDraftInfo,
    );
  }
}

class AiChatController extends Notifier<AiChatState> {
  final String? conversationId;
  AiChatController(this.conversationId);

  CancelToken? _cancelToken;

  AiRepository get _repo => ref.read(aiRepositoryProvider);

  @override
  AiChatState build() {
    if (conversationId != null && conversationId!.isNotEmpty) {
      Future.microtask(() => loadConversation());
    }
    return const AiChatState();
  }

  Future<void> loadConversation() async {
    final convId = conversationId;
    if (convId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await _repo.getConversation(convId);
      state = state.copyWith(
        conversation: detail,
        messages: detail.messages,
        isLoading: false,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    String targetConvId = conversationId ?? state.conversation?.id ?? '';
    if (targetConvId.isEmpty) {
      // Create new conversation
      try {
        final newConv = await _repo.createConversation(
          title: trimmed.length > 50 ? trimmed.substring(0, 50) : trimmed,
        );
        targetConvId = newConv.id;
        state = state.copyWith(
          conversation: AiConversationDetail(
            id: newConv.id,
            title: newConv.title,
            archived: newConv.archived,
            pinned: newConv.pinned,
            scope: newConv.scope,
            createdAt: newConv.createdAt,
            updatedAt: newConv.updatedAt,
          ),
        );
        ref.invalidate(aiConversationsProvider(false));
      } on DioException catch (e) {
        _handleDioError(e);
        return null;
      }
    }

    // Temporary optimistic user message
    final tempUserMsg = AiMessageItem(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: targetConvId,
      role: 'USER',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempUserMsg],
      isStreaming: true,
      streamingDelta: '',
      currentRoute: null,
      error: null,
    );

    _cancelToken = CancelToken();

    try {
      final eventStream = _repo.streamMessage(
        targetConvId,
        trimmed,
        cancelToken: _cancelToken,
      );

      final buffer = StringBuffer();
      AiMessageItem? finalAssistantMsg;
      AiDraftItem? finalDraft;

      await for (final event in eventStream) {
        if (event is AiStreamUserEvent) {
          final msgs = List<AiMessageItem>.from(state.messages);
          final idx = msgs.indexWhere((m) => m.id == tempUserMsg.id);
          if (idx != -1) {
            msgs[idx] = event.userMessage;
          } else {
            msgs.add(event.userMessage);
          }
          state = state.copyWith(messages: msgs);
        } else if (event is AiStreamRouteEvent) {
          state = state.copyWith(currentRoute: event.skill);
        } else if (event is AiStreamDeltaEvent) {
          buffer.write(event.text);
          state = state.copyWith(streamingDelta: buffer.toString());
        } else if (event is AiStreamDoneEvent) {
          finalAssistantMsg = event.message;
          finalDraft = event.draft;
        } else if (event is AiStreamErrorEvent) {
          state = state.copyWith(error: event.message);
        }
      }

      if (finalAssistantMsg != null) {
        final updatedMsg = finalAssistantMsg.copyWith(
          draft: finalDraft ?? finalAssistantMsg.draft,
        );
        state = state.copyWith(
          messages: [...state.messages, updatedMsg],
          isStreaming: false,
          streamingDelta: '',
          currentRoute: null,
        );
      } else if (buffer.isNotEmpty) {
        final fallbackMsg = AiMessageItem(
          id: 'gen-${DateTime.now().millisecondsSinceEpoch}',
          conversationId: targetConvId,
          role: 'ASSISTANT',
          content: buffer.toString(),
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, fallbackMsg],
          isStreaming: false,
          streamingDelta: '',
        );
      } else {
        state = state.copyWith(isStreaming: false);
      }

      ref.invalidate(aiUsageProvider);
      ref.invalidate(aiConversationsProvider(false));
      return targetConvId;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        state = state.copyWith(isStreaming: false, streamingDelta: '');
        await loadConversation();
      } else {
        _handleDioError(e);
        state = state.copyWith(isStreaming: false, streamingDelta: '');
      }
      return targetConvId;
    } catch (e) {
      state = state.copyWith(
        isStreaming: false,
        streamingDelta: '',
        error: e.toString(),
      );
      return targetConvId;
    } finally {
      _cancelToken = null;
    }
  }

  void stopStreaming() {
    _cancelToken?.cancel('User cancelled stream');
  }

  Future<bool> confirmDraft(
    String draftId, {
    Map<String, dynamic>? payload,
  }) async {
    try {
      final res = await _repo.confirmDraft(draftId, payload: payload);
      final msgs = state.messages.map((m) {
        if (m.draft?.id == draftId) {
          final updatedDraft =
              res.draft ??
              m.draft?.copyWith(
                status: payload != null ? 'EDITED' : 'CONFIRMED',
                finalPayload: payload ?? m.draft?.payload,
                result: res.result,
              );
          return m.copyWith(draft: updatedDraft);
        }
        return m;
      }).toList();

      List<String> createdTxIds = [];
      if (res.result != null && res.result is List) {
        for (final item in (res.result as List)) {
          if (item is Map && item['id'] != null) {
            createdTxIds.add(item['id'].toString());
          }
        }
      }

      state = state.copyWith(
        messages: msgs,
        lastSavedTransactionIds: createdTxIds,
        lastSavedDraftInfo: createdTxIds.isNotEmpty
            ? 'Đã lưu ${createdTxIds.length} khoản chi'
            : null,
      );
      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelDraft(String draftId) async {
    try {
      await _repo.cancelDraft(draftId);
      final msgs = state.messages.map((m) {
        if (m.draft?.id == draftId) {
          return m.copyWith(draft: m.draft?.copyWith(status: 'CANCELLED'));
        }
        return m;
      }).toList();
      state = state.copyWith(messages: msgs);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> undoTransactions() async {
    final ids = List<String>.from(state.lastSavedTransactionIds);
    if (ids.isEmpty) return;

    final txRepo = ref.read(transactionRepositoryProvider);
    state = state.copyWith(lastSavedTransactionIds: []);

    for (final id in ids) {
      try {
        await txRepo.deleteTransaction(id);
      } catch (_) {}
    }
  }

  void clearLastSaved() {
    state = state.copyWith(
      lastSavedTransactionIds: const [],
      lastSavedDraftInfo: null,
    );
  }

  Future<void> sendFeedback(
    String messageId, {
    required int rating,
    String? comment,
  }) async {
    try {
      await _repo.feedback(messageId, rating: rating, comment: comment);
    } catch (_) {}
  }

  Future<void> rerouteMessage(String messageId, String skill) async {
    try {
      state = state.copyWith(isLoading: true);
      final res = await _repo.reroute(messageId, skill: skill);
      state = state.copyWith(
        messages: [...state.messages, res.message],
        isLoading: false,
      );
      ref.invalidate(aiUsageProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 429) {
      state = state.copyWith(isQuotaReached: true);
    } else if (e.response?.statusCode == 503) {
      state = state.copyWith(isMaintenance: true);
    } else if (e.response?.statusCode == 403) {
      final code = (e.response?.data is Map)
          ? (e.response!.data as Map)['code']
          : null;
      if (code == 'FEATURE_DISABLED') {
        state = state.copyWith(isMaintenance: false);
      }
    }
  }
}

final aiChatControllerProvider = NotifierProvider.autoDispose
    .family<AiChatController, AiChatState, String?>(
      (arg) => AiChatController(arg),
    );
