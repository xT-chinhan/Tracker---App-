import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/app_session.dart';
import '../application/ai_service.dart';
import '../data/ai_models.dart';
import 'conversation_action_sheet.dart';
import 'reroute_menu_card.dart';
import 'transaction_draft_card.dart';
import 'undo_toast.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({this.conversationId, this.initialPrompt, super.key});

  final String? conversationId;
  final String? initialPrompt;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _downvotedMessageId;
  bool _initialPromptSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPrompt != null &&
          widget.initialPrompt!.isNotEmpty &&
          !_initialPromptSent) {
        _initialPromptSent = true;
        _sendMessage(widget.initialPrompt!);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? prompt]) async {
    final text = prompt ?? _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    final notifier = ref.read(
      aiChatControllerProvider(widget.conversationId).notifier,
    );
    _scrollToBottom();
    final convId = await notifier.sendMessage(text);
    _scrollToBottom();

    // If it was a new conversation, update route or history
    if (widget.conversationId == null && convId != null && mounted) {
      // Invalidate list so conversation shows
      ref.invalidate(aiConversationsProvider(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(appSessionProvider).user;
    final chatState = ref.watch(
      aiChatControllerProvider(widget.conversationId),
    );
    final chatNotifier = ref.read(
      aiChatControllerProvider(widget.conversationId).notifier,
    );
    final skillsAsync = ref.watch(aiSkillsProvider);
    final usageAsync = ref.watch(aiUsageProvider);

    final conv = chatState.conversation;
    final title = conv?.title ?? 'Cuộc trò chuyện mới';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(LucideIcons.chevron_left, size: 22)],
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.lock, size: 11, color: Color(0xFF787774)),
                SizedBox(width: 4),
                Text(
                  'Chỉ dữ liệu của bạn',
                  style: TextStyle(fontSize: 11, color: Color(0xFF787774)),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (conv != null)
            IconButton(
              icon: const Icon(LucideIcons.ellipsis, size: 20),
              onPressed: () {
                ConversationActionSheet.show(
                  context,
                  conversation: AiConversationItem(
                    id: conv.id,
                    title: conv.title,
                    archived: conv.archived,
                    pinned: conv.pinned,
                    scope: conv.scope,
                    createdAt: conv.createdAt,
                    updatedAt: conv.updatedAt,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Maintenance banner if any (matching 30-ai-12a)
            if (chatState.isMaintenance) _buildMaintenanceBanner(),

            // Chat body: Empty state OR Messages List
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isLoading
                  ? _buildNewChatHero(context, user?.name ?? 'bạn')
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      children: [
                        for (final msg in chatState.messages) ...[
                          if (msg.role == 'USER')
                            _buildUserBubble(msg)
                          else
                            _buildAssistantBubble(
                              context,
                              msg,
                              chatNotifier,
                              skillsAsync.value ?? [],
                            ),
                          const SizedBox(height: 12),
                        ],

                        // Shimmering reading skeleton or streaming text
                        if (chatState.isStreaming) ...[
                          if (chatState.streamingDelta.isNotEmpty)
                            _buildStreamingBubble(chatState.streamingDelta)
                          else
                            _buildReadingSkeleton(chatState.currentRoute),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),

            // Floating Undo Toast (matching 30-ai-06)
            if (chatState.lastSavedTransactionIds.isNotEmpty)
              UndoToast(
                title: chatState.lastSavedDraftInfo ?? 'Đã lưu giao dịch',
                subtitle: 'Chạm để hoàn tác giao dịch vừa lưu',
                onUndo: () => chatNotifier.undoTransactions(),
                onDismiss: () => chatNotifier.clearLastSaved(),
              ),

            // Bottom Input bar OR Quota limit card (matching 30-ai-11)
            if (chatState.isQuotaReached)
              _buildQuotaReachedCard(
                context,
                usageAsync.value?.dailyMessageLimit ?? 30,
              )
            else
              _buildInputBar(context, chatState, chatNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.construction, size: 20, color: Color(0xFFD97706)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý đang bảo trì',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hệ thống đang được nâng cấp. Bạn vẫn có thể đọc lại cuộc trò chuyện và xác nhận nháp cũ.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatHero(BuildContext context, String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sparkle circle 56x56
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF1E232A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.sparkles,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),

          // Greeting
          Text(
            'Chào $userName',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hỏi về ví, giao dịch, ngân sách, mục tiêu của bạn, hoặc ghi giao dịch bằng một câu. Không ai khác thấy cuộc trò chuyện này.',
            style: TextStyle(
              fontSize: 14.5,
              color: Color(0xFF787774),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Suggestions Card
          const Text(
            'Gợi ý từ dữ liệu của bạn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF787774),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              children: [
                _buildHeroSuggestionRow(
                  icon: LucideIcons.chart_no_axes_column,
                  text: 'Tháng này tôi chi bao nhiêu?',
                  onTap: () => _sendMessage('Tháng này tôi chi bao nhiêu?'),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF0EFEC)),
                _buildHeroSuggestionRow(
                  icon: LucideIcons.utensils,
                  text: 'Ăn uống còn bao nhiêu ngân sách?',
                  badgeText: '89%',
                  badgeColor: const Color(0xFFFFF3CD),
                  badgeTextColor: const Color(0xFFB45309),
                  onTap: () => _sendMessage('Ăn uống còn bao nhiêu ngân sách?'),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF0EFEC)),
                _buildHeroSuggestionRow(
                  icon: LucideIcons.shopping_bag,
                  text: 'Mua sắm vượt bao nhiêu rồi?',
                  badgeText: '115%',
                  badgeColor: const Color(0xFFFDE8E8),
                  badgeTextColor: const Color(0xFFDC2626),
                  onTap: () => _sendMessage('Mua sắm vượt bao nhiêu rồi?'),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF0EFEC)),
                _buildHeroSuggestionRow(
                  icon: LucideIcons.plane,
                  text: 'Bao giờ đủ tiền đi Đà Lạt?',
                  trailingText: '70%',
                  onTap: () => _sendMessage('Bao giờ đủ tiền đi Đà Lạt?'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick chips
          const Text(
            'Ghi nhanh',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF787774),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickChip('✏️ Ghi: cà phê 45k', 'cà phê 45k'),
              _buildQuickChip('✏️ Ghi: cơm trưa 55k', 'cơm trưa 55k'),
              _buildQuickChip('✏️ Ghi: Grab 38k', 'Grab 38k'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSuggestionRow({
    required IconData icon,
    required String text,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: const Color(0xFF111111)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFF1F0EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor ?? const Color(0xFF111111),
                  ),
                ),
              ),
            ],
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(fontSize: 13, color: Color(0xFF787774)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, String prompt) {
    return InkWell(
      onTap: () => _sendMessage(prompt),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111111),
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble(AiMessageItem msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F0EC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          msg.content,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF111111),
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(
    BuildContext context,
    AiMessageItem msg,
    AiChatController notifier,
    List<AiSkillItem> skills,
  ) {
    final hasDraft = msg.draft != null;
    final isDownvoted = _downvotedMessageId == msg.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If there's a draft
        if (hasDraft) ...[
          TransactionDraftCard(
            draft: msg.draft!,
            onConfirm: (payload) =>
                notifier.confirmDraft(msg.draft!.id, payload: payload),
            onCancel: () => notifier.cancelDraft(msg.draft!.id),
          ),
          const SizedBox(height: 8),
        ],

        // Assistant reply text
        if (msg.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              msg.content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF111111),
                height: 1.4,
              ),
            ),
          ),

        // Feedback row (thumbs up, thumbs down, latency)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Row(
            children: [
              InkWell(
                onTap: () => notifier.sendFeedback(msg.id, rating: 1),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.thumbs_up,
                    size: 16,
                    color: Color(0xFFA9A8A3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  notifier.sendFeedback(msg.id, rating: -1);
                  setState(() => _downvotedMessageId = msg.id);
                },
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.thumbs_down,
                    size: 16,
                    color: Color(0xFFA9A8A3),
                  ),
                ),
              ),
              const Spacer(),
              if (msg.latencyMs != null)
                Text(
                  '${(msg.latencyMs! / 1000).toStringAsFixed(1)} giây',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA9A8A3),
                  ),
                ),
            ],
          ),
        ),

        // Reroute menu if user tapped thumbs down on this message (matching 30-ai-08)
        if (isDownvoted)
          RerouteMenuCard(
            skills: skills,
            onSelectSkill: (skill) {
              setState(() => _downvotedMessageId = null);
              notifier.rerouteMessage(msg.id, skill);
            },
            onDismiss: () => setState(() => _downvotedMessageId = null),
          ),

        // Follow-up chips if any
        if (msg.followUps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: msg.followUps
                  .map(
                    (f) => InkWell(
                      onTap: () => _sendMessage(f),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReadingSkeleton(String? route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.sparkles,
              size: 16,
              color: Color(0xFF787774),
            ),
            const SizedBox(width: 8),
            Text(
              route != null
                  ? 'Đang đọc dữ liệu cho "$route"...'
                  : 'Đang đọc dữ liệu...',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF787774),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0EC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0EC),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0EC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreamingBubble(String delta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '$delta|',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF111111),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaReachedCard(BuildContext context, int limit) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F0EC),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.hourglass,
                  size: 18,
                  color: Color(0xFF787774),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hết $limit lượt hỏi hôm nay',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Lượt mới mở lúc 00:00. Nháp đang chờ vẫn xác nhận được.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF787774),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.push('/transactions/new'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111111),
              side: const BorderSide(color: Color(0xFFEAEAEA)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Ghi giao dịch thủ công',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    AiChatState chatState,
    AiChatController chatNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                onSubmitted: (v) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Hỏi hoặc ghi: “cà phê 45k”',
                  hintStyle: TextStyle(
                    color: Color(0xFFA9A8A3),
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (chatState.isStreaming)
            InkWell(
              onTap: () => chatNotifier.stopStreaming(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.square,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            )
          else
            InkWell(
              onTap: () => _sendMessage(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E7E3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.arrow_up,
                  size: 20,
                  color: Color(0xFF111111),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
